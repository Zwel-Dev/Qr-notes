# Event Registration & Attendance QR System - Implementation Plan

## Overview
Implement a two-tier QR code system for events:
1. **Event QR** - Public QR that shows event info and allows registration
2. **Attendee QR** - Unique QR generated for each registrant for attendance tracking

---

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    EVENT ORGANIZER                           │
│  Creates Event QR → Publishes/Prints → Event Day             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    USER SCANS EVENT QR                        │
│  → Sees Event Details → Clicks "Register Now"                │
│  → Fills Registration Form → Submits                         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              SYSTEM GENERATES ATTENDEE QR                     │
│  → Creates unique registration record                        │
│  → Generates unique QR code for attendee                     │
│  → Sends QR via email/SMS or displays on screen              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              ATTENDEE RECEIVES UNIQUE QR                      │
│  → Saves QR to phone (download image)                        │
│  → Or receives via email with QR image                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              EVENT DAY - ATTENDANCE TRACKING                  │
│  → Attendee scans their unique QR at event entrance          │
│  → System marks attendance (timestamp, location)             │
│  → Organizer can view real-time attendance list              │
└─────────────────────────────────────────────────────────────┘
```

---

## Database Schema Design

### 1. EventRegistration Table
```sql
CREATE TABLE EventRegistration (
    RegistrationID VARCHAR(50) PRIMARY KEY,
    EventQRCodeID VARCHAR(50) NOT NULL,  -- FK to QRCode.QRCodeID
    UniqueQRCodeID VARCHAR(50) NULL,      -- FK to QRCode.QRCodeID (the attendee's QR)
    
    -- Registrant Information
    Email NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(50) NULL,
    Company NVARCHAR(255) NULL,
    Position NVARCHAR(255) NULL,
    AdditionalInfo NVARCHAR(MAX) NULL,
    
    -- Registration Status
    RegistrationStatus INT DEFAULT 1,  -- 1=Pending, 2=Confirmed, 3=Cancelled
    RegistrationDate DATETIME NOT NULL,
    ConfirmationDate DATETIME NULL,
    
    -- Attendance Tracking
    AttendanceStatus INT DEFAULT 0,  -- 0=Not Attended, 1=Attended, 2=Late
    AttendanceTime DATETIME NULL,
    AttendanceLocation NVARCHAR(255) NULL,  -- GPS or manual entry
    
    -- QR Code Details
    UniqueQRContent NVARCHAR(500) NOT NULL,  -- e.g., "event/attendance/{uniqueId}"
    UniqueQRImageURL NVARCHAR(500) NULL,
    
    -- Metadata
    Active BIT DEFAULT 1,
    CreatedBy VARCHAR(50),
    CreatedOn DATETIME,
    ModifiedBy VARCHAR(50),
    ModifiedOn DATETIME,
    LastAction VARCHAR(50),
    
    -- Constraints
    FOREIGN KEY (EventQRCodeID) REFERENCES QRCode(QRCodeID),
    FOREIGN KEY (UniqueQRCodeID) REFERENCES QRCode(QRCodeID),
    UNIQUE (UniqueQRContent),
    INDEX IX_EventRegistration_EventQRCodeID (EventQRCodeID),
    INDEX IX_EventRegistration_Email (Email),
    INDEX IX_EventRegistration_UniqueQRContent (UniqueQRContent)
);
```

### 2. EventAttendanceLog Table (Optional - for detailed tracking)
```sql
CREATE TABLE EventAttendanceLog (
    AttendanceLogID VARCHAR(50) PRIMARY KEY,
    RegistrationID VARCHAR(50) NOT NULL,  -- FK to EventRegistration
    ScanTime DATETIME NOT NULL,
    IPAddress NVARCHAR(50) NULL,
    Location NVARCHAR(255) NULL,
    Latitude NVARCHAR(50) NULL,
    Longitude NVARCHAR(50) NULL,
    DeviceInfo NVARCHAR(255) NULL,
    Active BIT DEFAULT 1,
    CreatedOn DATETIME,
    
    FOREIGN KEY (RegistrationID) REFERENCES EventRegistration(RegistrationID),
    INDEX IX_EventAttendanceLog_RegistrationID (RegistrationID)
);
```

---

## API Endpoints Design

### 1. Registration Endpoints

#### POST `/api/Event/Register`
**Purpose**: Register for an event
**Request Body**:
```json
{
  "eventQRCodeID": "abc123...",
  "email": "user@example.com",
  "fullName": "John Doe",
  "phone": "+1234567890",
  "company": "Acme Corp",
  "position": "Manager",
  "additionalInfo": "Dietary requirements: Vegetarian"
}
```

**Response**:
```json
{
  "status": 200,
  "message": "Registration successful",
  "resultObject": {
    "registrationID": "reg123...",
    "uniqueQRCodeID": "qr456...",
    "uniqueQRContent": "event/attendance/uniqueId123",
    "uniqueQRImageURL": "https://api.../content/qr-images/...",
    "downloadQRUrl": "https://api.../api/Event/DownloadAttendeeQR/reg123",
    "emailSent": true
  }
}
```

**Business Logic**:
- Check if event exists and is active
- Check if max registrations reached (if set)
- Check if email already registered (prevent duplicates if needed)
- Generate unique registration ID
- Generate unique QR code for attendee
- Create EventRegistration record
- Generate QR image
- Send confirmation email with QR (optional)
- Return QR details

---

#### GET `/api/Event/GetAttendeeQR/{registrationID}`
**Purpose**: Get attendee's unique QR code
**Response**: QR image file or JSON with QR details

---

#### GET `/api/Event/Registrations/{eventQRCodeID}`
**Purpose**: Get all registrations for an event (organizer view)
**Authentication**: Required (must be event owner)
**Response**:
```json
{
  "status": 200,
  "resultObject": {
    "totalRegistrations": 150,
    "confirmedRegistrations": 145,
    "attendedCount": 120,
    "registrations": [
      {
        "registrationID": "reg123",
        "email": "user@example.com",
        "fullName": "John Doe",
        "phone": "+1234567890",
        "company": "Acme Corp",
        "registrationDate": "2024-01-15T10:30:00Z",
        "attendanceStatus": 1,
        "attendanceTime": "2024-01-20T09:15:00Z"
      }
    ]
  }
}
```

---

### 2. Attendance Endpoints

#### POST `/api/Event/MarkAttendance`
**Purpose**: Mark attendance when attendee scans their QR
**Request Body**:
```json
{
  "uniqueQRContent": "event/attendance/uniqueId123",
  "location": "Main Entrance",
  "latitude": "40.7128",
  "longitude": "-74.0060"
}
```

**Response**:
```json
{
  "status": 200,
  "message": "Attendance marked successfully",
  "resultObject": {
    "registrationID": "reg123",
    "attendeeName": "John Doe",
    "attendanceTime": "2024-01-20T09:15:00Z",
    "isFirstTime": true,
    "message": "Welcome, John Doe!"
  }
}
```

**Business Logic**:
- Extract unique ID from QR content
- Find EventRegistration by UniqueQRContent
- Check if already attended (prevent duplicate scans)
- Update attendance status and time
- Create EventAttendanceLog entry
- Return confirmation

---

#### GET `/api/Event/Attendance/{eventQRCodeID}`
**Purpose**: Get attendance list for event (organizer view)
**Authentication**: Required
**Query Params**: `?status=all|attended|notAttended`
**Response**: List of attendees with attendance status

---

### 3. Public Endpoints (No Auth Required)

#### GET `/api/Event/Public/{eventQRCodeID}`
**Purpose**: Get event details for public viewing (when scanning event QR)
**Response**: Event info (title, description, dates, location, etc.)

---

#### POST `/api/Event/CheckAvailability/{eventQRCodeID}`
**Purpose**: Check if event has available spots
**Response**:
```json
{
  "available": true,
  "currentRegistrations": 120,
  "maxRegistrations": 200,
  "remainingSpots": 80
}
```

---

## Frontend Implementation

### 1. Public Event View (When User Scans Event QR)

**Component**: `event-public-view.component.ts/html`
- Display event details (from existing event-mockup-frame)
- Show "Register Now" button
- Display registration form when clicked
- Handle form submission
- Show success message with unique QR code
- Allow download of attendee QR

**Key Features**:
- Check registration availability before showing form
- Validate email uniqueness (if required)
- Show loading states
- Handle errors gracefully
- Display unique QR after registration

---

### 2. Attendee QR Display

**Component**: `attendee-qr-display.component.ts/html`
- Display unique QR code image
- Show registration details
- Download QR button
- Email QR button (resend)
- Print-friendly view

---

### 3. Organizer Dashboard

**Component**: `event-registrations.component.ts/html`
- List all registrations
- Filter by status (pending, confirmed, attended)
- Export to CSV/Excel
- Real-time attendance count
- Search/filter functionality
- View individual registration details

---

### 4. Attendance Scanner (For Event Day)

**Component**: `event-attendance-scanner.component.ts/html`
- QR scanner interface
- Scan attendee QR codes
- Display attendee info on scan
- Mark attendance
- Show attendance confirmation
- Real-time attendance list

---

## Implementation Steps

### Phase 1: Database & Backend Foundation
1. ✅ Create EventRegistration table
2. ✅ Create EventAttendanceLog table (optional)
3. ✅ Create DB models (EventRegistration.cs, EventAttendanceLog.cs)
4. ✅ Create DTOs (EventRegistrationDTO.cs, RegisterEventRequestDTO.cs, etc.)
5. ✅ Create Controller (EventController.cs)
6. ✅ Create API endpoints (EventApi.cs)

### Phase 2: Registration Flow
1. ✅ Implement registration endpoint
2. ✅ Generate unique QR for each registrant
3. ✅ Store registration data
4. ✅ Implement email notification (optional)
5. ✅ Frontend: Public event view component
6. ✅ Frontend: Registration form submission
7. ✅ Frontend: Display attendee QR after registration

### Phase 3: Attendance Tracking
1. ✅ Implement attendance marking endpoint
2. ✅ QR content parsing logic
3. ✅ Prevent duplicate attendance
4. ✅ Frontend: Attendance scanner component
5. ✅ Frontend: Real-time attendance display

### Phase 4: Organizer Dashboard
1. ✅ Implement registrations list endpoint
2. ✅ Implement attendance list endpoint
3. ✅ Frontend: Registrations management component
4. ✅ Frontend: Export functionality
5. ✅ Frontend: Analytics/statistics

### Phase 5: Enhancements
1. ✅ Email notifications (confirmation, reminder, QR code)
2. ✅ SMS notifications (optional)
3. ✅ Check-in location validation (GPS)
4. ✅ Multiple check-in points
5. ✅ Late arrival detection
6. ✅ Waitlist functionality (if max registrations reached)

---

## Key Technical Decisions

### 1. Unique QR Content Format
**Option A**: `event/attendance/{registrationID}`
- Pros: Simple, direct lookup
- Cons: Exposes registration ID

**Option B**: `event/attendance/{encryptedToken}`
- Pros: More secure, can include expiry
- Cons: Requires decryption logic

**Recommendation**: Start with Option A, upgrade to Option B if security is a concern.

---

### 2. QR Code Generation
- Use existing `QrCodeService` to generate attendee QR codes
- Store as separate QRCode record (QRTypeID = special type for attendee QR)
- OR store only in EventRegistration table (simpler, but less flexible)

**Recommendation**: Create separate QRCode record for each attendee QR (allows tracking scans, analytics).

---

### 3. Duplicate Registration Prevention
- **Option A**: Allow multiple registrations per email
- **Option B**: One registration per email per event
- **Option C**: Configurable per event

**Recommendation**: Option B (one per email) with option to allow duplicates if needed.

---

### 4. Attendance Validation
- **Option A**: Allow multiple scans (re-entry)
- **Option B**: One-time scan only
- **Option C**: Configurable (e.g., allow re-entry within time window)

**Recommendation**: Option C (configurable, default: one-time with re-entry allowed after 1 hour).

---

## Security Considerations

1. **QR Content Security**: Use encrypted tokens or signed URLs
2. **Rate Limiting**: Prevent spam registrations
3. **Email Verification**: Optional email confirmation before QR generation
4. **Access Control**: Organizer endpoints require authentication
5. **Data Privacy**: GDPR compliance for attendee data

---

## Testing Checklist

- [ ] Register for event successfully
- [ ] Prevent duplicate registrations (if configured)
- [ ] Handle max registrations limit
- [ ] Generate unique QR correctly
- [ ] Mark attendance successfully
- [ ] Prevent duplicate attendance (if configured)
- [ ] Organizer can view registrations
- [ ] Organizer can view attendance list
- [ ] Export functionality works
- [ ] Email notifications sent (if enabled)
- [ ] Error handling for invalid QR codes
- [ ] Error handling for expired events

---

## Questions for Discussion

1. **Email Verification**: Should we require email verification before generating QR?
2. **QR Expiry**: Should attendee QR codes expire after event date?
3. **Multiple Check-ins**: Allow attendees to check in multiple times (re-entry)?
4. **Waitlist**: If max registrations reached, should we create a waitlist?
5. **Notifications**: What notifications should be sent? (Registration confirmation, QR code, event reminder, attendance confirmation)
6. **Analytics**: What analytics should be tracked? (Registration source, attendance rate, check-in time distribution)
7. **Offline Mode**: Should attendance scanner work offline and sync later?

---

## Next Steps

1. **Review this plan** and discuss the questions above
2. **Confirm database schema** and make adjustments if needed
3. **Prioritize features** (MVP vs. full implementation)
4. **Start with Phase 1** (Database & Backend Foundation)
5. **Iterate** based on feedback

---

## Estimated Timeline

- **Phase 1**: 2-3 days (Database, Models, DTOs, Basic API)
- **Phase 2**: 3-4 days (Registration flow, QR generation)
- **Phase 3**: 2-3 days (Attendance tracking)
- **Phase 4**: 2-3 days (Organizer dashboard)
- **Phase 5**: 2-3 days (Enhancements, polish)

**Total**: ~11-16 days for full implementation

---

Let me know your thoughts on this plan, and we can adjust as needed!

