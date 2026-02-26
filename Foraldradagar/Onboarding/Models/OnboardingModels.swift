import Foundation
import SwiftData

// MARK: - Enums

enum FamilyType: String, Codable, CaseIterable {
    case twoParents   = "two_parents"
    case singleParent = "single_parent"
}

enum FamilyStage: String, Codable, CaseIterable {
    case expecting = "expecting"   // Väntar barn
    case born      = "born"        // Barnet är fött
    case planning  = "planning"    // Planerar i förväg
}

enum MultipleType: String, Codable, CaseIterable {
    case single   = "single"
    case twins    = "twins"
    case triplets = "triplets_or_more"

    var extraDays: Int {
        switch self {
        case .single:   return 0
        case .twins:    return 180
        case .triplets: return 180 * 2
        }
    }

    var totalDays: Int { 480 + extraDays }
}

enum PlanningPriority: String, Codable, CaseIterable {
    case maximizeIncome = "maximize_income"
    case equalSplit     = "equal_split"
    case maxTime        = "max_time"
    case unsure         = "unsure"
}

enum ChildcarePlan: String, Codable, CaseIterable {
    case early     = "early"      // Förskola ~1 år
    case extended  = "extended"   // Hemma 2-3 år
    case undecided = "undecided"
}

enum KnowledgeLevel: String, Codable, CaseIterable {
    case beginner = "beginner"
    case some     = "some"
    case good     = "good"
}

enum TopUpPercentage: Int, Codable, CaseIterable {
    case eighty       = 80
    case eightyFive   = 85
    case ninety       = 90
    case hundred      = 100
}

enum TopUpMonths: Int, Codable, CaseIterable {
    case three  = 3
    case six    = 6
    case nine   = 9
    case twelve = 12
}

// MARK: - Data Models

struct ParentOnboardingData: Codable, Equatable {
    var name: String = ""
    var monthlyIncome: Decimal = 35000
    var hasEmployerTopUp: Bool? = nil     // nil = "vet inte"
    var topUpPercentage: TopUpPercentage? = nil
    var topUpMonths: TopUpMonths? = nil
}

struct OnboardingData: Codable, Equatable {
    // Step 2
    var familyType: FamilyType? = nil

    // Step 3
    var stage: FamilyStage? = nil

    // Step 4
    var childDate: Date? = nil

    // Step 5
    var multipleType: MultipleType? = nil

    // Step 6
    var isFirstChild: Bool? = nil

    // Steps 7-9
    var parent1 = ParentOnboardingData()

    // Steps 10-12 (nil if single parent)
    var parent2: ParentOnboardingData? = nil

    // Step 13
    var hasStartedTakingDays: Bool? = nil
    var daysTakenParent1: Int? = nil
    var daysTakenParent2: Int? = nil

    // Step 14
    var priority: PlanningPriority? = nil

    // Step 15
    var childcarePlan: ChildcarePlan? = nil

    // Step 16
    var knowledgeLevel: KnowledgeLevel? = nil

    // Step 20
    var notificationsEnabled: Bool = false

    // MARK: - Computed Helpers

    var totalDays: Int {
        (multipleType ?? .single).totalDays
    }

    var sjukpenningDays: Int { totalDays - 90 }
    var lagstaDays: Int { 90 }

    /// Dagar som kan delas fritt (480 - 2×90 reserverade = 300 delade)
    var sharedDays: Int {
        max(0, totalDays - 180) // 180 = 90 reserved each
    }

    var reservedPerParent: Int { 90 }
}

// MARK: - Onboarding Step Definition

enum OnboardingStep: String, CaseIterable, Identifiable {
    case welcome
    case familyType
    case stage
    case childDate
    case multipleBirths
    case firstChild
    case parent1Name
    case parent1Income
    case parent1TopUp
    case parent2Name
    case parent2Income
    case parent2TopUp
    case daysTaken
    case priority
    case childcare
    case knowledgeLevel
    case summary
    case aiInsight
    case featureShowcase
    case notifications

    var id: String { rawValue }

    var block: Int {
        switch self {
        case .welcome, .familyType, .stage: return 1
        case .childDate, .multipleBirths, .firstChild: return 2
        case .parent1Name, .parent1Income, .parent1TopUp,
             .parent2Name, .parent2Income, .parent2TopUp: return 3
        case .daysTaken, .priority, .childcare, .knowledgeLevel: return 4
        case .summary, .aiInsight, .featureShowcase, .notifications: return 5
        }
    }
}

// MARK: - SwiftData Persistence

@Model
final class OnboardingProgress {
    var currentStepIndex: Int = 0
    var dataJSON: Data? = nil
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init() {}

    var onboardingData: OnboardingData {
        get {
            guard let json = dataJSON else { return OnboardingData() }
            return (try? JSONDecoder().decode(OnboardingData.self, from: json)) ?? OnboardingData()
        }
        set {
            dataJSON = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }
}

// MARK: - Föräldrapenning Calculator
// Delegates to ParentalLeaveRules for all constants — single source of truth.

struct ForaldrapenningCalculator {

    /// Calculate daily föräldrapenning at sjukpenningnivå
    /// Formula: min(yearlyIncome, sgiCap) × 0.97 × 0.80 / 365
    static func dailyRate(monthlyIncome: Decimal) -> Decimal {
        ParentalLeaveRules.dailySGIPayment(monthlyIncome: monthlyIncome)
    }

    /// Monthly income on leave (daily × 30)
    static func monthlyRate(monthlyIncome: Decimal) -> Decimal {
        ParentalLeaveRules.monthlyLeaveIncome(monthlyGrossIncome: monthlyIncome)
    }

    /// Lägstanivå per day
    static var lagstaDailyRate: Decimal { ParentalLeaveRules.lagstanivaDaily }

    /// Format a Decimal as "X kr/dag"
    static func formatted(dailyRate: Decimal) -> String {
        let rounded = NSDecimalNumber(decimal: dailyRate).intValue
        return "\(rounded) kr/dag"
    }

    /// Format a Decimal as "X kr"
    static func formattedKr(_ amount: Decimal) -> String {
        let rounded = NSDecimalNumber(decimal: amount).intValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return (formatter.string(from: NSNumber(value: rounded)) ?? "\(rounded)") + " kr"
    }

    /// Format a Decimal as "XX XXX kr/mån"
    static func formattedMonthly(_ amount: Decimal) -> String {
        formattedKr(amount) + "/mån"
    }

    /// Day expiry date — föräldrapenningdagar expire when child turns 12
    static func expiryDate(childBirth: Date) -> Date {
        ParentalLeaveRules.allDaysExpiryDate(childBirthDate: childBirth)
    }

    /// SGI-level days expire effectively at age 4 (save limit)
    static func sjukpenningExpiryDate(childBirth: Date) -> Date {
        ParentalLeaveRules.sgiExpiryDate(childBirthDate: childBirth)
    }
}
