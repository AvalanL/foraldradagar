import SwiftUI
import SwiftData

// MARK: - Scenario Planner View
// The killer feature: visual timeline planner for parental leave.
// Users create up to 3 scenarios, add leave blocks per parent,
// and see real-time income projections + day consumption.

struct ScenarioPlannerView: View {
    let family: Family
    @Environment(\.modelContext) private var modelContext

    @State private var selectedIndex = 0
    @State private var showBlockSheet = false
    @State private var editingBlock: LeaveBlock?

    private var scenarios: [Scenario] {
        family.scenarios.sorted { $0.createdAt < $1.createdAt }
    }

    private var currentScenario: Scenario? {
        guard !scenarios.isEmpty else { return nil }
        return scenarios[min(selectedIndex, scenarios.count - 1)]
    }

    var body: some View {
        ZStack {
            Color.bgCanvas.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    scenarioTabBar

                    if let scenario = currentScenario {
                        timelineCard(scenario)
                        blockList(scenario)
                        addBlockButton
                        summaryCard(scenario)
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, Spacing.base)
                .padding(.bottom, Spacing.xxxxl)
            }
        }
        .navigationTitle("Planera")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: Spacing.base) {
                    if scenarios.count > 1, currentScenario != nil {
                        Button { deleteCurrentScenario() } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.accentCoral)
                        }
                    }

                    if scenarios.count < 3 {
                        Button { addScenario() } label: {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.textAccent)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showBlockSheet, onDismiss: { editingBlock = nil }) {
            if let scenario = currentScenario {
                AddBlockSheet(family: family, scenario: scenario, editingBlock: editingBlock)
            }
        }
        .onAppear { ensureDefaultScenario() }
    }

    // MARK: - Scenario Tab Bar

    private var scenarioTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(Array(scenarios.enumerated()), id: \.element.id) { index, scenario in
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) { selectedIndex = index }
                    } label: {
                        Text(scenario.name)
                            .font(.onboardingMeta)
                            .fontWeight(selectedIndex == index ? .semibold : .regular)
                            .foregroundStyle(selectedIndex == index ? .white : Color.textSecondary)
                            .padding(.horizontal, Spacing.base)
                            .padding(.vertical, Spacing.sm)
                            .background(
                                Capsule()
                                    .fill(selectedIndex == index ? Color.accentBlue : Color.bgSurface)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(selectedIndex == index ? Color.clear : Color.borderCard, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Timeline

    private func timelineCard(_ scenario: Scenario) -> some View {
        let monthWidth: CGFloat = 52
        let laneHeight: CGFloat = 48
        let start = Self.timelineStart(for: scenario)
        let months = Self.timelineMonths(for: scenario, from: start)
        let totalWidth = CGFloat(months) * monthWidth

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("TIDSLINJE")
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)

            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Month labels
                        HStack(spacing: 0) {
                            ForEach(0..<months, id: \.self) { i in
                                let date = Calendar.current.date(byAdding: .month, value: i, to: start)!
                                Text(Self.shortMonthLabel(date))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.textTertiary)
                                    .frame(width: monthWidth)
                            }
                        }
                        .padding(.vertical, 6)

                        Rectangle().fill(Color.separatorList).frame(height: 1)

                        // Parent 1 lane
                        timelineLane(
                            blocks: scenario.parent1Blocks,
                            color: .parent1Color,
                            label: family.parent1?.name ?? "Förälder 1",
                            totalWidth: totalWidth,
                            monthWidth: monthWidth,
                            laneHeight: laneHeight,
                            timelineStart: start,
                            totalMonths: months
                        )

                        Rectangle().fill(Color.separatorList).frame(height: 1)

                        // Parent 2 lane
                        if family.parent2 != nil {
                            timelineLane(
                                blocks: scenario.parent2Blocks,
                                color: .parent2Color,
                                label: family.parent2?.name ?? "Förälder 2",
                                totalWidth: totalWidth,
                                monthWidth: monthWidth,
                                laneHeight: laneHeight,
                                timelineStart: start,
                                totalMonths: months
                            )
                        }
                    }
                    .frame(width: totalWidth)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.bgSurface)
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .cardShadow()
        }
    }

    private func timelineLane(
        blocks: [LeaveBlock],
        color: Color,
        label: String,
        totalWidth: CGFloat,
        monthWidth: CGFloat,
        laneHeight: CGFloat,
        timelineStart: Date,
        totalMonths: Int
    ) -> some View {
        ZStack(alignment: .topLeading) {
            // Lane background
            Rectangle()
                .fill(Color.clear)
                .frame(width: totalWidth, height: laneHeight)

            // Alternating month stripes
            HStack(spacing: 0) {
                ForEach(0..<totalMonths, id: \.self) { i in
                    Rectangle()
                        .fill(i % 2 == 0 ? Color.clear : Color.textPrimary.opacity(0.015))
                        .frame(width: monthWidth, height: laneHeight)
                }
            }

            // Parent label
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.textTertiary.opacity(0.5))
                .padding(.leading, 4)
                .padding(.top, 3)

            // Leave blocks
            ForEach(blocks) { block in
                let startX = Self.xPosition(for: block.startDate, from: timelineStart, monthWidth: monthWidth)
                let endX = Self.xPosition(for: block.endDate, from: timelineStart, monthWidth: monthWidth)
                let width = max(monthWidth * 0.6, endX - startX - 2)

                RoundedRectangle(cornerRadius: 6)
                    .fill(color.gradient)
                    .frame(width: width, height: laneHeight - 14)
                    .overlay(
                        Text(width > 60 ? block.durationDescription : block.percentageDisplay)
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(1)
                    )
                    .offset(x: startX + 1, y: 7)
                    .onTapGesture {
                        editingBlock = block
                        showBlockSheet = true
                    }
            }

            // Today marker
            let todayX = Self.xPosition(for: Date(), from: timelineStart, monthWidth: monthWidth)
            if todayX > 0 && todayX < totalWidth {
                Rectangle()
                    .fill(Color.accentCoral.opacity(0.5))
                    .frame(width: 1.5, height: laneHeight)
                    .offset(x: todayX)
            }
        }
        .frame(width: totalWidth, height: laneHeight)
    }

    // MARK: - Block List

    private func blockList(_ scenario: Scenario) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("PERIODER")
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)

            if scenario.sortedBlocks.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.textTertiary)
                        Text("Inga perioder tillagda")
                            .font(.onboardingMeta)
                            .foregroundStyle(Color.textTertiary)
                    }
                    .padding(.vertical, Spacing.xxl)
                    Spacer()
                }
            } else {
                ForEach(scenario.sortedBlocks) { block in
                    blockCard(block)
                }
            }
        }
    }

    private func blockCard(_ block: LeaveBlock) -> some View {
        let color: Color = block.isParent1 ? .parent1Color : .parent2Color
        let parentName = block.isParent1
            ? (family.parent1?.name ?? "Förälder 1")
            : (family.parent2?.name ?? "Förälder 2")
        let income = block.isParent1
            ? (family.parent1?.monthlyGrossIncome ?? 0)
            : (family.parent2?.monthlyGrossIncome ?? 0)

        let dailyRate = block.payLevel == .sgiLevel
            ? ParentalLeaveRules.dailySGIPayment(monthlyIncome: income)
            : ParentalLeaveRules.lagstanivaDaily
        let monthlyOnLeave = dailyRate * 30 * Decimal(block.percentage)

        return Button {
            editingBlock = block
            showBlockSheet = true
        } label: {
            HStack(spacing: Spacing.md) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: 4, height: 44)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(parentName)
                            .font(.onboardingBodyBold)
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                        Text(block.durationDescription)
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.textSecondary)
                    }

                    Label(
                        "\(Self.formatDateShort(block.startDate)) \u{2192} \(Self.formatDateShort(block.endDate))",
                        systemImage: "calendar"
                    )
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textTertiary)

                    HStack(spacing: Spacing.sm) {
                        Text(block.payLevel == .sgiLevel ? "SGI-nivå" : "Lägstanivå")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(color.opacity(0.1)))

                        if block.percentage < 1.0 {
                            Text(block.percentageDisplay)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color.textSecondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.bgCream))
                        }

                        Spacer()

                        Text("~\(LeaveCalculator.formatCurrency(monthlyOnLeave))/mån")
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .padding(Spacing.base)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.bgSurface)
            )
            .cardShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Add Block Button

    private var addBlockButton: some View {
        Button {
            editingBlock = nil
            showBlockSheet = true
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                Text("Lägg till period")
                    .font(.onboardingBodyBold)
            }
            .foregroundStyle(Color.textAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.base)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(Color.textAccent.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [8, 4]))
            )
        }
    }

    // MARK: - Summary

    private func summaryCard(_ scenario: Scenario) -> some View {
        let summary = ScenarioCalculator.summarize(scenario: scenario, family: family)
        let totalDays = Double(LeaveCalculator.calculateDays(family: family).totalDays)
        let progress = totalDays > 0 ? summary.totalDaysUsed / totalDays : 0

        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("SAMMANFATTNING")
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)

            VStack(alignment: .leading, spacing: Spacing.base) {
                // Days progress
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("\(Int(summary.totalDaysUsed)) / \(Int(totalDays)) dagar")
                            .font(.onboardingBodyBold)
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                        Text("\(Int(summary.daysRemaining)) kvar")
                            .font(.onboardingMeta)
                            .foregroundStyle(summary.daysRemaining < 0 ? Color.accentCoral : Color.textSecondary)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.progressTrack)
                                .frame(height: 6)
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.parent1Color, Color.parent2Color],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(0, min(geo.size.width, geo.size.width * progress)), height: 6)
                        }
                    }
                    .frame(height: 6)
                }

                Divider()

                // Breakdown pills
                HStack(spacing: Spacing.xl) {
                    summaryPill(value: "\(Int(summary.sgiDaysUsed))", label: "SGI-dagar", color: .textAccent)
                    summaryPill(value: "\(Int(summary.basicDaysUsed))", label: "Lägstanivå", color: .textTertiary)
                    summaryPill(
                        value: "~\(LeaveCalculator.formatCurrency(summary.avgMonthlyHouseholdIncome))",
                        label: "Snitt/mån",
                        color: .accentGreen
                    )
                }

                Divider()

                // Per-parent
                HStack(spacing: Spacing.xl) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(family.parent1?.name ?? "Förälder 1")
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.parent1Color)
                        Text("\(Int(summary.parent1DaysUsed)) dagar")
                            .font(.onboardingMeta)
                            .foregroundStyle(Color.textPrimary)
                    }
                    if family.parent2 != nil {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(family.parent2?.name ?? "Förälder 2")
                                .font(.onboardingCaption)
                                .foregroundStyle(Color.parent2Color)
                            Text("\(Int(summary.parent2DaysUsed)) dagar")
                                .font(.onboardingMeta)
                                .foregroundStyle(Color.textPrimary)
                        }
                    }
                    Spacer()
                }

                // Warnings
                if !summary.warnings.isEmpty {
                    Divider()
                    ForEach(summary.warnings) { warning in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: warning.icon)
                                .font(.system(size: 14))
                                .foregroundStyle(warning.isUrgent ? Color.accentCoral : Color.accentGold)
                            Text(warning.message)
                                .font(.onboardingCaption)
                                .foregroundStyle(warning.isUrgent ? Color.accentCoral : Color.textSecondary)
                        }
                    }
                }
            }
            .padding(Spacing.base)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.bgSurface)
            )
            .cardShadow()
        }
    }

    private func summaryPill(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(Color.textTertiary)
            Text("Skapa din första plan")
                .font(.onboardingBody)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxxxl)
    }

    // MARK: - Actions

    private func ensureDefaultScenario() {
        if family.scenarios.isEmpty {
            addScenario()
        }
    }

    private func addScenario() {
        let count = scenarios.count
        let scenario = Scenario(name: "Plan \(count + 1)")
        scenario.family = family
        modelContext.insert(scenario)
        selectedIndex = count
    }

    private func deleteCurrentScenario() {
        guard let scenario = currentScenario else { return }
        modelContext.delete(scenario)
        selectedIndex = max(0, selectedIndex - 1)
    }

    // MARK: - Helpers

    static func timelineStart(for scenario: Scenario) -> Date {
        let cal = Calendar.current
        let now = Date()
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        if let earliest = scenario.sortedBlocks.first?.startDate {
            let blockStart = cal.date(from: cal.dateComponents([.year, .month], from: earliest))!
            return min(startOfMonth, blockStart)
        }
        return startOfMonth
    }

    static func timelineMonths(for scenario: Scenario, from start: Date) -> Int {
        let cal = Calendar.current
        if let latest = scenario.sortedBlocks.last?.endDate {
            let endMonth = cal.date(byAdding: .month, value: 3, to: latest)!
            let months = cal.dateComponents([.month], from: start, to: endMonth).month ?? 24
            return max(24, months)
        }
        return 24
    }

    static func xPosition(for date: Date, from start: Date, monthWidth: CGFloat) -> CGFloat {
        let days = Calendar.current.dateComponents([.day], from: start, to: date).day ?? 0
        return CGFloat(days) / 30.44 * monthWidth
    }

    static func shortMonthLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        let month = Calendar.current.component(.month, from: date)
        if month == 1 {
            f.dateFormat = "'Jan 'yy"
            return f.string(from: date)
        }
        f.dateFormat = "MMM"
        return f.string(from: date).prefix(3).capitalized
    }

    static func formatDateShort(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        f.dateFormat = "d MMM yy"
        return f.string(from: date)
    }
}

// MARK: - Add / Edit Block Sheet

struct AddBlockSheet: View {
    let family: Family
    let scenario: Scenario
    let editingBlock: LeaveBlock?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isParent1: Bool
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedPayLevel: PayLevel
    @State private var percentage: Double
    @State private var showDeleteConfirm = false

    init(family: Family, scenario: Scenario, editingBlock: LeaveBlock?) {
        self.family = family
        self.scenario = scenario
        self.editingBlock = editingBlock

        if let block = editingBlock {
            _isParent1 = State(initialValue: block.isParent1)
            _startDate = State(initialValue: block.startDate)
            _endDate = State(initialValue: block.endDate)
            _selectedPayLevel = State(initialValue: block.payLevel)
            _percentage = State(initialValue: block.percentage)
        } else {
            let cal = Calendar.current
            let nextMonth = cal.date(byAdding: .month, value: 1, to: Date()) ?? Date()
            let start = cal.date(from: cal.dateComponents([.year, .month], from: nextMonth)) ?? nextMonth
            let end = cal.date(byAdding: .month, value: 6, to: start) ?? start

            _isParent1 = State(initialValue: true)
            _startDate = State(initialValue: start)
            _endDate = State(initialValue: end)
            _selectedPayLevel = State(initialValue: .sgiLevel)
            _percentage = State(initialValue: 1.0)
        }
    }

    // Preview calculations (avoid creating @Model instances)
    private var weekdayCount: Int {
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

    private var daysConsumed: Double {
        Double(weekdayCount) * percentage
    }

    private var percentageLabel: String {
        if percentage == 1.0 { return "100%" }
        if percentage == 0.75 { return "75%" }
        if percentage == 0.5 { return "50%" }
        if percentage == 0.25 { return "25%" }
        if percentage == 0.125 { return "12,5%" }
        return "\(Int(percentage * 100))%"
    }

    private var monthlyIncome: Decimal {
        let income = isParent1
            ? (family.parent1?.monthlyGrossIncome ?? 0)
            : (family.parent2?.monthlyGrossIncome ?? 0)
        let dailyRate = selectedPayLevel == .sgiLevel
            ? ParentalLeaveRules.dailySGIPayment(monthlyIncome: income)
            : ParentalLeaveRules.lagstanivaDaily
        return dailyRate * 30 * Decimal(percentage)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCanvas.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        parentPicker
                        dateSection
                        payLevelSection
                        percentageSection
                        previewSection

                        if editingBlock != nil {
                            deleteButton
                        }
                    }
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.top, Spacing.base)
                    .padding(.bottom, Spacing.xxxxl)
                }
            }
            .navigationTitle(editingBlock != nil ? "Redigera period" : "Ny period")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Avbryt") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Spara") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textAccent)
                }
            }
        }
        .presentationDetents([.large])
        .onChange(of: startDate) { _, newValue in
            if endDate <= newValue {
                endDate = Calendar.current.date(byAdding: .month, value: 1, to: newValue) ?? newValue
            }
        }
        .alert("Ta bort period?", isPresented: $showDeleteConfirm) {
            Button("Ta bort", role: .destructive) { deleteBlock() }
            Button("Avbryt", role: .cancel) {}
        } message: {
            Text("Perioden tas bort permanent från planen.")
        }
    }

    // MARK: - Parent Picker

    private var parentPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("FÖRÄLDER")
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)

            HStack(spacing: Spacing.sm) {
                parentToggle(
                    name: family.parent1?.name ?? "Förälder 1",
                    color: .parent1Color,
                    isSelected: isParent1
                ) { isParent1 = true }

                if family.parent2 != nil {
                    parentToggle(
                        name: family.parent2?.name ?? "Förälder 2",
                        color: .parent2Color,
                        isSelected: !isParent1
                    ) { isParent1 = false }
                }
            }
        }
    }

    private func parentToggle(name: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(name)
                    .font(.onboardingMeta)
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textTertiary)
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(isSelected ? color.opacity(0.08) : Color.bgSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .stroke(isSelected ? color.opacity(0.3) : Color.borderCard, lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Dates

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("PERIOD")
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)

            VStack(spacing: 0) {
                HStack {
                    Text("Startdatum")
                        .font(.onboardingBody)
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "sv_SE"))
                }
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.md)

                Divider().padding(.leading, Spacing.base)

                HStack {
                    Text("Slutdatum")
                        .font(.onboardingBody)
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "sv_SE"))
                }
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.md)
            }
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.bgSurface)
            )
            .cardShadow()
        }
    }

    // MARK: - Pay Level

    private var payLevelSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("ERSÄTTNINGSNIVÅ")
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)

            HStack(spacing: Spacing.sm) {
                payLevelOption(title: "SGI-nivå", subtitle: "~80% av lön", level: .sgiLevel)
                payLevelOption(title: "Lägstanivå", subtitle: "180 kr/dag", level: .basicLevel)
            }
        }
    }

    private func payLevelOption(title: String, subtitle: String, level: PayLevel) -> some View {
        let isSelected = selectedPayLevel == level
        return Button { selectedPayLevel = level } label: {
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(.onboardingMeta)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textTertiary)
                Text(subtitle)
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(.vertical, Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(isSelected ? Color.accentBlue.opacity(0.06) : Color.bgSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .stroke(isSelected ? Color.accentBlue.opacity(0.3) : Color.borderCard, lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Percentage

    private var percentageSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("UTTAG")
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)

            HStack(spacing: Spacing.sm) {
                ForEach(ParentalLeaveRules.partTimeLevels, id: \.self) { level in
                    let isSelected = percentage == level
                    let label = level == 1.0 ? "100%" :
                                level == 0.75 ? "75%" :
                                level == 0.5 ? "50%" :
                                level == 0.25 ? "25%" : "12,5%"

                    Button { percentage = level } label: {
                        Text(label)
                            .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? .white : Color.textSecondary)
                            .padding(.vertical, Spacing.sm)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.small)
                                    .fill(isSelected ? Color.accentBlue : Color.bgSurface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CornerRadius.small)
                                            .stroke(isSelected ? Color.clear : Color.borderCard, lineWidth: 1)
                                    )
                            )
                    }
                }
            }
        }
    }

    // MARK: - Preview

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Divider()

            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("\(weekdayCount) vardagar \u{00D7} \(percentageLabel)")
                        .font(.onboardingMeta)
                        .foregroundStyle(Color.textPrimary)

                    Text("= \(Int(daysConsumed)) föräldrapenningdagar")
                        .font(.onboardingBodyBold)
                        .foregroundStyle(Color.textAccent)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("~\(LeaveCalculator.formatCurrency(monthlyIncome))")
                        .font(.onboardingBodyBold)
                        .foregroundStyle(Color.accentGreen)
                    Text("per månad")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .padding(Spacing.base)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.accentBlue.opacity(0.04))
            )
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button { showDeleteConfirm = true } label: {
            HStack {
                Image(systemName: "trash")
                Text("Ta bort period")
            }
            .font(.onboardingBody)
            .foregroundStyle(Color.accentCoral)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.base)
        }
    }

    // MARK: - Actions

    private func save() {
        if let block = editingBlock {
            block.isParent1 = isParent1
            block.startDate = startDate
            block.endDate = endDate
            block.payLevelRaw = selectedPayLevel.rawValue
            block.percentage = percentage
        } else {
            let block = LeaveBlock(
                startDate: startDate,
                endDate: endDate,
                isParent1: isParent1,
                payLevel: selectedPayLevel,
                percentage: percentage
            )
            block.scenario = scenario
            modelContext.insert(block)
        }
        dismiss()
    }

    private func deleteBlock() {
        if let block = editingBlock {
            modelContext.delete(block)
        }
        dismiss()
    }
}
