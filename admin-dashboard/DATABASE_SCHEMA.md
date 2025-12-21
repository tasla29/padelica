# Rez Padel - Database Schema Documentation

## Overview
Rez Padel uses Supabase (PostgreSQL) for backend. Single-tenant architecture (one database per padel center).

---

## Tables

### 1. users
Stores user profile information. Extends Supabase Auth for additional user data.

**Columns:**
- `id` (UUID, PRIMARY KEY): Links to `auth.users(id)`. User's unique identifier from Supabase Auth
- `first_name` (TEXT, NOT NULL): User's first name (e.g., "Miloš")
- `last_name` (TEXT, NOT NULL): User's last name (e.g., "Petrović")
- `phone` (TEXT, NOT NULL): User's phone number in format "+381 XX XXX XXXX"
- `role` (TEXT, NOT NULL, DEFAULT 'player'): User's permission level
  - `player`: Regular user, can book courts and manage own bookings
  - `staff`: Center employee, can manage all bookings and courts
  - `admin`: Full system access, can manage settings and pricing
- `created_at` (TIMESTAMPTZ, NOT NULL): When user account was created
- `updated_at` (TIMESTAMPTZ, NOT NULL): Last time profile was updated (auto-updated by trigger)

**Relationships:**
- Referenced by: `bookings.user_id`
- Links to: `auth.users` (Supabase Auth table)

**RLS Policies:**
- Users can view/update their own profile
- Staff/admin can view all users
- Only admin can change user roles

**Example:**
```json
{
  "id": "abc-123-xyz",
  "first_name": "Miloš",
  "last_name": "Petrović",
  "phone": "+381 64 123 4567",
  "role": "player",
  "created_at": "2024-12-01T10:30:00Z",
  "updated_at": "2024-12-01T10:30:00Z"
}
```

---

### 2. courts
Physical padel courts available for booking.

**Columns:**
- `id` (UUID, PRIMARY KEY): Unique court identifier
- `name` (TEXT, NOT NULL): Display name (e.g., "Teren 1", "VIP Teren")
- `type` (TEXT, NOT NULL): Court type, either 'indoor' or 'outdoor'
- `size` (TEXT, NOT NULL, DEFAULT 'double'): Court size, either 'single' or 'double'
- `status` (TEXT, NOT NULL, DEFAULT 'active'): Court availability status
  - `active`: Available for booking
  - `maintenance`: Under maintenance, not bookable
  - `unavailable`: Temporarily unavailable
- `description` (TEXT, NULLABLE): Optional details about the court
- `image_url` (TEXT, NULLABLE): URL to court photo in Supabase Storage
- `display_order` (INTEGER, NOT NULL, DEFAULT 0): Sort order in the app (lower = shown first)
- `created_at` (TIMESTAMPTZ, NOT NULL): When court was added
- `updated_at` (TIMESTAMPTZ, NOT NULL): Last modification timestamp

**Relationships:**
- Referenced by: `bookings.court_id`

**RLS Policies:**
- Everyone can view active courts
- Only staff/admin can manage courts

**Example:**
```json
{
  "id": "def-456-uvw",
  "name": "Teren 1",
  "type": "indoor",
  "size": "double",
  "status": "active",
  "description": "Glavni teren sa LED osvetljenjem",
  "image_url": "https://...storage.../court1.jpg",
  "display_order": 1
}
```

---

### 3. bookings
Court reservations made by users. Core business table.

**Columns:**
- `id` (UUID, PRIMARY KEY): Unique booking identifier
- `court_id` (UUID, NOT NULL, FK → courts.id): Which court is booked
- `user_id` (UUID, NOT NULL, FK → users.id): Who made the booking
- `booking_date` (DATE, NOT NULL): Date of the booking (e.g., "2024-12-15")
- `start_time` (TIME, NOT NULL): Start time (e.g., "18:00:00")
- `end_time` (TIME, NOT NULL): End time (e.g., "19:30:00")
- `duration_minutes` (INTEGER, NOT NULL): Booking duration in minutes (60, 90, 120)
- `status` (TEXT, NOT NULL, DEFAULT 'confirmed'): Booking lifecycle status
  - `pending`: Awaiting confirmation (future use)
  - `confirmed`: Active booking
  - `cancelled`: User or staff cancelled
  - `completed`: Booking finished (past end_time)
  - `no_show`: User didn't show up
- `payment_method` (TEXT, NOT NULL): How user will pay
  - `online`: Pre-paid online
  - `onsite`: Pay at the center
- `payment_status` (TEXT, NOT NULL, DEFAULT 'unpaid'): Payment tracking
  - `unpaid`: Not yet paid
  - `paid`: Payment completed
  - `refunded`: Money returned to user
- `total_price` (NUMERIC(10,2), NOT NULL): Total amount in RSD (court + rackets)
- `racket_rental_count` (INTEGER, DEFAULT 0): Number of rackets rented (0-4)
- `racket_rental_price` (NUMERIC(10,2), DEFAULT 0): Total racket rental cost
- `player_name` (TEXT, NULLABLE): Name if booking for someone else
- `player_phone` (TEXT, NULLABLE): Phone if booking for someone else
- `notes` (TEXT, NULLABLE): Special requests or comments
- `cancelled_at` (TIMESTAMPTZ, NULLABLE): When booking was cancelled
- `cancellation_reason` (TEXT, NULLABLE): Why booking was cancelled
- `created_at` (TIMESTAMPTZ, NOT NULL): When booking was made
- `updated_at` (TIMESTAMPTZ, NOT NULL): Last modification

**Business Rules:**
- Users can't book overlapping times on same court
- Users can't book if court status is 'maintenance' or 'unavailable'
- Bookings start every 30 minutes (09:00, 09:30, 10:00...)
- Players can cancel only 24+ hours before start time
- Staff can cancel anytime

**Relationships:**
- Links to: `courts.id`, `users.id`

**RLS Policies:**
- Users can view their own bookings
- Users can create bookings
- Users can cancel their bookings (24h+ before)
- Staff can view/manage all bookings

**Example:**
```json
{
  "id": "ghi-789-rst",
  "court_id": "def-456-uvw",
  "user_id": "abc-123-xyz",
  "booking_date": "2024-12-15",
  "start_time": "18:00:00",
  "end_time": "19:30:00",
  "duration_minutes": 90,
  "status": "confirmed",
  "payment_method": "onsite",
  "payment_status": "unpaid",
  "total_price": 6500,
  "racket_rental_count": 2,
  "racket_rental_price": 1000,
  "notes": "Molim zadnji teren ako je moguće"
}
```

---

### 4. pricing
Pricing rules based on day type, time, and duration.

**Columns:**
- `id` (UUID, PRIMARY KEY): Unique pricing rule identifier
- `name` (TEXT, NOT NULL): Display name (e.g., "1.5 sat - Radni dan - 09-15h")
- `day_type` (TEXT, NOT NULL): Day category
  - `weekday`: Monday-Friday (radni dan)
  - `weekend`: Saturday-Sunday (vikend)
- `duration_hours` (NUMERIC(3,1), NOT NULL): Booking duration (1.0, 1.5, 2.0 hours)
- `start_time` (TIME, NOT NULL): Time period start (e.g., "09:00:00")
- `end_time` (TIME, NOT NULL): Time period end (e.g., "15:00:00")
- `price` (NUMERIC(10,2), NOT NULL): Price in RSD for this configuration
- `is_active` (BOOLEAN, NOT NULL, DEFAULT true): Whether this rule is currently used
- `display_order` (INTEGER, NOT NULL, DEFAULT 0): Sort order for displaying prices
- `created_at` (TIMESTAMPTZ, NOT NULL): When rule was created
- `updated_at` (TIMESTAMPTZ, NOT NULL): Last modification

**Price Calculation Logic:**
1. Determine day_type from booking_date (weekday/weekend)
2. Match booking duration (60min = 1.0, 90min = 1.5, 120min = 2.0)
3. Check if start_time falls within pricing time range
4. Return matching price
5. Add racket_rental_price if applicable

**RLS Policies:**
- Everyone can view active pricing
- Only admin can modify pricing

**Example:**
```json
{
  "id": "jkl-012-opq",
  "name": "1.5 sat - Radni dan - 15-24h",
  "day_type": "weekday",
  "duration_hours": 1.5,
  "start_time": "15:00:00",
  "end_time": "24:00:00",
  "price": 5500,
  "is_active": true,
  "display_order": 5
}
```

---

### 5. center_settings
Global configuration for the padel center. Single row table.

**Columns:**
- `id` (UUID, PRIMARY KEY): Settings record ID
- `center_name` (TEXT, NOT NULL, DEFAULT 'Padel Space'): Center display name
- `address` (TEXT, NULLABLE): Physical address
- `city` (TEXT, DEFAULT 'Beograd'): City name
- `phone` (TEXT, NULLABLE): Contact phone number
- `email` (TEXT, NULLABLE): Contact email
- `logo_url` (TEXT, NULLABLE): URL to center logo
- `cover_image_url` (TEXT, NULLABLE): URL to hero/cover image
- `opening_time` (TIME, NOT NULL, DEFAULT '09:00:00'): Daily opening time
- `closing_time` (TIME, NOT NULL, DEFAULT '24:00:00'): Daily closing time
- `time_slot_interval` (INTEGER, NOT NULL, DEFAULT 30): Booking slot interval in minutes
- `min_booking_duration` (INTEGER, NOT NULL, DEFAULT 60): Minimum booking length (minutes)
- `max_booking_duration` (INTEGER, NOT NULL, DEFAULT 120): Maximum booking length (minutes)
- `advance_booking_days` (INTEGER, NOT NULL, DEFAULT 30): How many days ahead users can book
- `player_cancellation_hours` (INTEGER, NOT NULL, DEFAULT 24): Hours before booking players can cancel
- `racket_rental_price` (NUMERIC(10,2), NOT NULL, DEFAULT 500): Price per racket in RSD
- `currency` (TEXT, NOT NULL, DEFAULT 'RSD'): Currency code
- `timezone` (TEXT, NOT NULL, DEFAULT 'Europe/Belgrade'): Timezone identifier
- `terms_and_conditions` (TEXT, NULLABLE): T&C text
- `created_at` (TIMESTAMPTZ, NOT NULL): When settings were created
- `updated_at` (TIMESTAMPTZ, NOT NULL): Last modification

**Usage:**
- Fetch once at app startup
- Cache in app state
- Update via admin panel

**RLS Policies:**
- Everyone can read settings
- Only admin can modify settings

**Example:**
```json
{
  "center_name": "Padel Space Centar",
  "city": "Beograd",
  "opening_time": "09:00:00",
  "closing_time": "24:00:00",
  "time_slot_interval": 30,
  "advance_booking_days": 30,
  "player_cancellation_hours": 24,
  "racket_rental_price": 500
}
```

---

### 6. equipment_rentals
Rental items inventory (currently just rackets).

**Columns:**
- `id` (UUID, PRIMARY KEY): Equipment item identifier
- `name` (TEXT, NOT NULL, DEFAULT 'Reket'): Item display name
- `price` (NUMERIC(10,2), NOT NULL, DEFAULT 500): Rental price in RSD
- `available_quantity` (INTEGER, NOT NULL, DEFAULT 10): Stock quantity
- `is_active` (BOOLEAN, NOT NULL, DEFAULT true): Whether item is available
- `created_at` (TIMESTAMPTZ, NOT NULL): When item was added
- `updated_at` (TIMESTAMPTZ, NOT NULL): Last modification

**Usage:**
- Display available equipment during booking
- Track inventory (optional - can skip for MVP)
- Future: Add balls, bags, etc.

**RLS Policies:**
- Everyone can view active equipment
- Only admin can manage equipment

**Example:**
```json
{
  "id": "mno-345-tuv",
  "name": "Reket",
  "price": 500,
  "available_quantity": 20,
  "is_active": true
}
```

---

## Helper Functions

### is_slot_available()
Checks if a court time slot is available for booking.

**Parameters:**
- `p_court_id` (UUID): Court to check
- `p_booking_date` (DATE): Date to check
- `p_start_time` (TIME): Slot start time
- `p_end_time` (TIME): Slot end time
- `p_exclude_booking_id` (UUID, OPTIONAL): Booking ID to exclude (for updates)

**Returns:** BOOLEAN (true = available, false = occupied)

**Usage:**
```sql
SELECT is_slot_available(
  'court-uuid',
  '2024-12-15',
  '18:00:00',
  '19:30:00'
);
```

### get_day_type()
Determines if a date is a weekday or weekend.

**Parameters:**
- `p_date` (DATE): Date to check

**Returns:** TEXT ('weekday' or 'weekend')

**Usage:**
```sql
SELECT get_day_type('2024-12-15'); -- Returns 'weekend' if Saturday/Sunday
```

---

## Common Queries

### Get available courts for a date
```sql
SELECT * FROM courts 
WHERE status = 'active'
ORDER BY display_order;
```

### Get user's upcoming bookings
```sql
SELECT b.*, c.name as court_name
FROM bookings b
JOIN courts c ON b.court_id = c.id
WHERE b.user_id = 'user-uuid'
  AND b.status = 'confirmed'
  AND b.booking_date >= CURRENT_DATE
ORDER BY b.booking_date, b.start_time;
```

### Calculate price for a booking
```sql
SELECT price 
FROM pricing
WHERE day_type = get_day_type('2024-12-15')
  AND duration_hours = 1.5
  AND '18:00:00' >= start_time 
  AND '18:00:00' < end_time
  AND is_active = true;
```

### Check court availability
```sql
SELECT is_slot_available(
  'court-uuid',
  '2024-12-15',
  '18:00:00',
  '19:30:00'
);
```

---

## Important Notes

### Supabase Auth Integration
- User authentication handled by Supabase Auth (`auth.users` table)
- Our `users` table extends auth with profile data
- Always use `auth.uid()` in RLS policies to get current user ID

### Row Level Security (RLS)
- All tables have RLS enabled
- Policies enforce: users see only their data, staff see all
- Test RLS by signing in as different user roles

### Timestamps
- All timestamps use `TIMESTAMPTZ` (timezone-aware)
- Stored in UTC, converted to user timezone in app
- `updated_at` auto-updates via database trigger

### Constraints
- Foreign keys use `ON DELETE RESTRICT` to prevent orphaned records
- Check constraints validate enum values (status, role, type)
- Time validation: `end_time > start_time`

### Indexes
- Composite index on `(court_id, booking_date)` for fast availability checks
- Index on `booking_date` for calendar queries
- Index on `status` for filtering active/cancelled bookings