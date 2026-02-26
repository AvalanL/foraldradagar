import SwiftUI
import SwiftData

@Observable
final class OnboardingViewModel {
    // MARK: - State

    var data = OnboardingData()
    var currentStepIndex: Int = 0
    var direction: NavigationDirection = .forward
    var showPaywall: Bool = false

    enum NavigationDirection {
        case forward, backward
    }

    // MARK: - Dynamic Step Flow

    /// Steps are computed dynamically based on user's answers.
    /// Single parents skip steps 10-12; non-born children skip step 13.
    var steps: [OnboardingStep] {
        var s: [OnboardingStep] = [
            .welcome,
            .familyType,
            .stage,
            .childDate,
            .multipleBirths,
            .firstChild,
            .parent1Name,
            .parent1Income,
            .parent1TopUp,
        ]

        // Parent 2 steps only for two-parent families
        if data.familyType == .twoParents {
            s.append(contentsOf: [.parent2Name, .parent2Income, .parent2TopUp])
        }

        // Days-taken step only if child is already born
        if data.stage == .born {
            s.append(.daysTaken)
        }

        s.append(contentsOf: [
            .priority,
            .childcare,
            .knowledgeLevel,
            .summary,
            .aiInsight,
            .featureShowcase,
            .notifications,
        ])

        return s
    }

    var currentStep: OnboardingStep {
        guard currentStepIndex < steps.count else { return .notifications }
        return steps[currentStepIndex]
    }

    /// Progress from 0.0 to 1.0
    var progress: Double {
        guard steps.count > 1 else { return 0 }
        return Double(currentStepIndex) / Double(steps.count - 1)
    }

    /// The 0-based index used for gradient calculation
    var stepIndexForGradient: Int {
        currentStepIndex
    }

    var totalStepCount: Int { steps.count }

    var isFirstStep: Bool { currentStepIndex == 0 }

    var isLastStep: Bool { currentStepIndex >= steps.count - 1 }

    // MARK: - Navigation

    func advance() {
        guard currentStepIndex < steps.count - 1 else {
            // Last step done — show paywall
            showPaywall = true
            return
        }

        direction = .forward
        withAnimation(OnboardingAnimation.slideIn) {
            currentStepIndex += 1
        }

        // Initialize parent2 data when we reach parent2 steps
        if currentStep == .parent2Name && data.parent2 == nil {
            data.parent2 = ParentOnboardingData()
        }

        persist()
    }

    func goBack() {
        guard currentStepIndex > 0 else { return }
        direction = .backward
        withAnimation(OnboardingAnimation.slideIn) {
            currentStepIndex -= 1
        }
    }

    // MARK: - Validation

    /// Whether the current step has enough data to proceed.
    var canAdvance: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .familyType:
            return data.familyType != nil
        case .stage:
            return data.stage != nil
        case .childDate:
            return data.childDate != nil
        case .multipleBirths:
            return data.multipleType != nil
        case .firstChild:
            return data.isFirstChild != nil
        case .parent1Name:
            return !data.parent1.name.trimmingCharacters(in: .whitespaces).isEmpty
        case .parent1Income:
            return true // Slider always has a value
        case .parent1TopUp:
            return data.parent1.hasEmployerTopUp != nil
        case .parent2Name:
            return !(data.parent2?.name.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        case .parent2Income:
            return true
        case .parent2TopUp:
            return data.parent2?.hasEmployerTopUp != nil
        case .daysTaken:
            return data.hasStartedTakingDays != nil
        case .priority:
            return data.priority != nil
        case .childcare:
            return data.childcarePlan != nil
        case .knowledgeLevel:
            return data.knowledgeLevel != nil
        case .summary, .aiInsight, .featureShowcase, .notifications:
            return true
        }
    }

    // MARK: - Calculations

    var parent1DailyRate: Decimal {
        ForaldrapenningCalculator.dailyRate(monthlyIncome: data.parent1.monthlyIncome)
    }

    var parent2DailyRate: Decimal {
        guard let p2 = data.parent2 else { return 0 }
        return ForaldrapenningCalculator.dailyRate(monthlyIncome: p2.monthlyIncome)
    }

    var householdMonthlyIncome: Decimal {
        data.parent1.monthlyIncome + (data.parent2?.monthlyIncome ?? 0)
    }

    var daysExpiryDate: Date? {
        guard let birth = data.childDate else { return nil }
        return ForaldrapenningCalculator.expiryDate(childBirth: birth)
    }

    var formattedExpiryDate: String {
        guard let date = daysExpiryDate else { return "—" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        f.dateStyle = .long
        return f.string(from: date)
    }

    // MARK: - Personalized Insight (Step 18)

    var personalizedInsight: String {
        let p1Name = data.parent1.name.isEmpty ? "Förälder 1" : data.parent1.name
        let p2Name = data.parent2?.name.isEmpty == false ? data.parent2!.name : "din partner"
        let p1Income = data.parent1.monthlyIncome
        let p2Income = data.parent2?.monthlyIncome ?? 0
        let diff = abs(NSDecimalNumber(decimal: p1Income - p2Income).intValue)

        // Income difference > 10,000
        if data.familyType == .twoParents && diff > 10000 {
            let higherEarner = p1Income > p2Income ? p1Name : p2Name
            let topUpPerson = data.parent1.hasEmployerTopUp == true ? p1Name :
                              (data.parent2?.hasEmployerTopUp == true ? p2Name : nil)

            if let topUpPerson {
                return "Eftersom \(higherEarner) tjänar mer lönar det sig att \(topUpPerson) tar ledigt först under utfyllnadsperioden. Genom att tajma rätt kan ni behålla mer av er inkomst."
            } else {
                return "Eftersom \(higherEarner) tjänar mer kan det löna sig att den med lägre inkomst tar mer av sjukpenningdagarna. Vi kan räkna ut exakt hur ni optimerar hushållsinkomsten."
            }
        }

        // Both have top-up
        if data.parent1.hasEmployerTopUp == true && data.parent2?.hasEmployerTopUp == true {
            let p1Months = data.parent1.topUpMonths?.rawValue ?? 6
            let p2Months = data.parent2?.topUpMonths?.rawValue ?? 6
            let totalMonths = p1Months + p2Months
            return "Ni har båda arbetsgivarutfyllnad! Genom att tajma ledigheten rätt kan ni behålla nästan full lön i \(totalMonths) månader."
        }

        // First child + beginner
        if data.isFirstChild == true && data.knowledgeLevel == .beginner {
            return "Som förstagångsföräldrar har ni \(data.totalDays) dagar att planera. Vet du vilka dagar som försvinner om ni inte tar dem innan barnet fyller 4? Det reder vi ut åt er."
        }

        // Single parent
        if data.familyType == .singleParent {
            return "Som ensamstående får du alla \(data.totalDays) dagar själv. Det ger dig stor flexibilitet — men det gäller att planera smart så du inte tappar inkomst i onödan."
        }

        // Default
        return "Med \(data.totalDays) dagar att planera finns det många sätt att optimera. Vi hjälper er hitta uppdelningen som passar just er familj bäst."
    }

    /// Number of "optimization opportunities" shown on paywall.
    var optimizationCount: Int {
        var count = 2 // Everyone gets at least 2

        if data.familyType == .twoParents {
            count += 1 // Splitting optimization
        }

        if data.parent1.hasEmployerTopUp == true || data.parent2?.hasEmployerTopUp == true {
            count += 1 // Top-up timing optimization
        }

        let p1Income = data.parent1.monthlyIncome
        let p2Income = data.parent2?.monthlyIncome ?? 0
        if abs(NSDecimalNumber(decimal: p1Income - p2Income).intValue) > 5000 {
            count += 1 // Income difference optimization
        }

        return count
    }

    // MARK: - Persistence

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadProgress()
    }

    func persist() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<OnboardingProgress>()
        let existing = (try? context.fetch(descriptor))?.first

        let progress = existing ?? OnboardingProgress()
        progress.currentStepIndex = currentStepIndex
        progress.onboardingData = data

        if existing == nil {
            context.insert(progress)
        }

        try? context.save()
    }

    func loadProgress() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<OnboardingProgress>()
        guard let saved = try? context.fetch(descriptor).first, !saved.isCompleted else { return }

        data = saved.onboardingData
        currentStepIndex = min(saved.currentStepIndex, steps.count - 1)

        // Re-initialize parent2 if needed
        if data.familyType == .twoParents && data.parent2 == nil {
            data.parent2 = ParentOnboardingData()
        }
    }

    func markCompleted() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<OnboardingProgress>()
        if let saved = try? context.fetch(descriptor).first {
            saved.isCompleted = true
            saved.onboardingData = data
            try? context.save()
        }
    }
}
