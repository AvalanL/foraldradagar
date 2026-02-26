import SwiftUI

// MARK: - Paywall View (After Step 20)

struct PaywallView: View {
    let data: OnboardingData
    let parent1DailyRate: Decimal
    let optimizationCount: Int
    let expiryDateFormatted: String
    let onSubscribe: (PaywallPlan) -> Void
    let onSkip: () -> Void

    @State private var selectedPlan: PaywallPlan = .annual
    @State private var showContent = false
    @State private var showConfetti = false

    private var parent1Name: String {
        data.parent1.name.isEmpty ? "du" : data.parent1.name
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: OnboardingGradient.paywall,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Confetti
            if showConfetti {
                ConfettiView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.md) {
                        Text("Er plan är redo, \(parent1Name)! 🎉")
                            .font(.onboardingTitle)
                            .foregroundStyle(Color.textPrimary)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)

                        Text("Baserat på era svar:")
                            .font(.onboardingBody)
                            .foregroundStyle(Color.textSecondary)
                            .opacity(showContent ? 1 : 0)
                    }

                    // Stats card
                    statsCard
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)

                    // Premium features
                    premiumFeaturesList
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)

                    // Price cards
                    priceCardsSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)

                    // CTA
                    OnboardingCTAButton(
                        title: "Fortsätt med Pro →",
                        action: { onSubscribe(selectedPlan) }
                    )

                    // Skip — small, discreet, but always visible
                    OnboardingTextButton(
                        title: "Fortsätt med gratisversionen",
                        action: onSkip
                    )
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, Spacing.xxl)
                .padding(.bottom, Spacing.xxxxl)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showConfetti = true
            }
        }
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SummaryStatRow(
                icon: "📊",
                label: "dagar att planera",
                value: "\(data.totalDays)"
            )

            Divider()

            SummaryStatRow(
                icon: "💰",
                label: "i föräldrapenning",
                value: "~\(ForaldrapenningCalculator.formatted(dailyRate: parent1DailyRate))"
            )

            Divider()

            SummaryStatRow(
                icon: "⏰",
                label: "Reserverade dagar löper ut",
                value: expiryDateFormatted
            )

            Divider()

            HStack(spacing: Spacing.md) {
                Text("💡")
                    .font(.system(size: 20))
                    .frame(width: 32)

                Text("Vi hittade **\(optimizationCount) sätt** att optimera er plan")
                    .font(.onboardingBody)
                    .foregroundStyle(Color.textAccent)
            }
            .padding(.vertical, Spacing.sm)
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Color.bgSurface)
        )
        .cardShadow()
    }

    // MARK: - Premium Features List

    private var premiumFeaturesList: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            Text("Med Föräldradagar Pro får du:")
                .font(.onboardingBodyBold)
                .foregroundStyle(Color.textPrimary)

            premiumFeatureRow(
                icon: "sparkles",
                title: "AI-rådgivare",
                description: "Fråga vad som helst om föräldraledighet, dygnet runt"
            )

            premiumFeatureRow(
                icon: "slider.horizontal.3",
                title: "Scenarioplanerare",
                description: "Jämför olika upplägg visuellt"
            )

            premiumFeatureRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Inkomstoptimerare",
                description: "Maximera er hushållsinkomst under ledigheten"
            )

            premiumFeatureRow(
                icon: "doc.richtext",
                title: "Exportera plan som PDF",
                description: "Skicka till arbetsgivaren"
            )

            premiumFeatureRow(
                icon: "gift.fill",
                title: "Alla framtida funktioner",
                description: "Inkluderade utan extra kostnad"
            )
        }
    }

    private func premiumFeatureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.textAccent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.onboardingBodyBold)
                    .foregroundStyle(Color.textPrimary)

                Text(description)
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    // MARK: - Price Cards

    private var priceCardsSection: some View {
        VStack(spacing: Spacing.md) {
            // Top row: Annual + Weekly
            HStack(spacing: Spacing.md) {
                priceCard(
                    plan: .annual,
                    title: "ÅRSPLAN",
                    price: "249 kr/år",
                    subtitle: "Bara 21 kr/mån",
                    badge: "BÄST VÄRDE"
                )

                priceCard(
                    plan: .weekly,
                    title: "VECKOPLAN",
                    price: "29 kr/vecka",
                    subtitle: "Med 3 dagars\ngratis provperiod",
                    badge: nil
                )
            }

            // Lifetime
            priceCard(
                plan: .lifetime,
                title: "KÖP EN GÅNG",
                price: "499 kr",
                subtitle: "Betala en gång — för alltid",
                badge: nil
            )
        }
    }

    private func priceCard(plan: PaywallPlan, title: String, price: String, subtitle: String, badge: String?) -> some View {
        Button {
            withAnimation(OnboardingAnimation.cardSelect) {
                selectedPlan = plan
            }
        } label: {
            VStack(spacing: Spacing.sm) {
                // Title
                Text(title)
                    .font(.priceLabel)
                    .foregroundStyle(Color.textSecondary)
                    .tracking(1.5)

                // Price
                Text(price)
                    .font(.priceAmount)
                    .foregroundStyle(Color.textPrimary)

                // Subtitle
                Text(subtitle)
                    .font(.priceSubtitle)
                    .foregroundStyle(Color.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // Badge
                if let badge {
                    Text("⭐ \(badge)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.textAccent)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(
                            Capsule()
                                .fill(Color.textAccent.opacity(0.12))
                        )
                }
            }
            .padding(.vertical, Spacing.lg)
            .padding(.horizontal, Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.bgSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .stroke(
                                selectedPlan == plan ? Color.textAccent : Color.borderCard,
                                lineWidth: selectedPlan == plan ? 2.5 : 1
                            )
                    )
            )
            .cardShadow()
            .scaleEffect(selectedPlan == plan ? 1.02 : 1.0)
        }
        .buttonStyle(ScaleButtonStyle())
        .sensoryFeedback(.selection, trigger: selectedPlan)
    }
}

// MARK: - Paywall Plan

enum PaywallPlan: String, CaseIterable {
    case annual   = "annual"
    case weekly   = "weekly"
    case lifetime = "lifetime"
}
