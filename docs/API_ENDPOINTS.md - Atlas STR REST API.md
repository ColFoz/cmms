## Base URL

**Local Development:** `http://localhost:8080/api/v1`  
**Production:** `https://your-domain.com/api/v1`

## Authentication

All endpoints require JWT authentication except public health checks.

bash

```bash
# Login to get token
POST /auth/login
{
  "email": "colin@example.com",
  "password": "your-password"
}

# Response
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { ...user object... }
}

# Use token in subsequent requests
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## New Endpoints (To Be Built)

### 1. AI Checklist Generation

#### Generate Checklist from Photo

http

```http
POST /api/v1/checklists/generate
Content-Type: multipart/form-data
Authorization: Bearer {token}

# Form Data
photo: [file] (required)
brand: string (optional - AI will detect if not provided)
model: string (optional - AI will detect if not provided)
appliance_type: string (optional - AI will detect if not provided)
```

**Response:**

json

```json
{
  "template_id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Bosch SMS88TW06G Deep Clean",
  "appliance_type": "dishwasher",
  "brand": "Bosch",
  "model": "SMS88TW06G",
  "estimated_duration_minutes": 90,
  "photos_required": 6,
  "frequency": {
    "type": "months",
    "value": 6
  },
  "steps": [
    {
      "order": 1,
      "title": "Remove spray arm",
      "description": "Twist counterclockwise...",
      "estimated_minutes": 5,
      "requires_photo": true,
      "tools_required": ["soft brush"],
      "safety_warning": null
    },
    // ... more steps
  ],
  "ai_metadata": {
    "confidence": 0.92,
    "model": "claude-sonnet-4-20250514",
    "generated_at": "2025-11-08T10:30:00Z"
  }
}
```

**Error Responses:**

json

```json
// 400 Bad Request - Invalid file
{
  "error": "INVALID_FILE",
  "message": "File must be an image (jpg, png, webp)"
}

// 500 Internal Server Error - AI failed
{
  "error": "AI_GENERATION_FAILED",
  "message": "Could not identify appliance from photo",
  "suggestion": "Try a clearer photo or provide model number manually"
}
```

---

#### Get Checklist Template

http

```http
GET /api/v1/checklists/{template_id}
Authorization: Bearer {token}
```

**Response:**

json

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Bosch SMS88TW06G Deep Clean",
  "description": "6-month service checklist",
  "appliance_type": "dishwasher",
  "brand": "Bosch",
  "model": "SMS88TW06G",
  "source": "ai_generated",
  "steps": [...],
  "photos_required": 6,
  "estimated_duration_minutes": 90,
  "frequency_type": "months",
  "frequency_value": 6,
  "difficulty_level": "easy",
  "times_used": 12,
  "avg_completion_time_minutes": 95,
  "success_rate": 0.98,
  "created_by": "colin-user-id",
  "created_at": "2025-11-01T14:00:00Z",
  "updated_at": "2025-11-08T10:30:00Z"
}
```

---

#### List Checklist Templates

http

```http
GET /api/v1/checklists
Authorization: Bearer {token}

Query Parameters:
- appliance_type: string (filter by type)
- brand: string (filter by brand)
- search: string (full-text search)
- source: string (ai_generated, manual, imported)
- page: integer (default: 0)
- size: integer (default: 20)
- sort: string (default: created_at,desc)
```

**Response:**

json

```json
{
  "content": [
    {
      "id": "...",
      "name": "...",
      "appliance_type": "...",
      // ... other fields
    }
  ],
  "page": 0,
  "size": 20,
  "total_elements": 47,
  "total_pages": 3
}
```

---

#### Assign Checklist to Asset

http

```http
POST /api/v1/assets/{asset_id}/checklists
Authorization: Bearer {token}
Content-Type: application/json

{
  "template_id": "550e8400-e29b-41d4-a716-446655440000",
  "next_due_date": "2025-12-01",
  "assigned_to": "daniel-user-id",
  "recurring": true,
  "auto_create_work_order": true
}
```

**Response:**

json

```json
{
  "id": "asset-checklist-id",
  "asset_id": "villa-12-dishwasher-id",
  "template_id": "550e8400-e29b-41d4-a716-446655440000",
  "next_due_date": "2025-12-01",
  "assigned_to": "daniel-user-id",
  "active": true,
  "message": "Checklist assigned. First task will be created on 2025-11-24 (7 days before due date)."
}
```

---

### 2. Bulk Import

#### Upload CSV for Bulk Import

http

```http
POST /api/v1/import/csv
Content-Type: multipart/form-data
Authorization: Bearer {token}

# Form Data
file: [CSV file] (required)
dry_run: boolean (default: false - if true, validate only, don't create)
```

**CSV Format:**

csv

```csv
property_name,space,appliance_type,brand,model,photo_url,serial_number
Villa 12,Kitchen,Dishwasher,Bosch,SMS88TW06G,https://storage.com/photo.jpg,FD123456
Villa 12,Living Room,Air Conditioner,Daikin,FTXS35K,,
```

**Response (dry_run=true):**

json

```json
{
  "dry_run": true,
  "valid_rows": 45,
  "invalid_rows": 2,
  "errors": [
    {
      "row": 3,
      "field": "property_name",
      "error": "Property 'Villa 99' not found"
    },
    {
      "row": 7,
      "field": "appliance_type",
      "error": "Invalid appliance type 'Fridge'"
    }
  ],
  "estimated_tasks_to_create": 283,
  "estimated_processing_time_seconds": 120
}
```

**Response (dry_run=false):**

json

```json
{
  "job_id": "bulk-import-job-123",
  "status": "processing",
  "progress_url": "/api/v1/import/jobs/bulk-import-job-123"
}
```

---

#### Check Bulk Import Progress

http

```http
GET /api/v1/import/jobs/{job_id}
Authorization: Bearer {token}
```

**Response (in progress):**

json

```json
{
  "job_id": "bulk-import-job-123",
  "status": "processing",
  "progress": {
    "total_rows": 47,
    "processed_rows": 23,
    "successful_rows": 22,
    "failed_rows": 1,
    "percent_complete": 49
  },
  "current_task": "Generating checklist for Bosch dishwasher...",
  "estimated_completion": "2025-11-08T10:33:00Z"
}
```

**Response (completed):**

json

```json
{
  "job_id": "bulk-import-job-123",
  "status": "completed",
  "summary": {
    "total_rows": 47,
    "successful_rows": 45,
    "failed_rows": 2,
    "templates_created": 31,
    "tasks_created": 283,
    "errors": [
      {
        "row": 3,
        "error": "Manual not found for Model XYZ"
      },
      {
        "row": 15,
        "error": "AI confidence too low (0.45)"
      }
    ]
  },
  "completed_at": "2025-11-08T10:32:47Z",
  "processing_time_seconds": 118
}
```

---

### 3. Property Management (Extends Assets)

#### Get Property Details

http

```http
GET /api/v1/properties/{property_id}
Authorization: Bearer {token}
```

**Response:**

json

```json
{
  "id": "villa-12-id",
  "name": "Villa 12 - Blouberg",
  "description": "3BR beachfront property",
  "location": {
    "id": "blouberg-location-id",
    "name": "Blouberg, Cape Town",
    "address": "123 Beach Rd, Blouberg, 7441"
  },
  "property_metadata": {
    "listing_platform": "airbnb",
    "listing_url": "https://www.airbnb.com/rooms/12345678",
    "listing_id": "12345678",
    "check_in_time": "15:00",
    "check_out_time": "11:00",
    "bedrooms": 3,
    "bathrooms": 2,
    "max_guests": 6,
    "avg_rating": 4.87,
    "total_reviews": 234,
    "region": "Cape Town",
    "primary_housekeeper": {
      "id": "daniel-user-id",
      "name": "Daniel",
      "phone": "+27 xxx"
    },
    "handyman": {
      "id": "simba-user-id",
      "name": "Simba"
    },
    "last_deep_clean": "2025-10-15",
    "next_scheduled_maintenance": "2025-11-20"
  },
  "stats": {
    "open_tasks": 3,
    "upcoming_bookings": 8,
    "avg_turnover_time_hours": 3.5
  }
}
```

---

#### List All Properties

http

```http
GET /api/v1/properties
Authorization: Bearer {token}

Query Parameters:
- region: string (Cape Town, Strand)
- housekeeper_id: string (filter by assigned housekeeper)
- status: string (active, maintenance, offline)
- search: string (search by name/address)
- page: integer
- size: integer
```

**Response:**

json

```json
{
  "content": [
    {
      "id": "villa-12-id",
      "name": "Villa 12 - Blouberg",
      "region": "Cape Town",
      "bedrooms": 3,
      "avg_rating": 4.87,
      "open_tasks": 3,
      "next_booking_checkin": "2025-11-10T15:00:00Z",
      "thumbnail_url": "https://..."
    },
    // ... more properties
  ],
  "page": 0,
  "size": 20,
  "total_elements": 22
}
```

---

#### Update Property Metadata

http

```http
PATCH /api/v1/properties/{property_id}/metadata
Authorization: Bearer {token}
Content-Type: application/json

{
  "wifi_password": "NewPassword123",
  "lockbox_code": "5678",
  "primary_housekeeper_id": "new-housekeeper-id",
  "avg_rating": 4.91
}
```

**Response:**

json

```json
{
  "id": "villa-12-id",
  "property_metadata": {
    // ... updated metadata
  },
  "updated_at": "2025-11-08T10:45:00Z"
}
```

---

### 4. Task Management (Extends Work Orders)

#### Create Task

http

```http
POST /api/v1/tasks
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Pre-arrival deep clean",
  "description": "Prepare Villa 12 for guest check-in",
  "property_id": "villa-12-id",
  "task_category": "turnover",
  "priority": "high",
  "due_date": "2025-11-10T13:00:00Z",
  "assigned_to": "daniel-user-id",
  "estimated_duration_minutes": 180,
  "checklist_template_id": "deep-clean-checklist-id",
  "photos_required": 10,
  "booking_event_id": "booking-123"
}
```

**Response:**

json

```json
{
  "id": "task-uuid",
  "name": "Pre-arrival deep clean",
  "status": "OPEN",
  "created_at": "2025-11-08T10:50:00Z",
  "property": {
    "id": "villa-12-id",
    "name": "Villa 12 - Blouberg"
  },
  "assigned_to": {
    "id": "daniel-user-id",
    "name": "Daniel"
  },
  "checklist": {
    "total_steps": 15,
    "completed_steps": 0
  }
}
```

---

#### Update Task Status

http

```http
PATCH /api/v1/tasks/{task_id}/status
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "IN_PROGRESS",
  "notes": "Started at 10:00 AM"
}
```

---

#### Complete Checklist Step

http

```http
POST /api/v1/tasks/{task_id}/checklist/steps/{step_order}/complete
Authorization: Bearer {token}
Content-Type: application/json

{
  "completed": true,
  "notes": "Spray arm cleaned thoroughly",
  "actual_duration_minutes": 7
}
```

**Response:**

json

```json
{
  "task_id": "task-uuid",
  "checklist_progress": {
    "total_steps": 15,
    "completed_steps": 1,
    "percent_complete": 6.7
  },
  "next_step": {
    "order": 2,
    "title": "Clean filter assembly",
    "requires_photo": true
  }
}
```

---

### 5. Photo Upload

#### Upload Task Photo

http

```http
POST /api/v1/tasks/{task_id}/photos
Content-Type: multipart/form-data
Authorization: Bearer {token}

# Form Data
photo: [file] (required)
checklist_step_order: integer (optional)
photo_type: string (completion_proof, damage, before, after)
latitude: decimal (optional)
longitude: decimal (optional)
caption: string (optional)
```

**Response:**

json

```json
{
  "id": "photo-uuid",
  "file_path": "properties/villa-12/tasks/task-123/photo1.jpg",
  "thumbnail_url": "https://storage.supabase.co/.../thumb.jpg",
  "full_url": "https://storage.supabase.co/.../photo1.jpg",
  "uploaded_at": "2025-11-08T11:00:00Z",
  "quality_analysis": {
    "quality_score": 0.87,
    "is_acceptable": true,
    "feedback": "Good photo! Clear and well-lit."
  }
}
```

---

#### Get Task Photos

http

```http
GET /api/v1/tasks/{task_id}/photos
Authorization: Bearer {token}
```

**Response:**

json

```json
{
  "photos": [
    {
      "id": "photo-uuid",
      "checklist_step_order": 1,
      "photo_type": "completion_proof",
      "thumbnail_url": "https://...",
      "full_url": "https://...",
      "uploaded_by": "Daniel",
      "uploaded_at": "2025-11-08T11:00:00Z",
      "caption": "Spray arm cleaned"
    },
    // ... more photos
  ],
  "total_photos": 4,
  "required_photos": 6
}
```

---

### 6. Booking Integration

#### Receive Hospitable Webhook

http

```http
POST /api/v1/webhooks/hospitable
Content-Type: application/json
X-Hospitable-Signature: {signature}

{
  "event": "reservation.created",
  "data": {
    "id": "hospitable-reservation-123",
    "property_id": "villa-12-external-id",
    "platform": "airbnb",
    "check_in": "2025-11-15T15:00:00Z",
    "check_out": "2025-11-18T11:00:00Z",
    "guest_name": "John Smith",
    "guest_count": 4,
    "confirmation_code": "HMABCD123"
  }
}
```

**Processing:**

1. Validate signature
2. Map external property ID to internal property ID
3. Create booking_event record
4. Generate pre-arrival and post-checkout tasks
5. Assign to appropriate housekeeper
6. Send notification to Portia

**Response:**

json

```json
{
  "status": "accepted",
  "booking_event_id": "booking-event-uuid",
  "tasks_created": [
    {
      "id": "pre-arrival-task-id",
      "type": "pre_arrival",
      "due_date": "2025-11-15T13:00:00Z",
      "assigned_to": "Daniel"
    },
    {
      "id": "post-checkout-task-id",
      "type": "post_checkout",
      "due_date": "2025-11-18T15:00:00Z",
      "assigned_to": "Daniel"
    }
  ]
}
```

---

### 7. Morning Briefing

#### Get Today's Briefing

http

```http
GET /api/v1/briefing/today
Authorization: Bearer {token}

Query Parameters:
- date: string (YYYY-MM-DD, default: today)
- format: string (json, text, html, default: json)
```

**Response (format=json):**

json

```json
{
  "date": "2025-11-08",
  "summary": "Busy day ahead with 8 check-ins and 5 check-outs",
  "check_ins": [
    {
      "property": "Villa 12",
      "time": "15:00",
      "guest_name": "John Smith",
      "guest_count": 4,
      "pre_arrival_task_status": "COMPLETE",
      "special_requests": "Early check-in requested (14:00)"
    },
    // ... more check-ins
  ],
  "check_outs": [
    {
      "property": "Newport House",
      "time": "11:00",
      "guest_name": "Jane Doe",
      "turnover_time_hours": 4,
      "next_guest_checkin": "15:00",
      "post_checkout_task_status": "OPEN"
    },
    // ... more check-outs
  ],
  "urgent_tasks": [
    {
      "id": "task-urgent-1",
      "property": "Blouberg Apt",
      "title": "Fix broken door lock",
      "due_date": "2025-11-08T12:00:00Z",
      "assigned_to": "Simba"
    }
  ],
  "team_schedule": {
    "Daniel": {
      "region": "Cape Town",
      "tasks": 6,
      "estimated_hours": 18,
      "first_task": "Villa 12 pre-arrival (09:00)"
    },
    "Neddy": {
      "region": "Strand",
      "tasks": 4,
      "estimated_hours": 12
    },
    "Simba": {
      "region": "All",
      "tasks": 3,
      "type": "maintenance"
    }
  },
  "alerts": [
    {
      "type": "low_stock",
      "message": "Coffee pods running low (Villa 12, Villa 15)",
      "action": "Restock before next week"
    }
  ],
  "generated_at": "2025-11-08T06:00:00Z"
}
```

**Response (format=text):**

text

```text
Good morning Portia! Here's your briefing for November 8, 2025:

OVERVIEW
Busy day ahead with 8 check-ins and 5 check-outs across Cape Town and Strand.

CHECK-INS (8)
- Villa 12 - 15:00 - John Smith (4 guests) - Early check-in requested (14:00)
- Newport House - 15:00 - Jane Doe (2 guests)
...

CHECK-OUTS (5)
- Blouberg Apt - 11:00 - Mike Johnson → Next guest at 15:00 (4hr turnover)
...

URGENT TASKS (2)
⚠️ Blouberg Apt - Fix broken door lock - Due 12:00 PM - Assigned: Simba
⚠️ Villa 15 - No hot water reported - Due 10:00 AM - Assigned: Simba

TEAM SCHEDULE
Daniel (Cape Town): 6 tasks, ~18 hours - Starts at Villa 12 (09:00)
Neddy (Strand): 4 tasks, ~12 hours
Simba (Maintenance): 3 urgent repairs

ALERTS
⚠️ Low stock: Coffee pods (Villa 12, Villa 15) - Restock this week
```

---

### 8. Analytics & Reports

#### Task Completion Stats

http

```http
GET /api/v1/analytics/tasks/completion-stats
Authorization: Bearer {token}

Query Parameters:
- start_date: string (YYYY-MM-DD)
- end_date: string (YYYY-MM-DD)
- user_id: string (optional - filter by user)
- region: string (optional - filter by region)
```

**Response:**

json

```json
{
  "period": {
    "start_date": "2025-10-01",
    "end_date": "2025-10-31"
  },
  "overall": {
    "total_tasks": 247,
    "completed_tasks": 239,
    "completion_rate": 0.968,
    "avg_completion_time_hours": 3.2,
    "compliance_rate": 0.91
  },
  "by_user": [
    {
      "user_id": "daniel-user-id",
      "name": "Daniel",
      "tasks_completed": 87,
      "avg_completion_time_hours": 3.1,
      "compliance_rate": 0.95,
      "photo_documentation_rate": 0.98
    },
    // ... more users
  ],
  "by_category": [
    {
      "category": "turnover",
      "total_tasks": 145,
      "completion_rate": 0.99,
      "avg_time_hours": 3.5
    },
    // ... more categories
  ]
}
```

---

#### Property Performance

http

```http
GET /api/v1/analytics/properties/performance
Authorization: Bearer {token}

Query Parameters:
- property_id: string (optional - specific property)
- start_date: string
- end_date: string
```

**Response:**

json

```json
{
  "period": {
    "start_date": "2025-10-01",
    "end_date": "2025-10-31"
  },
  "properties": [
    {
      "property_id": "villa-12-id",
      "name": "Villa 12",
      "bookings": 18,
      "occupancy_rate": 0.87,
      "avg_rating": 4.89,
      "total_tasks": 42,
      "task_compliance_rate": 0.95,
      "maintenance_costs": 2340.50,
      "avg_turnover_time_hours": 3.2,
      "issues_reported": 2,
      "revenue_per_task": 2857.14
    },
    // ... more properties
  ]
}
```

---

## Existing Atlas Endpoints (Keep Unchanged)

These endpoints remain as-is from Atlas CMMS:

- `/api/v1/auth/login` - Authentication
- `/api/v1/users` - User management
- `/api/v1/locations` - Location management
- `/api/v1/teams` - Team management
- `/api/v1/vendors` - Vendor management
- `/api/v1/files` - File upload/download

Refer to Atlas CMMS documentation for these endpoints.

---

## Error Codes

Standard HTTP status codes:

- `200 OK` - Success
- `201 Created` - Resource created
- `204 No Content` - Success with no response body
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Missing or invalid auth token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource conflict (e.g., duplicate)
- `422 Unprocessable Entity` - Validation failed
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error
- `503 Service Unavailable` - Service temporarily down

**Error Response Format:**

json

```json
{
  "error": "ERROR_CODE",
  "message": "Human-readable error message",
  "details": {
    "field": "specific_field",
    "reason": "More details"
  },
  "timestamp": "2025-11-08T11:00:00Z"
}
```

---

## Rate Limiting

- **General API:** 1000 requests/hour per user
- **AI Endpoints:** 100 requests/hour per user
- **Photo Upload:** 500 requests/hour per user
- **Webhooks:** No limit (verified by signature)

Rate limit headers included in responses:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 847
X-RateLimit-Reset: 1699459200
```

---

## Webhook Signatures

All incoming webhooks include signature verification:

java

```java
// Verify Hospitable webhook signature
String payload = request.getBody();
String signature = request.getHeader("X-Hospitable-Signature");
String computed = HMAC_SHA256(payload, WEBHOOK_SECRET);

if (!signature.equals(computed)) {
    return 401 Unauthorized;
}
```

---

## Testing

### Postman Collection

Import the Postman collection: `postman/Atlas-STR.postman_collection.json`

### Example cURL Requests

bash

```bash
# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"colin@example.com","password":"password"}'

# Get properties
curl -X GET http://localhost:8080/api/v1/properties \
  -H "Authorization: Bearer {token}"

# Upload photo for checklist generation
curl -X POST http://localhost:8080/api/v1/checklists/generate \
  -H "Authorization: Bearer {token}" \
  -F "photo=@bosch-dishwasher.jpg"
```

---

**Last Updated:** 2025-11-08  
**Author:** Colin + Claude  
**Status:** In Development