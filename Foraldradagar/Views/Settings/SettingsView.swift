import SwiftUI
import SwiftData

// MARK: - Settings View
// The "Mer" tab — edit family info, view FK payments, configure API key.

struct SettingsView: View {
    @Query private var families: [Family]
    @State private var apiKey: String = AIAdvisorService.apiKey
    @State private var showAPIKeyField = false
    @State private var keySaved = false

    private var family: Family? { families.first }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCanvas.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        if let family {
                            familySection(family)
                        }

                        aiSection
                        appInfoSection
                    }
                    .padding(.horizontal, Spacing.screenH)
                    .padding(.top, Spacing.base)
                    .padding(.bottom, Spacing.xxxxl)
                }
            }
            .navigationTitle("Inställningar")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Family Section

    private func familySection(_ family: Family) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader("Familj")

            VStack(spacing: 0) {
                if let p1 = family.parent1 {
                    NavigationLink {
                        EditParentView(parent: p1)
                    } label: {
                        parentRow(p1)
                    }
                    Divider().padding(.leading, 52)
                }

                if let p2 = family.parent2 {
                    NavigationLink {
                        EditParentView(parent: p2)
                    } label: {
                        parentRow(p2)
                    }
                    Divider().padding(.leading, 52)
                }

                if let child = family.firstChild {
                    NavigationLink {
                        EditChildView(child: child)
                    } label: {
                        childRow(child)
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

    private func parentRow(_ parent: Parent) -> some View {
        let monthlyFK = ParentalLeaveRules.monthlyLeaveIncome(monthlyGrossIncome: parent.monthlyGrossIncome)

        return HStack(spacing: Spacing.md) {
            Image(systemName: "person.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: parent.color))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(parent.name.isEmpty ? (parent.isParent1 ? "Förälder 1" : "Förälder 2") : parent.name)
                    .font(.onboardingBody)
                    .foregroundStyle(Color.textPrimary)

                HStack(spacing: Spacing.sm) {
                    Text(LeaveCalculator.formatCurrency(parent.monthlyGrossIncome) + "/mån")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textSecondary)

                    Text("·")
                        .foregroundStyle(Color.textTertiary)

                    Text("FK ~\(LeaveCalculator.formatCurrency(monthlyFK))/mån")
                        .font(.onboardingCaption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.accentGreen)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.md)
    }

    private func childRow(_ child: Child) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: child.isBorn ? "figure.child" : "stork")
                .font(.system(size: 16))
                .foregroundStyle(Color.textAccent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(child.isBorn ? "Barn" : "Beräknad födsel")
                    .font(.onboardingBody)
                    .foregroundStyle(Color.textPrimary)

                Text(child.isBorn ? child.ageDescription : LeaveCalculator.formatDate(child.birthDate))
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - AI Section

    private var aiSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader("AI-rådgivare")

            VStack(spacing: 0) {
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showAPIKeyField.toggle()
                    }
                } label: {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textAccent)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Claude API-nyckel")
                                .font(.onboardingBody)
                                .foregroundStyle(Color.textPrimary)

                            Text(apiKey.isEmpty ? "Ej konfigurerad" : "Konfigurerad")
                                .font(.onboardingCaption)
                                .foregroundStyle(apiKey.isEmpty ? Color.textTertiary : Color.accentGreen)
                        }

                        Spacer()

                        Image(systemName: showAPIKeyField ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textTertiary)
                    }
                    .padding(.horizontal, Spacing.base)
                    .padding(.vertical, Spacing.md)
                }

                if showAPIKeyField {
                    VStack(spacing: Spacing.md) {
                        SecureField("sk-ant-...", text: $apiKey)
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundStyle(Color.textPrimary)
                            .padding(.horizontal, Spacing.base)
                            .padding(.vertical, Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.small)
                                    .fill(Color.bgCanvas)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CornerRadius.small)
                                            .stroke(Color.borderCard, lineWidth: 1)
                                    )
                            )

                        HStack {
                            Button {
                                AIAdvisorService.apiKey = apiKey
                                keySaved = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    keySaved = false
                                }
                            } label: {
                                Text(keySaved ? "Sparad" : "Spara")
                                    .font(.onboardingMeta)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, Spacing.lg)
                                    .padding(.vertical, Spacing.sm)
                                    .background(
                                        Capsule()
                                            .fill(keySaved ? Color.accentGreen : Color.textAccent)
                                    )
                            }
                            .sensoryFeedback(.success, trigger: keySaved)

                            if !apiKey.isEmpty {
                                Button {
                                    apiKey = ""
                                    AIAdvisorService.apiKey = ""
                                } label: {
                                    Text("Rensa")
                                        .font(.onboardingMeta)
                                        .foregroundStyle(Color.accentCoral)
                                }
                            }

                            Spacer()
                        }

                        Text("Nyckeln lagras lokalt på din enhet.")
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.textTertiary)
                    }
                    .padding(.horizontal, Spacing.base)
                    .padding(.bottom, Spacing.md)
                }

                Divider().padding(.leading, 52)

                if let family {
                    settingsRow(
                        icon: family.isPremium ? "crown.fill" : "crown",
                        iconColor: Color.textAccent,
                        title: family.isPremium ? "Premium" : "Gratisversion",
                        detail: family.isPremium ? "Obegränsade frågor" : "\(family.freeAIQuestionsRemaining) fria frågor kvar"
                    )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.bgSurface)
            )
            .cardShadow()
        }
    }

    // MARK: - App Info

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader("Om appen")

            VStack(spacing: 0) {
                settingsRow(
                    icon: "info.circle",
                    iconColor: .textTertiary,
                    title: "Version",
                    detail: "1.0.0"
                )

                Divider().padding(.leading, 52)

                settingsRow(
                    icon: "link",
                    iconColor: .textTertiary,
                    title: "Försäkringskassan",
                    detail: "forsakringskassan.se"
                )
            }
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.bgSurface)
            )
            .cardShadow()
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.onboardingCaption)
            .foregroundStyle(Color.textTertiary)
            .textCase(.uppercase)
    }

    private func settingsRow(icon: String, iconColor: Color, title: String, detail: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 32)

            Text(title)
                .font(.onboardingBody)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Text(detail)
                .font(.onboardingMeta)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.md)
    }
}

// MARK: - Edit Parent View

struct EditParentView: View {
    @Bindable var parent: Parent

    @State private var hasTopUp: Bool
    @State private var topUpPercentage: Int
    @State private var topUpMonths: Int

    init(parent: Parent) {
        self.parent = parent
        _hasTopUp = State(initialValue: parent.employerTopUpPercentage != nil)
        _topUpPercentage = State(initialValue: parent.employerTopUpPercentage ?? 90)
        _topUpMonths = State(initialValue: parent.employerTopUpMonths ?? 6)
    }

    private var incomeBinding: Binding<Double> {
        Binding(
            get: { max(15000, min(85000, NSDecimalNumber(decimal: parent.monthlyGrossIncome).doubleValue)) },
            set: { parent.monthlyGrossIncome = Decimal($0) }
        )
    }

    private var monthlyFK: Decimal {
        ParentalLeaveRules.monthlyLeaveIncome(monthlyGrossIncome: parent.monthlyGrossIncome)
    }

    private var dailyFK: Decimal {
        ParentalLeaveRules.dailySGIPayment(monthlyIncome: parent.monthlyGrossIncome)
    }

    private var percentageOfSalary: Int {
        guard parent.monthlyGrossIncome > 0 else { return 0 }
        return NSDecimalNumber(decimal: ParentalLeaveRules.leaveIncomePercentage(monthlyGrossIncome: parent.monthlyGrossIncome)).intValue
    }

    var body: some View {
        ZStack {
            Color.bgCanvas.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    nameSection
                    incomeSection
                    fkCard
                    topUpSection
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, Spacing.base)
                .padding(.bottom, Spacing.xxxxl)
            }
        }
        .navigationTitle("Redigera")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("NAMN")
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)

            TextField(parent.isParent1 ? "Förälder 1" : "Förälder 2", text: $parent.name)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .fill(Color.bgSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .stroke(Color.borderCard, lineWidth: 1)
                        )
                )
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
        }
    }

    // MARK: - Income

    private var incomeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("MÅNADSINKOMST (BRUTTO)")
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)

            // Big number display
            Text(LeaveCalculator.formatCurrency(parent.monthlyGrossIncome) + "/mån")
                .font(.onboardingSectionTitle)
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
                .contentTransition(.numericText())
                .padding(.top, Spacing.sm)

            Slider(value: incomeBinding, in: 15000...85000, step: 1000)
                .tint(Color.textAccent)

            HStack {
                Text("15 000")
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textTertiary)
                Spacer()
                Text("85 000+")
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textTertiary)
            }
        }
    }

    // MARK: - FK Card

    private var fkCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "banknote.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.accentGreen)
                Text("Föräldrapenning från Försäkringskassan")
                    .font(.onboardingMeta)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textPrimary)
            }

            // Hero monthly amount
            Text("~\(LeaveCalculator.formatCurrency(monthlyFK))")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(Color.accentGreen)
            Text("per månad (före skatt)")
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)
                .offset(y: -4)

            Divider()

            HStack(spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Per dag")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                    Text("~\(LeaveCalculator.formatCurrency(dailyFK))")
                        .font(.onboardingMeta)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Av lön")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                    Text("\(percentageOfSalary)%")
                        .font(.onboardingMeta)
                        .fontWeight(.medium)
                        .foregroundStyle(percentageOfSalary >= 70 ? Color.accentGreen : Color.accentGold)
                }

                Spacer()
            }

            if parent.monthlyGrossIncome > ParentalLeaveRules.sgiCapMonthly {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.accentGold)
                    Text("Inkomst över SGI-taket (\(LeaveCalculator.formatCurrency(ParentalLeaveRules.sgiCapMonthly))/mån). FK betalar max ~\(LeaveCalculator.formatCurrency(ParentalLeaveRules.maxDailySGI))/dag.")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(Spacing.base)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Color.accentGreen.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .stroke(Color.accentGreen.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Employer Top-Up

    private var topUpSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("ARBETSGIVARENS UTFYLLNAD")
                .font(.onboardingCaption)
                .foregroundStyle(Color.textTertiary)

            VStack(spacing: Spacing.base) {
                // Toggle
                HStack {
                    Text("Arbetsgivaren fyller ut lönen?")
                        .font(.onboardingBody)
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    Toggle("", isOn: $hasTopUp)
                        .labelsHidden()
                        .tint(Color.textAccent)
                }
                .onChange(of: hasTopUp) { _, newValue in
                    if newValue {
                        parent.employerTopUpPercentage = topUpPercentage
                        parent.employerTopUpMonths = topUpMonths
                    } else {
                        parent.employerTopUpPercentage = nil
                        parent.employerTopUpMonths = nil
                    }
                }

                if hasTopUp {
                    VStack(spacing: Spacing.md) {
                        // Percentage
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Utfyllnad till")
                                .font(.onboardingCaption)
                                .foregroundStyle(Color.textTertiary)
                            HStack(spacing: Spacing.sm) {
                                ForEach([80, 85, 90, 100], id: \.self) { pct in
                                    Button {
                                        topUpPercentage = pct
                                        parent.employerTopUpPercentage = pct
                                    } label: {
                                        Text("\(pct)%")
                                            .font(.system(size: 13, weight: topUpPercentage == pct ? .semibold : .regular))
                                            .foregroundStyle(topUpPercentage == pct ? .white : Color.textSecondary)
                                            .padding(.horizontal, Spacing.md)
                                            .padding(.vertical, Spacing.sm)
                                            .background(
                                                RoundedRectangle(cornerRadius: CornerRadius.small)
                                                    .fill(topUpPercentage == pct ? Color.accentBlue : Color.bgCanvas)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: CornerRadius.small)
                                                            .stroke(topUpPercentage == pct ? Color.clear : Color.borderCard, lineWidth: 1)
                                                    )
                                            )
                                    }
                                    .sensoryFeedback(.selection, trigger: topUpPercentage)
                                }
                            }
                        }

                        // Duration
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Antal månader")
                                .font(.onboardingCaption)
                                .foregroundStyle(Color.textTertiary)
                            HStack(spacing: Spacing.sm) {
                                ForEach([3, 6, 9, 12], id: \.self) { months in
                                    Button {
                                        topUpMonths = months
                                        parent.employerTopUpMonths = months
                                    } label: {
                                        Text("\(months) mån")
                                            .font(.system(size: 13, weight: topUpMonths == months ? .semibold : .regular))
                                            .foregroundStyle(topUpMonths == months ? .white : Color.textSecondary)
                                            .padding(.horizontal, Spacing.md)
                                            .padding(.vertical, Spacing.sm)
                                            .background(
                                                RoundedRectangle(cornerRadius: CornerRadius.small)
                                                    .fill(topUpMonths == months ? Color.accentBlue : Color.bgCanvas)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: CornerRadius.small)
                                                            .stroke(topUpMonths == months ? Color.clear : Color.borderCard, lineWidth: 1)
                                                    )
                                            )
                                    }
                                    .sensoryFeedback(.selection, trigger: topUpMonths)
                                }
                            }
                        }

                        // Result
                        let topUpMonthly = ParentalLeaveRules.monthlyWithTopUp(
                            monthlyGrossIncome: parent.monthlyGrossIncome,
                            topUpPercentage: topUpPercentage
                        )
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textAccent)
                            Text("Med utfyllnad: ~\(LeaveCalculator.formatCurrency(topUpMonthly))/mån i \(topUpMonths) mån")
                                .font(.onboardingMeta)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.small)
                                .fill(Color.textAccent.opacity(0.04))
                        )
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
}

// MARK: - Edit Child View

struct EditChildView: View {
    @Bindable var child: Child

    var body: some View {
        ZStack {
            Color.bgCanvas.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Birth date
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text(child.isBorn ? "FÖDELSEDATUM" : "BERÄKNAT DATUM")
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.textTertiary)

                        DatePicker(
                            "",
                            selection: $child.birthDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(Color.textAccent)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "sv_SE"))
                        .padding(Spacing.base)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(Color.bgSurface)
                        )
                        .cardShadow()
                    }

                    // isBorn toggle
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("STATUS")
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.textTertiary)

                        HStack {
                            Text("Barnet är fött")
                                .font(.onboardingBody)
                                .foregroundStyle(Color.textPrimary)
                            Spacer()
                            Toggle("", isOn: $child.isBorn)
                                .labelsHidden()
                                .tint(Color.textAccent)
                        }
                        .padding(Spacing.base)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(Color.bgSurface)
                        )
                        .cardShadow()
                    }

                    // Multiple type
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("FLERLING")
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.textTertiary)

                        HStack(spacing: Spacing.sm) {
                            multipleTypeButton("Ensam", type: .single)
                            multipleTypeButton("Tvilling", type: .twins)
                            multipleTypeButton("Trilling+", type: .triplets)
                        }
                    }

                    // Info card
                    let totalDays = ParentalLeaveRules.totalDays(multipleType: child.multipleType)
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textAccent)
                        Text("Totalt \(totalDays) föräldrapenningdagar för \(child.multipleType == .single ? "ett barn" : child.multipleType == .twins ? "tvillingar" : "trillingar").")
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.small)
                            .fill(Color.textAccent.opacity(0.04))
                    )
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, Spacing.base)
                .padding(.bottom, Spacing.xxxxl)
            }
        }
        .navigationTitle("Redigera barn")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func multipleTypeButton(_ label: String, type: MultipleType) -> some View {
        let isSelected = child.multipleType == type
        return Button {
            child.multipleType = type
        } label: {
            Text(label)
                .font(.onboardingMeta)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : Color.textSecondary)
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.md)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .fill(isSelected ? Color.accentBlue : Color.bgSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .stroke(isSelected ? Color.clear : Color.borderCard, lineWidth: 1)
                        )
                )
        }
        .sensoryFeedback(.selection, trigger: child.multipleTypeRaw)
    }
}
