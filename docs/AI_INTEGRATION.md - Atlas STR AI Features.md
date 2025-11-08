## Overview

This document specifies how AI is integrated into Atlas STR, with a focus on the **killer feature**: AI-generated dynamic maintenance checklists from appliance photos or model numbers.

---

## Core AI Features

### 1. AI Checklist Generation 🎯 **Priority #1**

**Goal:** Upload a photo of an appliance → Get a complete maintenance checklist in 30 seconds

**User Flow:**

```
1. User uploads photo of Bosch dishwasher
2. AI detects: Make, Model, Serial Number
3. System fetches: User manual PDF
4. AI extracts: Maintenance procedures, schedules, part numbers
5. System creates: Reusable checklist template
6. User reviews & approves
7. System schedules: Recurring tasks for all properties with same appliance
```

### 2. Photo Quality Verification

**Goal:** Ensure housekeepers upload clear, relevant photos

### 3. Damage Detection (Future)

**Goal:** Auto-detect property damage from photos

### 4. Morning Briefing Generation

**Goal:** Natural language summary of day's operations

---

## Architecture

### AI Provider: Anthropic Claude

**Why Claude:**

- Best-in-class vision capabilities (photo analysis)
- Superior instruction following for structured output
- 200K context window (can process entire appliance manuals)
- Fast response times (<5 seconds for checklists)
- Reasonable pricing ($3/MTok input, $15/MTok output)

**API Endpoint:** [https://api.anthropic.com/v1/messages](https://api.anthropic.com/v1/messages)

### Fallback Providers

**Google Cloud Vision API:**

- OCR for serial number extraction
- Fallback if Claude vision unavailable

**Local LLM (Future):**

- Llama 3 8B for simple tasks
- Cost optimization for high-volume operations

---

## Feature 1: AI Checklist Generation

### Technical Implementation

#### Backend Endpoint

**File:** `backend/src/main/java/com/grash/controller/ChecklistController.java`

java

```java
@RestController
@RequestMapping("/api/v1/checklists")
public class ChecklistController {
    
    @Autowired
    private AIChecklistService aiService;
    
    @PostMapping("/generate")
    public ResponseEntity<ChecklistGenerationResponse> generateChecklist(
        @RequestParam("photo") MultipartFile photo,
        @RequestParam(required = false) String brand,
        @RequestParam(required = false) String model,
        @RequestParam(required = false) String applianceType
    ) throws IOException {
        
        // Step 1: Upload photo to Supabase Storage
        String photoUrl = supabaseService.uploadPhoto(photo);
        
        // Step 2: Extract appliance details from photo (if not provided)
        if (brand == null || model == null) {
            ApplianceDetails details = aiService.identifyAppliance(photoUrl);
            brand = details.getBrand();
            model = details.getModel();
            applianceType = details.getType();
        }
        
        // Step 3: Fetch manufacturer manual
        String manualPdfUrl = manualService.fetchManual(brand, model);
        
        // Step 4: Generate checklist using AI
        ChecklistTemplate template = aiService.generateChecklist(
            applianceType, brand, model, manualPdfUrl
        );
        
        // Step 5: Save to database
        template = checklistRepository.save(template);
        
        // Step 6: Log AI usage for cost tracking
        aiLogService.log("checklist_generation", template.getId(), 
                        aiService.getLastTokensUsed());
        
        return ResponseEntity.ok(new ChecklistGenerationResponse(template));
    }
}
```

#### AI Service

**File:** `backend/src/main/java/com/grash/service/AIChecklistService.java`

java

```java
@Service
public class AIChecklistService {
    
    @Value("${anthropic.api.key}")
    private String anthropicApiKey;
    
    private static final String ANTHROPIC_API_URL = 
        "https://api.anthropic.com/v1/messages";
    
    /**
     * Identify appliance from photo using Claude Vision
     */
    public ApplianceDetails identifyAppliance(String photoUrl) {
        
        String prompt = """
            Analyze this photo of an appliance. Extract:
            1. Appliance type (dishwasher, washing machine, dryer, etc.)
            2. Brand/manufacturer
            3. Model number (look for labels, stickers, control panels)
            4. Serial number (if visible)
            5. Approximate age (based on design)
            
            Respond in JSON format:
            {
              "type": "dishwasher",
              "brand": "Bosch",
              "model": "SMS88TW06G",
              "serial": "FD9234567890",
              "estimated_age_years": 3,
              "confidence": 0.95
            }
            
            If you cannot determine a field with high confidence, set it to null.
            """;
        
        JSONObject request = new JSONObject()
            .put("model", "claude-sonnet-4-20250514")
            .put("max_tokens", 1024)
            .put("messages", new JSONArray()
                .put(new JSONObject()
                    .put("role", "user")
                    .put("content", new JSONArray()
                        .put(new JSONObject()
                            .put("type", "image")
                            .put("source", new JSONObject()
                                .put("type", "url")
                                .put("url", photoUrl)
                            )
                        )
                        .put(new JSONObject()
                            .put("type", "text")
                            .put("text", prompt)
                        )
                    )
                )
            );
        
        HttpResponse<String> response = sendClaudeRequest(request);
        JSONObject result = new JSONObject(response.body())
            .getJSONArray("content")
            .getJSONObject(0);
        
        String jsonText = extractJsonFromResponse(result.getString("text"));
        return new ObjectMapper().readValue(jsonText, ApplianceDetails.class);
    }
    
    /**
     * Generate maintenance checklist from appliance details and manual
     */
    public ChecklistTemplate generateChecklist(
        String applianceType, 
        String brand, 
        String model,
        String manualPdfUrl
    ) {
        
        // Step 1: Extract maintenance section from manual PDF
        String manualContent = pdfService.extractMaintenanceSection(manualPdfUrl);
        
        // Step 2: Call Claude to generate structured checklist
        String prompt = buildChecklistPrompt(applianceType, brand, model, manualContent);
        
        JSONObject request = new JSONObject()
            .put("model", "claude-sonnet-4-20250514")
            .put("max_tokens", 4096)
            .put("temperature", 0.3) // Lower temperature for consistent output
            .put("messages", new JSONArray()
                .put(new JSONObject()
                    .put("role", "user")
                    .put("content", prompt)
                )
            );
        
        HttpResponse<String> response = sendClaudeRequest(request);
        
        // Step 3: Parse response into ChecklistTemplate
        String responseText = new JSONObject(response.body())
            .getJSONArray("content")
            .getJSONObject(0)
            .getString("text");
        
        JSONObject checklistJson = new JSONObject(
            extractJsonFromResponse(responseText)
        );
        
        // Step 4: Build entity
        ChecklistTemplate template = new ChecklistTemplate();
        template.setName(checklistJson.getString("name"));
        template.setDescription(checklistJson.getString("description"));
        template.setApplianceType(applianceType);
        template.setBrand(brand);
        template.setModel(model);
        template.setSource("ai_generated");
        template.setManualPdfUrl(manualPdfUrl);
        
        // Parse steps
        JSONArray stepsArray = checklistJson.getJSONArray("steps");
        template.setSteps(stepsArray.toString());
        
        // Set metadata
        template.setPhotosRequired(checklistJson.getInt("photos_required"));
        template.setEstimatedDurationMinutes(checklistJson.getInt("estimated_duration_minutes"));
        template.setFrequencyType(checklistJson.getString("frequency_type"));
        template.setFrequencyValue(checklistJson.getInt("frequency_value"));
        
        // AI metadata
        template.setAiModel("claude-sonnet-4-20250514");
        template.setAiGenerationDate(LocalDateTime.now());
        template.setAiConfidenceScore(checklistJson.getDouble("confidence"));
        
        return template;
    }
    
    /**
     * Build the prompt for checklist generation
     */
    private String buildChecklistPrompt(
        String applianceType, 
        String brand, 
        String model,
        String manualContent
    ) {
        return String.format("""
            You are an expert appliance maintenance technician with 20 years of experience 
            maintaining short-term rental properties. You create detailed, photo-documented 
            maintenance checklists.
            
            APPLIANCE DETAILS:
            - Type: %s
            - Brand: %s
            - Model: %s
            
            MANUFACTURER MANUAL EXCERPT:
            %s
            
            TASK:
            Create a comprehensive maintenance checklist for this appliance. Focus on:
            1. Deep cleaning procedures
            2. Preventive maintenance to avoid breakdowns
            3. Safety checks
            4. Parts that commonly wear out
            
            REQUIREMENTS:
            - Assume the technician is competent but may not be an expert
            - Each step should be clear, actionable, and safe
            - Include photo requirements for verification
            - Specify tools/supplies needed
            - Indicate which steps require two people
            - Add safety warnings where appropriate
            - Estimate realistic time for each step
            - Reference manual page numbers when relevant
            
            OUTPUT FORMAT (strict JSON):
            {
              "name": "Bosch SMS88TW06G Deep Clean & Maintenance",
              "description": "Complete 6-month service checklist",
              "steps": [
                {
                  "order": 1,
                  "title": "Remove and clean lower spray arm",
                  "description": "Twist spray arm counterclockwise to remove. Clean nozzles with soft brush. Check for clogs.",
                  "estimated_minutes": 5,
                  "tools_required": ["soft brush", "towel"],
                  "supplies_needed": ["warm water"],
                  "requires_photo": true,
                  "photo_description": "Photo of cleaned spray arm with visible nozzles",
                  "safety_warning": null,
                  "requires_two_people": false,
                  "manual_reference": "Page 23, Section 5.2"
                },
                {
                  "order": 2,
                  "title": "Clean filter assembly",
                  "description": "Remove filter by twisting counterclockwise. Rinse under hot water. Scrub with soft brush. Inspect for damage.",
                  "estimated_minutes": 10,
                  "tools_required": ["soft brush"],
                  "supplies_needed": ["hot water", "mild detergent"],
                  "requires_photo": true,
                  "photo_description": "Before and after photos of filter",
                  "safety_warning": "Water may be hot if recently run",
                  "requires_two_people": false,
                  "manual_reference": "Page 24-25, Section 5.3"
                }
                // ... more steps
              ],
              "photos_required": 6,
              "estimated_duration_minutes": 90,
              "frequency_type": "months",
              "frequency_value": 6,
              "difficulty_level": "easy",
              "required_skills": [],
              "parts_that_may_need_replacement": [
                {
                  "part_name": "Filter assembly",
                  "part_number": "00427903",
                  "typical_lifespan": "2-3 years",
                  "signs_of_wear": "Cracks, warping, persistent odor"
                }
              ],
              "supplies_shopping_list": [
                {"name": "Finish Dishwasher Cleaner", "quantity": "1 bottle", "frequency": "every 6 months"},
                {"name": "Soft brush set", "quantity": "1 set", "frequency": "replace annually"}
              ],
              "confidence": 0.92
            }
            
            CRITICAL: Output ONLY the JSON object. No preamble, no explanation, no markdown formatting.
            """, 
            applianceType, brand, model, 
            manualContent.substring(0, Math.min(50000, manualContent.length()))
        );
    }
    
    /**
     * Send request to Claude API
     */
    private HttpResponse<String> sendClaudeRequest(JSONObject request) {
        HttpClient client = HttpClient.newHttpClient();
        
        HttpRequest httpRequest = HttpRequest.newBuilder()
            .uri(URI.create(ANTHROPIC_API_URL))
            .header("Content-Type", "application/json")
            .header("x-api-key", anthropicApiKey)
            .header("anthropic-version", "2023-06-01")
            .POST(HttpRequest.BodyPublishers.ofString(request.toString()))
            .build();
        
        try {
            return client.send(httpRequest, HttpResponse.BodyHandlers.ofString());
        } catch (Exception e) {
            throw new RuntimeException("Failed to call Claude API", e);
        }
    }
    
    /**
     * Extract JSON from Claude response (handles markdown formatting)
     */
    private String extractJsonFromResponse(String text) {
        // Remove markdown code blocks if present
        text = text.replaceAll("```json\\s*", "");
        text = text.replaceAll("```\\s*", "");
        text = text.trim();
        
        // Find first { and last }
        int start = text.indexOf('{');
        int end = text.lastIndexOf('}');
        
        if (start == -1 || end == -1) {
            throw new RuntimeException("No valid JSON found in response");
        }
        
        return text.substring(start, end + 1);
    }
}
```

### Prompt Engineering Best Practices

**Key Principles:**

1. **Specific Role:** "You are an expert appliance maintenance technician..."
2. **Clear Context:** Provide appliance details and manual excerpt
3. **Explicit Requirements:** List all must-have fields
4. **Format Specification:** Show exact JSON structure
5. **Safety Focus:** Request safety warnings
6. **Realistic Estimates:** Ask for time estimates per step
7. **Verification:** Require photo documentation points
8. **Low Temperature:** Use 0.3 for consistent structured output

---

## Feature 2: Photo Quality Verification

### Purpose

Ensure housekeeper photos are clear, relevant, and useful for quality control.

### Implementation

java

```java
@Service
public class PhotoQualityService {
    
    public PhotoQualityAnalysis analyzePhoto(String photoUrl, String expectedContent) {
        
        String prompt = String.format("""
            Analyze this photo that was uploaded as proof of task completion.
            
            Expected content: %s
            
            Evaluate:
            1. Is the photo clear and in focus? (not blurry)
            2. Is there adequate lighting?
            3. Does the photo show the expected content?
            4. Is the photo taken from an appropriate angle/distance?
            5. Are there any quality issues? (glare, obstruction, etc.)
            
            Respond in JSON:
            {
              "is_acceptable": true,
              "quality_score": 0.87,
              "issues": ["slight glare on surface"],
              "shows_expected_content": true,
              "feedback_for_user": "Good photo! Clear view of cleaned spray arm."
            }
            """, expectedContent);
        
        // Call Claude API...
        // Parse response...
        
        return analysis;
    }
}
```

**When to Use:**

- On every photo upload (async, doesn't block user)
- Flag low-quality photos for Portia's review
- Provide real-time feedback to housekeepers
- Track photo quality scores per user (training opportunity)

---

## Feature 3: Damage Detection (Future Phase)

### Purpose

Automatically detect property damage from photos to speed up damage reports.

### Example Implementation

java

```java
public DamageAnalysis detectDamage(String photoUrl, String assetType) {
    
    String prompt = String.format("""
        Analyze this photo for potential property damage.
        
        Asset type: %s
        
        Look for:
        - Water stains or moisture damage
        - Cracks, chips, or breaks
        - Scratches or dents
        - Missing parts or components
        - Discoloration or fading
        - Wear beyond normal use
        
        Assess severity:
        - MINOR: Cosmetic, guest likely won't notice
        - MODERATE: Visible, should be fixed between bookings
        - MAJOR: Affects functionality or guest experience
        - URGENT: Safety hazard or booking-critical
        
        Respond in JSON:
        {
          "damage_detected": true,
          "damage_types": ["water_stain", "crack"],
          "severity": "MODERATE",
          "location_description": "Bottom left corner of cabinet door",
          "estimated_repair_cost_range": "R500-R1000",
          "recommended_action": "Sand, repaint, and seal",
          "requires_immediate_attention": false,
          "confidence": 0.88
        }
        """, assetType);
    
    // ...
}
```

---

## Feature 4: Morning Briefing Generator

### Purpose

Generate natural language summary of the day's operations for Portia.

### Example Implementation

java

```java
public String generateMorningBriefrief(LocalDate date) {
    
    // Gather data
    List<BookingEvent> checkIns = bookingService.getTodayCheckIns(date);
    List<BookingEvent> checkOuts = bookingService.getTodayCheckOuts(date);
    List<WorkOrder> urgentTasks = workOrderService.getUrgentTasks(date);
    List<SupplyAlert> lowStock = inventoryService.getLowStockAlerts();
    TeamSchedule schedule = teamService.getTodaySchedule(date);
    
    // Build context
    String context = buildBriefingContext(checkIns, checkOuts, urgentTasks, lowStock, schedule);
    
    String prompt = String.format("""
        You are Portia's AI assistant. Create a concise morning briefing for %s.
        
        DATA:
        %s
        
        Format as a friendly email that covers:
        1. Overview (one sentence summary of the day)
        2. Check-ins (properties, times, any special requests)
        3. Check-outs (properties, times, turnaround time for next guest)
        4. Urgent tasks (what needs immediate attention)
        5. Team schedule (who's working where)
        6. Alerts (low stock, upcoming maintenance, etc.)
        7. Opportunities (upsells, extra cleaning, etc.)
        
        Keep it:
        - Professional but friendly
        - Action-oriented
        - Prioritized (most important first)
        - Under 500 words
        
        Start with: "Good morning Portia! Here's your briefing for [date]:"
        """, date, context);
    
    // Call Claude...
    return briefing;
}
```

**Delivery:**

- Email to Portia at 6:00 AM
- Push notification to mobile app
- Available in dashboard "Today" view
- Response time: <0.1s (pre-generated at 5:30 AM)

---

## Cost Management

### Estimated Monthly Costs

**Checklist Generation:**

- Average tokens per generation: ~8,000 tokens
- Generations per month: ~50 (initial batch) + ~10 (new appliances)
- Cost: 60 × 8,000 × $0.003/1K = **$1.44/month**

**Photo Quality Checks:**

- Average tokens per check: ~1,500 tokens
- Photos per day: ~30 (across all properties)
- Photos per month: ~900
- Cost: 900 × 1,500 × $0.003/1K = **$4.05/month**

**Morning Briefings:**

- Average tokens per briefing: ~3,000 tokens
- Briefings per day: 1
- Briefings per month: 30
- Cost: 30 × 3,000 × $0.003/1K = **$0.27/month**

**Total Estimated: ~$6/month** (scales with portfolio size)

### Cost Optimization Strategies

1. **Cache manual PDFs** - Don't re-fetch for same model
2. **Batch processing** - Generate multiple checklists in one API call
3. **Template reuse** - One template per appliance model, use across properties
4. **Async photo analysis** - Don't block user experience
5. **Rate limiting** - Max 100 AI calls/day (more than enough)

---

## Error Handling

### Common Errors & Solutions

**1. Claude API Rate Limit**

java

```java
try {
    return callClaudeAPI(request);
} catch (RateLimitException e) {
    // Wait and retry with exponential backoff
    Thread.sleep(1000 * Math.pow(2, retryCount));
    return callClaudeAPI(request);
}
```

**2. Invalid JSON Response**

java

```java
try {
    return parseClaudeResponse(response);
} catch (JsonException e) {
    // Log for debugging
    logger.error("Failed to parse Claude response: " + response);
    
    // Retry with more explicit prompt
    return callClaudeAPIWithStricterPrompt(request);
}
```

**3. Manual Not Found**

java

```java
if (manualPdfUrl == null) {
    // Fallback to generic checklist
    logger.warn("Manual not found for " + brand + " " + model);
    return generateGenericChecklist(applianceType);
}
```

**4. Low Confidence Score**

java

```java
if (template.getAiConfidenceScore() < 0.7) {
    // Flag for human review
    template.setRequiresHumanReview(true);
    notificationService.notifyAdmin(
        "Low confidence checklist generated for " + model
    );
}
```

---

## Testing Strategy

### Unit Tests

java

```java
@Test
public void testApplianceIdentification() {
    String testPhotoUrl = "https://test.com/bosch-dishwasher.jpg";
    
    ApplianceDetails details = aiService.identifyAppliance(testPhotoUrl);
    
    assertEquals("dishwasher", details.getType());
    assertEquals("Bosch", details.getBrand());
    assertNotNull(details.getModel());
    assertTrue(details.getConfidence() > 0.8);
}

@Test
public void testChecklistGeneration() {
    ChecklistTemplate template = aiService.generateChecklist(
        "dishwasher", "Bosch", "SMS88TW06G", "manual-url"
    );
    
    assertNotNull(template.getName());
    assertTrue(template.getSteps().length() > 0);
    assertTrue(template.getEstimatedDurationMinutes() > 0);
    assertEquals("ai_generated", template.getSource());
}
```

### Integration Tests

java

```java
@Test
public void testEndToEndChecklistCreation() {
    // Upload photo
    MultipartFile photo = new MockMultipartFile(...);
    
    // Generate checklist
    ResponseEntity<ChecklistGenerationResponse> response = 
        checklistController.generateChecklist(photo, null, null, null);
    
    // Verify
    assertEquals(HttpStatus.OK, response.getStatusCode());
    assertNotNull(response.getBody().getTemplateId());
    
    // Check database
    ChecklistTemplate saved = checklistRepository.findById(
        response.getBody().getTemplateId()
    ).orElseThrow();
    
    assertEquals("Bosch", saved.getBrand());
}
```

### Manual Testing Checklist

- [ ]  Upload photo of known appliance → verify correct identification
- [ ]  Generate checklist for known model → verify steps make sense
- [ ]  Test with poor quality photo → verify error handling
- [ ]  Test with unknown appliance → verify fallback behavior
- [ ]  Check token usage logging
- [ ]  Verify cost tracking
- [ ]  Test rate limiting (100 calls in quick succession)

---

## Monitoring & Observability

### Metrics to Track

1. **AI Performance:**
    - Average response time (target: <5s for checklist)
    - Success rate (target: >95%)
    - Confidence scores (track distribution)
    - Token usage per request type
2. **Quality Metrics:**
    - Checklist accuracy (user feedback)
    - Photo quality scores (average per user)
    - Manual review rate (how often humans need to intervene)
3. **Cost Metrics:**
    - Daily/monthly API spend
    - Cost per checklist
    - Cost per photo analysis
    - Trend over time

### Dashboards

**Admin Dashboard:**

- Total AI calls today/week/month
- Average cost per call
- Most generated appliance types
- Error rate graph
- Token usage over time

**Quality Dashboard:**

- Average checklist confidence scores
- Average photo quality scores
- Manual review queue
- User-reported issues

---

## Security & Privacy

### API Key Management

properties

```properties
# application.properties
anthropic.api.key=${ANTHROPIC_API_KEY}
google.cloud.vision.api.key=${GOOGLE_CLOUD_VISION_KEY}
```

**Never commit API keys to git!**

Store in:

- Local: `.env` file (gitignored)
- Production: Supabase secrets / environment variables

### Data Privacy

**Photo Handling:**

- Store in Supabase Storage with access controls
- Auto-delete after retention period (90 days for routine tasks)
- Never send guest photos to AI (only appliance/property photos)

**Manual Content:**

- Cache manufacturer manuals locally (don't re-fetch)
- Respect copyright (only use excerpts in prompts)
- Attribute sources in generated checklists

---

## Future Enhancements

### Phase 2 (Months 3-6)

- [ ]  Multi-language checklist generation (Afrikaans, Xhosa)
- [ ]  Voice-to-text task notes (for housekeepers)
- [ ]  Predictive maintenance (analyze failure patterns)
- [ ]  Supply forecasting (based on booking trends)

### Phase 3 (Months 6-12)

- [ ]  Community checklist marketplace (share templates)
- [ ]  Video tutorial generation (AI narration over photos)
- [ ]  Guest issue triaging (analyze guest messages)
- [ ]  Smart routing (optimize housekeeper routes with AI)

---

## Troubleshooting Guide

### Issue: "AI generated nonsensical checklist"

**Solution:**

1. Check manual quality - is PDF readable?
2. Review confidence score - if <0.7, flag for review
3. Test with different temperature (try 0.1)
4. Add more examples to prompt
5. Increase max_tokens if output was truncated

### Issue: "Photo identification failed"

**Solution:**

1. Check photo quality - is it clear?
2. Verify photo URL is accessible
3. Try Google Cloud Vision as fallback
4. Ask user to provide model number manually
5. Generate generic checklist as last resort

### Issue: "API costs higher than expected"

**Solution:**

1. Check token usage logs - any outliers?
2. Verify caching is working for manuals
3. Reduce max_tokens if possible
4. Batch operations where possible
5. Consider local LLM for simple tasks

---

**Last Updated:** 2025-11-08  
**Author:** Colin + Claude  
**Status:** In Development