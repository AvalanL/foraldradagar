import Foundation
import SwiftData

// MARK: - AI Advisor Service
// Orchestrates the Claude API calls with full rules + family context.
// PRD: "Like having a personal Försäkringskassan handläggare available 24/7"

@MainActor @Observable
final class AIAdvisorService {

    var isLoading = false
    var error: String?

    // MARK: - Configuration

    /// API key — bundled with the app. In production, use a proxy server.
    static var apiKey: String {
        get {
            // User override (from Settings) takes priority
            let userKey = UserDefaults.standard.string(forKey: "claude_api_key") ?? ""
            if !userKey.isEmpty { return userKey }
            // Bundled key
            let bundled = Secrets.claudeAPIKey
            return bundled == "YOUR_API_KEY_HERE" ? "" : bundled
        }
        set { UserDefaults.standard.set(newValue, forKey: "claude_api_key") }
    }

    private static let apiURL = "https://api.anthropic.com/v1/messages"
    private static let model = "claude-sonnet-4-6"
    private static let maxTokens = 1024

    // MARK: - System Prompt

    /// Builds the full system prompt with rules + family context.
    static func buildSystemPrompt(family: Family) -> String {
        let days = LeaveCalculator.calculateDays(family: family)
        let income = LeaveCalculator.calculateIncome(family: family)
        let child = family.firstChild

        let p1 = family.parent1
        let p2 = family.parent2

        // Build top-up descriptions
        let p1TopUp: String? = {
            guard let pct = p1?.employerTopUpPercentage,
                  let months = p1?.employerTopUpMonths else { return nil }
            return "\(pct)% i \(months) månader"
        }()

        let p2TopUp: String? = {
            guard let pct = p2?.employerTopUpPercentage,
                  let months = p2?.employerTopUpMonths else { return nil }
            return "\(pct)% i \(months) månader"
        }()

        let familyContext = ParentalLeaveKnowledgeBase.familyContext(
            parent1Name: p1?.name ?? "",
            parent1Income: p1?.monthlyGrossIncome ?? 0,
            parent1TopUp: p1TopUp,
            parent1DaysTaken: p1?.foraldraDaysTaken ?? 0,
            parent2Name: p2?.name,
            parent2Income: p2?.monthlyGrossIncome,
            parent2TopUp: p2TopUp,
            parent2DaysTaken: p2?.foraldraDaysTaken,
            childBirthDate: child?.birthDate ?? Date(),
            childIsBorn: child?.isBorn ?? false,
            childAge: child?.ageDescription ?? "",
            multipleType: child?.multipleType ?? .single,
            totalDays: days.totalDays,
            daysRemaining: days.daysRemainingTotal,
            sgiDaysRemaining: days.daysRemainingSGI,
            basicDaysRemaining: days.daysRemainingBasic,
            reservedP1Remaining: days.reservedRemainingParent1,
            reservedP2Remaining: days.reservedRemainingParent2,
            sharedDaysRemaining: days.sharedDaysRemaining,
            parent1DailyRate: income.parent1DailyRate,
            parent2DailyRate: income.parent2DailyRate,
            planningPriority: family.planningPriority,
            knowledgeLevel: family.knowledgeLevel
        )

        let knowledgeInstruction: String
        switch family.knowledgeLevel {
        case "beginner":
            knowledgeInstruction = "Föräldern är nybörjare. Förklara begrepp som SGI, grundnivå etc. Undvik jargong."
        case "good":
            knowledgeInstruction = "Föräldern har god kunskap. Du kan använda termer som SGI, prisbasbelopp etc. utan förklaring."
        default:
            knowledgeInstruction = "Anpassa ditt språk — förklara begrepp vid behov men var inte övertydlig."
        }

        return """
        Du är en varm, kunnig och stöttande AI-rådgivare för svenska föräldrar. \
        Du kan hela det svenska föräldraförsäkringssystemet. \
        Svara ALLTID på svenska. Var tydlig, konkret och personlig.

        \(ParentalLeaveKnowledgeBase.rulesDocument)

        \(familyContext)

        INSTRUKTIONER:
        - Ge personliga svar baserade på familjens situation ovan
        - Använd konkreta siffror (kronor, dagar, datum) — inte generella svar
        - Visa alltid månadsbelopp (inte bara dagbelopp) — föräldrar tänker i månadslön
        - \(knowledgeInstruction)
        - Om du inte är säker på svaret, säg "Det vet jag inte säkert, kontakta Försäkringskassan" — gissa ALDRIG
        - Var varm och stöttande — föräldrarna är ofta stressade och sömnlösa
        - Håll svaren koncisa men fullständiga (max 3-4 stycken)

        PROAKTIVA VARNINGAR — Lyft dessa om de är relevanta för frågan:
        - SGI-fälla: Varna om föräldern riskerar tappa SGI (studier, arbetslöshet, byte av jobb nära förlossning)
        - Dagars utgång: Varna om SGI-dagar närmar sig barnets 4-årsdag (max 96 sparas)
        - Helgregel (april 2025): Förklara att lördag/söndag bara ger ersättning om angränsande vardag också tas ut
        - Dubbeldagar: Påminn att 60 dubbeldagar finns men bara till barnet är 15 månader — planera tidigt
        - Pension: Nämn att pensionsrätt bara räknas automatiskt för barn under 4 — sedan tappar man pension under ledighet
        - VAB lägre tak: Upplys om att VAB har lägre SGI-tak (7,5 × prisbasbelopp = 444 000 kr)

        - Avsluta VARJE svar med: "💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
        """
    }

    // MARK: - Send Message

    /// Sends a user message and returns the AI response.
    func sendMessage(
        _ userMessage: String,
        conversationHistory: [(role: String, content: String)],
        family: Family
    ) async throws -> String {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let apiKey = Self.apiKey
        guard !apiKey.isEmpty else {
            let fallback = generateOfflineResponse(for: userMessage, family: family)
            return fallback
        }

        let systemPrompt = Self.buildSystemPrompt(family: family)

        // Build messages array
        var messages: [[String: String]] = []
        for msg in conversationHistory {
            messages.append(["role": msg.role, "content": msg.content])
        }
        messages.append(["role": "user", "content": userMessage])

        // Build request body
        let body: [String: Any] = [
            "model": Self.model,
            "max_tokens": Self.maxTokens,
            "system": systemPrompt,
            "messages": messages
        ]

        guard let url = URL(string: Self.apiURL) else {
            throw AIAdvisorError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIAdvisorError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIAdvisorError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        // Parse response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw AIAdvisorError.parseError
        }

        return text
    }

    // MARK: - Offline / No-API-Key Fallback

    /// Generates smart responses locally when no API key is configured.
    /// Uses the family's data + rules engine for common questions.
    func generateOfflineResponse(for question: String, family: Family) -> String {
        let days = LeaveCalculator.calculateDays(family: family)
        let income = LeaveCalculator.calculateIncome(family: family)
        let p1Name = family.parent1?.name ?? "Förälder 1"
        let p2Name = family.parent2?.name ?? "Förälder 2"
        let lowered = question.lowercased()

        // Pattern match common questions
        if lowered.contains("hur många dagar") || lowered.contains("dagar kvar") {
            var response = "Ni har **\(days.daysRemainingTotal) dagar kvar** av totalt \(days.totalDays).\n\n"
            response += "- \(days.daysRemainingSGI) dagar på SGI-nivå (ca 80% av inkomsten)\n"
            response += "- \(days.daysRemainingBasic) dagar på lägstanivå (180 kr/dag)\n\n"
            response += "**Reserverade dagar:**\n"
            response += "- \(p1Name): \(days.reservedRemainingParent1) kvar\n"
            if !family.isSingleParent {
                response += "- \(p2Name): \(days.reservedRemainingParent2) kvar\n"
            }
            response += "\n💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
            return response
        }

        if lowered.contains("dela") || lowered.contains("fördela") || lowered.contains("split") {
            let p1Rate = NSDecimalNumber(decimal: income.parent1DailyRate).intValue
            let p2Rate = NSDecimalNumber(decimal: income.parent2DailyRate).intValue
            let p1Monthly = p1Rate * 30
            let p2Monthly = p2Rate * 30
            var response = ""
            if p1Rate > p2Rate {
                response = "\(p1Name) har högre ersättning (~\(p1Monthly) kr/mån) jämfört med \(p2Name) (~\(p2Monthly) kr/mån).\n\n"
                response += "**Rekommendation:** Om \(p1Name) har arbetsgivarutfyllnad kan det vara fördelaktigt att \(p1Name) tar ledigt under utfyllnadsperioden först. Sedan kan \(p2Name) ta över.\n\n"
            } else if p2Rate > p1Rate {
                response = "\(p2Name) har högre ersättning (~\(p2Monthly) kr/mån) jämfört med \(p1Name) (~\(p1Monthly) kr/mån).\n\n"
                response += "**Rekommendation:** Om \(p2Name) har arbetsgivarutfyllnad kan det vara fördelaktigt att \(p2Name) tar ledigt under utfyllnadsperioden först.\n\n"
            } else {
                response = "Ni har ungefär lika hög ersättning (~\(p1Monthly) kr/mån). Ni kan fördela dagarna efter vad som passar er bäst.\n\n"
            }
            response += "Kom ihåg: 90 reserverade dagar per förälder kan inte överlåtas. De övriga \(days.sharedDaysRemaining) delade dagarna kan ni fördela fritt.\n\n"
            response += "💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
            return response
        }

        if lowered.contains("sgi") || lowered.contains("sjukpenning") {
            let p1Income = NSDecimalNumber(decimal: family.parent1?.monthlyGrossIncome ?? 0).intValue
            let p1Rate = NSDecimalNumber(decimal: income.parent1DailyRate).intValue
            let p1Monthly = p1Rate * 30
            var response = "**SGI (Sjukpenninggrundande Inkomst)** är din förväntade årsinkomst baserat på din nuvarande anställning.\n\n"
            response += "- Taket är 592 000 kr/år (10 × prisbasbelopp 2026)\n"
            response += "- Dagbelopp = SGI × 0,97 × 0,80 / 365\n\n"
            response += "Med \(p1Name)s inkomst på \(p1Income) kr/mån:\n"
            response += "- Dagbelopp: ca **\(p1Rate) kr/dag** före skatt\n"
            response += "- Månadsbelopp: ca **\(p1Monthly) kr/mån** före skatt\n\n"
            response += "⚠️ **SGI-fällor att undvika:**\n"
            response += "- Blir du arbetslös → anmäl dig på Arbetsförmedlingen DIREKT, annars tappar du SGI\n"
            response += "- Börjar du studera → SGI nollställs (ansök om föräldrapenning INNAN)\n"
            response += "- Byter jobb → se till att det inte blir glapp mellan anställningarna\n\n"
            response += "💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
            return response
        }

        if lowered.contains("vab") || lowered.contains("vård av barn") || lowered.contains("sjukt barn") {
            var response = "**VAB (Vård av barn)** är ett separat system från föräldrapenningen.\n\n"
            response += "- 120 dagar per barn per kalenderår\n"
            response += "- Barnet ska vara 8 månader – 12 år\n"
            response += "- Ersättning: ca 80% av SGI\n"
            response += "- VAB tar INTE från era \(days.totalDays) föräldrapenningdagar\n\n"
            response += "⚠️ **Viktigt:** VAB har ett **lägre SGI-tak** än föräldrapenning!\n"
            response += "- Föräldrapenning: tak 592 000 kr/år (10 × prisbasbelopp)\n"
            response += "- VAB: tak 444 000 kr/år (7,5 × prisbasbelopp)\n"
            response += "- Tjänar du över 37 000 kr/mån märks skillnaden\n\n"
            response += "📅 **Ny regel april 2026:** Retroaktiv VAB-ansökan kortas från 90 till 30 dagar — anmäl snabbare!\n\n"
            response += "💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
            return response
        }

        if lowered.contains("deltid") || lowered.contains("jobba") || lowered.contains("halvdag") {
            var response = "Ja, du kan ta föräldrapenning på deltid!\n\n"
            response += "**Tillgängliga nivåer:**\n"
            response += "- 100% — du arbetar inte alls\n"
            response += "- 75% — du arbetar 25%\n"
            response += "- 50% — du arbetar 50%\n"
            response += "- 25% — du arbetar 75%\n"
            response += "- 12,5% — du arbetar 87,5%\n\n"
            response += "En dag med 50% uttag förbrukar bara 0,5 föräldrapenningdagar.\n\n"
            response += "💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
            return response
        }

        if lowered.contains("helg") || lowered.contains("lördag") || lowered.contains("söndag") || lowered.contains("weekend") {
            var response = "**Helgregeln (sedan april 2025):**\n\n"
            response += "Du kan bara få föräldrapenning på lördag/söndag om du OCKSÅ tar ut föräldrapenning på den angränsande vardagen (fredagen eller måndagen).\n\n"
            response += "**I praktiken:**\n"
            response += "- Jobbar du mån–fre och är ledig lör–sön → ingen ersättning för helgen\n"
            response += "- Är du ledig fredag + lördag + söndag → du får ersättning alla tre dagarna\n"
            response += "- Är du ledig hela veckan → inga problem\n\n"
            response += "Detta påverkar mest dig som tar föräldrapenning på deltid.\n\n"
            response += "💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
            return response
        }

        if lowered.contains("dubbel") || lowered.contains("samtidig") || lowered.contains("båda hemma") || lowered.contains("tillsammans") {
            var response = "**Dubbeldagar** — ni kan båda vara hemma samtidigt!\n\n"
            response += "- **60 dagar** totalt (30 per förälder)\n"
            response += "- Måste användas innan barnet fyller **15 månader**\n"
            if let child = family.firstChild {
                let expiry = ParentalLeaveRules.dubbeldagarExpiryDate(childBirthDate: child.birthDate)
                let daysLeft = ParentalLeaveRules.daysUntil(expiry)
                if daysLeft > 0 {
                    response += "- ⏰ Ni har **\(daysLeft) dagar kvar** att använda dubbeldagar\n"
                } else {
                    response += "- ❌ Tyvärr har perioden för dubbeldagar passerat\n"
                }
            }
            response += "\nPerfekt för de första veckorna med barnet, inskolning på förskola, eller om ni vill ha semester tillsammans.\n\n"
            response += "💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
            return response
        }

        if lowered.contains("pension") || lowered.contains("tjänstepension") {
            var response = "**Pension och föräldraledighet:**\n\n"
            response += "🟢 **Allmän pension:** Du får pensionsrätt automatiskt för barn under 4 år — oavsett om du jobbar eller inte.\n\n"
            response += "🔴 **Tjänstepension:** Här förlorar de flesta pengar!\n"
            response += "- De flesta kollektivavtal ger tjänstepension bara under utfyllnadsperioden\n"
            response += "- Varje månad utan tjänstepension kostar ca 4–5% av lönen i framtida pension\n"
            response += "- Ett års ledighet utan tjänstepension ≈ 50 000–80 000 kr mindre i total pension\n\n"
            response += "**Tips:** Kolla med din arbetsgivare exakt hur länge tjänstepensionen betalas under ledigheten.\n\n"
            response += "💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
            return response
        }

        if lowered.contains("när") && (lowered.contains("löper ut") || lowered.contains("deadline") || lowered.contains("försvinner")) {
            guard let child = family.firstChild else {
                return "Jag behöver veta barnets födelsedatum för att beräkna deadlines.\n\n💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
            }
            let sgiExpiry = ParentalLeaveRules.sgiExpiryDate(childBirthDate: child.birthDate)
            let allExpiry = ParentalLeaveRules.allDaysExpiryDate(childBirthDate: child.birthDate)
            let sgiDays = ParentalLeaveRules.daysUntil(sgiExpiry)
            let allDays = ParentalLeaveRules.daysUntil(allExpiry)

            var response = "**Viktiga datum:**\n\n"
            response += "- SGI-dagar (390 st): Måste huvudsakligen användas innan barnet fyller 4 → **\(LeaveCalculator.formatDate(sgiExpiry))** (om \(LeaveCalculator.formatDaysUntil(sgiDays)))\n"
            response += "  - Undantag: 96 dagar kan sparas till barnet fyller 12\n"
            response += "- Alla dagar: Senast innan barnet fyller 12 → **\(LeaveCalculator.formatDate(allExpiry))** (om \(LeaveCalculator.formatDaysUntil(allDays)))\n\n"
            response += "💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
            return response
        }

        // Generic fallback
        let p1Rate = NSDecimalNumber(decimal: income.parent1DailyRate).intValue
        let p1Monthly = p1Rate * 30
        var response = "Det är en bra fråga! Här är vad jag vet om er situation:\n\n"
        response += "- Ni har **\(days.daysRemainingTotal) dagar kvar** av \(days.totalDays)\n"
        response += "- \(p1Name): ~\(p1Rate) kr/dag (~\(p1Monthly) kr/mån)\n"
        if !family.isSingleParent {
            let p2Rate = NSDecimalNumber(decimal: income.parent2DailyRate).intValue
            let p2Monthly = p2Rate * 30
            response += "- \(p2Name): ~\(p2Rate) kr/dag (~\(p2Monthly) kr/mån)\n"
        }
        response += "\nFör att ge ett bättre svar behöver jag en API-nyckel till Claude. Lägg till den under Inställningar.\n\n"
        response += "💡 Tips: Verifiera alltid med Försäkringskassan (forsakringskassan.se) innan du ansöker."
        return response
    }

    // MARK: - Starter Questions

    /// Suggested starter questions based on the family's situation.
    static func starterQuestions(for family: Family) -> [String] {
        var questions = [
            "Hur många dagar har vi kvar?",
            "Hur skyddar jag min SGI?",
        ]

        if !family.isSingleParent {
            questions.insert("Hur bör vi dela dagarna?", at: 1)
        }

        if let child = family.firstChild {
            let sgiExpiry = ParentalLeaveRules.sgiExpiryDate(childBirthDate: child.birthDate)
            let sgiDays = ParentalLeaveRules.daysUntil(sgiExpiry)

            // Urgent: days expiring soon
            if sgiDays < 365 * 2 {
                questions.append("Vilka dagar försvinner snart?")
            }

            // Dubbeldagar still available
            let dubbelExpiry = ParentalLeaveRules.dubbeldagarExpiryDate(childBirthDate: child.birthDate)
            let dubbelDays = ParentalLeaveRules.daysUntil(dubbelExpiry)
            if dubbelDays > 0 && dubbelDays < 365 {
                questions.append("Hur funkar dubbeldagar?")
            }
        }

        // Rotate in different relevant questions
        let extras = [
            "Hur påverkar helgregeln mig?",
            "Vad händer med min pension?",
            "Kan jag jobba deltid under ledigheten?",
        ]
        // Add one extra to keep the list from being too long
        let extraIndex = Calendar.current.component(.day, from: Date()) % extras.count
        if questions.count < 5 {
            questions.append(extras[extraIndex])
        }

        return questions
    }

    // MARK: - Greeting

    /// Personalized greeting for the chat view.
    static func greeting(for family: Family) -> String {
        let name = family.parent1?.name ?? ""
        let base = name.isEmpty ? "Hej!" : "Hej \(name)!"

        // Build proactive nudge based on family situation
        var nudge = ""
        if let child = family.firstChild {
            let dubbelExpiry = ParentalLeaveRules.dubbeldagarExpiryDate(childBirthDate: child.birthDate)
            let dubbelDays = ParentalLeaveRules.daysUntil(dubbelExpiry)
            let sgiExpiry = ParentalLeaveRules.sgiExpiryDate(childBirthDate: child.birthDate)
            let sgiDays = ParentalLeaveRules.daysUntil(sgiExpiry)

            if dubbelDays > 0 && dubbelDays < 90 {
                nudge = " ⏰ Dubbeldagarna går ut om \(dubbelDays) dagar — fråga mig hur ni använder dem bäst!"
            } else if sgiDays > 0 && sgiDays < 365 {
                nudge = " ⏰ Era SGI-dagar börjar gå ut om \(sgiDays) dagar — fråga mig vad ni bör göra."
            }
        }

        let priorityText: String
        if let priority = family.planningPriority {
            switch priority {
            case "maximize_income":
                priorityText = "Jag hjälper dig maximera familjens inkomst under ledigheten."
            case "equal_split":
                priorityText = "Jag hjälper er hitta en rättvis uppdelning."
            case "max_time":
                priorityText = "Jag hjälper er maximera tiden hemma med barnet."
            default:
                priorityText = "Jag ger personliga svar baserade på just er situation."
            }
        } else {
            priorityText = "Jag ger personliga svar baserade på just er situation."
        }

        return "\(base) Jag kan hela föräldraförsäkringen. \(priorityText) Fråga mig vad som helst!\(nudge)"
    }
}

// MARK: - Errors

enum AIAdvisorError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case parseError
    case noAPIKey
    case notPremium

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ogiltig URL"
        case .invalidResponse:
            return "Ogiltigt svar från servern"
        case .apiError(let code, _):
            return "API-fel (status \(code))"
        case .parseError:
            return "Kunde inte tolka svaret"
        case .noAPIKey:
            return "Ingen API-nyckel konfigurerad"
        case .notPremium:
            return "Uppgradera till premium för obegränsade frågor"
        }
    }
}
