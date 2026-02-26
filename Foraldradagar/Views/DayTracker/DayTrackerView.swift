import SwiftUI
import SwiftData

// MARK: - Day Tracker View
// Calendar-based view for logging and viewing parental leave + VAB days.
// PRD: "Tap a day to log: type, which parent. Weekly/monthly summary."

struct DayTrackerView: View {
    let family: Family

    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate: Date = Date()
    @State private var displayedMonth: Date = Date()
    @State private var showLogSheet = false

    private var calendar: Calendar { Calendar.current }

    private var days: LeaveCalculator.DaysSummary {
        LeaveCalculator.calculateDays(family: family)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCanvas.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {
                        // Month summary card
                        monthSummaryCard

                        // Calendar grid
                        calendarCard

                        // Selected day detail
                        selectedDaySection

                        // Recent activity
                        recentActivitySection
                    }
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.top, Spacing.base)
                    .padding(.bottom, Spacing.xxxxl)
                }
            }
            .navigationTitle("Dagkalender")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedDate = Date()
                            displayedMonth = Date()
                        }
                    } label: {
                        Text("Idag")
                            .font(.onboardingMeta)
                            .foregroundStyle(Color.textAccent)
                    }
                }
            }
            .sheet(isPresented: $showLogSheet) {
                LogDaySheet(
                    family: family,
                    date: selectedDate,
                    onSave: { type, payLevel, parent in
                        logDay(date: selectedDate, type: type, payLevel: payLevel, parent: parent)
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Month Summary

    private var monthSummaryCard: some View {
        let monthDays = leaveDaysInMonth(displayedMonth)
        let p1Days = monthDays.filter { $0.parent?.isParent1 == true }.count
        let p2Days = monthDays.filter { $0.parent?.isParent1 == false }.count
        let vabDays = monthDays.filter { $0.type == .vab }.count

        return HStack(spacing: Spacing.lg) {
            summaryPill(
                count: days.daysRemainingTotal,
                label: "Kvar totalt",
                color: .textAccent
            )

            summaryPill(
                count: p1Days + p2Days,
                label: "Denna månad",
                color: .accentBlue
            )

            if vabDays > 0 {
                summaryPill(
                    count: vabDays,
                    label: "VAB",
                    color: .vabColor
                )
            }
        }
        .padding(.vertical, Spacing.base)
        .padding(.horizontal, Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .fill(Color.bgSurface)
        )
        .cardShadow()
    }

    private func summaryPill(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            Text("\(count)")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(color)

            Text(label)
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Calendar Card

    private var calendarCard: some View {
        VStack(spacing: Spacing.base) {
            // Month navigation
            HStack {
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(monthYearString(displayedMonth))
                        .font(.onboardingBodyBold)
                        .foregroundStyle(Color.textPrimary)
                }

                Spacer()

                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 44, height: 44)
                }
            }

            // Day-of-week headers
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Date grid
            let dates = datesForMonth(displayedMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 4) {
                ForEach(dates, id: \.self) { date in
                    calendarDateCell(date)
                }
            }
        }
        .padding(Spacing.base)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .fill(Color.bgSurface)
        )
        .cardShadow()
    }

    private func calendarDateCell(_ date: Date) -> some View {
        let isCurrentMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let leaveDay = leaveDayFor(date)

        return Button {
            withAnimation(.easeOut(duration: 0.15)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 2) {
                ZStack {
                    // Selected background
                    if isSelected {
                        Circle()
                            .fill(Color.textAccent)
                            .frame(width: 36, height: 36)
                    } else if isToday {
                        Circle()
                            .stroke(Color.textAccent, lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                    }

                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 16, weight: isToday ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected ? .white :
                            !isCurrentMonth ? Color.textDisabled :
                            Color.textPrimary
                        )
                }
                .frame(width: 40, height: 40)

                // Leave indicator dot
                if let leaveDay, isCurrentMonth {
                    Circle()
                        .fill(colorForLeaveDay(leaveDay))
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Selected Day Detail

    private var selectedDaySection: some View {
        let leaveDay = leaveDayFor(selectedDate)

        return VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text(selectedDateString)
                    .font(.onboardingBodyBold)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                if leaveDay == nil {
                    Button {
                        showLogSheet = true
                    } label: {
                        Label("Logga dag", systemImage: "plus.circle.fill")
                            .font(.onboardingMeta)
                            .foregroundStyle(Color.textAccent)
                    }
                }
            }

            if let leaveDay {
                // Show logged day
                HStack(spacing: Spacing.md) {
                    // Color indicator
                    RoundedRectangle(cornerRadius: 3)
                        .fill(colorForLeaveDay(leaveDay))
                        .frame(width: 4, height: 40)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(leaveDay.type.displayName)
                            .font(.onboardingBodyBold)
                            .foregroundStyle(Color.textPrimary)

                        HStack(spacing: Spacing.sm) {
                            Text(leaveDay.parent?.name ?? (leaveDay.parent?.isParent1 == true ? "Förälder 1" : "Förälder 2"))
                                .font(.onboardingCaption)
                                .foregroundStyle(Color.textSecondary)

                            Text("·")
                                .foregroundStyle(Color.textTertiary)

                            Text(leaveDay.payLevel.displayName)
                                .font(.onboardingCaption)
                                .foregroundStyle(Color.textSecondary)

                            if leaveDay.isPlanned {
                                Text("Planerad")
                                    .font(.onboardingCaption)
                                    .foregroundStyle(Color.textAccent)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.textAccent.opacity(0.1))
                                    )
                            }
                        }
                    }

                    Spacer()

                    // Delete button
                    Button {
                        deleteLeaveDay(leaveDay)
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textTertiary)
                            .frame(width: 36, height: 36)
                    }
                }
                .padding(Spacing.base)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .fill(Color.bgSurface)
                )
                .cardShadow()
            } else {
                // Empty state
                HStack(spacing: Spacing.md) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.textTertiary)

                    Text("Ingen dag loggad")
                        .font(.onboardingMeta)
                        .foregroundStyle(Color.textTertiary)
                }
                .padding(Spacing.base)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .fill(Color.bgSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .stroke(Color.borderCard, lineWidth: 1)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                        )
                )
            }
        }
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        let recent = recentLeaveDays(limit: 5)

        return Group {
            if !recent.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Senaste aktivitet")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                        .textCase(.uppercase)

                    VStack(spacing: 0) {
                        ForEach(Array(recent.enumerated()), id: \.element.id) { index, day in
                            recentDayRow(day)

                            if index < recent.count - 1 {
                                Divider()
                                    .padding(.leading, 48)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(Color.bgSurface)
                    )
                    .cardShadow()
                }
            }
        }
    }

    private func recentDayRow(_ day: LeaveDay) -> some View {
        HStack(spacing: Spacing.md) {
            Circle()
                .fill(colorForLeaveDay(day))
                .frame(width: 10, height: 10)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(day.type.displayName)
                    .font(.onboardingMeta)
                    .foregroundStyle(Color.textPrimary)

                Text("\(day.parent?.name ?? "—") · \(shortDateString(day.date))")
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textTertiary)
            }

            Spacer()

            Text(day.payLevel.displayName)
                .font(.onboardingCaption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Helpers

    private var weekdaySymbols: [String] {
        // Swedish calendar starts on Monday
        let symbols = calendar.veryShortWeekdaySymbols
        // Rotate: [Sön, Mån, Tis, ...] → [Mån, Tis, ..., Sön]
        return Array(symbols[1...]) + [symbols[0]]
    }

    private func datesForMonth(_ month: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }

        // Weekday of the first (1=Sun, 2=Mon, ...)
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        // Adjust for Monday start: Mon=0, Tue=1, ..., Sun=6
        let mondayOffset = (firstWeekday + 5) % 7

        var dates: [Date] = []

        // Previous month padding
        for i in (0..<mondayOffset).reversed() {
            if let date = calendar.date(byAdding: .day, value: -(i + 1), to: firstOfMonth) {
                dates.append(date)
            }
        }

        // Current month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }

        // Next month padding (fill to 42 cells = 6 rows)
        let remaining = 42 - dates.count
        if let lastOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: firstOfMonth) {
            for i in 1...max(remaining, 7) {
                if dates.count >= 42 { break }
                if let date = calendar.date(byAdding: .day, value: i, to: lastOfMonth) {
                    dates.append(date)
                }
            }
        }

        return dates
    }

    private func monthYearString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date).capitalized
    }

    private var selectedDateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        f.dateFormat = "EEEE d MMMM"
        return f.string(from: selectedDate).capitalized
    }

    private func shortDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        f.dateFormat = "d MMM"
        return f.string(from: date)
    }

    private func leaveDayFor(_ date: Date) -> LeaveDay? {
        let allDays = (family.parent1?.leaveDays ?? []) + (family.parent2?.leaveDays ?? [])
        return allDays.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func leaveDaysInMonth(_ month: Date) -> [LeaveDay] {
        let allDays = (family.parent1?.leaveDays ?? []) + (family.parent2?.leaveDays ?? [])
        return allDays.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }

    private func recentLeaveDays(limit: Int) -> [LeaveDay] {
        let allDays = (family.parent1?.leaveDays ?? []) + (family.parent2?.leaveDays ?? [])
        return allDays
            .filter { !$0.isPlanned }
            .sorted { $0.date > $1.date }
            .prefix(limit)
            .map { $0 }
    }

    private func colorForLeaveDay(_ day: LeaveDay) -> Color {
        if day.type == .vab { return .vabColor }
        if day.parent?.isParent1 == true { return .parent1Color }
        return .parent2Color
    }

    // MARK: - Actions

    private func logDay(date: Date, type: LeaveDayType, payLevel: PayLevel, parent: Parent) {
        let day = LeaveDay(date: date, type: type, payLevel: payLevel, isPlanned: false)
        day.parent = parent
        parent.leaveDays.append(day)
        modelContext.insert(day)
        try? modelContext.save()
    }

    private func deleteLeaveDay(_ day: LeaveDay) {
        modelContext.delete(day)
        try? modelContext.save()
    }
}

// MARK: - Log Day Sheet

struct LogDaySheet: View {
    let family: Family
    let date: Date
    let onSave: (LeaveDayType, PayLevel, Parent) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: LeaveDayType = .foraldrapenning
    @State private var selectedPayLevel: PayLevel = .sgiLevel
    @State private var selectedParent: Parent?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Date
                Text(dateString)
                    .font(.onboardingTitle)
                    .foregroundStyle(Color.textPrimary)

                // Day type
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Typ")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                        .textCase(.uppercase)

                    HStack(spacing: Spacing.sm) {
                        ForEach(LeaveDayType.allCases, id: \.self) { type in
                            logPill(
                                label: type.displayName,
                                isSelected: selectedType == type,
                                color: type == .vab ? .vabColor : .textAccent
                            ) {
                                selectedType = type
                                if type == .vab {
                                    selectedPayLevel = .sgiLevel
                                }
                            }
                        }
                    }
                }

                // Pay level (only for föräldrapenning)
                if selectedType == .foraldrapenning {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Ersättningsnivå")
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.textTertiary)
                            .textCase(.uppercase)

                        HStack(spacing: Spacing.sm) {
                            logPill(
                                label: "SGI-nivå",
                                isSelected: selectedPayLevel == .sgiLevel,
                                color: .textAccent
                            ) { selectedPayLevel = .sgiLevel }

                            logPill(
                                label: "Grundnivå",
                                isSelected: selectedPayLevel == .basicLevel,
                                color: .textSecondary
                            ) { selectedPayLevel = .basicLevel }
                        }
                    }
                }

                // Parent selector
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Förälder")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                        .textCase(.uppercase)

                    HStack(spacing: Spacing.sm) {
                        if let p1 = family.parent1 {
                            logPill(
                                label: p1.name.isEmpty ? "Förälder 1" : p1.name,
                                isSelected: selectedParent?.id == p1.id,
                                color: .parent1Color
                            ) { selectedParent = p1 }
                        }

                        if let p2 = family.parent2 {
                            logPill(
                                label: p2.name.isEmpty ? "Förälder 2" : p2.name,
                                isSelected: selectedParent?.id == p2.id,
                                color: .parent2Color
                            ) { selectedParent = p2 }
                        }
                    }
                }

                Spacer()

                // Save button
                Button {
                    guard let parent = selectedParent else { return }
                    onSave(selectedType, selectedPayLevel, parent)
                    dismiss()
                } label: {
                    Text("Logga dag")
                        .font(.onboardingCTA)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(selectedParent != nil ? Color.buttonPrimary : Color.textDisabled)
                        )
                }
                .disabled(selectedParent == nil)
            }
            .padding(.horizontal, Spacing.screenH)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.lg)
            .background(Color.bgCanvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Avbryt") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .onAppear {
            // Default to parent 1
            selectedParent = family.parent1
        }
    }

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        f.dateFormat = "EEEE d MMMM"
        return f.string(from: date).capitalized
    }

    private func logPill(label: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.onboardingMeta)
                .foregroundStyle(isSelected ? .white : Color.textPrimary)
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? color : Color.bgSurface)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.borderCard, lineWidth: 1)
                )
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
