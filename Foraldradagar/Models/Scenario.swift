import Foundation
import SwiftData

// MARK: - Scenario
// A named leave plan containing blocks of leave for each parent.
// Users can save up to 3 scenarios and compare them.

@Model
final class Scenario {
    var id: UUID = UUID()
    var name: String = "Plan 1"

    @Relationship(deleteRule: .cascade, inverse: \LeaveBlock.scenario)
    var leaveBlocks: [LeaveBlock] = []

    var family: Family?
    var createdAt: Date = Date()

    init() {}

    init(name: String) {
        self.name = name
    }

    // MARK: - Convenience

    var sortedBlocks: [LeaveBlock] {
        leaveBlocks.sorted { $0.startDate < $1.startDate }
    }

    var parent1Blocks: [LeaveBlock] {
        leaveBlocks.filter { $0.isParent1 }.sorted { $0.startDate < $1.startDate }
    }

    var parent2Blocks: [LeaveBlock] {
        leaveBlocks.filter { !$0.isParent1 }.sorted { $0.startDate < $1.startDate }
    }
}

// MARK: - Leave Block
// A continuous period of leave for one parent within a scenario.

@Model
final class LeaveBlock {
    var id: UUID = UUID()
    var startDate: Date = Date()
    var endDate: Date = Date()
    var isParent1: Bool = true
    var payLevelRaw: String = PayLevel.sgiLevel.rawValue
    var percentage: Double = 1.0  // 1.0, 0.75, 0.5, 0.25, 0.125

    @Transient
    var payLevel: PayLevel {
        get { PayLevel(rawValue: payLevelRaw) ?? .sgiLevel }
        set { payLevelRaw = newValue.rawValue }
    }

    var scenario: Scenario?

    init() {}

    init(startDate: Date, endDate: Date, isParent1: Bool, payLevel: PayLevel, percentage: Double = 1.0) {
        self.startDate = startDate
        self.endDate = endDate
        self.isParent1 = isParent1
        self.payLevelRaw = payLevel.rawValue
        self.percentage = percentage
    }

    // MARK: - Convenience

    /// Calendar days in this block
    var calendarDays: Int {
        max(0, Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0)
    }

    /// Weekdays (Mon-Fri) in this block — these are "föräldrapenningdagar"
    var weekdays: Int {
        var count = 0
        var current = startDate
        let cal = Calendar.current
        while current < endDate {
            let weekday = cal.component(.weekday, from: current)
            if weekday != 1 && weekday != 7 { count += 1 }
            current = cal.date(byAdding: .day, value: 1, to: current) ?? endDate
        }
        return count
    }

    /// Föräldrapenningdagar consumed (weekdays × percentage)
    var daysConsumed: Double {
        Double(weekdays) * percentage
    }

    /// Number of months this block spans (for display)
    var monthsSpan: Int {
        max(1, Calendar.current.dateComponents([.month], from: startDate, to: endDate).month ?? 1)
    }

    /// Short description: "6 mån, 130 dagar"
    var durationDescription: String {
        let months = monthsSpan
        let days = Int(daysConsumed)
        if months >= 1 {
            return "\(months) mån, \(days) dagar"
        }
        return "\(days) dagar"
    }

    /// Percentage display: "100%", "75%", etc.
    var percentageDisplay: String {
        if percentage == 1.0 { return "100%" }
        if percentage == 0.75 { return "75%" }
        if percentage == 0.5 { return "50%" }
        if percentage == 0.25 { return "25%" }
        if percentage == 0.125 { return "12,5%" }
        return "\(Int(percentage * 100))%"
    }
}
