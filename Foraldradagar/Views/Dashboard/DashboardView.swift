import SwiftUI
import SwiftData

// MARK: - Dashboard View
// The home screen. Answers "how many days do we have left?" in < 1 second.
// PRD: "Glanceable — the home screen answers the core question instantly."

struct DashboardView: View {
    let family: Family
    @Binding var selectedTab: AppTab

    @State private var showPlanner = false

    private var days: LeaveCalculator.DaysSummary {
        LeaveCalculator.calculateDays(family: family)
    }

    private var income: LeaveCalculator.IncomeSummary {
        LeaveCalculator.calculateIncome(family: family)
    }

    private var deadline: LeaveCalculator.DeadlineInfo? {
        LeaveCalculator.nextDeadline(family: family)
    }

    private var greeting: String {
        let name = family.parent1?.name ?? ""
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        switch hour {
        case 5..<10:  timeGreeting = "God morgon"
        case 10..<17: timeGreeting = "Hej"
        case 17..<22: timeGreeting = "God kväll"
        default:      timeGreeting = "Hej"
        }
        return name.isEmpty ? timeGreeting + "!" : timeGreeting + ", \(name)!"
    }

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "sv_SE")
        f.dateFormat = "EEEE d MMMM"
        return f.string(from: Date()).capitalized
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCanvas.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        // Header
                        headerSection

                        // Hero: Days remaining
                        daysHeroCard

                        // Parent split (side by side)
                        parentSplitSection

                        // Next deadline
                        if let deadline {
                            deadlineCard(deadline)
                        }

                        // Quick actions
                        quickActionsSection

                        // Income overview
                        incomeCard

                        // Child info
                        if let child = family.firstChild {
                            childInfoCard(child)
                        }
                    }
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.top, Spacing.base)
                    .padding(.bottom, Spacing.xxxxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showPlanner) {
                ScenarioPlannerView(family: family)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(greeting)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(Color.textPrimary)

            Text(dateString)
                .font(.onboardingMeta)
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Hero Card: Days Remaining

    private var daysHeroCard: some View {
        VStack(spacing: Spacing.base) {
            // Big number
            Text("\(days.daysRemainingTotal)")
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundStyle(Color.textPrimary)
                .contentTransition(.numericText())

            Text("dagar kvar")
                .font(.onboardingBody)
                .foregroundStyle(Color.textSecondary)
                .offset(y: -8)

            // Progress bar
            progressBar

            // Breakdown row
            HStack(spacing: Spacing.xl) {
                dayBreakdownPill(
                    count: days.daysRemainingSGI,
                    label: "SGI-nivå",
                    color: .textAccent
                )

                dayBreakdownPill(
                    count: days.daysRemainingBasic,
                    label: "Lägstanivå",
                    color: .textTertiary
                )

                if days.daysTakenTotal > 0 {
                    dayBreakdownPill(
                        count: days.daysTakenTotal,
                        label: "Tagna",
                        color: .checkboxFilled
                    )
                }
            }
        }
        .padding(.vertical, Spacing.xl)
        .padding(.horizontal, Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .fill(Color.bgSurface)
        )
        .cardShadow()
    }

    private var progressBar: some View {
        let total = Double(days.totalDays)
        let taken = Double(days.daysTakenTotal)
        let progress = total > 0 ? taken / total : 0

        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background
                Capsule()
                    .fill(Color.textPrimary.opacity(0.06))
                    .frame(height: 8)

                // Filled portion
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentBlue, Color.parent2Color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geo.size.width * progress), height: 8)
            }
        }
        .frame(height: 8)
        .padding(.horizontal, Spacing.lg)
    }

    private func dayBreakdownPill(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            Text("\(count)")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundStyle(color)

            Text(label)
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Parent Split

    private var parentSplitSection: some View {
        HStack(spacing: Spacing.md) {
            if let p1 = family.parent1 {
                parentCard(
                    parent: p1,
                    reservedRemaining: days.reservedRemainingParent1,
                    monthlyOnLeave: income.parent1MonthlyOnLeave,
                    accentColor: Color(hex: p1.color)
                )
            }

            if let p2 = family.parent2 {
                parentCard(
                    parent: p2,
                    reservedRemaining: days.reservedRemainingParent2,
                    monthlyOnLeave: income.parent2MonthlyOnLeave,
                    accentColor: Color(hex: p2.color)
                )
            }
        }
    }

    private func parentCard(
        parent: Parent,
        reservedRemaining: Int,
        monthlyOnLeave: Decimal,
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Name + color bar
            HStack(spacing: Spacing.sm) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor)
                    .frame(width: 4, height: 24)

                Text(parent.name.isEmpty ? (parent.isParent1 ? "Förälder 1" : "Förälder 2") : parent.name)
                    .font(.onboardingBodyBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
            }

            // Monthly FK payment — the hero number
            VStack(alignment: .leading, spacing: 2) {
                Text("~\(LeaveCalculator.formatCurrency(monthlyOnLeave))")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("föräldrapenning/mån")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.textTertiary)
            }

            // Stats
            VStack(alignment: .leading, spacing: Spacing.sm) {
                parentStat(label: "Reserverade", value: "\(reservedRemaining) kvar")
                parentStat(label: "Tagna", value: "\(parent.foraldraDaysTaken) dagar")
            }

            // VAB this year
            if parent.vabDaysThisYear > 0 {
                Divider()
                parentStat(
                    label: "VAB i år",
                    value: "\(parent.vabDaysThisYear)/\(ParentalLeaveRules.vabDaysPerChildPerYear)"
                )
            }
        }
        .padding(Spacing.base)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Color.bgSurface)
        )
        .cardShadow()
    }

    private func parentStat(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)
            Spacer()
            Text(value)
                .font(.onboardingCaption)
                .foregroundStyle(Color.textPrimary)
        }
    }

    // MARK: - Deadline Card

    private func deadlineCard(_ deadline: LeaveCalculator.DeadlineInfo) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: deadline.icon)
                .font(.system(size: 24))
                .foregroundStyle(deadline.isUrgent ? Color.accentCoral : Color.textAccent)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(deadline.description)
                    .font(.onboardingBodyBold)
                    .foregroundStyle(Color.textPrimary)

                Text("\(LeaveCalculator.formatDate(deadline.date)) — om \(LeaveCalculator.formatDaysUntil(deadline.daysUntil))")
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
        .padding(Spacing.base)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(deadline.isUrgent ? Color.accentCoral.opacity(0.06) : Color.bgSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .stroke(deadline.isUrgent ? Color.accentCoral.opacity(0.2) : Color.clear, lineWidth: 1)
                )
        )
        .cardShadow()
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Snabbval")
                .font(.onboardingBodyBold)
                .foregroundStyle(Color.textPrimary)

            HStack(spacing: Spacing.md) {
                quickActionCard(
                    icon: "calendar.badge.plus",
                    label: "Logga dag",
                    color: .checkboxFilled
                ) { selectedTab = .days }

                quickActionCard(
                    icon: "sparkles",
                    label: "Fråga AI",
                    color: .textAccent
                ) { selectedTab = .ask }

                quickActionCard(
                    icon: "chart.bar.xaxis",
                    label: "Planera",
                    color: .accentCoral
                ) { showPlanner = true }
            }
        }
    }

    @State private var hapticTrigger = false

    private func quickActionCard(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            hapticTrigger.toggle()
            action()
        } label: {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)

                Text(label)
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.base)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.bgSurface)
            )
            .cardShadow()
        }
        .buttonStyle(ScaleButtonStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: hapticTrigger)
    }

    // MARK: - Income Card

    private var incomeCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Ekonomisk översikt")
                .font(.onboardingBodyBold)
                .foregroundStyle(Color.textPrimary)

            // Per-parent FK breakdown
            VStack(spacing: Spacing.sm) {
                if let p1 = family.parent1 {
                    HStack {
                        Circle()
                            .fill(Color(hex: p1.color))
                            .frame(width: 6, height: 6)
                        Text(p1.name.isEmpty ? "Förälder 1" : p1.name)
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text("~\(LeaveCalculator.formatCurrency(income.parent1MonthlyOnLeave))/mån")
                            .font(.onboardingMeta)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.textPrimary)
                    }
                }

                if let p2 = family.parent2 {
                    HStack {
                        Circle()
                            .fill(Color(hex: p2.color))
                            .frame(width: 6, height: 6)
                        Text(p2.name.isEmpty ? "Förälder 2" : p2.name)
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text("~\(LeaveCalculator.formatCurrency(income.parent2MonthlyOnLeave))/mån")
                            .font(.onboardingMeta)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.textPrimary)
                    }
                }
            }

            Divider()

            // Household comparison
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Arbete")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                    Text(LeaveCalculator.formatCurrency(income.householdMonthlyWorking) + "/mån")
                        .font(.onboardingBodyBold)
                        .foregroundStyle(Color.textPrimary)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .foregroundStyle(Color.textTertiary)

                Spacer()

                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Båda ledig")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                    Text("~" + LeaveCalculator.formatCurrency(income.householdMonthlyBothOnLeave) + "/mån")
                        .font(.onboardingBodyBold)
                        .foregroundStyle(Color.accentGreen)
                }
            }

            // Difference
            let diff = income.monthlyDifference
            if NSDecimalNumber(decimal: diff).intValue > 0 {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "arrow.down.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.accentCoral)
                    Text("-\(LeaveCalculator.formatCurrency(diff))/mån under ledighet")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(Spacing.base)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Color.bgSurface)
        )
        .cardShadow()
    }

    // MARK: - Child Info

    private func childInfoCard(_ child: Child) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: child.isBorn ? "figure.child" : "stork")
                .font(.system(size: 20))
                .foregroundStyle(Color.textAccent)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.textAccent.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(child.isBorn ? "Barnet" : "Beräknad födsel")
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textTertiary)

                Text(child.isBorn
                     ? "\(child.ageDescription) — Född \(LeaveCalculator.formatShortDate(child.birthDate))"
                     : LeaveCalculator.formatDate(child.birthDate))
                    .font(.onboardingMeta)
                    .foregroundStyle(Color.textPrimary)
            }

            Spacer()
        }
        .padding(Spacing.base)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Color.bgSurface)
        )
        .cardShadow()
    }
}

// MARK: - Color from Hex String

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}
