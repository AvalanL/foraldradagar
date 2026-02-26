# PRD: Föräldradagar - Swedish Parental Leave Planner

## 1. Overview

**App Name:** Föräldradagar
**Tagline:** Planera er föräldraledighet, tillsammans.
**Platform:** iOS 17+ (iPhone, iPad)
**Language:** Svenska (enbart svenska -- inget engelskt språkstöd)
**Category:** App Store > Lifestyle (or Health & Fitness > Parenting)

---

## 2. Problem Statement

Sweden's parental leave system is the most generous in the world -- 480 days shared between two parents -- but also one of the most complex. Parents must navigate:

- 480 total days split across two pay levels (390 days at ~80% income, 90 days at ~180 SEK/day)
- 90 reserved days per parent that cannot be transferred
- Interaction with employer top-up agreements (many employers pay 90-100% for the first months)
- VAB (vård av barn) -- up to 120 days/year for caring for a sick child
- Deadlines: days expire when the child turns 12 (basic level) or 4 (some reserved days at higher level)
- Coordination between two parents, often with different employers and income levels

Currently, parents use the clunky Försäkringskassan website/app (which is a calculator, not a planner) and shared spreadsheets. There is no dedicated native app that helps Swedish parents plan, track, and optimize their parental leave.

---

## 3. Target Audience

- **Primary:** Swedish parents expecting a child or with children aged 0-4 (peak leave usage)
- **Secondary:** Parents with children 4-12 (VAB tracking, remaining days)
- **Size:** ~115,000 births/year in Sweden = ~230,000 new parents annually
- **Characteristics:** Digitally native (97% internet usage in Sweden), high willingness to pay for family tools, active in parenting communities (mammagrupper/pappagrupper on Facebook, familjeliv.se)

---

## 4. Design & Style

### Visuell Identitet
- **Design system:** Clean Scandinavian minimalism. Think: Klarna meets Apple Health.
- **Färgpalett:**
  - Bakgrund: varm vit (#FFFDF3)
  - Kort/ytor: mjuk cream (#F5F3E9)
  - Blå accent (knappar, länkar, aktiva element): periwinkle (#839BEC)
  - Guld accent (highlights, premium, siffror): (#D3AA4E)
  - Röd/korall accent (varningar, deadlines, viktig info): (#DC6861)
  - Vit (#FFFFFF) för kort, modaler, input-fält
  - Text: mörkgrå/svart för kontrast mot den varma bakgrunden
  - Dark mode: inverterad palette -- mörk bakgrund (#1A1B2E) med samma accentfärger, cream → mörkgrå kort
- **Typography:** SF Pro (system font) for UI. Consider a warm serif like New York for headings/marketing screens.
- **Iconography:** SF Symbols throughout. Rounded, friendly.
- **Illustrations:** Optional -- simple line illustrations of families, not stock photos. Diverse family representations (same-sex couples, single parents, etc.).
- **Layout:** Card-based UI. Generous whitespace. Large touch targets (parents often use phones one-handed while holding a baby).

### UX Principles
1. **One-handed use** -- everything reachable with thumb
2. **Glanceable** -- the home screen answers "how many days do we have left?" in under 1 second
3. **Partner-aware** -- the app always shows both parents' status side by side
4. **No login required for basic use** -- only needed for partner sync
5. **Offline-first** -- all calculations happen on-device

---

## 5. Killer Features

### 5.1 "Scenarioplannern" (The Scenario Planner)

A visual timeline where parents can drag and drop leave blocks for each parent across the child's first years. The app instantly calculates:
- Total income impact per month for the household
- How many days remain in each category
- Whether any days will expire unused
- Optimal split to maximize household income
- Side-by-side comparison of up to 3 different plans

No other app or tool offers this visual, interactive planning experience for Swedish parental leave.

### 5.2 "Fråga Appen" (AI Parental Leave Advisor)

The app encodes the **entire** Swedish parental leave rule system -- every rule, exception, edge case, and deadline from Försäkringskassan -- and combines it with an AI chat assistant (powered by Claude API) that gives **personalized answers** based on the family's specific situation.

Parents ask in plain Swedish and get instant, accurate answers:

- "Kan jag överlåta mina dagar till min sambo?"
- "Vi tjänar olika mycket, hur borde vi dela för att maximera inkomsten?"
- "Jag jobbar deltid 75%, hur påverkar det min SGI?"
- "Vilka dagar försvinner om vi inte tar dem innan Ella fyller 4?"
- "Min arbetsgivare betalar ut 90% i 6 månader -- hur ska vi tänka?"
- "Vi väntar tvillingar, får vi fler dagar?"
- "Kan jag ta föräldraledigt och jobba halvdagar samtidigt?"

**Why this is transformative:**
- Försäkringskassan's phone line has 45+ minute wait times
- Their website is a maze of legal text that parents don't understand
- Google results are outdated (rules change yearly)
- The AI knows the current rules AND the family's exact situation (incomes, days taken, child's age)
- It's like having a personal Försäkringskassan handläggare available 24/7 in your pocket

**How it works technically:**
1. A comprehensive `ParentalLeaveKnowledgeBase` encodes all rules as structured data + natural language documentation
2. The family's situation (incomes, children, days taken/planned, employer top-ups) is injected as context
3. Claude API processes the question with full rules + family context and returns a personalized answer
4. Answers include specific numbers ("Med din inkomst på 45 000 kr/mån får du 987 kr/dag före skatt")
5. When relevant, the AI suggests actions in the app ("Vill du att jag lägger till det i din plan?")

**Safety:** Every response includes a disclaimer linking to Försäkringskassan for official verification. The AI is instructed to say "Det vet jag inte säkert, kontakta Försäkringskassan" rather than guess on edge cases.

---

## 6. MVP Features (v1.0 -- App Store Launch)

### 6.1 Onboarding (3 screens max)
- Screen 1: "Welcome" -- select number of parents (1 or 2)
- Screen 2: Enter child's birth date (or expected date)
- Screen 3: Enter each parent's monthly gross income (SEK)
- Optional: employer top-up info (percentage, duration)

### 6.2 Dashboard (Hemskärm)
- **Dagräknare** -- stor, prominent visning (blå #839BEC):
  - Totalt kvarvarande dagar (av 480)
  - Per förälder: delade dagar, reserverade dagar
  - Dagar på sjukpenningnivå vs. lägstanivå (180 kr/dag)
- **Inkomstöversikt** -- guld (#D3AA4E) kort som visar:
  - Aktuell månadsinkomst under ledighet (~X kr/mån)
  - Jämförelse med vanlig lön (du behåller Y%)
- **Aktuell status** -- vem som är ledig just nu, vilken typ
- **Nästa deadline** -- röd (#DC6861) highlight för när dagar löper ut
- **Snabbåtgärder** -- "Logga en ledighetsdag", "Logga en VAB-dag", "Planera framåt"
- **Bakgrund:** #FFFDF3, kort i vit (#FFFFFF) och cream (#F5F3E9)

### 6.3 Day Tracker
- Calendar view showing:
  - Days taken by Parent 1 (color A)
  - Days taken by Parent 2 (color B)
  - VAB days (color C)
  - Planned future days (lighter shade)
- Tap a day to log: type (föräldrapenning, VAB, obetald), which parent
- Weekly/monthly summary view

### 6.4 Scenarioplaneraren (Killer Feature)
- Visuell tidslinje: horisontellt scrollande Gantt-liknande vy
- Dra för att skapa ledighetsblock per förälder
  - Förälder 1: blå (#839BEC) block
  - Förälder 2: guld (#D3AA4E) block
- Beräkningspanel i realtid som visar:
  - Hushållets månadsinkomst under planen (guld #D3AA4E, stor text)
  - Förbrukade dagar per kategori
  - Varningar (dagar som löper ut, överskrider gränser) i röd (#DC6861)
- Spara upp till 3 scenarier och jämför dem
- "Optimera"-knapp som föreslår inkomstmaximerande uppdelning
- Bakgrund: #FFFDF3, kort: vit (#FFF), cream (#F5F3E9) för sektioner

### 6.5 VAB Tracker
- Log VAB days per child
- Running counter: days used this year / 120 limit
- History view
- Reminder when approaching limit

### 6.6 Income Calculator
- Input: monthly gross income per parent
- Input: employer top-up (% and duration, e.g., "90% for 6 months")
- Calculates:
  - Daily SGI-based amount (80% of income, capped at 10 prisbasbelopp)
  - Monthly income on leave vs. working
  - Total household income impact of any plan

### 6.7 AI Advisor -- "Fråga Appen" (Killer Feature #2)

**Chat interface:**
- Clean chat UI at the bottom tab bar (conversation icon)
- The AI introduces itself: "Hej! Jag kan hela föräldraförsäkringen. Fråga mig vad som helst om er ledighet."
- Suggested starter questions shown as tappable chips:
  - "Hur många dagar har vi kvar?"
  - "Hur bör vi dela dagarna?"
  - "Vad händer om jag jobbar deltid?"
  - "Förklara SGI för mig"

**Context-aware responses:**
- The AI always has access to the family's current data (incomes, child age, days taken, active plan)
- Responses are personalized with real numbers, not generic
- Example: "Eftersom du tjänar 52 000 kr/mån och din partner tjänar 38 000 kr/mån, sparar ni 4 200 kr/mån om du tar ledigt först (tack vare arbetsgivarens utfyllnad)."

**Actionable suggestions:**
- When the AI recommends a plan change, it can offer a button: "Lägg till i scenarioplannern"
- Links to relevant in-app screens (e.g., "Se din VAB-översikt")
- Links to Försäkringskassan for official applications

**Conversation history:**
- Saved locally per family
- Searchable -- find that answer you got last week
- Exportable as PDF (for sharing with partner or employer)

**Safety guardrails:**
- Disclaimer on every session: "Jag ger vägledning baserad på gällande regler. Verifiera alltid med Försäkringskassan innan du ansöker."
- The AI explicitly says "Det vet jag inte säkert" rather than hallucinate on genuine edge cases
- A feedback button on each response ("Var detta rätt?") for quality monitoring

### 6.8 Inställningar & Info
- Redigera familjeuppgifter (inkomster, barnets födelsedatum, etc.)
- Informationssidor som förklarar reglerna för föräldraledighet (klarspråk, inte juridisk jargong)
- Länkar till Försäkringskassan för officiella ansökningar

---

## 7. Features NOT in MVP (Future Versions)

- **Partner sync** via iCloud or invite code (v1.1)
- **Push notifications** for deadlines and reminders (v1.1)
- **BankID authentication** for importing data from Försäkringskassan (v2.0 -- complex, requires partnership)
- **Förskola queue tracking** integration (v2.0)
- **Barnbidrag and other benefits** overview (v2.0)
- **Apple Watch complication** showing days remaining (v1.2)
- **Widgets** for home screen (v1.1)
- **Export** plan as PDF to share with employer (v1.1)
- **Multiple children** support (v1.1)

---

## 8. Technical Architecture

### Platform
- **Language:** Swift 6
- **UI Framework:** SwiftUI
- **Minimum iOS:** 17.0
- **Persistence:** SwiftData (local-first)
- **AI:** Claude API (claude-sonnet-4-6 for fast, affordable responses)
- **Architecture:** MVVM with @Observable

### Data Model (Core)

```swift
@Model
class Family {
    var id: UUID
    var parents: [Parent]
    var children: [Child]
    var scenarios: [Scenario]
    var createdAt: Date
}

@Model
class Parent {
    var id: UUID
    var name: String
    var monthlyGrossIncome: Decimal // SEK
    var employerTopUpPercentage: Decimal? // e.g., 0.90 for 90%
    var employerTopUpMonths: Int? // e.g., 6
    var leaveDays: [LeaveDay]
}

@Model
class Child {
    var id: UUID
    var name: String?
    var birthDate: Date // or expected date
    var isborn: Bool
}

@Model
class LeaveDay {
    var id: UUID
    var date: Date
    var parentId: UUID
    var type: LeaveDayType // .foraldrapenning, .vab, .unpaid
    var payLevel: PayLevel // .sgiLevel (80%), .basicLevel (180 SEK), .none
    var isPlanned: Bool // false = actually taken, true = planned future
}

enum LeaveDayType: String, Codable {
    case foraldrapenning
    case vab
    case unpaid
}

enum PayLevel: String, Codable {
    case sgiLevel  // ~80% of income (capped)
    case basicLevel // 180 SEK/day
    case none
}

@Model
class Scenario {
    var id: UUID
    var name: String
    var leaveBlocks: [LeaveBlock]
    var createdAt: Date
}

@Model
class LeaveBlock {
    var id: UUID
    var parentId: UUID
    var startDate: Date
    var endDate: Date
    var payLevel: PayLevel
}
```

### Key Calculations Engine

```
// Prisbasbelopp 2026 (update yearly)
let prisbasbelopp2026: Decimal = 58_800

// SGI cap = 10 * prisbasbelopp
let sgiCap: Decimal = 10 * prisbasbelopp2026

// Daily SGI-based payment = (min(yearlyIncome, sgiCap) * 0.80) / 365
func dailySGIPayment(monthlyIncome: Decimal) -> Decimal {
    let yearly = monthlyIncome * 12
    let capped = min(yearly, sgiCap)
    return (capped * 0.80) / 365
}

// Basic level = 180 SEK/day (flat)
let basicLevelDaily: Decimal = 180

// Total days: 480 per child
// High-pay days: 390
// Basic-level days: 90
// Reserved per parent: 90 days (cannot be transferred)
// Shared days: 480 - 90 - 90 = 300 (can be split freely)
```

### AI Advisor Architecture

```
[User Question (Swedish)]
        |
        v
[AIAdvisorService]
  1. Loads ParentalLeaveKnowledgeBase (rules, thresholds, edge cases)
  2. Serializes FamilyContext (incomes, children, days taken, current plan)
  3. Builds system prompt with rules + context
  4. Sends to Claude API (claude-sonnet-4-6)
        |
        v
[Claude API Response]
        |
        v
[Parse response + extract any suggested actions]
        |
        v
[Display in chat UI with optional action buttons]
```

**System Prompt Structure:**
```
Du är en expert på det svenska föräldraförsäkringssystemet. Du hjälper föräldrar att förstå
och planera sin föräldraledighet. Svara ALLTID på svenska.

REGLER:
{ParentalLeaveKnowledgeBase - full rules document}

FAMILJENS SITUATION:
- Förälder 1: {name}, inkomst {income} kr/mån, arbetsgivare fyller ut {topup}%, {days_taken} dagar tagna
- Förälder 2: {name}, inkomst {income} kr/mån, arbetsgivare fyller ut {topup}%, {days_taken} dagar tagna
- Barn: {name}, född {date}, ålder {age}
- Dagar kvar: {remaining} av 480 ({high_pay} på SGI-nivå, {low_pay} på grundnivå)
- Reserverade dagar: Förälder 1: {x} kvar, Förälder 2: {y} kvar

INSTRUKTIONER:
- Ge personliga svar baserade på familjens situation ovan
- Använd konkreta siffror (kronor, dagar, datum)
- Om du inte är säker på svaret, säg det och hänvisa till Försäkringskassan
- Föreslå åtgärder i appen när det är relevant
- Var varm, stöttande och tydlig -- föräldrarna är ofta stressade och sömnlösa
```

**ParentalLeaveKnowledgeBase (comprehensive rules document):**
```swift
struct ParentalLeaveKnowledgeBase {
    // This is a large structured document (~3000-5000 tokens) covering:

    // 1. GRUNDREGLER
    // - 480 dagar totalt per barn
    // - 390 dagar på sjukpenningnivå (SGI-nivå, ~80% av inkomsten)
    // - 90 dagar på grundnivå (180 kr/dag)
    // - 90 reserverade dagar per förälder (kan ej överlåtas)
    // - 300 delade dagar (kan fördelas fritt)

    // 2. SGI-BERÄKNING
    // - SGI = Sjukpenninggrundande inkomst = årsinkomst (capped)
    // - Cap: 10 × prisbasbelopp (588 000 kr 2026)
    // - Dagbelopp = SGI × 0.97 × 0.80 / 365 (sjukpenningnivå)
    // - Karensdagar: inga vid föräldrapenning
    // - SGI-skydd under föräldraledighet

    // 3. ARBETSGIVARUTFYLLNAD
    // - Vanligt: 10% utfyllnad i 6-12 månader (totalt ~90% av lön)
    // - Varierar per kollektivavtal
    // - Statligt anställda: 6 månader via Villkorsavtalet
    // - Privat (Teknikavtalet, Handels, etc.): oftast 6 månader

    // 4. TIDSFRISTER
    // - Dagar på SGI-nivå: innan barnet fyller 4 år (undantag: 96 dagar kan sparas till 12)
    // - Dagar på grundnivå: innan barnet fyller 12 år
    // - Ansökan: retroaktivt upp till 90 dagar

    // 5. DELTID & KOMBINATIONER
    // - Kan ta ut 100%, 75%, 50%, 25% eller 12.5% av en dag
    // - Möjligt att kombinera deltidsarbete med deltidsföräldrapenning
    // - SGI påverkas vid längre deltidsarbete

    // 6. SÄRSKILDA SITUATIONER
    // - Tvillingar: +180 dagar (totalt 660)
    // - Ensamstående: alla 480 dagar till en förälder
    // - Adoption: samma regler, räknas från barnets ankomst
    // - Sjukt barn + föräldraledighet: kan byta till VAB
    // - Separation: dagarna följer barnet, ej föräldern

    // 7. VAB (VÅRD AV BARN)
    // - 120 dagar per barn per år
    // - Barnet: 8 mån - 12 år
    // - Ersättning: ~80% av SGI
    // - Smittbärarpeng: om barnet har smittsam sjukdom

    // 8. TIPS & OPTIMERING
    // - Den med högst inkomst bör ofta ta ledigt först (arbetsgivarutfyllnad)
    // - Grundnivådagar (180 kr) bör tas sist eller under lågsäsong
    // - Spara inte för många dagar -- de minskar i reellt värde (inflation)
    // - Ansök i tid -- retroaktivt max 90 dagar

    // 9. VANLIGA MISSFÖRSTÅND
    // - "Man måste dela 50/50" -- Nej, bara 90 reserverade dagar per förälder
    // - "Dagarna tar slut vid 1 år" -- Nej, de gäller upp till 4/12 år
    // - "Man kan inte jobba alls" -- Jo, deltidsuttag är möjligt
    // - "SGI försvinner om man är ledig länge" -- SGI-skydd finns under föräldraledighet
}
```

**Cost estimation for AI feature:**
- Claude Sonnet: ~$3/1M input tokens, ~$15/1M output tokens
- Avg conversation: ~4000 input tokens (rules + context + question), ~500 output tokens (response)
- Cost per question: ~$0.02
- At 5 questions/user/month, 1000 active users = ~$100/month
- Well within premium subscription revenue

### Local-First + AI Hybrid
- All data stored locally in SwiftData (works offline)
- Calculations (days remaining, income) are deterministic and work offline
- AI advisor requires internet connection (shows "Ingen anslutning -- AI-rådgivaren kräver internet" when offline)
- Partner sync in v1.1 via CloudKit or shared iCloud container

---

## 9. APIs & External Dependencies

### MVP: Claude API (for AI Advisor)

**Anthropic Claude API:**
```
Base URL: https://api.anthropic.com/v1/messages
Model: claude-sonnet-4-6 (best balance of quality, speed, and cost for Swedish language)
Auth: API key (X-API-Key header)
Pricing: ~$3/1M input, ~$15/1M output tokens
Latency: 1-3 seconds for typical responses

Implementation:
- Call directly from iOS app (API key stored in Keychain, obfuscated in binary)
- OR: Thin proxy server to protect API key (recommended for production)
  - Simple Cloudflare Worker or Hetzner VPS that forwards requests
  - Adds rate limiting per user (prevent abuse)
  - Allows switching models without app update
```

**Proxy server (recommended):**
```
POST https://api.foraldradagar.se/v1/ask
Headers: X-Device-ID: {uuid}, X-Premium-Token: {storekit_receipt_token}
Body: { "question": "...", "family_context": { ... } }

The proxy:
1. Validates premium subscription (receipt validation)
2. Rate limits (20 questions/day per user)
3. Injects the ParentalLeaveKnowledgeBase server-side (saves tokens, keeps rules updatable)
4. Forwards to Claude API
5. Returns response
```

### Future versions:
| API | Purpose | Version |
|-----|---------|---------|
| CloudKit / iCloud | Partner sync | v1.1 |
| Försäkringskassan (if available) | Import actual days taken | v2.0 |
| BankID (Freja eID as alternative) | Identity verification for sync | v2.0 |

### Data that must be hardcoded and updated yearly:
- Prisbasbelopp (updated by SCB each year, announced in autumn)
- SGI calculation rules
- VAB day limits
- Basic level amount (180 SEK/day -- rarely changes)
- Tax tables (optional, for net income estimates)

Create a `SwedishParentalLeaveRules` configuration file that can be updated via App Store updates or remote config.

---

## 10. Monetization

### Model: Freemium with subscription

**Free tier:**
- Dashboard with days remaining
- Day logging (föräldraledighet + VAB)
- Basic income calculator
- 1 scenario

**Premium tier ("Föräldradagar Pro"):**
- **AI-rådgivare** -- fråga vad som helst om föräldraledighet och få personliga svar (killer feature)
- Unlimited scenarios in Scenario Planner
- Income optimization suggestions
- Partner sync
- Widgets
- Export to PDF
- Priority support

**Pricing:**
- Weekly: 29 SEK/week (with 3-day free trial)
- Annual: 249 SEK/year (best value, promoted)
- Lifetime: 499 SEK (one-time)

**Paywall placement:** Let users ask 3 free AI questions (so they experience the magic), then gate continued access behind premium. Also soft paywall when creating a 2nd scenario or accessing optimization.

---

## 11. App Store Optimization (ASO)

### Keywords (Swedish)
Primary: föräldraledighet, föräldrapenning, föräldradagar, VAB
Secondary: försäkringskassan, barnledigt, föräldraledig, mammaledighet, pappaledighet
Long-tail: planera föräldraledighet, föräldrapenning kalkylator, VAB dagar kvar

### App Name
`Föräldradagar - Ledighetsplanerare`

### Subtitle
`Planera och spåra föräldraledighet & VAB`

### App Store Description (first 3 lines are critical)
```
Föräldradagar hjälper svenska föräldrar att planera, spåra och optimera sin föräldraledighet. Ställ vilken fråga som helst om föräldrapenning, VAB eller era dagar -- och få personliga svar direkt i appen.

Funktioner:
- AI-rådgivare som kan hela föräldraförsäkringen -- fråga på svenska, få svar på sekunder
- Se alla 480 dagar i en tydlig översikt
- Planera ledigheten med vår visuella scenarioplanerare
- Spåra VAB-dagar automatiskt
- Beräkna inkomstpåverkan för olika upplägg
- Stöd för två föräldrar med delning av dagar
- Slipp 45 minuters telefonkö till Försäkringskassan
```

---

## 12. Launch Strategy

1. **Pre-launch:** Post in Swedish parenting Facebook groups and familjeliv.se forums. Build an email list via a simple landing page.
2. **Launch day:** Submit to Swedish tech blogs (di.se/digital, breakit.se). Post on Twitter/X with #föräldraledighet hashtag.
3. **Ongoing:** SEO via a blog with articles like "Hur planerar man föräldraledighet 2026?" targeting Google searches.
4. **Partnerships:** Reach out to barnmorskemottagningar (midwife clinics) who give new parents information packets. A QR code in their materials would be high-converting.

---

## 13. Success Metrics

| Metric | Target (6 months) |
|--------|-------------------|
| Downloads | 10,000 |
| DAU/MAU ratio | 30%+ (daily tracking behavior) |
| AI questions asked/user/month | 5+ |
| Trial-to-paid conversion | 12%+ (AI advisor drives higher conversion) |
| App Store rating | 4.7+ |
| MRR | 20,000 SEK |
| AI cost per paying user/month | < 1 SEK |

---

## 14. Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Parental leave rules change | Modular rules engine; update knowledge base server-side without app update. Monitor Försäkringskassan. |
| AI gives incorrect advice | Comprehensive knowledge base reduces hallucination. Disclaimer on every response. "Unsure" fallback. User feedback button. |
| AI costs grow with scale | Sonnet is cheap (~2 öre/fråga). Rate limit free tier. Cache common Q&A pairs. Monitor spend per user. |
| Försäkringskassan builds this feature | They won't -- government apps are notoriously bad at UX. They'll never add AI. Focus on planning, not filing. |
| Small market (Sweden only) | Låg konkurrens ger hög konvertering. Möjlig expansion till Norge (foreldrepenger) / Danmark (barselsdagpenge) i v2 -- samma AI-arkitektur, ny kunskapsbas. |
| Incorrect calculations causing user harm | Prominent disclaimer: "Appen ger uppskattningar för planeringsändamål. Verifiera alltid med Försäkringskassan." |
| Apple rejects AI chat feature | AI chat in apps is well-established (Copilot, ChatGPT, etc.). Ensure compliance with App Store Review Guidelines 5.6 (AI-generated content). |
