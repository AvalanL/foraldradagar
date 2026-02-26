# Föräldradagar -- Onboarding Flow (20 steg + betalvägg)

## Designfilosofi

**Språk: Hela produkten är på svenska. Inget engelskt språkstöd.**

Inspirerad av "Quiz / Self-Identification Lead"-tekniken från direct response copywriting:
- Varje steg är ett **micro-commitment** som ökar användarens investering i appen
- Frågorna bygger en **personlig profil** så att betalväggen kan visa exakt värde
- Användaren identifierar sig själv ("Den här appen är för MIG") genom sina egna svar
- Vid steg 20 vet appen allt om deras situation -- vilket gör betalväggen oemotståndlig eftersom den kan visa **personliga besparingar och rekommendationer**
- Ton: varm, stöttande, aldrig klinisk. Det här är trötta, stressade, exalterade blivande föräldrar.

## Visuell Stil

- **Bakgrund:** #FFFDF3 (varm vit) som bas. Gradient skiftar subtilt med varje steg med cream (#F5F3E9).
- **Kort/valalternativ:** Vita (#FFFFFF) kort med mjuk skugga mot #FFFDF3-bakgrunden. Valt alternativ får #839BEC (blå) kantlinje + lätt blå bakgrund.
- **Knappar:** Primär CTA = #839BEC (blå) med vit text. Sekundära knappar = #F5F3E9 med mörk text.
- **Siffror/belopp:** Guld (#D3AA4E) för framhävda belopp (kr/dag, kr/mån). Ger premium-känsla.
- **Varningar/deadlines:** Röd/korall (#DC6861) för viktiga datum och varningar.
- **Framsteg:** Tunn framstegsindikator i #839BEC högst upp (inga siffror -- känns lättare än "Steg 7 av 20")
- **Animationer:** Varje skärm glider in mjukt. Valda alternativ har en tillfredsställande haptisk feedback + skalanimation.
- **Typografi:** Stora, varma rubriker (New York serif). Ren brödtext (SF Pro). Belopp i guld (#D3AA4E).
- **Val-UI:** Stora tryckbara kort (#FFFFFF) mot #FFFDF3-bakgrund, inte små radioknappar. Envänligt för enhandsanvändning.
- **Illustration:** Valfri liten illustration per skärm (enkel linjekonst, olika familjer). Illustrationer i dämpade versioner av accentfärgerna.
- **Hoppa över:** Ingen hoppa över-knapp. Varje steg är viktigt och matar AI:n. Men "tillbaka"-pil finns alltid.

---

## De 20 Stegen

### BLOCK 1: VÄLKOMMEN (Steg 1-3) -- Emotionell Hook

---

**Steg 1: Välkommen / Emotionell Hook**

```
[Bakgrund: #FFFDF3]
[Mjuk illustration: två föräldrar som håller en bebis -- linjekonst i #839BEC]

Grattis! 🎉                              ← guld (#D3AA4E)

Att bli förälder är livets största äventyr.
Vi hjälper dig att planera ledigheten
så du kan fokusera på det som verkligen räknas.

[Kom igång →]                             ← blå knapp (#839BEC), vit text
```

*Syfte: Emotionell koppling. Sätter tonen. Enda CTA.*

---

**Steg 2: Vem är du?**

```
[Bakgrund: #FFFDF3]

Vem planerar?

┌─────────────────────────────┐  ← vita kort (#FFF), mjuk skugga
│  👫  Vi är två föräldrar     │    valt = #839BEC kantlinje
└─────────────────────────────┘
┌─────────────────────────────┐
│  👤  Jag är ensamstående     │
└─────────────────────────────┘
```

*Syfte: Grundläggande förgrening. Påverkar alla framtida beräkningar (480 dagar delat vs. ensam). Självidentifiering börjar.*

---

**Steg 3: Var i resan är ni?**

```
Var är ni i resan?

┌─────────────────────────────┐
│  🤰  Vi väntar barn          │
│     Beräknad födsel snart    │
└─────────────────────────────┘
┌─────────────────────────────┐
│  👶  Barnet är fött           │
│     Redan igång med ledighet │
└─────────────────────────────┘
┌─────────────────────────────┐
│  📋  Vi planerar i förväg     │
│     Inte gravida än          │
└─────────────────────────────┘
```

*Syfte: Bestämmer hur brådskande det är och vilka funktioner som lyfts fram. "Vi planerar i förväg" = fokus på scenarioplaneraren. "Barnet är fött" = fokus på dagräknaren.*

---

### BLOCK 2: BARNET (Steg 4-6) -- Barnet

---

**Steg 4: När är/var barnet fött?**

```
[If "väntar barn":]
När är beräknat födelsedatum (BF)?

[Datumväljare -- standard ~3 månader framåt]

[If "barnet är fött":]
När föddes ert barn?

[Datumväljare]

[If "planerar i förväg":]
Ungefär när planerar ni att få barn?

[Månad/År-väljare -- ungefärligt räcker]
```

*Syfte: Kritiskt för alla beräkningar -- utgångsdatum för dagar, aktuell ålder, planeringstidslinje.*

---

**Steg 5: Flerbarnsbörd?**

```
Väntar ni fler än ett barn?

┌─────────────────────────────┐
│  👶  Ett barn                 │
└─────────────────────────────┘
┌─────────────────────────────┐
│  👶👶  Tvillingar             │
│     +180 extra dagar!        │
└─────────────────────────────┘
┌─────────────────────────────┐
│  👶👶👶  Trillingar eller fler │
│     Ännu fler dagar          │
└─────────────────────────────┘
```

*Syfte: Tvillingar = 660 dagar istället för 480. Stor skillnad i beräkningar. "+180 extra dagar!" är en positiv överraskning som bygger goodwill.*

---

**Steg 6: Är detta ert första barn?**

```
Är detta ert första barn?

┌─────────────────────────────┐
│  🌟  Ja, vårt första!        │
└─────────────────────────────┘
┌─────────────────────────────┐
│  👨‍👩‍👧  Nej, vi har barn sedan │
│     innan                    │
└─────────────────────────────┘
```

*Syfte: Förstagångsföräldrar behöver mer utbildning (AI-rådgivaren blir mer värdefull). Erfarna föräldrar kan ha kvarvarande dagar från tidigare barn. Påverkar även framtida flerbarnssstöd.*

---

### BLOCK 3: FÖRÄLDRARNA (Steg 7-12) -- Föräldrarna

---

**Steg 7: Förälder 1 -- Namn**

```
Vad heter du?

[Textfält: "Förnamn"]

Vi använder namn för att göra planen
personlig -- inte för att skapa konto.
```

*Syfte: Personalisering. Gör varje framtida skärm personlig ("Saras dagar", "Ahmeds inkomst"). Micro-commitment: att skriva sitt namn = investering.*

---

**Steg 8: Förälder 1 -- Inkomst**

```
Vad är din ungefärliga månadslön
före skatt, {name}?

[Slider: 15 000 -- 80 000+ SEK]
[Eller textfält för exakt belopp]

[Live-beräkning som uppdateras medan slidern dras:]

┌─────────────────────────────────────┐
│                                     │
│  Din föräldrapenning:               │
│                                     │
│  💰  {X} kr/dag                     │  ← guld (#D3AA4E)
│  📅  ~{X×30} kr/mån                 │  ← guld (#D3AA4E), STOR text
│                                     │
│  Jämfört med din lön:               │
│  Du behåller ~{Y}% av inkomsten     │
│                                     │
└─────────────────────────────────────┘
```

*Syfte: Kritiskt för SGI-beräkning. LIVE-beräkningen medan de drar i slidern är ett magiskt ögonblick -- "wow, appen beräknar mitt exakta belopp." Månadsbeloppet är det som verkligen landar -- föräldrar tänker i månadsinkomst, inte dagbelopp. Procentandelen av lön gör det ännu mer konkret.*

---

**Steg 9: Förälder 1 -- Arbetsgivarutfyllnad**

```
Fyller din arbetsgivare ut lönen
under föräldraledigheten?

Många arbetsgivare betalar upp till 90%
av lönen de första månaderna.

┌─────────────────────────────┐
│  ✅  Ja                      │
└─────────────────────────────┘
┌─────────────────────────────┐
│  ❌  Nej                     │
└─────────────────────────────┘
┌─────────────────────────────┐
│  🤷  Vet inte                │
└─────────────────────────────┘

[If "Ja":]
Hur mycket och hur länge?

Utfyllnad: [80%] [85%] [90%] [100%]
Antal månader: [3] [6] [9] [12]
```

*Syfte: Arbetsgivarutfyllnad påverkar dramatiskt den optimala planeringen. "Vet inte" minskar friktion -- AI:n kan råda dem att kolla senare. Utbildar föräldrar som inte visste att detta fanns.*

---

**Steg 10: Förälder 2 -- Namn** *(bara om "två föräldrar" i steg 2)*

```
Vad heter din partner?

[Textfält: "Förnamn"]
```

---

**Steg 11: Förälder 2 -- Inkomst** *(bara om "två föräldrar")*

```
Vad är {partner_name}s ungefärliga
månadslön före skatt?

[Slider: 15 000 -- 80 000+ SEK]
[Eller textfält för exakt belopp]

[Live-beräkning:]

┌─────────────────────────────────────┐
│                                     │
│  {partner_name}s föräldrapenning:   │
│                                     │
│  💰  {X} kr/dag                     │
│  📅  ~{X×30} kr/mån                 │  ← guld (#D3AA4E)
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  💡 Er samlade hushållsinkomst:     │
│     {name} + {partner}: {X+Y} kr/mån│
│                                     │
│     Under ledighet beror inkomsten  │
│     på vem som är hemma och när.    │
│                                     │
└─────────────────────────────────────┘
```

*Syfte: Dubbla inkomster möjliggör optimeringsfunktionen. Att visa partnerns månadsbelopp direkt (inte bara dagbelopp) gör det konkret. Hushållsinkomsten förbereder dem för premium-funktionen "inkomstoptimering".*

---

**Steg 12: Förälder 2 -- Arbetsgivarutfyllnad** *(bara om "två föräldrar")*

```
Fyller {partner_name}s arbetsgivare
ut lönen?

┌─────────────────────────────┐
│  ✅  Ja                      │
└─────────────────────────────┘
┌─────────────────────────────┐
│  ❌  Nej                     │
└─────────────────────────────┘
┌─────────────────────────────┐
│  🤷  Vet inte                │
└─────────────────────────────┘

[Samma uppföljning som steg 9 om "Ja"]
```

---

### BLOCK 4: ER PLAN (Steg 13-16) -- Nuvarande situation & preferenser

---

**Steg 13: Har ni redan tagit ut dagar?** *(bara om "barnet är fött")*

```
Har ni redan tagit ut föräldradagar?

┌─────────────────────────────┐
│  📅  Ja, vi har börjat       │
└─────────────────────────────┘
┌─────────────────────────────┐
│  🔜  Nej, inte än            │
└─────────────────────────────┘

[If "Ja":]
Ungefär hur många dagar har ni tagit?

{name}: [____] dagar
{partner}: [____] dagar

💡 Du kan justera detta senare.
   Vi hjälper dig räkna ut exakt antal.
```

*Syfte: För föräldrar som redan är lediga -- fyller dagräknaren med initiala data. Ungefärligt är okej; AI:n kan hjälpa dem beräkna exakta siffror senare (premium-hook).*

---

**Steg 14: Vad är viktigast?**

```
Vad är viktigast för er?

Välj det som stämmer bäst:

┌─────────────────────────────┐
│  💰  Maximera inkomsten      │
│     Tappa så lite pengar     │
│     som möjligt              │
└─────────────────────────────┘
┌─────────────────────────────┐
│  ⚖️  Dela lika                │
│     Båda ska vara hemma      │
│     ungefär lika länge       │
└─────────────────────────────┘
┌─────────────────────────────┐
│  🏠  Längsta möjliga ledighet │
│     Maximera tiden hemma     │
│     oavsett pengar           │
└─────────────────────────────┘
┌─────────────────────────────┐
│  🤔  Vet inte -- hjälp mig!  │
│     Jag vill se alla         │
│     alternativ               │
└─────────────────────────────┘
```

*Syfte: Självidentifiering när den är som bäst. Varje val förbereder för olika premiumfunktioner (inkomstoptimerare, scenarioplanerare, AI-rådgivare). "Vet inte"-segmentet konverterar bäst till AI-rådgivare premium.*

---

**Steg 15: Förskoleplaner?**

```
Planerar ni förskola?

┌─────────────────────────────┐
│  🏫  Ja, så tidigt som       │
│     möjligt (från ~1 år)     │
└─────────────────────────────┘
┌─────────────────────────────┐
│  🏡  Vi vill vara hemma      │
│     längre (2-3 år)          │
└─────────────────────────────┘
┌─────────────────────────────┐
│  🤷  Har inte bestämt        │
└─────────────────────────────┘
```

*Syfte: Påverkar planeringstidslinjen och brådskan att använda dagar innan de går ut. Matar scenarioplanerens standardvärden.*

---

**Steg 16: Hur bra koll har du?**

```
Hur bra koll har du på reglerna
för föräldrapenning?

┌─────────────────────────────┐
│  😅  Nybörjare               │
│     Jag vet typ ingenting    │
└─────────────────────────────┘
┌─────────────────────────────┐
│  📖  Lite koll               │
│     Jag vet grunderna        │
└─────────────────────────────┘
┌─────────────────────────────┐
│  🧠  Ganska bra koll         │
│     Har läst på en del       │
└─────────────────────────────┘
```

*Syfte: Två saker samtidigt: (1) kalibrerar hur mycket AI:n förklarar, (2) "Nybörjare"-användare inser att de BEHÖVER AI-rådgivaren = högre konvertering. Sätter perfekt upp värdeerbjudandet på betalväggen.*

---

### BLOCK 5: DIN PERSONLIGA SAMMANFATTNING (Steg 17-20) -- Utdelningen

---

**Steg 17: Din personliga sammanfattning (Det magiska ögonblicket)**

```
[Animerad beräkning -- siffror som räknar upp]
[2-3 sekunders uppbyggnad med framstegsanimation]

✨ Er föräldraledighet i siffror:

┌─────────────────────────────────────┐
│                                     │
│  480 dagar totalt                   │  ← blå (#839BEC)
│                                     │
│  {name}                {partner}    │
│  ━━━━━━━━━━            ━━━━━━━━━━  │
│  90 reserverade        90 reserv.   │
│  +150 delade           +150 delade  │
│  ─────────             ─────────    │
│  240 dagar             240 dagar    │
│                                     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  💰 INKOMST UNDER LEDIGHETEN        │
│                                     │
│  {name}:                            │
│  ~{X×30} kr/mån                     │  ← STOR guld (#D3AA4E)
│  ({Y}% av din lön)                  │
│                                     │
│  {partner}:                         │
│  ~{Z×30} kr/mån                     │  ← STOR guld (#D3AA4E)
│  ({W}% av din lön)                  │
│                                     │
│  [Om arbetsgivarutfyllnad finns:]   │
│  Med utfyllnad: ~{högre} kr/mån     │  ← grön highlight
│  de första {N} månaderna            │
│                                     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  ⏰ VIKTIGA DATUM                    │  ← röd (#DC6861)
│                                     │
│  Dagarna gäller till: {date}        │
│  Spargräns (96 dagar) vid: {date4}  │
│                                     │
└─────────────────────────────────────┘

🎯 Baserat på era inkomster kan vi
   optimera er plan. Mer om det strax!

[Nästa →]                               ← blå knapp (#839BEC)
```

*Syfte: DEN stora utdelningen för att ha svarat på 16 frågor. Användaren ser sina personliga siffror för första gången. Det här är "wow"-ögonblicket. Månadsbeloppet i guld är det som verkligen landar -- "så mycket pengar får vi varje månad." Arbetsgivarutfyllnaden visar den högre siffran först = positiv överraskning. Deadlines i rött skapar brådska utan panik.*

---

**Steg 18: Din första insikt (AI-driven teaser)**

```
[Personlig insikt baserad på deras svar]

💡 Visste du?

[Dynamiskt -- en av dessa baserat på situation:]

IF income_difference > 10000:
"Eftersom {high_earner} tjänar mer lönar det sig
att {high_earner} tar ledigt först -- ni får
~{X} kr/mån med utfyllnad istället för ~{Y} kr/mån
utan. Det är {Z} kr mer varje månad!"       ← belopp i guld (#D3AA4E)

IF both_have_topup:
"Ni har båda arbetsgivarutfyllnad! Genom att
tajma ledigheten rätt kan ni behålla nästan
full lön (~{X} kr/mån) i {Y} månader."     ← belopp i guld (#D3AA4E)

IF first_child AND nybörjare:
"Som förstagångsföräldrar har ni {480} dagar att
planera. Vet du vilka dagar som försvinner om
ni inte tar dem innan {child} fyller 4?       ← datum i röd (#DC6861)
Det reder vi ut åt er."

IF ensamstående:
"Som ensamstående får du alla {480} dagar själv
och ~{X} kr/mån under ledigheten.             ← belopp i guld (#D3AA4E)
Det ger dig stor flexibilitet -- men det gäller
att planera smart så du inte tappar inkomst
i onödan."

[Nästa →]
```

*Syfte: Första smaken av AI:ns intelligens. Visar användaren att appen inte bara lagrar data -- den TÄNKER. Detta är bryggan till betalväggen. Demonstrerar värde utan att ge bort allt.*

---

**Steg 19: Vad AI:n kan hjälpa dig med (Funktionsvisning)**

```
Din personliga rådgivare

Ställ vilken fråga som helst om
föräldraledighet -- och få svar direkt.

[Chattbubbla-mockup som visar:]

👤 "Hur borde vi dela dagarna för att
    tjäna mest?"

🤖 "Baserat på era inkomster rekommenderar
    jag att {name} tar ledigt de första 8
    månaderna (arbetsgivarutfyllnad), sedan
    tar {partner} över i 6 månader. Det ger
    er {X} kr mer totalt jämfört med att
    dela 50/50."

👤 "Kan vi ta föräldraledigt samtidigt?"

🤖 "Ja! Ni kan ta upp till 60 dubbeldagar
    tills barnet är 15 månader. Sedan
    kan ni ta ut dagar parallellt, men det
    går snabbare åt av de 480 dagarna."

[Nästa →]
```

*Syfte: Visar exakt hur premium AI-rådgivaren ser ut. Att använda DERAS namn och situation i mockupen gör det verkligt och personligt. Användaren tänker nu "Jag vill ställa MINA frågor."*

---

**Steg 20: En sak till -- Notifikationer**

```
Vill du få en påminnelse innan
viktiga datum?

Vi kan meddela dig om:

☑️  Dagar som snart går ut
☑️  Tid att ansöka hos Försäkringskassan
☑️  Imorgons priser (om Elpriset-koppling finns)

┌─────────────────────────────┐
│  🔔  Ja, påminn mig          │
└─────────────────────────────┘
┌─────────────────────────────┐
│  🔕  Inte nu, kanske senare  │
└─────────────────────────────┘
```

*Syfte: Notifikationstillstånd begärs EFTER att värdet etablerats (inte vid första start). Högre opt-in-rate eftersom de nu förstår varför notifikationer är viktiga. Dessutom: sista steget innan betalväggen = ren övergång.*

---

## BETALVÄGGEN (Efter steg 20)

```
[Bakgrund: #FFFDF3 med mjuk konfettianimation i guld (#D3AA4E)]

Er plan är redo, {name}! 🎉

Baserat på era svar:

┌─────────────────────────────────────┐  ← vit (#FFF) kort
│                                     │
│  📊  480 dagar att planera          │  ← blå (#839BEC)
│  💰  ~{X} kr/mån under ledigheten   │  ← STOR guld (#D3AA4E)
│  ⏰  Reserverade dagar löper ut     │  ← röd (#DC6861)
│      {date}                         │
│  💡  Vi hittade {N} sätt att        │  ← blå (#839BEC)
│      optimera er plan               │
│                                     │
└─────────────────────────────────────┘

Med Föräldradagar Pro får du:

✅  AI-rådgivare -- fråga vad som helst
    om föräldraledighet, dygnet runt

✅  Scenarioplanerare -- jämför olika
    upplägg visuellt

✅  Inkomstoptimerare -- maximera er
    hushållsinkomst under ledigheten

✅  Exportera plan som PDF till
    arbetsgivaren

✅  Alla framtida funktioner inkluderade


[Priskort:]

┌──────────────────┐  ┌──────────────────┐
│  ÅRSPLAN         │  │  VECKOPLAN       │  ← vita kort (#FFF)
│                  │  │                  │
│  249 kr/år       │  │  29 kr/vecka     │  ← guld (#D3AA4E) pris
│                  │  │                  │
│  Bara 21 kr/mån  │  │  Med 3 dagars    │
│                  │  │  gratis provperiod│
│  ⭐ BÄST VÄRDE   │  │                  │
│  ← guld ram      │  │                  │
└──────────────────┘  └──────────────────┘

          ┌──────────────────┐
          │  KÖP EN GÅNG     │
          │  499 kr -- för alltid │
          └──────────────────┘

[Fortsätt med Pro →]               ← blå knapp (#839BEC), vit text
[Fortsätt med gratisversionen]      ← diskret text, alltid synlig
```

**Betalväggens psykologi:**
1. **Personligt värde** -- visar DERAS siffror, inte generiska löften
2. **"Vi hittade N sätt att optimera"** -- nyfikenhetsgap, de vill veta VAD
3. **Årsplanen lyfts fram** som bäst värde (lägre månadskostnad = lättare att motivera)
4. **Veckoplanen** har gratis provperiod (låg risk att börja)
5. **Livstid** för den beslutsamma köparen
6. **Gratisalternativet alltid synligt** -- inga mörka mönster, bygger tillit (och vissa gratisanvändare konverterar senare)
7. Hela onboardingen har varit en commitment-stege -- 20 små ja som leder till det stora ja:et

---

## Gratis vs. Premium efter betalväggen

**Om användaren väljer Gratis:**
- Dashboard med kvarvarande dagar (använder all onboarding-data)
- Dagloggning
- Enkel inkomstkalkylator
- 3 gratis AI-frågor (sedan låst)
- 1 scenario i planeraren (sedan låst)
- Periodiska mjuka påminnelser: "Du har {N} outforskade optimeringsmöjligheter"

**Om användaren väljer Premium:**
- Hela appen låses upp direkt
- AI-rådgivaren hälsar: "Hej {name}! Jag såg att du vill {prioritet från steg 14}. Vill du att vi börjar med en optimal plan?"
- Scenarioplaneraren förpopulerad med ett föreslaget startplan baserat på onboarding-data

---

## Tekniska Anteckningar

### Data som samlas in under onboarding

```swift
struct OnboardingData {
    // Step 2
    var familyType: FamilyType // .twoParents, .singleParent

    // Step 3
    var stage: FamilyStage // .expecting, .born, .planning

    // Step 4
    var childDate: Date // birth date or expected date

    // Step 5
    var multipleType: MultipleType // .single, .twins, .triplets

    // Step 6
    var isFirstChild: Bool

    // Steps 7-9
    var parent1: ParentOnboardingData

    // Steps 10-12
    var parent2: ParentOnboardingData? // nil if single parent

    // Step 13
    var daysTakenParent1: Int?
    var daysTakenParent2: Int?

    // Step 14
    var priority: PlanningPriority // .maximizeIncome, .equalSplit, .maxTime, .unsure

    // Step 15
    var childcarePlan: ChildcarePlan // .early, .extended, .undecided

    // Step 16
    var knowledgeLevel: KnowledgeLevel // .beginner, .some, .good

    // Step 20
    var notificationsEnabled: Bool
}

struct ParentOnboardingData {
    var name: String
    var monthlyIncome: Decimal
    var hasEmployerTopUp: Bool?
    var topUpPercentage: Decimal?
    var topUpMonths: Int?
}
```

### Onboarding-persistens
- Spara framsteg efter varje steg (användaren kan stänga appen och återuppta)
- Lagra i SwiftData som `OnboardingProgress`-entitet
- Konvertera till `Family` + `Parent` + `Child`-modeller vid slutförande
- Onboarding-data serialiseras också som kontext för AI-rådgivarens systemprompt

### Analyshändelser
Spåra per steg: `onboarding_step_completed(step: Int, choice: String)`
Spåra avhopp: vilket steg har högst avhoppsfrekvens
Spåra betalvägg: `paywall_shown`, `paywall_converted(plan: String)`, `paywall_skipped`
