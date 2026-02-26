import Foundation

// MARK: - Leave Calculator
// Pure functions that compute everything from Family + Rules.
// No side effects, no state — just math.

struct LeaveCalculator {

    // MARK: - Days Remaining

    struct DaysSummary {
        let totalDays: Int             // 480 (or 660 for twins)
        let sgiLevelTotal: Int         // 390 (or more for twins)
        let basicLevelTotal: Int       // 90

        let daysTakenTotal: Int
        let daysTakenParent1: Int
        let daysTakenParent2: Int

        let daysRemainingTotal: Int
        let daysRemainingSGI: Int
        let daysRemainingBasic: Int

        // Per-parent reserved days remaining
        let reservedRemainingParent1: Int
        let reservedRemainingParent2: Int

        // Shared days remaining (freely distributable)
        let sharedDaysRemaining: Int
    }

    static func calculateDays(family: Family) -> DaysSummary {
        let child = family.firstChild
        let multipleType = child?.multipleType ?? .single
        let total = ParentalLeaveRules.totalDays(multipleType: multipleType)
        let sgiTotal = ParentalLeaveRules.sgiLevelDays + (multipleType == .single ? 0 : multipleType == .twins ? ParentalLeaveRules.twinExtraDays : ParentalLeaveRules.tripletExtraDays)
        let basicTotal = ParentalLeaveRules.lagstanivaDays

        let p1 = family.parent1
        let p2 = family.parent2

        let p1Taken = p1?.foraldraDaysTaken ?? 0
        let p2Taken = p2?.foraldraDaysTaken ?? 0
        let totalTaken = p1Taken + p2Taken

        let reserved = ParentalLeaveRules.reservedDaysPerParent
        let p1ReservedUsed = min(p1Taken, reserved)
        let p2ReservedUsed = min(p2Taken, reserved)

        // SGI-level days taken (assume taken days are SGI first, then basic)
        let sgiTaken = min(totalTaken, sgiTotal)
        let basicTaken = max(0, totalTaken - sgiTotal)

        return DaysSummary(
            totalDays: total,
            sgiLevelTotal: sgiTotal,
            basicLevelTotal: basicTotal,
            daysTakenTotal: totalTaken,
            daysTakenParent1: p1Taken,
            daysTakenParent2: p2Taken,
            daysRemainingTotal: max(0, total - totalTaken),
            daysRemainingSGI: max(0, sgiTotal - sgiTaken),
            daysRemainingBasic: max(0, basicTotal - basicTaken),
            reservedRemainingParent1: max(0, reserved - p1ReservedUsed),
            reservedRemainingParent2: max(0, reserved - p2ReservedUsed),
            sharedDaysRemaining: max(0, ParentalLeaveRules.sharedDays - max(0, p1Taken - reserved) - max(0, p2Taken - reserved))
        )
    }

    // MARK: - Income

    struct IncomeSummary {
        let parent1DailyRate: Decimal
        let parent2DailyRate: Decimal
        let parent1MonthlyOnLeave: Decimal
        let parent2MonthlyOnLeave: Decimal
        let householdMonthlyWorking: Decimal
        let householdMonthlyBothOnLeave: Decimal
        let monthlyDifference: Decimal // how much less per month on leave
    }

    static func calculateIncome(family: Family) -> IncomeSummary {
        let p1Income = family.parent1?.monthlyGrossIncome ?? 0
        let p2Income = family.parent2?.monthlyGrossIncome ?? 0

        let p1Daily = ParentalLeaveRules.dailySGIPayment(monthlyIncome: p1Income)
        let p2Daily = ParentalLeaveRules.dailySGIPayment(monthlyIncome: p2Income)

        let p1Monthly = p1Daily * 30
        let p2Monthly = p2Daily * 30

        let working = p1Income + p2Income
        let bothOnLeave = p1Monthly + p2Monthly

        return IncomeSummary(
            parent1DailyRate: p1Daily,
            parent2DailyRate: p2Daily,
            parent1MonthlyOnLeave: p1Monthly,
            parent2MonthlyOnLeave: p2Monthly,
            householdMonthlyWorking: working,
            householdMonthlyBothOnLeave: bothOnLeave,
            monthlyDifference: working - bothOnLeave
        )
    }

    // MARK: - Deadlines

    struct DeadlineInfo {
        let description: String
        let date: Date
        let daysUntil: Int
        let isUrgent: Bool // < 180 days
        let icon: String
    }

    static func nextDeadline(family: Family) -> DeadlineInfo? {
        guard let child = family.firstChild else { return nil }
        let now = Date()

        // SGI-level expiry (age 4)
        let sgiExpiry = ParentalLeaveRules.sgiExpiryDate(childBirthDate: child.birthDate)
        let sgiDays = ParentalLeaveRules.daysUntil(sgiExpiry)

        // All days expiry (age 12)
        let allExpiry = ParentalLeaveRules.allDaysExpiryDate(childBirthDate: child.birthDate)
        let allDays = ParentalLeaveRules.daysUntil(allExpiry)

        // For expecting parents: birth date itself
        if !child.isBorn && child.birthDate > now {
            let birthDays = ParentalLeaveRules.daysUntil(child.birthDate)
            return DeadlineInfo(
                description: "Beräknad födsel",
                date: child.birthDate,
                daysUntil: birthDays,
                isUrgent: birthDays < 30,
                icon: "stork"
            )
        }

        // If SGI expiry is still in the future and relevant
        if sgiDays > 0 && sgiDays < allDays {
            return DeadlineInfo(
                description: "SGI-dagar löper ut",
                date: sgiExpiry,
                daysUntil: sgiDays,
                isUrgent: sgiDays < 180,
                icon: "exclamationmark.triangle.fill"
            )
        }

        // Fallback: all days expiry
        if allDays > 0 {
            return DeadlineInfo(
                description: "Alla dagar löper ut",
                date: allExpiry,
                daysUntil: allDays,
                isUrgent: allDays < 365,
                icon: "calendar.badge.clock"
            )
        }

        return nil
    }

    // MARK: - Formatting Helpers

    static func formatDaysUntil(_ days: Int) -> String {
        if days <= 0 { return "Utgånget" }

        let years = days / 365
        let months = (days % 365) / 30
        let remainingDays = days % 30

        if years > 0 && months > 0 {
            return "\(years) år och \(months) mån"
        } else if years > 0 {
            return "\(years) år"
        } else if months > 0 && remainingDays > 0 {
            return "\(months) mån och \(remainingDays) dagar"
        } else if months > 0 {
            return "\(months) månader"
        } else {
            return "\(remainingDays) dagar"
        }
    }

    static func formatCurrency(_ amount: Decimal) -> String {
        let rounded = NSDecimalNumber(decimal: amount).intValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        return (formatter.string(from: NSNumber(value: rounded)) ?? "\(rounded)") + " kr"
    }

    static func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        f.dateStyle = .long
        return f.string(from: date)
    }

    static func formatShortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        f.dateFormat = "d MMM yyyy"
        return f.string(from: date)
    }
}
