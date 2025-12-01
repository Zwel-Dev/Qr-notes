# Event QR Feature - TODO List

## 📋 Implementation Checklist

This document contains a comprehensive TODO list for implementing the Event QR feature. Check off items as you complete them.

---

## Phase 1: Database Setup & Models ⚙️

### 1.1 Database Schema
- [ ] Create `QREventRegistration` table SQL script
- [ ] Add foreign key constraints to `QRCode` and `QRCodeData`
- [ ] Add unique constraint on `(QRCodeID, Email)` combination
- [ ] Create indexes for performance:
  - [ ] Index on `QRCodeID`
  - [ ] Index on `Email`
  - [ ] Index on `DataID`
- [ ] Test table creation in development database
- [ ] Create database migration script

### 1.2 QRType Setup
- [ ] Insert Event QR type into `QRType` table
  - [ ] QRTypeID: '5' (or next available)
  - [ ] TypeName: 'event'
  - [ ] DisplayName: 'Event QR'
  - [ ] Description: 'Create event QR codes with registration functionality'
  - [ ] IconURL: 'event'
  - [ ] Color: '#9B59B6' (or preferred color)
  - [ ] DisplayOrder: 5
- [ ] Verify QR type appears in system

### 1.3 QRTypeField Setup
- [ ] Insert Event QR fields into `QRTypeField` table:
  - [ ] `eventTitle` (text, required)
  - [ ] `eventDescription` (textarea, optional)
  - [ ] `eventDateTime` (datetime, required)
  - [ ] `eventLocation` (text, optional)
  - [ ] `eventLogo` (image, optional)
  - [ ] `maxRegistrations` (number, optional)
  - [ ] `registrationFields` (json, optional) - for custom fields
- [ ] Verify all fields are created correctly

### 1.4 Entity Framework Models
- [ ] Create `QREventRegistration.cs` model file
  - [ ] Add all properties matching database schema
  - [ ] Add navigation properties (if needed)
  - [ ] Add data annotations
- [ ] Update `SmartProjectContext.cs`:
  - [ ] Add `DbSet<QREventRegistration>` property
  - [ ] Configure entity in `OnModelCreating` method
  - [ ] Set up relationships and constraints
- [ ] Run EF Core migration or update database
- [ ] Verify model compiles without errors

---

## Phase 2: Backend DTOs & Interfaces 📦

### 2.1 DTOs
- [ ] Create `EventRegistrationRequestDTO` class
  - [ ] QRCodeID (string)
  - [ ] Email (string)
  - [ ] FullName (string)
  - [ ] PhoneNumber (string, optional)
  - [ ] AdditionalFields (Dictionary<string, string>, optional)
  - [ ] IPAddress (string)
  - [ ] UserAgent (string)
- [ ] Create `EventRegistrationResponseDTO` class
  - [ ] RegistrationID (string)
  - [ ] Success (bool)
  - [ ] Message (string)
  - [ ] AlreadyRegistered (bool)
- [ ] Create `CheckRegistrationStatusDTO` class
  - [ ] QRCodeID (string)
  - [ ] Email (string)
  - [ ] IsRegistered (bool)
  - [ ] Registration (QREventRegistrationDTO, optional)
- [ ] Create `QREventRegistrationDTO` class
  - [ ] RegistrationID (string)
  - [ ] Email (string)
  - [ ] FullName (string)
  - [ ] PhoneNumber (string)
  - [ ] RegistrationDate (DateTime)
- [ ] Add all DTOs to `SmartQRDTO.cs` file
- [ ] Verify DTOs compile without errors

---

## Phase 3: Backend Controller Logic 🎮

### 3.1 Registration Methods
- [ ] Implement `RegisterForEvent` method in `SmartQRController.cs`
  - [ ] Validate QR code exists and is active
  - [ ] Check if QR code is expired
  - [ ] Validate email format
  - [ ] Check for duplicate registration (email + QRCodeID)
  - [ ] Get event data from QRCodeData
  - [ ] Check max registrations (if set)
  - [ ] Count current registrations
  - [ ] Validate capacity not exceeded
  - [ ] Create new registration record
  - [ ] Save to database
  - [ ] Return success response
  - [ ] Add error handling and logging
- [ ] Test `RegisterForEvent` method:
  - [ ] Test successful registration
  - [ ] Test duplicate registration prevention
  - [ ] Test max capacity enforcement
  - [ ] Test expired QR code handling
  - [ ] Test invalid email handling
  - [ ] Test missing required fields

### 3.2 Check Registration Method
- [ ] Implement `CheckEventRegistration` method
  - [ ] Accept QRCodeID and Email parameters
  - [ ] Query `QREventRegistration` table
  - [ ] Check if registration exists and is active
  - [ ] Return registration status and data
  - [ ] Handle not found case
  - [ ] Add error handling
- [ ] Test `CheckEventRegistration` method:
  - [ ] Test for registered user
  - [ ] Test for non-registered user
  - [ ] Test with invalid QRCodeID
  - [ ] Test with invalid email

### 3.3 Get Registrations Method (Authenticated)
- [ ] Implement `GetEventRegistrations` method
  - [ ] Verify user authentication
  - [ ] Verify user owns the QR code
  - [ ] Query all registrations for QR code
  - [ ] Order by registration date (descending)
  - [ ] Map to DTOs
  - [ ] Return list of registrations
  - [ ] Add error handling
- [ ] Test `GetEventRegistrations` method:
  - [ ] Test with valid owner
  - [ ] Test with non-owner (should fail)
  - [ ] Test with unauthenticated user (should fail)
  - [ ] Test with no registrations

### 3.4 Helper Methods
- [ ] Create helper method to get max registrations from field values
- [ ] Create helper method to count current registrations
- [ ] Create helper method to validate email format
- [ ] Add logging for all operations

---

## Phase 4: Backend API Endpoints 🌐

### 4.1 Public Endpoints
- [ ] Add `RegisterForEvent` endpoint in `SmartQRApi.cs`
  - [ ] Route: `POST /SmartQRApi/RegisterForEvent`
  - [ ] Allow anonymous access `[AllowAnonymous]`
  - [ ] Accept `EventRegistrationRequestDTO`
  - [ ] Call controller method
  - [ ] Return appropriate HTTP status codes
  - [ ] Add XML documentation comments
- [ ] Add `CheckEventRegistration` endpoint
  - [ ] Route: `POST /SmartQRApi/CheckEventRegistration`
  - [ ] Allow anonymous access
  - [ ] Accept `CheckRegistrationStatusDTO`
  - [ ] Call controller method
  - [ ] Return appropriate HTTP status codes
  - [ ] Add XML documentation comments

### 4.2 Authenticated Endpoints
- [ ] Add `GetEventRegistrations` endpoint
  - [ ] Route: `GET /SmartQRApi/GetEventRegistrations/{qrCodeID}`
  - [ ] Require authentication
  - [ ] Call controller method
  - [ ] Return appropriate HTTP status codes
  - [ ] Add XML documentation comments

### 4.3 API Testing
- [ ] Test all endpoints with Postman/Thunder Client
- [ ] Test with valid data
- [ ] Test with invalid data
- [ ] Test error cases
- [ ] Test authentication/authorization
- [ ] Verify CORS settings (if applicable)

---

## Phase 5: Frontend Service Layer 🔧

### 5.1 QR Code Service Updates
- [ ] Add `registerForEvent` method to `qr-code.service.ts`
  - [ ] Accept registration data
  - [ ] Call `/RegisterForEvent` API
  - [ ] Handle response
  - [ ] Return typed response
  - [ ] Add error handling
- [ ] Add `checkEventRegistration` method
  - [ ] Accept QRCodeID and email
  - [ ] Call `/CheckEventRegistration` API
  - [ ] Handle response
  - [ ] Return typed response
  - [ ] Add error handling
- [ ] Add `getEventRegistrations` method (authenticated)
  - [ ] Accept QRCodeID
  - [ ] Call `/GetEventRegistrations` API
  - [ ] Handle response
  - [ ] Return typed response
  - [ ] Add error handling
- [ ] Add TypeScript interfaces for Event QR:
  - [ ] `EventRegistrationRequest`
  - [ ] `EventRegistrationResponse`
  - [ ] `CheckRegistrationStatus`
  - [ ] `EventRegistration`
- [ ] Test service methods

---

## Phase 6: Frontend - Creation Flow 📝

### 6.1 Event Step One Component
- [ ] Create `event-step-one` component folder structure
- [ ] Create `event-step-one.component.ts`
  - [ ] Implement `OnInit` lifecycle
  - [ ] Add form properties:
    - [ ] eventTitle (FormControl, required)
    - [ ] eventDescription (FormControl, optional)
    - [ ] eventDateTime (FormControl, required)
    - [ ] eventLocation (FormControl, optional)
    - [ ] eventLogo (FormControl, optional)
    - [ ] maxRegistrations (FormControl, optional)
  - [ ] Add form validation
  - [ ] Implement image upload for logo
  - [ ] Add image preview
  - [ ] Implement `loadFromSessionStorage` for create mode
  - [ ] Implement `loadExistingDataForEdit` for edit mode
  - [ ] Implement `onNext` method to save to sessionStorage
  - [ ] Implement `onBack` method
  - [ ] Add date/time picker integration
- [ ] Create `event-step-one.component.html`
  - [ ] Add form layout
  - [ ] Add input fields with labels
  - [ ] Add date/time picker
  - [ ] Add image upload component
  - [ ] Add validation messages
  - [ ] Add navigation buttons (Back, Next)
  - [ ] Make responsive
- [ ] Create `event-step-one.component.scss`
  - [ ] Style form layout
  - [ ] Style input fields
  - [ ] Style image upload area
  - [ ] Add responsive styles
  - [ ] Match design system
- [ ] Test component:
  - [ ] Test form validation
  - [ ] Test image upload
  - [ ] Test navigation
  - [ ] Test edit mode loading

### 6.2 Event Step Two Component
- [ ] Create `event-step-two` component folder structure
- [ ] Create `event-step-two.component.ts`
  - [ ] Implement `OnInit` lifecycle
  - [ ] Load data from sessionStorage
  - [ ] Implement QR design customization (same as other QR types)
  - [ ] Implement `loadExistingDesign` for edit mode
  - [ ] Implement `onNext` method to save QR code
  - [ ] Implement `onBack` method
  - [ ] Integrate with QR code generation
  - [ ] Handle image capture for QR code
- [ ] Create `event-step-two.component.html`
  - [ ] Add QR design customization UI
  - [ ] Add QR preview component
  - [ ] Add navigation buttons
- [ ] Create `event-step-two.component.scss`
  - [ ] Style customization UI
  - [ ] Add responsive styles
- [ ] Test component:
  - [ ] Test design customization
  - [ ] Test QR generation
  - [ ] Test save functionality

### 6.3 Routing Updates
- [ ] Add routes to `app-routing.module.ts`:
  - [ ] `/qr-codes/type/event` → EventStepOneComponent
  - [ ] `/qr-codes/type/event/customize` → EventStepTwoComponent
  - [ ] `/qr-codes/edit/event/:id` → EventStepOneComponent
  - [ ] `/qr-codes/edit/event/:id/customize` → EventStepTwoComponent
- [ ] Test routing

### 6.4 QR Type Selection Page
- [ ] Update `qr-codes-type.component.ts`
  - [ ] Add Event QR to `qrCodesType` array
  - [ ] Add icon, image, colors
  - [ ] Add button link
- [ ] Update `qr-codes-type.component.html` (if needed)
- [ ] Add translation keys for Event QR:
  - [ ] English (`en.json`)
  - [ ] Myanmar (`mm.json`)
- [ ] Test QR type selection

### 6.5 QR List Integration
- [ ] Update `qr-codes.component.ts`
  - [ ] Add Event QR to type mapping
  - [ ] Add edit route for Event QR
  - [ ] Handle Event QR in list display
- [ ] Test QR list with Event QR

---

## Phase 7: Frontend - Viewer Component 👁️

### 7.1 Event Viewer Component
- [ ] Create `event-viewer` component folder structure
- [ ] Create `event-viewer.component.ts`
  - [ ] Implement `OnInit` lifecycle
  - [ ] Get QR code ID from route params
  - [ ] Add properties:
    - [ ] `qrCodeId: string`
    - [ ] `eventData: any`
    - [ ] `isRegistered: boolean`
    - [ ] `registrationData: any`
    - [ ] `showRegistrationForm: boolean`
    - [ ] `loading: boolean`
    - [ ] `error: string | null`
  - [ ] Implement `loadEventData` method
    - [ ] Call `getQRDetailsPublic` API
    - [ ] Parse field values into event data
    - [ ] Handle errors
  - [ ] Implement `checkRegistrationStatus` method
    - [ ] Get email from localStorage
    - [ ] Call `checkEventRegistration` API
    - [ ] Update UI state based on result
  - [ ] Implement `submitRegistration` method
    - [ ] Validate form
    - [ ] Get IP address
    - [ ] Call `registerForEvent` API
    - [ ] Save email to localStorage
    - [ ] Update UI state
    - [ ] Show success message
  - [ ] Implement `getIPAddress` helper method
  - [ ] Implement form validation
  - [ ] Add error handling
- [ ] Create `event-viewer.component.html`
  - [ ] Add loading state
  - [ ] Add error state
  - [ ] Add event details section:
    - [ ] Event title
    - [ ] Event description
    - [ ] Event date/time
    - [ ] Event location
    - [ ] Event logo
  - [ ] Add conditional rendering:
    - [ ] Show registration form if `!isRegistered`
    - [ ] Show "Registration Completed" if `isRegistered`
  - [ ] Add registration form:
    - [ ] Email input (required)
    - [ ] Full Name input (required)
    - [ ] Phone Number input (optional)
    - [ ] Submit button
    - [ ] Validation messages
  - [ ] Add registration success message:
    - [ ] Registration date
    - [ ] Email confirmation
    - [ ] Thank you message
  - [ ] Make responsive
  - [ ] Add mobile-friendly design
- [ ] Create `event-viewer.component.scss`
  - [ ] Style event details section
  - [ ] Style registration form
  - [ ] Style success message
  - [ ] Add responsive styles
  - [ ] Match design system
  - [ ] Add animations/transitions
- [ ] Test component:
  - [ ] Test loading event data
  - [ ] Test registration flow
  - [ ] Test duplicate registration prevention
  - [ ] Test re-scanning (already registered)
  - [ ] Test error handling
  - [ ] Test responsive design

### 7.2 Registration Form Component (Optional - if separate component)
- [ ] Create reusable registration form component (if needed)
- [ ] Add form validation
- [ ] Add custom field support (if implemented)
- [ ] Test component

---

## Phase 8: Frontend - Edit Mode ✏️

### 8.1 Edit Mode Integration
- [ ] Update `qr-codes.component.ts`
  - [ ] Add Event QR to edit route mapping
  - [ ] Handle Event QR in `onEdit` method
- [ ] Update `event-step-one.component.ts`
  - [ ] Implement edit mode detection
  - [ ] Load existing event data
  - [ ] Populate form fields
  - [ ] Handle image paths (logo)
- [ ] Update `event-step-two.component.ts`
  - [ ] Load existing design
  - [ ] Handle edit mode in save
- [ ] Test edit flow:
  - [ ] Test loading existing data
  - [ ] Test updating event details
  - [ ] Test updating design
  - [ ] Test saving changes

---

## Phase 9: Frontend - Registration Management 📊

### 9.1 Registration List Component (Optional)
- [ ] Create registration list component for QR owners
- [ ] Display registrations in table format
- [ ] Add sorting functionality
- [ ] Add search/filter functionality
- [ ] Add export to CSV functionality
- [ ] Add pagination (if many registrations)
- [ ] Test component

### 9.2 Analytics Integration
- [ ] Update analytics component to include Event QR registrations
- [ ] Add registration count to QR code details
- [ ] Add registration statistics
- [ ] Test analytics

---

## Phase 10: Testing & Quality Assurance 🧪

### 10.1 Unit Tests
- [ ] Write unit tests for backend controller methods
- [ ] Write unit tests for frontend service methods
- [ ] Write unit tests for component logic
- [ ] Achieve minimum 80% code coverage

### 10.2 Integration Tests
- [ ] Test complete registration flow
- [ ] Test edit flow
- [ ] Test viewer flow
- [ ] Test error scenarios

### 10.3 Manual Testing
- [ ] Test Event QR creation
- [ ] Test Event QR scanning
- [ ] Test registration (first time)
- [ ] Test re-scanning (already registered)
- [ ] Test duplicate registration prevention
- [ ] Test max capacity enforcement
- [ ] Test expired event handling
- [ ] Test edit functionality
- [ ] Test on different devices (mobile, tablet, desktop)
- [ ] Test on different browsers
- [ ] Test responsive design

### 10.4 Edge Cases
- [ ] Test with very long event title/description
- [ ] Test with special characters in form fields
- [ ] Test with invalid email formats
- [ ] Test with max registrations = 0
- [ ] Test with no max registrations set
- [ ] Test registration when event is full
- [ ] Test registration after event expired
- [ ] Test with cleared localStorage
- [ ] Test with multiple users registering simultaneously

### 10.5 Performance Testing
- [ ] Test with many registrations (100+)
- [ ] Test page load times
- [ ] Test API response times
- [ ] Optimize database queries if needed

---

## Phase 11: Security & Validation 🔒

### 11.1 Input Validation
- [ ] Validate email format (frontend)
- [ ] Validate email format (backend)
- [ ] Sanitize user inputs
- [ ] Validate date/time format
- [ ] Validate phone number format (if applicable)
- [ ] Prevent XSS attacks
- [ ] Prevent SQL injection (EF Core handles this)

### 11.2 Security Measures
- [ ] Implement rate limiting for registration endpoint
- [ ] Add CAPTCHA (optional, future enhancement)
- [ ] Verify QR code ownership for registration list
- [ ] Add request logging
- [ ] Add error logging (without exposing sensitive data)

### 11.3 Data Privacy
- [ ] Ensure GDPR compliance (if applicable)
- [ ] Add data retention policy
- [ ] Add user data deletion capability (future)

---

## Phase 12: Documentation & Deployment 📚

### 12.1 Code Documentation
- [ ] Add XML comments to all backend methods
- [ ] Add JSDoc comments to frontend methods
- [ ] Document API endpoints
- [ ] Document component props and methods

### 12.2 User Documentation
- [ ] Create user guide for creating Event QR
- [ ] Create user guide for viewing registrations
- [ ] Add help tooltips in UI
- [ ] Create FAQ section

### 12.3 Database Documentation
- [ ] Document new table structure
- [ ] Document relationships
- [ ] Document indexes
- [ ] Create ER diagram update

### 12.4 Deployment
- [ ] Create database migration script for production
- [ ] Test migration on staging environment
- [ ] Deploy backend changes
- [ ] Deploy frontend changes
- [ ] Verify deployment
- [ ] Monitor for errors

---

## Phase 13: Future Enhancements (Optional) 🚀

### 13.1 Email Notifications
- [ ] Send confirmation email to registrant
- [ ] Send notification to event organizer
- [ ] Send reminder emails before event

### 13.2 Advanced Features
- [ ] Custom registration fields
- [ ] Payment integration for paid events
- [ ] Waitlist functionality
- [ ] QR code check-in at event
- [ ] Export registrations to Excel/CSV
- [ ] Registration analytics dashboard
- [ ] Email verification for registrations

### 13.3 UI/UX Improvements
- [ ] Add animations
- [ ] Improve mobile experience
- [ ] Add dark mode support
- [ ] Add accessibility features

---

## Progress Tracking

### Overall Progress: 0% Complete

**Phase Completion:**
- Phase 1: Database Setup - 0/15 tasks
- Phase 2: Backend DTOs - 0/6 tasks
- Phase 3: Backend Controller - 0/15 tasks
- Phase 4: Backend API - 0/7 tasks
- Phase 5: Frontend Service - 0/6 tasks
- Phase 6: Frontend Creation - 0/25 tasks
- Phase 7: Frontend Viewer - 0/20 tasks
- Phase 8: Frontend Edit - 0/5 tasks
- Phase 9: Registration Management - 0/5 tasks
- Phase 10: Testing - 0/20 tasks
- Phase 11: Security - 0/10 tasks
- Phase 12: Documentation - 0/12 tasks
- Phase 13: Future Enhancements - 0/10 tasks

**Total Tasks: 156**

---

## Notes

- Mark tasks as complete by changing `[ ]` to `[x]`
- Add notes or blockers next to tasks if needed
- Update progress percentages as you complete phases
- Prioritize Phases 1-7 for initial release
- Phases 8-13 can be done incrementally

---

## Quick Start Checklist

If you want to get started quickly, focus on these essential tasks first:

1. ✅ Create database table
2. ✅ Add QR type and fields
3. ✅ Create backend model and DTOs
4. ✅ Implement registration API
5. ✅ Create frontend service methods
6. ✅ Create event-step-one component
7. ✅ Create event-step-two component
8. ✅ Create event-viewer component
9. ✅ Test basic flow
10. ✅ Deploy and verify

---

**Last Updated:** [Date]
**Status:** Planning Phase
**Assigned To:** [Team Member/Your Name]

