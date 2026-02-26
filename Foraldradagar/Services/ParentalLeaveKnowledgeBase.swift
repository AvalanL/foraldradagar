import Foundation

// MARK: - Parental Leave Knowledge Base
// Comprehensive Swedish parental leave rules encoded as structured text.
// This is injected into the AI system prompt for every conversation.
// Source: Försäkringskassan 2026, SCB, Regeringen.se
// Last verified: February 2026
//
// IMPORTANT: This knowledge base is designed around REAL parent pain points
// identified from Familjeliv.se, Swedish news, and Försäkringskassan data.
// The AI should proactively warn about common traps and mistakes.

struct ParentalLeaveKnowledgeBase {

    /// The full rules document (~4500 tokens), used as the AI's reference.
    static let rulesDocument: String = """
    SVENSKA FÖRÄLDRAFÖRSÄKRINGEN — KOMPLETT REGELVERK 2026

    ═══════════════════════════════════════════════════════
    1. GRUNDREGLER
    ═══════════════════════════════════════════════════════

    • 480 föräldrapenningdagar totalt per barn.
    • 390 dagar på sjukpenningnivå (inkomstbaserad, ~80 % av SGI).
    • 90 dagar på lägstanivå (180 kr/dag, fast belopp).
    • 90 reserverade dagar per förälder — KAN INTE överlåtas.
    • 300 överlåtbara dagar (210 sjukpenningnivå + 90 lägstanivå).
    • Ensamstående: alla 480 dagar.

    Dagfördelning per förälder (tvåföräldrafamilj):
    • 90 reserverade (sjukpenningnivå, ej överlåtbara)
    • 105 överlåtbara sjukpenningdagar
    • 45 lägstanivådagar
    • = 240 dagar per förälder som standard

    Sedan juli 2024: Föräldrar kan överlåta upp till 45 dagar till en icke-förälder (t.ex. mor-/farföräldrar). Ensam vårdnadshavare: upp till 90 dagar.

    ═══════════════════════════════════════════════════════
    2. TRE ERSÄTTNINGSNIVÅER (inte två!)
    ═══════════════════════════════════════════════════════

    A) SJUKPENNINGNIVÅ (390 dagar)
    • Formel: min(årsinkomst, 592 000) × 0,97 × 0,80 / 365
    • Tak: 10 × prisbasbelopp = 592 000 kr/år (49 333 kr/mån) 2026
    • Max dagbelopp: ~1 259 kr/dag
    • Effektiv ersättningsgrad: 77,6 % (0,97 × 0,80)
    • Kräver 240 sammanhängande arbetsdagar innan beräknad förlossning

    Räkneexempel:
    • 35 000 kr/mån → 35 000×12×0,97×0,80/365 = ~895 kr/dag ≈ 26 850 kr/mån
    • 45 000 kr/mån → 45 000×12×0,97×0,80/365 = ~1 151 kr/dag ≈ 34 530 kr/mån
    • 55 000 kr/mån → cappas → 592 000×0,97×0,80/365 = ~1 259 kr/dag ≈ 37 770 kr/mån

    B) GRUNDNIVÅ (250 kr/dag)
    • Ersätter sjukpenningnivå om föräldern SAKNAR SGI
    • Gäller: studenter, nyanlända, <240 dagars arbete innan BF
    • 250 kr/dag × 30 = 7 500 kr/mån före skatt

    C) LÄGSTANIVÅ (180 kr/dag)
    • De sista 90 dagarna
    • Kan bara tas ut efter att minst 180 dagar på sjukpenningnivå tagits ut för barnet
    • 180 kr/dag × 30 = 5 400 kr/mån före skatt

    ═══════════════════════════════════════════════════════
    3. ⚠️ SGI-FÄLLOR — VANLIGASTE MISSTAGET!
    ═══════════════════════════════════════════════════════

    SGI (sjukpenninggrundande inkomst) styr ersättningen. Förlorar du din SGI kollapsar din föräldrapenning.

    FÄLLA 1: FÖR FÅ DAGAR EFTER BARNETS 1 ÅR
    • Barnets första levnadsår: SGI skyddas automatiskt
    • EFTER 1 år: du MÅSTE ta ut minst 5 hela föräldrapenningdagar/vecka om du är hemma heltid
    • Tar du 3 dagar och är hemma 7 → SGI räknas om baserat på noll inkomst för de 4 dagarna
    • Konsekvens: drastiskt sänkt föräldrapenning och framtida sjukpenning

    FÄLLA 2: LUCKA MELLAN JOBB
    • Även 5 dagars lucka mellan anställningar kan nollställa SGI
    • Lösning: skriv in dig på Arbetsförmedlingen SAMMA dag som du slutar

    FÄLLA 3: OBETALD LEDIGHET
    • Hemma utan föräldrapenning och utan jobb = SGI kan sjunka till noll
    • Lösning: ta alltid ut minst 5 föräldrapenningdagar/vecka eller var inskriven på AF

    FÄLLA 4: DELTIDSARBETE UTAN KOMPLETTERING
    • Jobbar 60 %, hemma 40 % utan föräldrapenning → SGI baseras på 60 %-inkomsten
    • Lösning: komplettera med föräldrapenning för de 40 % du inte jobbar

    ═══════════════════════════════════════════════════════
    4. EKONOMISK VERKLIGHET — SÅ MYCKET FÅR MAN FAKTISKT
    ═══════════════════════════════════════════════════════

    Föräldrapenning betalas för ALLA 7 dagar/vecka (kalenderdagar), men mån-lön baseras på 5 dagar.
    Därför är månadsbeloppet LÄGRE än många tror.

    Ungefärlig månadsinkomst under ledighet (heltid, sjukpenningnivå, före skatt):
    • 25 000 kr/mån lön → ~19 500 kr/mån föräldrapenning
    • 30 000 kr/mån lön → ~23 400 kr/mån
    • 35 000 kr/mån lön → ~26 850 kr/mån
    • 40 000 kr/mån lön → ~30 600 kr/mån
    • 45 000 kr/mån lön → ~34 530 kr/mån
    • 50 000+ kr/mån lön → ~37 770 kr/mån (tak)

    VIKTIGT: ca 60 % av män och 40 % av kvinnor tjänar ÖVER taket (49 333 kr/mån).
    De får max ~37 770 kr/mån oavsett hur hög lönen är.

    Med arbetsgivarutfyllnad (~90 % av lön) blir skillnaden mindre under utfyllnadsperioden.

    ═══════════════════════════════════════════════════════
    5. ARBETSGIVARUTFYLLNAD (FÖRÄLDRALÖN)
    ═══════════════════════════════════════════════════════

    Standardmodell: 10 % utfyllnad under taket + 90 % över taket → totalt ~90 % av lön.

    Vanliga avtal:
    • Statligt (Villkorsavtalet): upp till 360 dagar (~12 mån). Mest generöst.
    • Teknikavtalet (tjänstemän): 2 mån (1-2 år), 6 mån (2+ år anställning)
    • Handels (tjänstemän): upp till 6 mån
    • Kommunal/regional: 180 dagar tillägg + 270 dagar föräldralön (höginkomsttagare)
    • Unionen/privat: upp till 6 mån (kräver ofta 2+ år)
    • Arbetare via AFA Försäkring: 60 dagar (1 år) eller 180 dagar (2+ år). Måste ansöka själv!

    OPTIMERINGSTIPS: Föräldern med utfyllnad bör ta ledigt UNDER utfyllnadsperioden.
    Om båda har utfyllnad: tajma så att en tar hela sin period, sedan den andra.

    ═══════════════════════════════════════════════════════
    6. TIDSFRISTER — DAGAR FÖRSVINNER TYST!
    ═══════════════════════════════════════════════════════

    ⚠️ VIKTIGT: Dagar försvinner utan varning om man inte planerar:

    • Innan 4 år: alla 480 dagar kan användas fritt.
    • Vid 4 år: MAX 96 DAGAR kan sparas (totalt, båda föräldrarna). Övriga FÖRSVINNER.
    • Tvillingar: max 132 dagar kan sparas efter 4 år.
    • Absolut deadline: ALLA dagar måste tas innan barnet fyller 12 år (eller slutar årskurs 5).
    • Retroaktiv ansökan: max 90 dagar bakåt.

    VANLIGT MISSTAG: Föräldrar "sparar" dagar och upptäcker för sent att de försvunnit vid 4-årsdagen.

    ═══════════════════════════════════════════════════════
    7. DUBBELDAGAR (uppdaterat juli 2024)
    ═══════════════════════════════════════════════════════

    • Båda föräldrarna kan ta föräldrapenning SAMTIDIGT i upp till 60 dagar (ökade från 30).
    • Gäller tills barnet är 15 månader (förlängt från 12).
    • Varje dubbeldag förbrukar 2 dagar (en per förälder).
    • Måste ta samma omfattning (t.ex. båda hel dag).
    • Reserverade dagar KAN INTE användas för dubbeldagar.

    ═══════════════════════════════════════════════════════
    8. NY HELGREGEL (från 1 april 2025)
    ═══════════════════════════════════════════════════════

    SEDAN APRIL 2025: Föräldrapenning på lördag/söndag/helgdag kräver att du OCKSÅ tar föräldrapenning i minst samma omfattning på en intilliggande arbetsdag (fredag eller måndag).

    Bakgrund: Tidigare kunde föräldrar ta billiga lägstanivådagar (180 kr) på helger som "fyllnad". Det är inte längre möjligt utan att också ta ut dagar på vardagar.

    ═══════════════════════════════════════════════════════
    9. DELTIDSUTTAG
    ═══════════════════════════════════════════════════════

    Fem nivåer:
    • 100 % (hel dag) — 1 dag förbrukas
    • 75 % — 0,75 dagar förbrukas
    • 50 % (halvdag) — 0,5 dagar förbrukas
    • 25 % — 0,25 dagar förbrukas
    • 12,5 % — 0,125 dagar förbrukas

    480 hela dagar = 960 halvdagar = ca 4 års halvtidsledighet.

    ═══════════════════════════════════════════════════════
    10. FLERBARNSFÖDSLAR
    ═══════════════════════════════════════════════════════

    Per extra barn: +90 sjukpenningnivå + 90 lägstanivå = +180 dagar
    • Tvillingar: 660 dagar totalt
    • Trillingar: 840 dagar totalt

    ═══════════════════════════════════════════════════════
    11. VAB — VÅRD AV BARN
    ═══════════════════════════════════════════════════════

    • 120 dagar per barn per år. Helt separat från de 480 dagarna.
    • Ålder: 8 månader till 12 år (12-16 för läkarbesök).
    • Allvarligt sjukt barn: obegränsade dagar till 18 år.

    ⚠️ VIKTIGT — LÄGRE TAK ÄN FÖRÄLDRAPENNING:
    • VAB SGI-tak: 7,5 × prisbasbelopp = 444 000 kr/år (37 000 kr/mån)
    • Max dagbelopp VAB: ~944 kr/dag (jämfört med 1 259 kr för föräldrapenning)
    • Höginkomsttagare förlorar mer på VAB än på föräldrapenning!

    NYA REGLER 2026:
    • Från 1 jan 2026: VAB kan tas för möten med skola/förskola om barnets vårdbehov.
    • Från 1 april 2026: Retroaktiv ansökan kortas från 90 till 30 dagar!

    ═══════════════════════════════════════════════════════
    12. SÄRSKILDA SITUATIONER
    ═══════════════════════════════════════════════════════

    • Adoption: samma regler, räknas från barnets ankomst.
    • Separation: dagarna följer barnet. Reserverade dagar kvarstår.
    • Sambo: samma regler som gifta.
    • Sjukt barn under föräldraledighet: kan byta till VAB.
    • Utlandsboende partner: komplicerat (EU/EES-regler) → hänvisa till Försäkringskassan.

    ═══════════════════════════════════════════════════════
    13. VANLIGA MISSFÖRSTÅND
    ═══════════════════════════════════════════════════════

    ❌ "Man måste dela 50/50" → Bara 90 reserverade dagar/förälder. 300 dagar kan fördelas fritt.
    ❌ "Dagarna tar slut vid 1 år" → Gäller till 4 år (96 kan sparas till 12).
    ❌ "Man kan inte jobba alls" → Deltidsuttag möjligt (12,5-75 %).
    ❌ "SGI försvinner om man är ledig länge" → SGI-skydd finns, men MAN MÅSTE ta ut ≥5 dagar/vecka efter barnets 1-årsdag.
    ❌ "Grundnivå och lägstanivå är samma sak" → Grundnivå = 250 kr (ersätter SGI om det saknas). Lägstanivå = 180 kr (sista 90 dagarna).
    ❌ "VAB och föräldrapenning har samma tak" → VAB-tak = 7,5×prisbasbelopp (lägre!).
    ❌ "Man kan ta lägstanivådagar när som helst" → Minst 180 SGI-dagar måste ha tagits ut först.
    ❌ "Man kan ta helgdagar fritt" → Sedan april 2025: kräver intilliggande arbetsdag.

    ═══════════════════════════════════════════════════════
    14. BELOPP OCH TAK 2026
    ═══════════════════════════════════════════════════════

    • Prisbasbelopp: 59 200 kr
    • SGI-tak (föräldrapenning): 592 000 kr/år (49 333 kr/mån)
    • SGI-tak (VAB): 444 000 kr/år (37 000 kr/mån)
    • Max dagbelopp sjukpenningnivå: ~1 259 kr/dag
    • Max dagbelopp VAB: ~944 kr/dag
    • Grundnivå: 250 kr/dag
    • Lägstanivå: 180 kr/dag

    ═══════════════════════════════════════════════════════
    15. PENSION — DEN DOLDA KOSTNADEN
    ═══════════════════════════════════════════════════════

    • Barnår (barnets första 4 år) ger pensionsrätt via "barnårsrätt" — automatiskt.
    • MEN: längre ledighet + deltid = lägre tjänstepension och premiepension.
    • Kvinnor får i snitt 5 500 kr/mån MINDRE i pension, delvis pga föräldraledighet.
    • Tips: överväg att kompensera den förälder som tar mer ledighet (privat sparande, premiepensionsöverföring).
    """

    // MARK: - Family Context Builder

    /// Builds a personalized context string from the family's data.
    /// Now includes monthly income (not just daily) since parents think in months.
    static func familyContext(
        parent1Name: String,
        parent1Income: Decimal,
        parent1TopUp: String?,
        parent1DaysTaken: Int,
        parent2Name: String?,
        parent2Income: Decimal?,
        parent2TopUp: String?,
        parent2DaysTaken: Int?,
        childBirthDate: Date,
        childIsBorn: Bool,
        childAge: String,
        multipleType: MultipleType,
        totalDays: Int,
        daysRemaining: Int,
        sgiDaysRemaining: Int,
        basicDaysRemaining: Int,
        reservedP1Remaining: Int,
        reservedP2Remaining: Int,
        sharedDaysRemaining: Int,
        parent1DailyRate: Decimal,
        parent2DailyRate: Decimal?,
        planningPriority: String?,
        knowledgeLevel: String?
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "sv_SE")
        dateFormatter.dateStyle = .long

        let p1Monthly = parent1DailyRate * 30
        let p1Pct = parent1Income > 0 ? (p1Monthly / parent1Income * 100) : 0

        var context = """
        FAMILJENS SITUATION:
        - Förälder 1: \(parent1Name.isEmpty ? "Ej namngivd" : parent1Name), inkomst \(formatDecimal(parent1Income)) kr/mån\
        \(parent1TopUp.map { ", arbetsgivarutfyllnad: \($0)" } ?? "")\
        , \(parent1DaysTaken) dagar tagna
          → Föräldrapenning: ~\(formatDecimal(parent1DailyRate)) kr/dag, ~\(formatDecimal(p1Monthly)) kr/mån (~\(formatDecimal(p1Pct))% av lön)
        """

        if let p2Name = parent2Name, let p2Income = parent2Income {
            let p2Daily = parent2DailyRate ?? 0
            let p2Monthly = p2Daily * 30
            let p2Pct = p2Income > 0 ? (p2Monthly / p2Income * 100) : 0
            context += """

            - Förälder 2: \(p2Name.isEmpty ? "Ej namngivd" : p2Name), inkomst \(formatDecimal(p2Income)) kr/mån\
            \(parent2TopUp.map { ", arbetsgivarutfyllnad: \($0)" } ?? "")\
            , \(parent2DaysTaken ?? 0) dagar tagna
              → Föräldrapenning: ~\(formatDecimal(p2Daily)) kr/dag, ~\(formatDecimal(p2Monthly)) kr/mån (~\(formatDecimal(p2Pct))% av lön)
            """
        } else {
            context += "\n- Ensamstående förälder"
        }

        context += """

        - Barn: \(childIsBorn ? "Fött" : "Beräknad födsel") \(dateFormatter.string(from: childBirthDate))\
        \(childIsBorn ? " (\(childAge))" : "")
        """

        if multipleType != .single {
            context += "\n- Flerbarnsfödslar: \(multipleType == .twins ? "Tvillingar" : "Trillingar")"
        }

        context += """

        - Totalt \(totalDays) föräldrapenningdagar
        - Kvar: \(daysRemaining) dagar (\(sgiDaysRemaining) sjukpenningnivå, \(basicDaysRemaining) lägstanivå)
        - Reserverade kvar: Förälder 1: \(reservedP1Remaining), Förälder 2: \(reservedP2Remaining)
        - Delade dagar kvar: \(sharedDaysRemaining)
        """

        let saveLimitDate = ParentalLeaveRules.saveLimitDate(childBirthDate: childBirthDate)
        let allExpiry = ParentalLeaveRules.allDaysExpiryDate(childBirthDate: childBirthDate)
        let saveLimitDays = ParentalLeaveRules.daysUntil(saveLimitDate)
        context += """

        - 96-dagarsgräns vid: \(dateFormatter.string(from: saveLimitDate)) (om \(saveLimitDays) dagar)
        - Alla dagar löper ut: \(dateFormatter.string(from: allExpiry))
        """

        // Warn about save limit if approaching
        if saveLimitDays < 365 && daysRemaining > 96 {
            context += "\n- ⚠️ VARNING: \(daysRemaining - 96) dagar riskerar att förfalla vid 4-årsdagen!"
        }

        if let priority = planningPriority {
            let mapped: String
            switch priority {
            case "maximize_income": mapped = "Maximera familjens inkomst"
            case "equal_split":    mapped = "Dela lika"
            case "max_time":       mapped = "Maximera tid hemma"
            default:               mapped = "Osäker — vill ha vägledning"
            }
            context += "\n- Planeringsmål: \(mapped)"
        }

        if let level = knowledgeLevel {
            let mapped: String
            switch level {
            case "beginner": mapped = "Nybörjare — behöver enkla förklaringar"
            case "some":     mapped = "Lite kunskap"
            case "good":     mapped = "God kunskap — kan använda termer som SGI, prisbasbelopp"
            default:         mapped = "Okänt"
            }
            context += "\n- Kunskapsnivå: \(mapped)"
        }

        return context
    }

    private static func formatDecimal(_ value: Decimal) -> String {
        let rounded = NSDecimalNumber(decimal: value).intValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: rounded)) ?? "\(rounded)"
    }
}
