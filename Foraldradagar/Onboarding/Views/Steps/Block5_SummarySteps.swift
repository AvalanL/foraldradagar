import SwiftUI

// MARK: - BLOCK 5: DIN PERSONLIGA SAMMANFATTNING (Steps 17-20) — The Payoff

// ──────────────────────────────────────────────
// Step 17: Your Personalized Summary (The Magic Moment)
// ──────────────────────────────────────────────

struct SummaryStepView: View {
    let data: OnboardingData
    let parent1DailyRate: Decimal
    let parent2DailyRate: Decimal
    let expiryDateFormatted: String
    let onContinue: () -> Void

    @State private var showStats = false
    @State private var animatedDays: Int = 0

    private var parent1Name: String {
        data.parent1.name.isEmpty ? "Förälder 1" : data.parent1.name
    }

    private var parent2Name: String {
        data.parent2?.name.isEmpty == false ? data.parent2!.name : "Förälder 2"
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xl) {
                    // Title with sparkle
                    Text("✨ \(data.familyType == .singleParent ? "Din" : "Er") föräldraledighet i siffror:")
                        .font(.onboardingTitle)
                        .foregroundStyle(Color.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(showStats ? 1 : 0)
                        .offset(y: showStats ? 0 : 20)

                    // Animated day counter
                    VStack(spacing: Spacing.sm) {
                        Text("\(animatedDays)")
                            .font(.system(size: 64, weight: .bold, design: .serif))
                            .foregroundStyle(Color.textPrimary)
                            .contentTransition(.numericText())

                        Text("dagar totalt")
                            .font(.onboardingBody)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.xl)
                    .opacity(showStats ? 1 : 0)
                    .scaleEffect(showStats ? 1 : 0.8)

                    // Day split card
                    if data.familyType == .twoParents {
                        daysSplitCard
                            .opacity(showStats ? 1 : 0)
                            .offset(y: showStats ? 0 : 30)
                    }

                    // Daily rate card
                    dailyRateCard
                        .opacity(showStats ? 1 : 0)
                        .offset(y: showStats ? 0 : 30)

                    // Expiry date
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(Color.textAccent)
                        Text("Dagarna gäller till: \(expiryDateFormatted)")
                            .font(.onboardingMeta)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(showStats ? 1 : 0)

                    // Teaser for next screen
                    HStack(spacing: Spacing.sm) {
                        Text("🎯")
                        Text("Baserat på \(data.familyType == .singleParent ? "din inkomst" : "era inkomster") kan vi optimera \(data.familyType == .singleParent ? "din" : "er") plan. Mer om det strax!")
                            .font(.onboardingMeta)
                            .foregroundStyle(Color.textAccent)
                    }
                    .padding(Spacing.base)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(Color.textAccent.opacity(0.08))
                    )
                    .opacity(showStats ? 1 : 0)
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, Spacing.xl)
                .padding(.bottom, 120)
            }

            Spacer(minLength: 0)

            OnboardingCTAButton(title: "Nästa →", action: onContinue)
                .padding(.horizontal, Spacing.screenH)
                .padding(.bottom, Spacing.lg)
        }
        .onAppear {
            // Staggered animation
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showStats = true
            }
            // Count-up animation for total days
            animateDayCounter()
        }
    }

    // MARK: - Subviews

    private var daysSplitCard: some View {
        VStack(spacing: Spacing.base) {
            HStack(alignment: .top) {
                // Parent 1
                VStack(spacing: Spacing.sm) {
                    Text(parent1Name)
                        .font(.onboardingBodyBold)
                        .foregroundStyle(Color.textPrimary)

                    Rectangle()
                        .fill(Color.textAccent)
                        .frame(height: 3)
                        .cornerRadius(1.5)

                    Text("\(data.reservedPerParent) reserverade")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)

                    Text("+\(data.sharedDays / 2) delade")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)

                    Divider()

                    Text("\(data.reservedPerParent + data.sharedDays / 2) dagar")
                        .font(.onboardingBodyBold)
                        .foregroundStyle(Color.textPrimary)
                }
                .frame(maxWidth: .infinity)

                // Parent 2
                VStack(spacing: Spacing.sm) {
                    Text(parent2Name)
                        .font(.onboardingBodyBold)
                        .foregroundStyle(Color.textPrimary)

                    Rectangle()
                        .fill(Color.accentCoral)
                        .frame(height: 3)
                        .cornerRadius(1.5)

                    Text("\(data.reservedPerParent) reserverade")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)

                    Text("+\(data.sharedDays / 2) delade")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)

                    Divider()

                    Text("\(data.reservedPerParent + data.sharedDays / 2) dagar")
                        .font(.onboardingBodyBold)
                        .foregroundStyle(Color.textPrimary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Color.bgSurface)
        )
        .cardShadow()
    }

    private var dailyRateCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Föräldrapenning per dag:")
                .font(.onboardingBodyBold)
                .foregroundStyle(Color.textPrimary)

            HStack {
                Text(parent1Name)
                    .font(.onboardingBody)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text("~\(ForaldrapenningCalculator.formatted(dailyRate: parent1DailyRate))")
                    .font(.onboardingBodyBold)
                    .foregroundStyle(Color.textPrimary)
            }

            if data.familyType == .twoParents {
                HStack {
                    Text(parent2Name)
                        .font(.onboardingBody)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text("~\(ForaldrapenningCalculator.formatted(dailyRate: parent2DailyRate))")
                        .font(.onboardingBodyBold)
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Color.bgSurface)
        )
        .cardShadow()
    }

    // MARK: - Animation

    private func animateDayCounter() {
        let target = data.totalDays
        let duration: Double = 2.0
        let steps = 60
        let interval = duration / Double(steps)

        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i) + 0.5) {
                let progress = Double(i) / Double(steps)
                let eased = 1 - pow(1 - progress, 3) // ease-out cubic
                withAnimation(.none) {
                    animatedDays = Int(Double(target) * eased)
                }
            }
        }
    }
}

// ──────────────────────────────────────────────
// Step 18: Your First Insight (AI-Powered Teaser)
// ──────────────────────────────────────────────

struct AIInsightStepView: View {
    let insightText: String
    let onContinue: () -> Void

    @State private var showInsight = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Title
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.textAccent)

                        Text("Visste du?")
                            .font(.onboardingTitle)
                            .foregroundStyle(Color.textPrimary)
                    }

                    // Insight card
                    Text(insightText)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundStyle(Color.textPrimary)
                        .lineSpacing(6)
                        .padding(Spacing.xl)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.large)
                                .fill(Color.bgSurface)
                        )
                        .cardShadow()
                        .opacity(showInsight ? 1 : 0)
                        .offset(y: showInsight ? 0 : 20)
                        .scaleEffect(showInsight ? 1 : 0.97)

                    // Small note
                    Text("Detta är bara en av många insikter. Din AI-rådgivare kan hjälpa dig med alla frågor om föräldraledighet.")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                        .opacity(showInsight ? 1 : 0)
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, Spacing.xl)
                .padding(.bottom, 120)
            }

            Spacer(minLength: 0)

            OnboardingCTAButton(title: "Nästa →", action: onContinue)
                .padding(.horizontal, Spacing.screenH)
                .padding(.bottom, Spacing.lg)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                showInsight = true
            }
        }
    }
}

// ──────────────────────────────────────────────
// Step 19: Feature Showcase (AI Chat Mockup)
// ──────────────────────────────────────────────

struct FeatureShowcaseStepView: View {
    let data: OnboardingData
    let onContinue: () -> Void

    @State private var visibleBubbles: Int = 0

    private var parent1Name: String {
        data.parent1.name.isEmpty ? "du" : data.parent1.name
    }

    private var parent2Name: String {
        data.parent2?.name.isEmpty == false ? data.parent2!.name : "din partner"
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Title
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Din personliga rådgivare")
                            .font(.onboardingTitle)
                            .foregroundStyle(Color.textPrimary)

                        Text("Ställ vilken fråga som helst om föräldraledighet — och få svar direkt.")
                            .font(.onboardingBody)
                            .foregroundStyle(Color.textSecondary)
                    }

                    // Chat mockup
                    VStack(spacing: Spacing.base) {
                        if visibleBubbles >= 1 {
                            ChatBubble(
                                isUser: true,
                                text: "Hur borde vi dela dagarna för att tjäna mest?"
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        if visibleBubbles >= 2 {
                            ChatBubble(
                                isUser: false,
                                text: "Baserat på era inkomster rekommenderar jag att \(parent1Name) tar ledigt de första 8 månaderna (arbetsgivarutfyllnad), sedan tar \(parent2Name) över i 6 månader. Det ger er mer totalt jämfört med att dela 50/50."
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        if visibleBubbles >= 3 {
                            ChatBubble(
                                isUser: true,
                                text: "Kan vi ta föräldraledigt samtidigt?"
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        if visibleBubbles >= 4 {
                            ChatBubble(
                                isUser: false,
                                text: "Ja! Under de första 30 dagarna efter födseln kan ni ta dubbeldagar. Sedan kan ni ta ut dagar parallellt, men det går snabbare åt av de \(data.totalDays) dagarna."
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, Spacing.xl)
                .padding(.bottom, 120)
            }

            Spacer(minLength: 0)

            OnboardingCTAButton(title: "Nästa →", action: onContinue)
                .padding(.horizontal, Spacing.screenH)
                .padding(.bottom, Spacing.lg)
        }
        .onAppear {
            animateBubbles()
        }
    }

    private func animateBubbles() {
        let delays: [Double] = [0.3, 1.0, 2.0, 2.8]
        for (index, delay) in delays.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 0.4)) {
                    visibleBubbles = index + 1
                }
            }
        }
    }
}

// ──────────────────────────────────────────────
// Step 20: Notifications
// ──────────────────────────────────────────────

struct NotificationsStepView: View {
    @Binding var notificationsEnabled: Bool
    let onContinue: () -> Void

    @State private var hasChosen = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    Text("Vill du få en påminnelse innan viktiga datum?")
                        .font(.onboardingTitle)
                        .foregroundStyle(Color.textPrimary)

                    Text("Vi kan meddela dig om:")
                        .font(.onboardingBody)
                        .foregroundStyle(Color.textSecondary)

                    // Notification types
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        notificationRow(icon: "calendar.badge.exclamationmark", text: "Dagar som snart går ut")
                        notificationRow(icon: "doc.text.fill", text: "Tid att ansöka hos Försäkringskassan")
                        notificationRow(icon: "bell.badge.fill", text: "Viktiga milstolpar i er plan")
                    }

                    // Selection
                    VStack(spacing: Spacing.md) {
                        SelectionCard(
                            emoji: "🔔",
                            title: "Ja, påminn mig",
                            isSelected: hasChosen && notificationsEnabled,
                            action: {
                                notificationsEnabled = true
                                hasChosen = true
                            }
                        )

                        SelectionCard(
                            emoji: "🔕",
                            title: "Inte nu, kanske senare",
                            isSelected: hasChosen && !notificationsEnabled,
                            action: {
                                notificationsEnabled = false
                                hasChosen = true
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, Spacing.xl)
                .padding(.bottom, 120)
            }

            Spacer(minLength: 0)

            OnboardingCTAButton(
                title: "Visa min plan →",
                isEnabled: hasChosen,
                action: onContinue
            )
            .padding(.horizontal, Spacing.screenH)
            .padding(.bottom, Spacing.lg)
        }
    }

    private func notificationRow(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.textAccent)
                .frame(width: 28)

            Text(text)
                .font(.onboardingBody)
                .foregroundStyle(Color.textPrimary)
        }
    }
}
