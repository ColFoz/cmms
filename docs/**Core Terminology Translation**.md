## 

### **FROM → TO**

**Assets/Equipment** → **Property Features/Amenities**

- Machinery → Appliances & Systems
- Equipment → Guest Amenities & Fixtures
- Vehicles → N/A (unless you have property vehicles)
- Buildings → Properties/Units/Listings

**Locations** → **Properties/Units**

- Facility → Property Portfolio
- Site → Individual Property
- Building → Unit/Apartment/House
- Room → Space/Area (Living Room, Bedroom, Kitchen, etc.)

**Work Orders** → **Maintenance Tasks/Service Requests**

- Preventive Maintenance (PM) → **Routine Inspections & Turnovers**
- Reactive/Emergency → **Guest-Reported Issues**
- Corrective → **Property Improvements**
- Recurring → **Scheduled Maintenance**

**Parts Inventory** → **Property Supplies & Consumables**

- Parts → Supplies/Replacements
- Spare Parts → Backup Items
- Inventory → Supply Closet/Storage

**Technicians** → **Service Team**

- Technician → Handyman/Maintenance Tech
- Operators → Property Managers/Housekeepers
- Field Workers → On-site Staff

**Requesters** → **Reporting Parties**

- Requester → Guest/Housekeeper/Property Manager
- Work Request → Service Request/Issue Report

**Downtime** → **Property Unavailability**

- Equipment Downtime → Unit Out of Service
- MTBF (Mean Time Between Failures) → Time Between Issues
- MTTR (Mean Time To Repair) → Repair Turnaround Time

---

## **Asset Hierarchy Rebranding**

### **Industrial CMMS Structure:**

```
Location → Building → Floor → Department → Equipment
```

### **Airbnb Property Structure:**

```
Portfolio → Property → Unit/Listing → Space/Room → Feature/System
```

**Example for your 22 properties:**

- **Level 1: Portfolio** - "Colin's Cape Town Rentals"
- **Level 2: Region** - "Cape Town" or "Strand"
- **Level 3: Property** - "Newport House," "Blouberg Beachfront," etc.
- **Level 4: Space** - "Master Bedroom," "Kitchen," "Living Area," "Bathroom 1"
- **Level 5: Asset** - "Samsung TV," "Washing Machine," "Air Conditioner," "Door Lock"

---

## **Work Order Categories (Rebranded)**

### **FROM Industrial:**

- Reactive, Preventive, Corrective, Project

### **TO Airbnb:**

1. **Guest Experience** (High Priority)
    - Guest-reported issues during stay
    - Emergency repairs (no hot water, broken lock, AC failure)
    - Comfort items (extra towels, amenity requests)
2. **Turnover Operations** (Time-Sensitive)
    - Pre-arrival inspection
    - Deep cleaning
    - Linen change
    - Amenity restocking
    - Damage assessment
3. **Routine Maintenance** (Preventive)
    - Monthly HVAC filter change
    - Quarterly appliance checks
    - Annual deep cleans
    - Seasonal prep (winter/summer readiness)
4. **Property Improvements** (Projects)
    - Upgrades (new bedding, furniture)
    - Renovations
    - Compliance updates
5. **Inventory Replenishment** (Supply Chain)
    - Coffee, toiletries, cleaning supplies
    - Linen replacement
    - Equipment replacements

---

## **Priority Levels (Hospitality Context)**

**High Priority:**

- Affects guest stay (no wifi, broken bed, leaking pipe)
- Safety issues (faulty smoke detector, broken glass)
- Booking-critical (property unrentable)

**Medium Priority:**

- Impacts guest comfort but not critical (slow drain, minor stain)
- Needs attention within 48 hours
- Could affect review scores

**Low Priority:**

- Cosmetic improvements
- Non-urgent upgrades
- Can wait until between bookings

**None:**

- Wishlist items
- Future considerations

---

## **Parts/Inventory Categories**

### **FROM:**

- Mechanical Parts, Electrical Components, Consumables

### **TO:**

1. **Guest Consumables**
    - Coffee, tea, sugar, condiments
    - Toiletries (shampoo, soap, toilet paper)
    - Paper products, trash bags
    - Welcome pack items
2. **Linen & Soft Goods**
    - Bed sheets, duvet covers, pillowcases
    - Towels (bath, hand, beach)
    - Blankets, throws, pillows
    - Bathmats, tablecloths
3. **Appliance Parts & Replacements**
    - Light bulbs, batteries
    - Air filters (HVAC, dryer)
    - Remote controls
    - Fuses, power adapters
4. **Cleaning Supplies**
    - Detergents, disinfectants
    - Mops, brooms, vacuum bags
    - Sponges, cloths, gloves
5. **Fixtures & Hardware**
    - Door locks, keys, lockboxes
    - Shower heads, faucet parts
    - Curtain rods, hooks
    - Picture hangers, screws
6. **Kitchen Equipment**
    - Dishes, glassware, cutlery
    - Cookware, utensils
    - Coffee makers, kettles
    - Wine glasses, serving items

---

## **Analytics Dashboard Rebrand**

### **Industrial Metrics → Hospitality KPIs**

- **Overall Equipment Effectiveness (OEE)** → **Property Availability Rate**
- **Downtime Events** → **Unavailable Nights/Booking Blocks**
- **MTBF** → **Days Between Maintenance Issues**
- **MTTR** → **Average Resolution Time**
- **Work Order Compliance** → **Task Completion Before Guest Arrival**
- **Labor Utilization** → **Housekeeper/Handyman Productivity**
- **Inventory Turnover** → **Supply Consumption Rate**

### **New Hospitality-Specific Reports:**

- Guest Issue Response Time
- Turnover Completion Rate
- Pre-Arrival Inspection Scores
- Supply Stock Levels by Property
- Seasonal Maintenance Calendar
- Review Score Impact from Maintenance

---

## **User Roles Rebranding**

**Administrator** → **Portfolio Manager** (You/Colin)  
**Maintenance Manager** → **Operations Manager** (Portia)  
**Technician** → **Handyman/Maintenance Tech** (Simba)  
**Operator** → **Housekeeper** (Daniel, Neddy, Sanela)  
**Requester** → **Issue Reporter** (Guests, Team Members)

---

## **Workflow Rebranding**

### **PM (Preventive Maintenance) Task** → **Scheduled Property Care**

**Examples:**

- **Pre-Guest Arrival Checklist** (every booking)
- **Post-Checkout Deep Clean** (every checkout)
- **Monthly Property Walkthrough** (monthly)
- **Quarterly Appliance Service** (quarterly)
- **Annual Safety Compliance** (yearly)

---

## **Quick Reference Cheat Sheet**

|**Atlas CMMS Term**|**Your Airbnb System**|
|---|---|
|Asset|Property Feature/Appliance|
|Location|Property/Unit|
|Work Order|Service Task|
|PM Task|Routine Inspection|
|Reactive Work|Guest Issue|
|Parts|Supplies|
|Technician|Service Team|
|Downtime|Unavailable|
|Requester|Reporter|
|Labor Cost|Service Cost|
|Inventory|Supply Closet|
|Compliance|Task Completed On-Time|

---

Would you like me to:

1. Create a specific configuration guide for setting up Atlas with these rebranded categories?
2. Design custom field mappings for your 22 properties?
3. Build out example workflows for common scenarios (guest issue, turnover, quarterly inspection)?
4. Create supply inventory templates organized by property?

This rebranding should make Atlas feel like it was built specifically for short-term rental operations rather than a factory floor!