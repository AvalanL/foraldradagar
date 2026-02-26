import Foundation
import SwiftData

// MARK: - Onboarding → Core Model Converter
// Transforms OnboardingData into Family/Parent/Child entities.
// Called once when user finishes onboarding.

struct OnboardingConverter {

    /// Converts onboarding data into persisted core models.
    /// Returns the newly created Family.
    @discardableResult
    static func convert(
        from data: OnboardingData,
        isPremium: Bool,
        in context: ModelContext
    ) -> Family {
        let family = Family()
        family.isPremium = isPremium
        family.freeAIQuestionsRemaining = isPremium ? 999 : 3
        family.planningPriority = data.priority?.rawValue
        family.childcarePlan = data.childcarePlan?.rawValue
        family.knowledgeLevel = data.knowledgeLevel?.rawValue

        // Parent 1
        let parent1 = Parent()
        parent1.name = data.parent1.name
        parent1.monthlyGrossIncome = data.parent1.monthlyIncome
        parent1.isParent1 = true
        parent1.colorHex = "839BEC" // accentBlue — Förälder 1
        if data.parent1.hasEmployerTopUp == true {
            parent1.employerTopUpPercentage = data.parent1.topUpPercentage?.rawValue
            parent1.employerTopUpMonths = data.parent1.topUpMonths?.rawValue
        }
        parent1.family = family
        family.parents.append(parent1)

        // Seed parent 1's already-taken days
        if let daysTaken = data.daysTakenParent1, daysTaken > 0 {
            seedDays(count: daysTaken, for: parent1, child: data.childDate ?? Date())
        }

        // Parent 2 (if two-parent family)
        if data.familyType == .twoParents, let p2Data = data.parent2 {
            let parent2 = Parent()
            parent2.name = p2Data.name
            parent2.monthlyGrossIncome = p2Data.monthlyIncome
            parent2.isParent1 = false
            parent2.colorHex = "D3AA4E" // accentGold — Förälder 2
            if p2Data.hasEmployerTopUp == true {
                parent2.employerTopUpPercentage = p2Data.topUpPercentage?.rawValue
                parent2.employerTopUpMonths = p2Data.topUpMonths?.rawValue
            }
            parent2.family = family
            family.parents.append(parent2)

            // Seed parent 2's already-taken days
            if let daysTaken = data.daysTakenParent2, daysTaken > 0 {
                seedDays(count: daysTaken, for: parent2, child: data.childDate ?? Date())
            }
        }

        // Child
        let child = Child()
        child.birthDate = data.childDate ?? Date()
        child.isBorn = data.stage == .born
        child.multipleTypeRaw = (data.multipleType ?? .single).rawValue
        child.isFirstChild = data.isFirstChild ?? true
        child.family = family
        family.children.append(child)

        // Persist
        context.insert(family)
        try? context.save()

        return family
    }

    // MARK: - Seed Historical Days

    /// Creates placeholder LeaveDay entries for days already taken.
    /// Spreads them backwards from today, weekdays only.
    private static func seedDays(count: Int, for parent: Parent, child childBirthDate: Date) {
        let calendar = Calendar.current
        var date = Date()
        var seeded = 0

        while seeded < count {
            // Skip weekends
            let weekday = calendar.component(.weekday, from: date)
            if weekday != 1 && weekday != 7 {
                // Don't seed before child birth
                if date >= childBirthDate {
                    let day = LeaveDay(
                        date: date,
                        type: .foraldrapenning,
                        payLevel: .sgiLevel,
                        isPlanned: false
                    )
                    day.parent = parent
                    parent.leaveDays.append(day)
                    seeded += 1
                }
            }
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
    }
}
