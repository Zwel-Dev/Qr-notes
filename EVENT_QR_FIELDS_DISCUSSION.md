# Event QR Fields Discussion

## Overview
This document discusses which fields should be included in:
1. **Event QR Creation Form** (when admin/user creates the event)
2. **Registration Form** (when users register for the event)

---

## Part 1: Event QR Creation Form Fields

### 🎯 Essential Fields (Must Have)

#### 1. **Event Title** ⭐ Required
- **Field Name:** `eventTitle`
- **Type:** Text input
- **Validation:** Required, max 200 characters
- **Purpose:** Main event name displayed prominently
- **Example:** "Tech Conference 2025", "Annual Company Meeting"
- **Display:** Large, prominent heading in viewer

#### 2. **Event Date & Time** ⭐ Required
- **Field Name:** `eventDateTime`
- **Type:** DateTime picker (date + time)
- **Validation:** Required, must be future date
- **Purpose:** When the event takes place
- **Format:** 
  - Date: YYYY-MM-DD
  - Time: HH:MM (24-hour or 12-hour with AM/PM)
  - Timezone: Consider adding timezone support
- **Display:** Formatted nicely (e.g., "December 15, 2025 at 10:00 AM")

#### 3. **QR Code Name** ⭐ Required
- **Field Name:** `qrName` (already exists in QRCode table)
- **Type:** Text input
- **Purpose:** Internal name for the QR code (for admin to identify)
- **Example:** "Tech Conference QR - Main Entrance"

---

### 📝 Recommended Fields (Should Have)

#### 4. **Event Description** 
- **Field Name:** `eventDescription`
- **Type:** Textarea (multi-line)
- **Validation:** Optional, max 2000 characters
- **Purpose:** Detailed information about the event
- **Features:**
  - Rich text editor? (Simple formatting: bold, italic, lists)
  - Or plain text with line breaks
- **Display:** Below title, formatted nicely

#### 5. **Event Location**
- **Field Name:** `eventLocation`
- **Type:** Text input or Address picker
- **Validation:** Optional
- **Purpose:** Where the event takes place
- **Options:**
  - **Simple:** Just text input (e.g., "Convention Center, Yangon")
  - **Advanced:** Address fields (Street, City, State, Country, Postal Code)
  - **Map Integration:** Google Maps picker (future enhancement)
- **Display:** With location icon, clickable for map (if address provided)

#### 6. **Event Logo/Banner Image**
- **Field Name:** `eventLogo`
- **Type:** Image upload
- **Validation:** Optional, max 5MB, formats: JPG, PNG, WebP
- **Purpose:** Visual branding for the event
- **Features:**
  - Image preview
  - Crop/resize tool (recommended: 1200x600px for banner, 200x200px for logo)
  - Multiple images? (Logo + Banner)
- **Display:** 
  - Logo: Top of event page, small (100x100px)
  - Banner: Full width header image (optional)

#### 7. **Maximum Registrations**
- **Field Name:** `maxRegistrations`
- **Type:** Number input
- **Validation:** Optional, must be positive integer if provided
- **Purpose:** Limit number of registrations
- **Features:**
  - Leave empty = unlimited
  - Show current count vs max (e.g., "45/100 registered")
  - Auto-disable form when full
- **Display:** In event details, registration form shows availability

---

### 🎨 Optional/Advanced Fields (Nice to Have)

#### 8. **Event Category/Type**
- **Field Name:** `eventCategory`
- **Type:** Dropdown or tags
- **Options:** Conference, Workshop, Seminar, Networking, Social, etc.
- **Purpose:** Categorization and filtering
- **Display:** Badge/tag on event card

#### 9. **Event End Date & Time**
- **Field Name:** `eventEndDateTime`
- **Type:** DateTime picker
- **Purpose:** For multi-day events or events with end time
- **Display:** "December 15-17, 2025" or "10:00 AM - 5:00 PM"

#### 10. **Event Organizer Information**
- **Field Name:** `organizerName`, `organizerEmail`, `organizerPhone`
- **Type:** Text inputs
- **Purpose:** Contact information for event organizer
- **Display:** "Organized by: [Name]" with contact info

#### 11. **Event Website/Registration Link**
- **Field Name:** `eventWebsite`
- **Type:** URL input
- **Purpose:** Link to full event page or external registration
- **Display:** "Learn more" button

#### 12. **Event Tags/Keywords**
- **Field Name:** `eventTags`
- **Type:** Multi-select or comma-separated
- **Purpose:** For search and categorization
- **Example:** "Technology", "Business", "Networking"

#### 13. **Registration Deadline**
- **Field Name:** `registrationDeadline`
- **Type:** DateTime picker
- **Purpose:** When registration closes (can be before event date)
- **Features:** Auto-disable form after deadline

#### 14. **Event Cost/Price**
- **Field Name:** `eventPrice`, `currency`
- **Type:** Number + currency dropdown
- **Purpose:** For paid events
- **Display:** "Free" or "$50.00" or "MMK 75,000"
- **Note:** Payment integration would be separate feature

#### 15. **Custom Registration Fields Configuration**
- **Field Name:** `registrationFields`
- **Type:** JSON configuration
- **Purpose:** Allow event creator to add custom fields to registration form
- **Structure:**
  ```json
  {
    "fields": [
      {
        "name": "company",
        "label": "Company Name",
        "type": "text",
        "required": false
      },
      {
        "name": "dietary",
        "label": "Dietary Requirements",
        "type": "select",
        "options": ["None", "Vegetarian", "Vegan", "Halal", "Kosher"],
        "required": false
      }
    ]
  }
  ```

#### 16. **Welcome Screen Image**
- **Field Name:** `welcomeScreenImage`
- **Type:** Image upload
- **Purpose:** Full-screen image shown before event details (like vCard)
- **Display:** Similar to vCard welcome screen

#### 17. **Event Color Scheme**
- **Field Name:** `primaryColor`, `secondaryColor`
- **Type:** Color picker
- **Purpose:** Customize event page colors
- **Display:** Applied to event viewer UI

#### 18. **Terms & Conditions**
- **Field Name:** `termsAndConditions`
- **Type:** Textarea or rich text
- **Purpose:** Terms users must accept during registration
- **Display:** Checkbox in registration form

#### 19. **Privacy Policy Link**
- **Field Name:** `privacyPolicyUrl`
- **Type:** URL input
- **Purpose:** Link to privacy policy
- **Display:** Link in registration form footer

---

## Part 2: Registration Form Fields

### 🎯 Essential Fields (Must Have)

#### 1. **Email Address** ⭐ Required
- **Field Name:** `email`
- **Type:** Email input
- **Validation:** 
  - Required
  - Valid email format
  - Unique per event (enforced by backend)
- **Purpose:** 
  - Primary identifier for registration
  - Used to check if already registered
  - For confirmation emails (future)
- **Display:** 
  - Large, clear input
  - Email format validation message
  - "Already registered" message if duplicate

#### 2. **Full Name** ⭐ Required
- **Field Name:** `fullName`
- **Type:** Text input
- **Validation:** 
  - Required
  - Min 2 characters, max 100 characters
  - Allow spaces, hyphens, apostrophes
- **Purpose:** 
  - Attendee identification
  - Name tags, check-in lists
- **Display:** 
  - Single field (or split into First/Last if preferred)
  - Clear label

---

### 📝 Recommended Fields (Should Have)

#### 3. **Phone Number**
- **Field Name:** `phoneNumber`
- **Type:** Tel input
- **Validation:** 
  - Optional
  - Format validation (international format)
  - Consider country code picker
- **Purpose:** 
  - Contact for event updates
  - Emergency contact
  - SMS reminders (future)
- **Display:** 
  - With country code selector
  - Format: +959 123 456 789

#### 4. **Company/Organization**
- **Field Name:** `company`
- **Type:** Text input
- **Validation:** Optional, max 100 characters
- **Purpose:** 
  - Networking information
  - Business events
- **Display:** Below name field

---

### 🎨 Optional/Advanced Fields (Nice to Have)

#### 5. **Job Title/Position**
- **Field Name:** `jobTitle`
- **Type:** Text input
- **Purpose:** Professional networking
- **Display:** With company field

#### 6. **Dietary Requirements**
- **Field Name:** `dietaryRequirements`
- **Type:** Multi-select or checkboxes
- **Options:** None, Vegetarian, Vegan, Halal, Kosher, Gluten-free, Other
- **Purpose:** Event catering planning
- **Display:** If event includes food

#### 7. **Accessibility Requirements**
- **Field Name:** `accessibilityNeeds`
- **Type:** Textarea or multi-select
- **Options:** Wheelchair access, Sign language interpreter, etc.
- **Purpose:** Ensure event is accessible
- **Display:** If applicable

#### 8. **How did you hear about this event?**
- **Field Name:** `referralSource`
- **Type:** Dropdown or radio buttons
- **Options:** Social Media, Email, Friend, Website, Other
- **Purpose:** Marketing analytics
- **Display:** Optional field

#### 9. **Additional Comments/Questions**
- **Field Name:** `comments`
- **Type:** Textarea
- **Purpose:** Allow registrants to ask questions or provide info
- **Display:** Optional, expandable section

#### 10. **Emergency Contact**
- **Field Name:** `emergencyContactName`, `emergencyContactPhone`
- **Type:** Text inputs
- **Purpose:** Safety for large events
- **Display:** Collapsible section

#### 11. **T-Shirt Size** (if applicable)
- **Field Name:** `tshirtSize`
- **Type:** Dropdown
- **Options:** XS, S, M, L, XL, XXL
- **Purpose:** Event swag distribution
- **Display:** If event provides t-shirts

#### 12. **Workshop/Session Selection** (for multi-track events)
- **Field Name:** `selectedSessions`
- **Type:** Multi-select checkboxes
- **Purpose:** Track which sessions attendee wants
- **Display:** If event has multiple sessions

---

## Recommended Field Sets by Event Type

### 🎓 Conference/Seminar
**Creation Form:**
- Title, Description, Date/Time, Location, Logo, Max Registrations
- Category, Organizer Info, Website, Tags

**Registration Form:**
- Email, Full Name, Phone, Company, Job Title
- Dietary Requirements, Accessibility Needs
- Session Selection (if multi-track)

### 🍽️ Networking Event
**Creation Form:**
- Title, Description, Date/Time, Location, Logo
- Organizer Info

**Registration Form:**
- Email, Full Name, Phone, Company, Job Title
- How did you hear about us?

### 🎉 Social Event
**Creation Form:**
- Title, Description, Date/Time, Location, Logo, Max Registrations
- Cost (if paid)

**Registration Form:**
- Email, Full Name, Phone
- Dietary Requirements
- Emergency Contact

### 🏋️ Workshop/Training
**Creation Form:**
- Title, Description, Date/Time, Location, Logo, Max Registrations
- End Date/Time, Organizer Info

**Registration Form:**
- Email, Full Name, Phone, Company
- Experience Level, Dietary Requirements

---

## Field Configuration Options

### Option 1: Fixed Fields (Simplest)
- **Pros:** Easy to implement, consistent UX
- **Cons:** Less flexible, may have unused fields
- **Recommendation:** Start with this for MVP

### Option 2: Configurable Fields (Recommended)
- **Pros:** Flexible, event creator chooses what to collect
- **Cons:** More complex implementation
- **Implementation:** 
  - Event creator can enable/disable optional fields
  - Can add custom fields (text, dropdown, checkbox)
  - Stored in `registrationFields` JSON

### Option 3: Templates
- **Pros:** Best of both worlds
- **Cons:** More initial setup
- **Implementation:**
  - Pre-defined templates (Conference, Networking, Social, etc.)
  - Each template has recommended fields
  - Event creator can customize

---

## My Recommendations

### For MVP (Minimum Viable Product):

**Event Creation Form:**
1. ✅ Event Title (required)
2. ✅ Event Date & Time (required)
3. ✅ Event Description (optional)
4. ✅ Event Location (optional)
5. ✅ Event Logo (optional)
6. ✅ Maximum Registrations (optional)
7. ✅ QR Code Name (required - already exists)

**Registration Form:**
1. ✅ Email (required)
2. ✅ Full Name (required)
3. ✅ Phone Number (optional)

### For Full Version:

**Event Creation Form:**
- All MVP fields +
- Event End Date/Time
- Event Category
- Organizer Information
- Event Website
- Registration Deadline
- Custom Registration Fields Configuration
- Welcome Screen Image
- Color Scheme

**Registration Form:**
- All MVP fields +
- Company/Organization
- Job Title
- Dietary Requirements (if food provided)
- Custom fields (based on event creator's configuration)

---

## Implementation Priority

### Phase 1: Core Fields (MVP)
- Essential fields only
- Get basic functionality working

### Phase 2: Enhanced Fields
- Add recommended fields
- Improve UX

### Phase 3: Advanced Features
- Custom fields configuration
- Templates
- Advanced options

---

## Questions to Consider

1. **Do we need custom registration fields from the start?**
   - **My suggestion:** No, add in Phase 2 or 3
   - Start with fixed fields, add customization later

2. **Should we support multiple timezones?**
   - **My suggestion:** Phase 2
   - Start with local timezone, add timezone support later

3. **Do we need rich text editor for description?**
   - **My suggestion:** Phase 2
   - Start with plain text, add formatting later

4. **Should registration form fields be configurable?**
   - **My suggestion:** Phase 2
   - Start with fixed fields, add configuration later

5. **Do we need event categories/tags?**
   - **My suggestion:** Phase 2
   - Not essential for MVP

---

## Database Field Mapping

### Event Creation Fields → QRTypeFieldValue
```
eventTitle → FieldName: "eventTitle", FieldValue: "Tech Conference 2025"
eventDescription → FieldName: "eventDescription", FieldValue: "Annual..."
eventDateTime → FieldName: "eventDateTime", FieldValue: "2025-12-15T10:00:00"
eventLocation → FieldName: "eventLocation", FieldValue: "Convention Center"
eventLogo → FieldName: "eventLogo", FieldValue: "qr-images/events/logo.png"
maxRegistrations → FieldName: "maxRegistrations", FieldValue: "100"
```

### Registration Fields → QREventRegistration
```
email → Email column
fullName → FullName column
phoneNumber → PhoneNumber column
customFields → AdditionalData column (JSON)
```

---

## UI/UX Considerations

### Event Creation Form:
- **Layout:** Step-by-step or single page with sections?
- **Validation:** Real-time or on submit?
- **Preview:** Show live preview of how event will look?
- **Save Draft:** Allow saving incomplete events?

### Registration Form:
- **Layout:** Single page or multi-step?
- **Progress Indicator:** Show progress if multi-step?
- **Mobile First:** Ensure mobile-friendly design
- **Auto-fill:** Use browser autofill for common fields
- **Validation:** Show errors inline, not just on submit

---

## Final Recommendation Summary

### Start With (MVP):
**Event Creation:**
- Title, Date/Time, Description, Location, Logo, Max Registrations

**Registration:**
- Email, Full Name, Phone

### Add Later (Phase 2):
**Event Creation:**
- End Date/Time, Category, Organizer Info, Custom Registration Fields Config

**Registration:**
- Company, Job Title, Dietary Requirements, Custom Fields

This gives you a solid, working MVP that can be enhanced based on user feedback!

---

**What are your thoughts? Which fields do you think are most important for your use case?**

