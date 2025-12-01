# Event QR Flow Explanation

## Overview
This document explains the complete flow of the Event QR feature, from creation to registration and viewing.

---

## Flow 1: Creating an Event QR Code

### Step-by-Step Process

```
User (Admin) → QR Type Selection → Event QR Creation → Design Customization → Save & Generate QR
```

### Detailed Steps:

1. **User selects "Event QR" type**
   - User navigates to QR code creation page
   - Selects "Event QR" from available types
   - Route: `/qr-codes/type/event`

2. **Step One: Fill Event Details** (`event-step-one.component.ts`)
   - User enters:
     - **Event Title** (required) - e.g., "Tech Conference 2025"
     - **Event Description** (optional) - e.g., "Annual technology conference"
     - **Event Date & Time** (required) - e.g., "2025-12-15 10:00 AM"
     - **Event Location** (optional) - e.g., "Convention Center, Yangon"
     - **Event Logo** (optional) - Upload image
     - **Max Registrations** (optional) - e.g., 100
   - Data is stored in `QRTypeFieldValue` table with field names:
     - `eventTitle`, `eventDescription`, `eventDateTime`, `eventLocation`, `eventLogo`, `maxRegistrations`
   - User clicks "Next" → Navigates to Step Two

3. **Step Two: Customize QR Design** (`event-step-two.component.ts`)
   - User customizes:
     - QR code colors (dot color, background)
     - Pattern style
     - Frame style, color, text
   - QR code image is generated with design
   - User clicks "Save" → QR code is created

4. **Backend Processing** (When "Save" is clicked)
   ```
   Frontend → POST /SmartQRApi/SaveQR
   {
     QRCode: { Name, QRTypeID: 5, ... },
     QRCodeData: { DataJson: {...} },
     QRCodeDesign: { DotColor, BackgroundColor, ... },
     FieldValues: [
       { FieldName: "eventTitle", FieldValue: "Tech Conference 2025" },
       { FieldName: "eventDescription", FieldValue: "Annual..." },
       { FieldName: "eventDateTime", FieldValue: "2025-12-15T10:00:00" },
       ...
     ]
   }
   ```
   - Backend saves to:
     - `QRCode` table (main QR record)
     - `QRCodeData` table (JSON data)
     - `QRCodeDesign` table (design settings)
     - `QRTypeFieldValue` table (event details as field values)
   - Returns QR code ID and image URL

5. **QR Code Generated**
   - QR code image is displayed
   - User can download or share the QR code
   - QR code URL: `https://yourdomain.com/event/{qrCodeID}`

---

## Flow 2: User Scans Event QR Code

### Step-by-Step Process

```
User Scans QR → Opens URL → Load Event Data → Check Registration Status → Show Content
```

### Detailed Steps:

1. **User Scans QR Code**
   - QR code contains URL: `https://yourdomain.com/event/{qrCodeID}`
   - Mobile browser opens the URL
   - Route: `/event/:id` → `EventViewerComponent`

2. **Event Viewer Component Loads** (`event-viewer.component.ts`)

   ```typescript
   ngOnInit() {
     // Get QR code ID from URL
     this.qrCodeId = route.params['id'];
     
     // Load event data
     this.loadEventData();
   }
   ```

3. **Load Event Data** (Public API - No Authentication)
   ```
   Frontend → GET /SmartQRApi/GetQRPublic/{qrCodeID}
   ```
   - Backend returns:
     - QR code details
     - Field values (eventTitle, eventDescription, etc.)
     - QR design settings
   - Frontend parses field values into event data object:
     ```typescript
     eventData = {
       title: "Tech Conference 2025",
       description: "Annual technology conference",
       dateTime: "2025-12-15T10:00:00",
       location: "Convention Center, Yangon",
       logo: "https://...",
       maxRegistrations: 100
     }
     ```

4. **Check Registration Status**
   ```typescript
   // Check if user is already registered
   const userEmail = localStorage.getItem('event_user_email');
   if (userEmail) {
     await this.checkRegistrationStatus(userEmail);
   }
   ```
   - Frontend calls: `POST /SmartQRApi/CheckEventRegistration`
   - Request:
     ```json
     {
       "QRCodeID": "abc-123",
       "Email": "user@example.com"
     }
     ```
   - Backend checks `QREventRegistration` table:
     ```sql
     SELECT * FROM QREventRegistration 
     WHERE QRCodeID = 'abc-123' 
     AND Email = 'user@example.com' 
     AND Active = 1
     ```
   - Response:
     ```json
     {
       "IsRegistered": true/false,
       "Registration": { ... } // if registered
     }
     ```

5. **Display Content Based on Status**
   - **If NOT registered**: Show event details + registration form
   - **If registered**: Show event details + "Registration Completed" message

---

## Flow 3: User Registers for Event (First Time)

### Step-by-Step Process

```
User Fills Form → Submit Registration → Backend Validation → Save Registration → Show Success
```

### Detailed Steps:

1. **User Fills Registration Form**
   - Form fields:
     - **Email** (required) - e.g., "john@example.com"
     - **Full Name** (required) - e.g., "John Doe"
     - **Phone Number** (optional) - e.g., "+959123456789"
     - **Additional Fields** (if any custom fields defined)
   - User clicks "Register" button

2. **Frontend Validation**
   ```typescript
   if (!email || !fullName) {
     alert('Please fill in required fields');
     return;
   }
   ```

3. **Submit Registration** (Public API - No Authentication)
   ```
   Frontend → POST /SmartQRApi/RegisterForEvent
   {
     "QRCodeID": "abc-123",
     "Email": "john@example.com",
     "FullName": "John Doe",
     "PhoneNumber": "+959123456789",
     "AdditionalFields": {},
     "IPAddress": "192.168.1.1",
     "UserAgent": "Mozilla/5.0..."
   }
   ```

4. **Backend Processing** (`RegisterForEvent` method)

   **Step 4.1: Validate QR Code**
   ```csharp
   var qrCode = _DBContext.QRCode
     .FirstOrDefault(c => c.QRCodeID == request.QRCodeID && c.Active == true);
   if (qrCode == null) return "Event QR Code not found";
   if (qrCode.ExpiresOn < DateTime.Now) return "Event expired";
   ```

   **Step 4.2: Check Duplicate Registration**
   ```csharp
   var existing = _DBContext.QREventRegistration
     .FirstOrDefault(r => r.QRCodeID == request.QRCodeID && 
                         r.Email == request.Email && 
                         r.Active == true);
   if (existing != null) return "Already registered";
   ```

   **Step 4.3: Check Max Capacity** (if set)
   ```csharp
   var maxReg = GetMaxRegistrations(qrCodeID);
   var currentCount = _DBContext.QREventRegistration
     .Count(r => r.QRCodeID == qrCodeID && r.Active == true);
   if (currentCount >= maxReg) return "Event is full";
   ```

   **Step 4.4: Create Registration Record**
   ```csharp
   var registration = new QREventRegistration {
     RegistrationID = Guid.NewGuid().ToString(),
     QRCodeID = request.QRCodeID,
     DataID = qrData.QRDataID,
     Email = request.Email,
     FullName = request.FullName,
     PhoneNumber = request.PhoneNumber,
     RegistrationDate = DateTime.Now,
     IPAddress = request.IPAddress,
     UserAgent = request.UserAgent,
     Active = true
   };
   _DBContext.QREventRegistration.Add(registration);
   _DBContext.SaveChanges();
   ```

5. **Response to Frontend**
   ```json
   {
     "status": 200,
     "message": "Registration successful",
     "resultObject": {
       "RegistrationID": "reg-123",
       "Success": true,
       "AlreadyRegistered": false,
       "Message": "Thank you for registering!"
     }
   }
   ```

6. **Frontend Updates UI**
   ```typescript
   // Save email to localStorage
   localStorage.setItem('event_user_email', email);
   
   // Update UI state
   this.isRegistered = true;
   this.showRegistrationForm = false;
   this.registrationData = response.resultObject;
   
   // Show success message
   alert('Registration successful!');
   ```

---

## Flow 4: Registered User Scans QR Again

### Step-by-Step Process

```
User Scans QR → Load Event → Check Email in localStorage → Check Registration → Show "Already Registered"
```

### Detailed Steps:

1. **User Scans QR Code Again**
   - Same URL opens: `/event/{qrCodeID}`
   - `EventViewerComponent` loads

2. **Check localStorage for Email**
   ```typescript
   const userEmail = localStorage.getItem('event_user_email');
   // e.g., "john@example.com"
   ```

3. **Auto-Check Registration Status**
   ```typescript
   if (userEmail) {
     await this.checkRegistrationStatus(userEmail);
   }
   ```
   - API call: `POST /SmartQRApi/CheckEventRegistration`
   - Backend finds existing registration
   - Returns: `{ IsRegistered: true, Registration: {...} }`

4. **Display "Already Registered" View**
   - Event details are shown
   - Registration form is **hidden**
   - Success message displayed:
     ```
     ✓ Registration Completed
     You registered on: December 1, 2025
     Email: john@example.com
     ```

---

## Flow 5: QR Owner Views Registrations

### Step-by-Step Process

```
QR Owner → Analytics/QR List → View Registrations → See List → Export (Optional)
```

### Detailed Steps:

1. **QR Owner Logs In**
   - Navigates to QR codes list
   - Finds their Event QR code

2. **View Registrations** (Authenticated API)
   ```
   Frontend → GET /SmartQRApi/GetEventRegistrations/{qrCodeID}
   Headers: { Authorization: "Bearer token" }
   ```

3. **Backend Validation**
   ```csharp
   // Verify user owns this QR code
   var qrCode = _DBContext.QRCode.FirstOrDefault(c => c.QRCodeID == qrCodeID);
   if (qrCode.UserID != currentUserID) {
     return "No permission";
   }
   ```

4. **Retrieve Registrations**
   ```csharp
   var registrations = _DBContext.QREventRegistration
     .Where(r => r.QRCodeID == qrCodeID && r.Active == true)
     .OrderByDescending(r => r.RegistrationDate)
     .Select(r => new {
       Email = r.Email,
       FullName = r.FullName,
       PhoneNumber = r.PhoneNumber,
       RegistrationDate = r.RegistrationDate
     })
     .ToList();
   ```

5. **Display Registration List**
   - Table showing:
     - Email
     - Full Name
     - Phone Number
     - Registration Date
   - Total count displayed
   - Export to CSV option (future enhancement)

---

## Data Flow Diagram

```
┌─────────────────┐
│  User Creates   │
│   Event QR      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Save to DB:    │
│  - QRCode       │
│  - QRCodeData   │
│  - QRCodeDesign │
│  - FieldValues  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  QR Code        │
│  Generated      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────────┐
│  User Scans QR  │─────▶│  Event Viewer    │
└─────────────────┘      │  Component       │
                          └────────┬─────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
                    ▼                             ▼
          ┌──────────────────┐        ┌──────────────────┐
          │  Check if        │        │  Show Event      │
          │  Registered      │        │  Details         │
          └────────┬─────────┘        └──────────────────┘
                   │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
┌───────────────┐      ┌──────────────────┐
│  Not          │      │  Already         │
│  Registered   │      │  Registered      │
└───────┬───────┘      └──────────────────┘
        │
        ▼
┌──────────────────┐
│  Show            │
│  Registration    │
│  Form            │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  User Submits    │
│  Registration    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Save to         │
│  QREventRegistration│
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Show Success    │
│  & Hide Form     │
└──────────────────┘
```

---

## Key Database Tables Interaction

```
QRCode (1) ──────┐
                  │
                  ├──▶ (1) QRCodeData
                  │
                  ├──▶ (1) QRCodeDesign
                  │
                  └──▶ (N) QREventRegistration
                         │
                         └──▶ Stores: Email, Name, Phone, Date
```

---

## Important Points to Remember

1. **Public vs Authenticated Endpoints**
   - **Public** (No login required):
     - `GetQRPublic` - View event details
     - `CheckEventRegistration` - Check registration status
     - `RegisterForEvent` - Register for event
   
   - **Authenticated** (Login required):
     - `GetEventRegistrations` - View registration list (QR owner only)

2. **Registration Detection**
   - Primary: Email stored in `localStorage`
   - Backend: Email + QRCodeID unique constraint
   - If user clears localStorage, they can register again (but backend prevents duplicate)

3. **Data Storage**
   - Event details: Stored in `QRTypeFieldValue` table (normalized)
   - Registration data: Stored in `QREventRegistration` table (separate table)

4. **Security**
   - Email uniqueness enforced at database level
   - QR owner verification for viewing registrations
   - Input validation on both frontend and backend

---

## Example Scenario

**Scenario: Tech Conference Event**

1. **Admin creates Event QR:**
   - Title: "Tech Conference 2025"
   - Date: "2025-12-15 10:00 AM"
   - Location: "Convention Center"
   - Max: 100 registrations

2. **User A scans QR:**
   - Sees event details
   - Fills form: email="alice@example.com", name="Alice"
   - Submits → Registration saved
   - Sees "Registration Completed"

3. **User A scans QR again (same device):**
   - Email found in localStorage
   - Backend confirms registration
   - Sees "Already Registered" (no form)

4. **User B scans QR:**
   - Sees event details
   - Fills form: email="bob@example.com", name="Bob"
   - Submits → Registration saved

5. **Admin views registrations:**
   - Logs in
   - Views registration list
   - Sees: Alice, Bob, and others
   - Total: 2 registrations (out of 100 max)

---

This flow ensures a smooth user experience while maintaining data integrity and security. The system handles both first-time registrations and returning users elegantly.

