# Event QR Implementation Plan

## Overview
This document outlines the implementation plan for adding a new "Event QR" type to the Smart QR system. This QR type allows users to create event details with registration functionality.

---

## 1. Database Structure

### 1.1 New Table: `QREventRegistration`

This table will store user registrations for Event QR codes.

```sql
CREATE TABLE QREventRegistration (
    RegistrationID NVARCHAR(50) PRIMARY KEY,
    QRCodeID NVARCHAR(50) NOT NULL,
    DataID NVARCHAR(50) NOT NULL, -- Links to QRCodeData.QRDataID
    Email NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(255) NOT NULL,
    PhoneNumber NVARCHAR(50),
    AdditionalData NVARCHAR(MAX), -- JSON for custom fields
    RegistrationDate DATETIME NOT NULL DEFAULT GETDATE(),
    IPAddress NVARCHAR(50),
    UserAgent NVARCHAR(500),
    Active BIT NOT NULL DEFAULT 1,
    CreatedBy NVARCHAR(50),
    CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedBy NVARCHAR(50),
    ModifiedOn DATETIME NOT NULL DEFAULT GETDATE(),
    LastAction NVARCHAR(50),
    
    -- Indexes
    CONSTRAINT FK_QREventRegistration_QRCode FOREIGN KEY (QRCodeID) REFERENCES QRCode(QRCodeID),
    CONSTRAINT FK_QREventRegistration_QRCodeData FOREIGN KEY (DataID) REFERENCES QRCodeData(QRDataID),
    CONSTRAINT UQ_QREventRegistration_QRCode_Email UNIQUE (QRCodeID, Email) -- Prevent duplicate registrations
);

-- Indexes for performance
CREATE INDEX IX_QREventRegistration_QRCodeID ON QREventRegistration(QRCodeID);
CREATE INDEX IX_QREventRegistration_Email ON QREventRegistration(Email);
CREATE INDEX IX_QREventRegistration_DataID ON QREventRegistration(DataID);
```

### 1.2 Update Existing Tables

**QRType Table:**
- Add new record for "Event QR" type (QRTypeID = 5 or next available)
- TypeName: "event"
- DisplayName: "Event QR"

**QRTypeField Table:**
Add fields for Event QR type:
- `eventTitle` (text, required)
- `eventDescription` (textarea, optional)
- `eventDateTime` (datetime, required)
- `eventLocation` (text, optional)
- `eventLogo` (image, optional)
- `maxRegistrations` (number, optional)
- `registrationFields` (json, optional) - Custom registration fields

---

## 2. Backend Implementation

### 2.1 Database Model

**File:** `Smart_QR_API/DBModels/SmartProject/QREventRegistration.cs`

```csharp
public partial class QREventRegistration
{
    public string RegistrationID { get; set; }
    public string QRCodeID { get; set; }
    public string DataID { get; set; }
    public string Email { get; set; }
    public string FullName { get; set; }
    public string PhoneNumber { get; set; }
    public string AdditionalData { get; set; } // JSON
    public DateTime RegistrationDate { get; set; }
    public string IPAddress { get; set; }
    public string UserAgent { get; set; }
    public bool Active { get; set; }
    public string CreatedBy { get; set; }
    public DateTime CreatedOn { get; set; }
    public string ModifiedBy { get; set; }
    public DateTime ModifiedOn { get; set; }
    public string LastAction { get; set; }
}
```

### 2.2 DTOs

**File:** `Smart_QR_API/DTO/SmartQR_Module/SmartQRDTO.cs`

Add new DTOs:

```csharp
// DTO for Event Registration Request
public class EventRegistrationRequestDTO
{
    public string QRCodeID { get; set; }
    public string Email { get; set; }
    public string FullName { get; set; }
    public string PhoneNumber { get; set; }
    public Dictionary<string, string> AdditionalFields { get; set; } // Custom fields
    public string IPAddress { get; set; }
    public string UserAgent { get; set; }
}

// DTO for Event Registration Response
public class EventRegistrationResponseDTO
{
    public string RegistrationID { get; set; }
    public bool Success { get; set; }
    public string Message { get; set; }
    public bool AlreadyRegistered { get; set; }
}

// DTO for Checking Registration Status
public class CheckRegistrationStatusDTO
{
    public string QRCodeID { get; set; }
    public string Email { get; set; }
    public bool IsRegistered { get; set; }
    public QREventRegistrationDTO Registration { get; set; }
}

// DTO for Event Registration Details
public class QREventRegistrationDTO
{
    public string RegistrationID { get; set; }
    public string Email { get; set; }
    public string FullName { get; set; }
    public string PhoneNumber { get; set; }
    public DateTime RegistrationDate { get; set; }
}
```

### 2.3 API Endpoints

**File:** `Smart_QR_API/APIs/SmartQR_Module/SmartQRApi.cs`

Add new endpoints:

```csharp
/// <summary>
/// Register for an event (Public - No Authentication Required)
/// </summary>
[HttpPost("RegisterForEvent")]
[AllowAnonymous]
public IActionResult RegisterForEvent([FromBody] EventRegistrationRequestDTO request)
{
    ServiceActionResult result = _controller.RegisterForEvent(request);
    
    switch (result.Status)
    {
        case ReturnStatus.success: return Ok(result);
        case ReturnStatus.BadRequest: return BadRequest(result);
        case ReturnStatus.NotFound: return NotFound(result);
        default: return StatusCode(500, result);
    }
}

/// <summary>
/// Check if email is already registered for an event (Public)
/// </summary>
[HttpPost("CheckEventRegistration")]
[AllowAnonymous]
public IActionResult CheckEventRegistration([FromBody] CheckRegistrationStatusDTO request)
{
    ServiceActionResult result = _controller.CheckEventRegistration(request.QRCodeID, request.Email);
    
    switch (result.Status)
    {
        case ReturnStatus.success: return Ok(result);
        case ReturnStatus.NotFound: return NotFound(result);
        default: return StatusCode(500, result);
    }
}

/// <summary>
/// Get event registration list (Authenticated - for QR owner)
/// </summary>
[HttpGet("GetEventRegistrations/{qrCodeID}")]
public IActionResult GetEventRegistrations(string qrCodeID)
{
    ServiceActionResult result = _controller.GetEventRegistrations(qrCodeID);
    
    switch (result.Status)
    {
        case ReturnStatus.success: return Ok(result);
        case ReturnStatus.NotFound: return NotFound(result);
        default: return StatusCode(500, result);
    }
}
```

### 2.4 Controller Logic

**File:** `Smart_QR_API/Infrastructure/Repository/SmartQR_Module/SmartQRController.cs`

Add methods:

```csharp
public ServiceActionResult RegisterForEvent(EventRegistrationRequestDTO request)
{
    string requestid = "Anonymous"; // Public endpoint
    
    try
    {
        // Validate QR Code exists and is active
        var qrCode = _DBContext.QRCode.FirstOrDefault(c => c.QRCodeID == request.QRCodeID && c.Active == true);
        if (qrCode == null)
            return new ServiceActionResult(ReturnStatus.NotFound, "Event QR Code not found", null);
        
        // Check if QR Code is expired
        if (qrCode.ExpiresOn < DateTime.Now)
            return new ServiceActionResult(ReturnStatus.BadRequest, "This event QR code has expired", null);
        
        // Get event data to check max registrations
        var qrData = _DBContext.QRCodeData.FirstOrDefault(d => d.QRCodeID == request.QRCodeID && d.Active == true);
        if (qrData == null)
            return new ServiceActionResult(ReturnStatus.NotFound, "Event data not found", null);
        
        // Check if already registered
        var existingRegistration = _DBContext.QREventRegistration
            .FirstOrDefault(r => r.QRCodeID == request.QRCodeID && 
                                r.Email.ToLower() == request.Email.ToLower() && 
                                r.Active == true);
        
        if (existingRegistration != null)
        {
            return new ServiceActionResult(ReturnStatus.success, "Already registered", new EventRegistrationResponseDTO
            {
                Success = false,
                AlreadyRegistered = true,
                Message = "You are already registered for this event"
            });
        }
        
        // Check max registrations if set
        var fieldValues = _DBContext.QRTypeFieldValue
            .Where(v => v.DataID == qrData.QRDataID && v.Active == true)
            .ToList();
        
        var maxRegistrationsField = fieldValues.FirstOrDefault(f => f.FieldName == "maxRegistrations");
        if (maxRegistrationsField != null && int.TryParse(maxRegistrationsField.FieldValue, out int maxReg))
        {
            var currentRegistrations = _DBContext.QREventRegistration
                .Count(r => r.QRCodeID == request.QRCodeID && r.Active == true);
            
            if (currentRegistrations >= maxReg)
            {
                return new ServiceActionResult(ReturnStatus.BadRequest, "Event is full", new EventRegistrationResponseDTO
                {
                    Success = false,
                    Message = "Sorry, this event has reached maximum capacity"
                });
            }
        }
        
        // Create registration
        var registration = new QREventRegistration
        {
            RegistrationID = Guid.NewGuid().ToString(),
            QRCodeID = request.QRCodeID,
            DataID = qrData.QRDataID,
            Email = request.Email,
            FullName = request.FullName,
            PhoneNumber = request.PhoneNumber ?? string.Empty,
            AdditionalData = request.AdditionalFields != null ? 
                System.Text.Json.JsonSerializer.Serialize(request.AdditionalFields) : string.Empty,
            RegistrationDate = DateTime.Now,
            IPAddress = request.IPAddress ?? string.Empty,
            UserAgent = request.UserAgent ?? string.Empty,
            Active = true,
            CreatedBy = requestid,
            CreatedOn = DateTime.Now,
            ModifiedBy = requestid,
            ModifiedOn = DateTime.Now,
            LastAction = Guid.NewGuid().ToString()
        };
        
        _DBContext.QREventRegistration.Add(registration);
        _DBContext.SaveChanges();
        
        return new ServiceActionResult(ReturnStatus.success, "Registration successful", new EventRegistrationResponseDTO
        {
            RegistrationID = registration.RegistrationID,
            Success = true,
            AlreadyRegistered = false,
            Message = "Thank you for registering!"
        });
    }
    catch (Exception ex)
    {
        return Common_Methods.doErrorLog(ControllerLogLabel, ex.Message, ex, requestid);
    }
}

public ServiceActionResult CheckEventRegistration(string qrCodeID, string email)
{
    try
    {
        var registration = _DBContext.QREventRegistration
            .FirstOrDefault(r => r.QRCodeID == qrCodeID && 
                                r.Email.ToLower() == email.ToLower() && 
                                r.Active == true);
        
        if (registration == null)
        {
            return new ServiceActionResult(ReturnStatus.success, "Not registered", new CheckRegistrationStatusDTO
            {
                QRCodeID = qrCodeID,
                Email = email,
                IsRegistered = false
            });
        }
        
        return new ServiceActionResult(ReturnStatus.success, "Registration found", new CheckRegistrationStatusDTO
        {
            QRCodeID = qrCodeID,
            Email = email,
            IsRegistered = true,
            Registration = new QREventRegistrationDTO
            {
                RegistrationID = registration.RegistrationID,
                Email = registration.Email,
                FullName = registration.FullName,
                PhoneNumber = registration.PhoneNumber,
                RegistrationDate = registration.RegistrationDate
            }
        });
    }
    catch (Exception ex)
    {
        return Common_Methods.doErrorLog(ControllerLogLabel, ex.Message, ex, "Anonymous");
    }
}

public ServiceActionResult GetEventRegistrations(string qrCodeID)
{
    string requestid = _tokenManager.GetAuthorizedUser()?.userID ?? "Anonymous";
    
    try
    {
        // Verify user owns this QR code
        var qrCode = _DBContext.QRCode.FirstOrDefault(c => c.QRCodeID == qrCodeID);
        if (qrCode == null)
            return new ServiceActionResult(ReturnStatus.NotFound, "QR Code not found", null);
        
        if (qrCode.UserID != requestid)
            return new ServiceActionResult(ReturnStatus.error_NoViewPermission, "You don't have permission to view registrations for this QR code", null);
        
        var registrations = _DBContext.QREventRegistration
            .Where(r => r.QRCodeID == qrCodeID && r.Active == true)
            .OrderByDescending(r => r.RegistrationDate)
            .Select(r => new QREventRegistrationDTO
            {
                RegistrationID = r.RegistrationID,
                Email = r.Email,
                FullName = r.FullName,
                PhoneNumber = r.PhoneNumber,
                RegistrationDate = r.RegistrationDate
            })
            .ToList();
        
        return new ServiceActionResult(ReturnStatus.success, "Registrations retrieved", registrations);
    }
    catch (Exception ex)
    {
        return Common_Methods.doErrorLog(ControllerLogLabel, ex.Message, ex, requestid);
    }
}
```

---

## 3. Frontend Implementation

### 3.1 Create Event QR Components

#### 3.1.1 Event Step One Component
**Path:** `Smart_QR_UI/src/app/pages/systematic/modules/qr-code-list/qr-operation/event-step-one/event-step-one.component.ts`

Similar structure to `v-card-step-one` but with event-specific fields:
- Event Title (required)
- Event Description (optional)
- Event Date & Time (required)
- Event Location (optional)
- Event Logo (optional)
- Max Registrations (optional)
- Registration Form Fields (customizable)

#### 3.1.2 Event Step Two Component
**Path:** `Smart_QR_UI/src/app/pages/systematic/modules/qr-code-list/qr-operation/event-step-two/event-step-two.component.ts`

For QR design customization (same as other QR types).

### 3.2 Event Viewer Component

**Path:** `Smart_QR_UI/src/app/pages/systematic/modules/qr-code-list/qr-viewer/event-viewer/event-viewer.component.ts`

Key features:
1. Display event details (title, description, date/time, location, logo)
2. Check if user is already registered (using email from localStorage or prompt)
3. Show registration form if not registered
4. Show "Registration Completed" message if already registered
5. Handle registration submission

**Implementation Logic:**

```typescript
export class EventViewerComponent implements OnInit {
  qrCodeId: string = '';
  eventData: any = null;
  isRegistered: boolean = false;
  registrationData: any = null;
  showRegistrationForm: boolean = true;
  registrationForm: any = {
    email: '',
    fullName: '',
    phoneNumber: '',
    additionalFields: {}
  };
  
  ngOnInit() {
    this.route.paramMap.subscribe(params => {
      this.qrCodeId = params.get('id') || '';
      this.loadEventData();
    });
  }
  
  async loadEventData() {
    // Load QR code data
    const qrData = await this.qrCodeService.getQRDetailsPublic(this.qrCodeId);
    
    // Parse event data from field values
    this.eventData = this.parseEventData(qrData.FieldValues);
    
    // Check if user is already registered
    const userEmail = localStorage.getItem('event_user_email') || '';
    if (userEmail) {
      await this.checkRegistrationStatus(userEmail);
    }
  }
  
  async checkRegistrationStatus(email: string) {
    const response = await this.http.post(`${apiUrl}/CheckEventRegistration`, {
      QRCodeID: this.qrCodeId,
      Email: email
    }).toPromise();
    
    if (response?.resultObject?.IsRegistered) {
      this.isRegistered = true;
      this.registrationData = response.resultObject.Registration;
      this.showRegistrationForm = false;
    }
  }
  
  async submitRegistration() {
    // Validate form
    if (!this.registrationForm.email || !this.registrationForm.fullName) {
      alert('Please fill in required fields');
      return;
    }
    
    // Submit registration
    const response = await this.http.post(`${apiUrl}/RegisterForEvent`, {
      QRCodeID: this.qrCodeId,
      Email: this.registrationForm.email,
      FullName: this.registrationForm.fullName,
      PhoneNumber: this.registrationForm.phoneNumber,
      AdditionalFields: this.registrationForm.additionalFields,
      IPAddress: await this.getIPAddress(),
      UserAgent: navigator.userAgent
    }).toPromise();
    
    if (response?.resultObject?.Success) {
      // Save email to localStorage for future checks
      localStorage.setItem('event_user_email', this.registrationForm.email);
      this.isRegistered = true;
      this.showRegistrationForm = false;
      alert('Registration successful!');
    } else if (response?.resultObject?.AlreadyRegistered) {
      this.isRegistered = true;
      this.showRegistrationForm = false;
    } else {
      alert(response?.message || 'Registration failed');
    }
  }
  
  // Helper to get IP address (use a service or API)
  async getIPAddress(): Promise<string> {
    try {
      const response = await this.http.get('https://api.ipify.org?format=json').toPromise();
      return response['ip'] || '';
    } catch {
      return '';
    }
  }
}
```

### 3.3 Registration Detection Strategy

**Option 1: Email-based (Recommended)**
- Store user email in localStorage after first registration
- Check registration status on page load using email
- Pros: Simple, works across devices for same user
- Cons: User can clear localStorage to re-register

**Option 2: Browser Fingerprinting**
- Use browser fingerprinting library
- Store fingerprint + QRCodeID combination
- Pros: More reliable
- Cons: Complex, privacy concerns

**Option 3: Cookie-based**
- Store registration status in cookie
- Pros: Works across sessions
- Cons: User can clear cookies

**Recommended: Hybrid Approach**
- Primary: Email-based check
- Fallback: Check by IP address (if email not available)
- Store both in localStorage for better reliability

---

## 4. Routing Updates

**File:** `Smart_QR_UI/src/app/app-routing.module.ts`

Add routes:

```typescript
{ path: 'qr-codes/type/event', component: EventStepOneComponent },
{ path: 'qr-codes/type/event/customize', component: EventStepTwoComponent },
{ path: 'qr-codes/edit/event/:id', component: EventStepOneComponent },
{ path: 'qr-codes/edit/event/:id/customize', component: EventStepTwoComponent },
{ path: 'event/:id', component: EventViewerComponent },
```

---

## 5. Service Updates

**File:** `Smart_QR_UI/src/app/services/qr-code.service.ts`

Add methods:

```typescript
async registerForEvent(qrCodeID: string, registrationData: any): Promise<any> {
  // Implementation
}

async checkEventRegistration(qrCodeID: string, email: string): Promise<any> {
  // Implementation
}

async getEventRegistrations(qrCodeID: string): Promise<any> {
  // Implementation (authenticated)
}
```

---

## 6. Database Migration Script

**File:** `Smart_QR_API/SQL_Migrations/Create_EventQR_Tables.sql`

```sql
-- Create QREventRegistration table
-- (See section 1.1 for full SQL)

-- Insert Event QR Type
INSERT INTO QRType (QRTypeID, TypeName, DisplayName, Description, IconURL, Color, DisplayOrder, Active, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn, LastAction)
VALUES ('5', 'event', 'Event QR', 'Create event QR codes with registration functionality', 'event', '#9B59B6', 5, 1, 'System', GETDATE(), 'System', GETDATE(), NEWID());

-- Insert Event QR Fields
INSERT INTO QRTypeField (QRTypeFieldID, QRTypeID, FieldName, DisplayName, FieldType, IsRequired, DefaultValue, ValidationRules, Active, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn, LastAction)
VALUES 
(NEWID(), '5', 'eventTitle', 'Event Title', 'text', 1, '', '', 1, 'System', GETDATE(), 'System', GETDATE(), NEWID()),
(NEWID(), '5', 'eventDescription', 'Event Description', 'textarea', 0, '', '', 1, 'System', GETDATE(), 'System', GETDATE(), NEWID()),
(NEWID(), '5', 'eventDateTime', 'Event Date & Time', 'datetime', 1, '', '', 1, 'System', GETDATE(), 'System', GETDATE(), NEWID()),
(NEWID(), '5', 'eventLocation', 'Event Location', 'text', 0, '', '', 1, 'System', GETDATE(), 'System', GETDATE(), NEWID()),
(NEWID(), '5', 'eventLogo', 'Event Logo', 'image', 0, '', '', 1, 'System', GETDATE(), 'System', GETDATE(), NEWID()),
(NEWID(), '5', 'maxRegistrations', 'Max Registrations', 'number', 0, '', '', 1, 'System', GETDATE(), 'System', GETDATE(), NEWID());
```

---

## 7. Implementation Steps

### Phase 1: Database Setup
1. Create `QREventRegistration` table
2. Add Event QR type to `QRType` table
3. Add Event QR fields to `QRTypeField` table
4. Update `SmartProjectContext.cs` with new entity

### Phase 2: Backend API
1. Create `QREventRegistration` model
2. Add DTOs for registration
3. Implement controller methods
4. Add API endpoints
5. Test API endpoints

### Phase 3: Frontend - Creation Flow
1. Create `event-step-one` component
2. Create `event-step-two` component
3. Add routes
4. Update QR type selection page
5. Test creation flow

### Phase 4: Frontend - Viewer Flow
1. Create `event-viewer` component
2. Implement registration form
3. Implement registration status check
4. Add registration submission
5. Test viewer flow

### Phase 5: Testing & Refinement
1. Test complete flow
2. Test edge cases (duplicate registration, max capacity, expired events)
3. Add error handling
4. Add loading states
5. Polish UI/UX

---

## 8. Additional Considerations

### 8.1 Email Validation
- Validate email format on both frontend and backend
- Consider sending confirmation email (future enhancement)

### 8.2 Spam Prevention
- Add CAPTCHA for registration (optional)
- Rate limiting per IP address
- Email verification (future enhancement)

### 8.3 Analytics
- Track registration count per event
- Show registration statistics in analytics dashboard

### 8.4 Export Functionality
- Allow QR owners to export registration list as CSV/Excel

### 8.5 Notifications
- Email notifications to event organizer when someone registers
- Confirmation email to registrant (future enhancement)

---

## 9. Security Considerations

1. **Input Validation**: Validate all user inputs on backend
2. **SQL Injection**: Use parameterized queries (EF Core handles this)
3. **XSS Prevention**: Sanitize user inputs before displaying
4. **Rate Limiting**: Prevent spam registrations
5. **Email Uniqueness**: Enforce unique email per event (database constraint)

---

## 10. Future Enhancements

1. **Email Confirmation**: Send confirmation email with unique link
2. **QR Code for Registration**: Generate QR code for each registrant
3. **Custom Registration Fields**: Allow event creator to add custom fields
4. **Payment Integration**: Add payment for paid events
5. **Waitlist**: Automatic waitlist when event is full
6. **Reminder Emails**: Send reminder emails before event
7. **Check-in System**: QR code check-in at event venue

---

This implementation plan provides a comprehensive roadmap for adding Event QR functionality to your Smart QR system. Would you like me to start implementing any specific part of this plan?

