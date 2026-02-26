import Foundation

// MARK: - Swedish Parental Leave Rules
// Updated yearly. Source: Försäkringskassan, SCB, Regeringen.se
// This is the single config file that changes when rules change.
// Last verified: February 2026

struct ParentalLeaveRules {
    // MARK: - Current Year Constants (2026)

    /// Prisbasbelopp — set by SCB, announced each autumn for the following year.
    /// Source: Regeringen.se (September 2025)
    static let prisbasbelopp: Decimal = 59_200

    /// SGI cap = 10 × prisbasbelopp (for föräldrapenning)
    static let sgiCap: Decimal = 10 * prisbasbelopp // 592,000 kr

    /// VAB SGI cap = 7.5 × prisbasbelopp (LOWER than föräldrapenning!)
    static let vabSgiCap: Decimal = Decimal(string: "7.5")! * prisbasbelopp // 444,000 kr

    /// SGI cap as monthly income
    static var sgiCapMonthly: Decimal { sgiCap / 12 } // ~49,333 kr/mån

    // MARK: - Compensation Levels

    /// SGI replacement factors
    static let sgiFactorKarens: Decimal = Decimal(string: "0.97")!
    static let sgiFactorRate: Decimal = Decimal(string: "0.80")!

    /// Grundnivå: for parents WITHOUT qualifying SGI (students, newly arrived, etc.)
    static let grundnivaDaily: Decimal = 250

    /// Lägstanivå: flat rate for the last 90 days
    static let lagstanivaDaily: Decimal = 180

    /// Consecutive work days required before due date for sjukpenningnivå
    static let workDaysRequiredForSGI: Int = 240

    // MARK: - Day Allocations

    /// Total föräldrapenningdagar per child
    static let totalDaysPerChild: Int = 480

    /// Days at sjukpenningnivå (SGI-level, ~80% income)
    static let sgiLevelDays: Int = 390

    /// Days at lägstanivå (180 kr/day)
    static let lagstanivaDays: Int = 90

    /// Reserved days per parent (cannot be transferred)
    static let reservedDaysPerParent: Int = 90

    /// Shared days (freely distributable between parents)
    static let sharedDays: Int = 300 // 480 - 90 - 90

    /// Extra days for twins (+90 SGI + 90 lägstanivå)
    static let twinExtraDays: Int = 180

    /// Extra days for triplets+ (×2)
    static let tripletExtraDays: Int = 360

    /// Minimum SGI days that must be taken before lägstanivå can be used
    static let minSgiDaysBeforeLagsta: Int = 180

    // MARK: - Dubbeldagar (Double Days)

    /// Both parents on leave simultaneously — updated July 2024
    static let dubbeldagarCount: Int = 60
    static let dubbeldagarMaxChildAgeMonths: Int = 15

    // MARK: - Transfer Rules

    /// Max days transferable to a non-parent (e.g., grandparent) — new July 2024
    static let maxDaysToNonParent: Int = 45
    static let maxDaysToNonParentSoleCustodian: Int = 90

    // MARK: - Deadlines

    /// After child turns 4: max this many days can remain (both parents combined)
    static let maxDaysSaveableAfterAge4: Int = 96
    static let maxDaysSaveableAfterAge4Twins: Int = 132

    /// All remaining days expire when child turns this age
    static let allDaysExpiryAge: Int = 12

    /// Age at which save limit kicks in
    static let saveLimitAge: Int = 4

    /// Maximum retroactive application period (days) for föräldrapenning
    static let retroactiveApplicationMaxDays: Int = 90

    /// VAB retroactive application — changing April 2026
    static let vabRetroactiveDaysBefore2026April: Int = 90
    static let vabRetroactiveDaysAfter2026April: Int = 30

    // MARK: - VAB (Vård av barn)

    /// Maximum VAB days per child per year
    static let vabDaysPerChildPerYear: Int = 120

    /// Minimum child age for VAB (months)
    static let vabMinAgeMonths: Int = 8

    /// Maximum child age for VAB (years)
    static let vabMaxAgeYears: Int = 12

    /// Seriously ill: unlimited until this age
    static let vabSeriousIllnessMaxAge: Int = 18

    // MARK: - Part-time Leave Options

    /// Available fractional levels for part-time leave
    static let partTimeLevels: [Double] = [1.0, 0.75, 0.5, 0.25, 0.125]

    // MARK: - Weekend Rule

    /// Since April 2025: föräldrapenning on non-work days requires adjacent work day
    static let weekendRuleEffective = "2025-04-01"

    // MARK: - Calculations

    /// Total days for a given multiple type
    static func totalDays(multipleType: MultipleType) -> Int {
        switch multipleType {
        case .single:   return totalDaysPerChild
        case .twins:    return totalDaysPerChild + twinExtraDays
        case .triplets: return totalDaysPerChild + tripletExtraDays
        }
    }

    /// Daily SGI-based payment (sjukpenningnivå)
    /// Formula: min(yearlyIncome, sgiCap) × 0.97 × 0.80 / 365
    static func dailySGIPayment(monthlyIncome: Decimal) -> Decimal {
        let yearly = monthlyIncome * 12
        let capped = min(yearly, sgiCap)
        return (capped * sgiFactorKarens * sgiFactorRate) / 365
    }

    /// Daily VAB payment (lower cap!)
    static func dailyVABPayment(monthlyIncome: Decimal) -> Decimal {
        let yearly = monthlyIncome * 12
        let capped = min(yearly, vabSgiCap)
        return (capped * sgiFactorKarens * sgiFactorRate) / 365
    }

    /// Monthly income while on leave at SGI level (approximately 30 calendar days)
    static func monthlyLeaveIncome(monthlyGrossIncome: Decimal) -> Decimal {
        dailySGIPayment(monthlyIncome: monthlyGrossIncome) * 30
    }

    /// Monthly income with employer top-up
    static func monthlyWithTopUp(
        monthlyGrossIncome: Decimal,
        topUpPercentage: Int
    ) -> Decimal {
        let topUpFraction = Decimal(topUpPercentage) / 100
        return monthlyGrossIncome * topUpFraction
    }

    /// Percentage of salary retained on leave
    static func leaveIncomePercentage(monthlyGrossIncome: Decimal) -> Decimal {
        guard monthlyGrossIncome > 0 else { return 0 }
        return (monthlyLeaveIncome(monthlyGrossIncome: monthlyGrossIncome) / monthlyGrossIncome) * 100
    }

    /// Maximum daily amount at sjukpenningnivå
    static var maxDailySGI: Decimal {
        dailySGIPayment(monthlyIncome: sgiCapMonthly)
    }

    /// Maximum daily VAB amount
    static var maxDailyVAB: Decimal {
        dailyVABPayment(monthlyIncome: vabSgiCap / 12)
    }

    /// Save limit date (child's 4th birthday)
    static func saveLimitDate(childBirthDate: Date) -> Date {
        Calendar.current.date(byAdding: .year, value: saveLimitAge, to: childBirthDate) ?? childBirthDate
    }

    /// SGI-level days expiry date for a child (same as save limit for most purposes)
    static func sgiExpiryDate(childBirthDate: Date) -> Date {
        saveLimitDate(childBirthDate: childBirthDate)
    }

    /// All days expiry date for a child
    static func allDaysExpiryDate(childBirthDate: Date) -> Date {
        Calendar.current.date(byAdding: .year, value: allDaysExpiryAge, to: childBirthDate) ?? childBirthDate
    }

    /// Dubbeldagar expiry date (child reaches 15 months)
    static func dubbeldagarExpiryDate(childBirthDate: Date) -> Date {
        Calendar.current.date(byAdding: .month, value: dubbeldagarMaxChildAgeMonths, to: childBirthDate) ?? childBirthDate
    }

    /// Days until a given expiry date
    static func daysUntil(_ date: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: Date(), to: date)
        return max(0, components.day ?? 0)
    }
}
