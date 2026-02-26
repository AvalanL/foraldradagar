import SwiftUI

// MARK: - BLOCK 3: FÖRÄLDRARNA (Steps 7-12) — The Parents

// ──────────────────────────────────────────────
// Step 7: Parent 1 — Name
// ──────────────────────────────────────────────

struct Parent1NameStepView: View {
    @Binding var name: String
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepLayout(
            title: "Vad heter du?",
            ctaTitle: "Nästa →",
            ctaEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty,
            onCTA: onContinue
        ) {
            OnboardingTextField(
                placeholder: "Förnamn",
                text: $name,
                caption: "Vi använder namn för att göra planen personlig — inte för att skapa konto."
            )
        }
    }
}

// ──────────────────────────────────────────────
// Step 8: Parent 1 — Income
// ──────────────────────────────────────────────

struct Parent1IncomeStepView: View {
    @Binding var income: Decimal
    let name: String
    let onContinue: () -> Void

    private var displayName: String {
        name.isEmpty ? "du" : name
    }

    var body: some View {
        OnboardingStepLayout(
            title: "Vad är din ungefärliga månadslön före skatt, \(displayName)?",
            ctaTitle: "Nästa →",
            onCTA: onContinue
        ) {
            IncomeSlider(income: $income, name: name)
        }
    }
}

// ──────────────────────────────────────────────
// Step 9: Parent 1 — Employer Top-Up
// ──────────────────────────────────────────────

struct Parent1TopUpStepView: View {
    @Binding var hasTopUp: Bool?
    @Binding var topUpPercentage: TopUpPercentage?
    @Binding var topUpMonths: TopUpMonths?
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepLayout(
            title: "Fyller din arbetsgivare ut lönen under föräldraledigheten?",
            subtitle: "Många arbetsgivare betalar upp till 90% av lönen de första månaderna.",
            ctaTitle: "Nästa →",
            ctaEnabled: hasTopUp != nil,
            onCTA: onContinue
        ) {
            VStack(spacing: Spacing.md) {
                SelectionCard(
                    emoji: "✅",
                    title: "Ja",
                    isSelected: hasTopUp == true,
                    action: { hasTopUp = true }
                )

                SelectionCard(
                    emoji: "❌",
                    title: "Nej",
                    isSelected: hasTopUp == false,
                    action: {
                        hasTopUp = false
                        topUpPercentage = nil
                        topUpMonths = nil
                    }
                )

                // "Vet inte" — sets hasTopUp to nil but marks step as answered
                // We use a special sentinel: we track it differently
                SelectionCard(
                    emoji: "🤷",
                    title: "Vet inte",
                    isSelected: hasTopUp == nil && topUpPercentage == nil && topUpMonths == nil,
                    action: {
                        // We need a way to mark "answered but unknown"
                        // We'll use hasTopUp = nil with a flag
                        hasTopUp = nil
                    }
                )

                // Follow-up: If "Ja" is selected
                if hasTopUp == true {
                    VStack(alignment: .leading, spacing: Spacing.base) {
                        Text("Hur mycket och hur länge?")
                            .font(.onboardingBodyBold)
                            .foregroundStyle(Color.textPrimary)

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Utfyllnad:")
                                .font(.onboardingMeta)
                                .foregroundStyle(Color.textSecondary)

                            PillSelector(
                                options: TopUpPercentage.allCases.map { (value: $0, label: "\($0.rawValue)%") },
                                selected: $topUpPercentage
                            )
                        }

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Antal månader:")
                                .font(.onboardingMeta)
                                .foregroundStyle(Color.textSecondary)

                            PillSelector(
                                options: TopUpMonths.allCases.map { (value: $0, label: "\($0.rawValue) mån") },
                                selected: $topUpMonths
                            )
                        }
                    }
                    .padding(.top, Spacing.md)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

// ──────────────────────────────────────────────
// Step 10: Parent 2 — Name
// ──────────────────────────────────────────────

struct Parent2NameStepView: View {
    @Binding var name: String
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepLayout(
            title: "Vad heter din partner?",
            ctaTitle: "Nästa →",
            ctaEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty,
            onCTA: onContinue
        ) {
            OnboardingTextField(
                placeholder: "Förnamn",
                text: $name
            )
        }
    }
}

// ──────────────────────────────────────────────
// Step 11: Parent 2 — Income
// ──────────────────────────────────────────────

struct Parent2IncomeStepView: View {
    @Binding var income: Decimal
    let partnerName: String
    let parent1Income: Decimal
    let onContinue: () -> Void

    private var displayName: String {
        partnerName.isEmpty ? "din partner" : partnerName
    }

    var body: some View {
        OnboardingStepLayout(
            title: "Vad är \(displayName)s ungefärliga månadslön före skatt?",
            ctaTitle: "Nästa →",
            onCTA: onContinue
        ) {
            VStack(spacing: Spacing.xl) {
                IncomeSlider(income: $income, name: partnerName)

                // Household income display
                let household = parent1Income + income
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Color.textAccent)
                        .font(.system(size: 14))
                    Text("Er samlade hushållsinkomst: \(ForaldrapenningCalculator.formattedKr(household))/mån")
                        .font(.onboardingMeta)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.small)
                        .fill(Color.textAccent.opacity(0.08))
                )

                Text("Under ledighet beror inkomsten på vem som är hemma och när.")
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textTertiary)
            }
        }
    }
}

// ──────────────────────────────────────────────
// Step 12: Parent 2 — Employer Top-Up
// ──────────────────────────────────────────────

struct Parent2TopUpStepView: View {
    @Binding var hasTopUp: Bool?
    @Binding var topUpPercentage: TopUpPercentage?
    @Binding var topUpMonths: TopUpMonths?
    let partnerName: String
    let onContinue: () -> Void

    private var displayName: String {
        partnerName.isEmpty ? "din partners" : "\(partnerName)s"
    }

    var body: some View {
        OnboardingStepLayout(
            title: "Fyller \(displayName) arbetsgivare ut lönen?",
            ctaTitle: "Nästa →",
            ctaEnabled: hasTopUp != nil,
            onCTA: onContinue
        ) {
            VStack(spacing: Spacing.md) {
                SelectionCard(
                    emoji: "✅",
                    title: "Ja",
                    isSelected: hasTopUp == true,
                    action: { hasTopUp = true }
                )

                SelectionCard(
                    emoji: "❌",
                    title: "Nej",
                    isSelected: hasTopUp == false,
                    action: {
                        hasTopUp = false
                        topUpPercentage = nil
                        topUpMonths = nil
                    }
                )

                SelectionCard(
                    emoji: "🤷",
                    title: "Vet inte",
                    isSelected: hasTopUp == nil && topUpPercentage == nil && topUpMonths == nil,
                    action: { hasTopUp = nil }
                )

                if hasTopUp == true {
                    VStack(alignment: .leading, spacing: Spacing.base) {
                        Text("Hur mycket och hur länge?")
                            .font(.onboardingBodyBold)
                            .foregroundStyle(Color.textPrimary)

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Utfyllnad:")
                                .font(.onboardingMeta)
                                .foregroundStyle(Color.textSecondary)

                            PillSelector(
                                options: TopUpPercentage.allCases.map { (value: $0, label: "\($0.rawValue)%") },
                                selected: $topUpPercentage
                            )
                        }

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Antal månader:")
                                .font(.onboardingMeta)
                                .foregroundStyle(Color.textSecondary)

                            PillSelector(
                                options: TopUpMonths.allCases.map { (value: $0, label: "\($0.rawValue) mån") },
                                selected: $topUpMonths
                            )
                        }
                    }
                    .padding(.top, Spacing.md)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}
