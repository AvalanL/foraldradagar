import Foundation

// MARK: - Scenario Calculator
// Projects month-by-month income and day consumption for a scenario.

struct ScenarioCalculator {

    // MARK: - Month Projection

    struct MonthProjection: Identifiable {
        let id = UUID()
        let month: Date
        let parent1OnLeave: Bool
        let parent2OnLeave: Bool
        let householdIncome: Decimal
        let parent1Income: Decimal
        let parent2Income: Decimal
    }

    // MARK: - Plan Summary

    struct PlanSummary {
        let totalDaysUsed: Double
        let daysRemaining: Double
        let sgiDaysUsed: Double
        let basicDaysUsed: Double
        let parent1DaysUsed: Double
        let parent2DaysUsed: Double
        let avgMonthlyHouseholdIncome: Decimal
        let totalIncomeOnLeave: Decimal
        let totalIncomeWorking: Decimal
        let warnings: [Warning]
    }

    struct Warning: Identifiable {
        let id = UUID()
        let icon: String
        let message: String
        let isUrgent: Bool
    }

    // MARK: - Project Month by Month

    static func project(scenario: Scenario, family: Family, months: Int = 48) -> [MonthProjection] {
        let cal = Calendar.current
        let now = Date()
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? now

        let p1Income = family.parent1?.monthlyGrossIncome ?? 0
        let p2Income = family.parent2?.monthlyGrossIncome ?? 0

        return (0..<months).compactMap { offset -> MonthProjection? in
            guard let month = cal.date(byAdding: .month, value: offset, to: startOfMonth) else { return nil }
            guard let monthEnd = cal.date(byAdding: .month, value: 1, to: month) else { return nil }

            // Check if each parent has a leave block covering this month
            let p1Block = scenario.parent1Blocks.first { $0.startDate < monthEnd && $0.endDate > month }
            let p2Block = scenario.parent2Blocks.first { $0.startDate < monthEnd && $0.endDate > month }

            let p1MonthlyIncome: Decimal
            if let block = p1Block {
                let dailyRate = block.payLevel == .sgiLevel
                    ? ParentalLeaveRules.dailySGIPayment(monthlyIncome: p1Income)
                    : ParentalLeaveRules.lagstanivaDaily
                p1MonthlyIncome = dailyRate * 30 * Decimal(block.percentage)
            } else {
                p1MonthlyIncome = p1Income
            }

            let p2MonthlyIncome: Decimal
            if let block = p2Block {
                let dailyRate = block.payLevel == .sgiLevel
                    ? ParentalLeaveRules.dailySGIPayment(monthlyIncome: p2Income)
                    : ParentalLeaveRules.lagstanivaDaily
                p2MonthlyIncome = dailyRate * 30 * Decimal(block.percentage)
            } else {
                p2MonthlyIncome = p2Income
            }

            return MonthProjection(
                month: month,
                parent1OnLeave: p1Block != nil,
                parent2OnLeave: p2Block != nil,
                householdIncome: p1MonthlyIncome + p2MonthlyIncome,
                parent1Income: p1MonthlyIncome,
                parent2Income: p2MonthlyIncome
            )
        }
    }

    // MARK: - Summarize

    static func summarize(scenario: Scenario, family: Family) -> PlanSummary {
        let child = family.firstChild
        let multipleType = child?.multipleType ?? .single
        let totalDays = Double(ParentalLeaveRules.totalDays(multipleType: multipleType))
        let alreadyTaken = Double((family.parent1?.foraldraDaysTaken ?? 0) + (family.parent2?.foraldraDaysTaken ?? 0))

        let p1SGI = scenario.parent1Blocks.filter { $0.payLevel == .sgiLevel }.reduce(0.0) { $0 + $1.daysConsumed }
        let p1Basic = scenario.parent1Blocks.filter { $0.payLevel == .basicLevel }.reduce(0.0) { $0 + $1.daysConsumed }
        let p2SGI = scenario.parent2Blocks.filter { $0.payLevel == .sgiLevel }.reduce(0.0) { $0 + $1.daysConsumed }
        let p2Basic = scenario.parent2Blocks.filter { $0.payLevel == .basicLevel }.reduce(0.0) { $0 + $1.daysConsumed }

        let totalPlanned = p1SGI + p1Basic + p2SGI + p2Basic
        let totalUsed = alreadyTaken + totalPlanned
        let remaining = totalDays - totalUsed

        // Income projection
        let projections = project(scenario: scenario, family: family, months: 48)
        let leaveMonths = projections.filter { $0.parent1OnLeave || $0.parent2OnLeave }
        let avgIncome: Decimal = leaveMonths.isEmpty ? 0
            : leaveMonths.reduce(Decimal(0)) { $0 + $1.householdIncome } / Decimal(leaveMonths.count)

        let workingIncome = (family.parent1?.monthlyGrossIncome ?? 0) + (family.parent2?.monthlyGrossIncome ?? 0)
        let totalOnLeave = leaveMonths.reduce(Decimal(0)) { $0 + $1.householdIncome }
        let totalWorking = workingIncome * Decimal(leaveMonths.count)

        // Warnings
        var warnings: [Warning] = []

        if remaining < 0 {
            warnings.append(Warning(
                icon: "exclamationmark.triangle.fill",
                message: "Planen använder \(Int(-remaining)) fler dagar än tillgängligt!",
                isUrgent: true
            ))
        }

        let sgiTotal = Double(ParentalLeaveRules.sgiLevelDays)
        if (p1SGI + p2SGI) > sgiTotal - alreadyTaken {
            warnings.append(Warning(
                icon: "exclamationmark.triangle.fill",
                message: "Fler SGI-dagar planerade än tillgängliga",
                isUrgent: true
            ))
        }

        // Reserved days check
        let reserved = Double(ParentalLeaveRules.reservedDaysPerParent)
        let p1Total = p1SGI + p1Basic
        let p2Total = p2SGI + p2Basic
        if family.parent2 != nil {
            if p1Total < reserved && p2Total > (totalDays - reserved * 2) {
                warnings.append(Warning(
                    icon: "person.fill.questionmark",
                    message: "\(family.parent1?.name ?? "Förälder 1") har reserverade dagar kvar att använda",
                    isUrgent: false
                ))
            }
        }

        // SGI expiry warning
        if let child = child {
            let sgiExpiry = ParentalLeaveRules.sgiExpiryDate(childBirthDate: child.birthDate)
            let daysUntilExpiry = ParentalLeaveRules.daysUntil(sgiExpiry)
            if daysUntilExpiry < 365 && remaining > Double(ParentalLeaveRules.maxDaysSaveableAfterAge4) {
                warnings.append(Warning(
                    icon: "calendar.badge.exclamationmark",
                    message: "SGI-dagar bör användas före \(LeaveCalculator.formatDate(sgiExpiry))",
                    isUrgent: daysUntilExpiry < 180
                ))
            }
        }

        return PlanSummary(
            totalDaysUsed: totalUsed,
            daysRemaining: remaining,
            sgiDaysUsed: p1SGI + p2SGI + alreadyTaken,
            basicDaysUsed: p1Basic + p2Basic,
            parent1DaysUsed: p1SGI + p1Basic,
            parent2DaysUsed: p2SGI + p2Basic,
            avgMonthlyHouseholdIncome: avgIncome,
            totalIncomeOnLeave: totalOnLeave,
            totalIncomeWorking: totalWorking,
            warnings: warnings
        )
    }

    // MARK: - Formatting

    static func monthLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        f.dateFormat = "MMM"
        return f.string(from: date).capitalized
    }

    static func monthYearLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        f.dateFormat = "MMM yy"
        return f.string(from: date).capitalized
    }
}
