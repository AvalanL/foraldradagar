import Foundation
import SwiftData

// MARK: - Core Data Models
// Source: PRD Section 8 — Technical Architecture

// ─────────────────────────────────────────────
// Family — The root entity
// ─────────────────────────────────────────────

@Model
final class Family {
    var id: UUID = UUID()

    @Relationship(deleteRule: .cascade, inverse: \Parent.family)
    var parents: [Parent] = []

    @Relationship(deleteRule: .cascade, inverse: \Child.family)
    var children: [Child] = []

    @Relationship(deleteRule: .cascade, inverse: \Scenario.family)
    var scenarios: [Scenario] = []

    // Subscription / gating
    var isPremium: Bool = false
    var freeAIQuestionsRemaining: Int = 3

    // Onboarding preferences (used by AI advisor for personalization)
    var planningPriority: String? = nil   // PlanningPriority raw value
    var childcarePlan: String? = nil      // ChildcarePlan raw value
    var knowledgeLevel: String? = nil     // KnowledgeLevel raw value

    var createdAt: Date = Date()

    init() {}

    // MARK: - Convenience

    var parent1: Parent? {
        parents.first(where: { $0.isParent1 })
    }

    var parent2: Parent? {
        parents.first(where: { !$0.isParent1 })
    }

    var isSingleParent: Bool {
        parents.count <= 1
    }

    var firstChild: Child? {
        children.sorted(by: { $0.birthDate < $1.birthDate }).first
    }
}

// ─────────────────────────────────────────────
// Parent
// ─────────────────────────────────────────────

@Model
final class Parent {
    var id: UUID = UUID()
    var name: String = ""
    var monthlyGrossIncome: Decimal = 0
    var employerTopUpPercentage: Int? = nil   // 80, 85, 90, 100
    var employerTopUpMonths: Int? = nil       // 3, 6, 9, 12
    var isParent1: Bool = true
    var colorHex: String = "D4A94D"          // gold for P1

    @Relationship(deleteRule: .cascade, inverse: \LeaveDay.parent)
    var leaveDays: [LeaveDay] = []

    var family: Family?

    init() {}

    // MARK: - Convenience

    var color: String {
        isParent1 ? "4F46E5" : "E879A4"
    }

    var daysTaken: Int {
        leaveDays.filter { !$0.isPlanned }.count
    }

    var daysPlanned: Int {
        leaveDays.filter { $0.isPlanned }.count
    }

    var foraldraDaysTaken: Int {
        leaveDays.filter { !$0.isPlanned && $0.type == .foraldrapenning }.count
    }

    var vabDaysTaken: Int {
        leaveDays.filter { !$0.isPlanned && $0.type == .vab }.count
    }

    /// VAB days taken this calendar year
    var vabDaysThisYear: Int {
        let year = Calendar.current.component(.year, from: Date())
        return leaveDays.filter {
            !$0.isPlanned &&
            $0.type == .vab &&
            Calendar.current.component(.year, from: $0.date) == year
        }.count
    }
}

// ─────────────────────────────────────────────
// Child
// ─────────────────────────────────────────────

@Model
final class Child {
    var id: UUID = UUID()
    var name: String? = nil
    var birthDate: Date = Date()
    var isBorn: Bool = false
    var multipleTypeRaw: String = MultipleType.single.rawValue

    @Transient
    var multipleType: MultipleType {
        get { MultipleType(rawValue: multipleTypeRaw) ?? .single }
        set { multipleTypeRaw = newValue.rawValue }
    }
    var isFirstChild: Bool = true

    var family: Family?

    init() {}

    // MARK: - Convenience

    var ageDescription: String {
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day], from: birthDate, to: now)

        if !isBorn {
            let remaining = Calendar.current.dateComponents([.day], from: now, to: birthDate)
            let days = remaining.day ?? 0
            if days <= 0 { return "BF passerat" }
            return "\(days) dagar kvar"
        }

        if let years = components.year, years >= 1 {
            let months = components.month ?? 0
            return months > 0 ? "\(years) år, \(months) mån" : "\(years) år"
        } else if let months = components.month, months >= 1 {
            return "\(months) mån"
        } else {
            return "\(components.day ?? 0) dagar"
        }
    }
}

// ─────────────────────────────────────────────
// LeaveDay — A single logged or planned day
// ─────────────────────────────────────────────

@Model
final class LeaveDay {
    var id: UUID = UUID()
    var date: Date = Date()
    var typeRaw: String = LeaveDayType.foraldrapenning.rawValue
    var payLevelRaw: String = PayLevel.sgiLevel.rawValue

    @Transient
    var type: LeaveDayType {
        get { LeaveDayType(rawValue: typeRaw) ?? .foraldrapenning }
        set { typeRaw = newValue.rawValue }
    }

    @Transient
    var payLevel: PayLevel {
        get { PayLevel(rawValue: payLevelRaw) ?? .sgiLevel }
        set { payLevelRaw = newValue.rawValue }
    }
    var isPlanned: Bool = false

    var parent: Parent?

    init() {}

    init(date: Date, type: LeaveDayType, payLevel: PayLevel, isPlanned: Bool) {
        self.date = date
        self.typeRaw = type.rawValue
        self.payLevelRaw = payLevel.rawValue
        self.isPlanned = isPlanned
    }
}

// ─────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────

enum LeaveDayType: String, Codable, CaseIterable {
    case foraldrapenning = "foraldrapenning"
    case vab             = "vab"
    case unpaid          = "unpaid"

    var displayName: String {
        switch self {
        case .foraldrapenning: return "Föräldrapenning"
        case .vab:             return "VAB"
        case .unpaid:          return "Obetald"
        }
    }
}

enum PayLevel: String, Codable, CaseIterable {
    case sgiLevel   = "sgi_level"     // ~80% of income (capped)
    case basicLevel = "basic_level"   // 180 SEK/day
    case none       = "none"          // unpaid

    var displayName: String {
        switch self {
        case .sgiLevel:   return "Sjukpenningnivå"
        case .basicLevel: return "Grundnivå"
        case .none:       return "Ingen ersättning"
        }
    }
}
