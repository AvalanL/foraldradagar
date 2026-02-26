import SwiftUI

// MARK: - BLOCK 1: VÄLKOMMEN (Steps 1-3) — Emotional Hook

// ──────────────────────────────────────────────
// Step 1: Welcome / Emotional Hook
// ──────────────────────────────────────────────

struct WelcomeStepView: View {
    let onContinue: () -> Void

    @State private var showContent = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.xxl) {
                // Illustration placeholder
                Image(systemName: "figure.and.child.holdinghands")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.textAccent)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)

                VStack(spacing: Spacing.base) {
                    Text("Grattis! 🎉")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.textPrimary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Text("Att bli förälder är livets\nstörsta äventyr.")
                        .font(.onboardingSubtitle)
                        .foregroundStyle(Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Text("Vi hjälper dig att planera ledigheten\nså du kan fokusera på det som\nverkligen räknas.")
                        .font(.onboardingBody)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
            }
            .padding(.horizontal, Spacing.screenH)

            Spacer()
            Spacer()

            // CTA
            OnboardingCTAButton(title: "Kom igång →", action: onContinue)
                .padding(.horizontal, Spacing.screenH)
                .padding(.bottom, Spacing.lg)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// ──────────────────────────────────────────────
// Step 2: Who Are You? (Family Type)
// ──────────────────────────────────────────────

struct FamilyTypeStepView: View {
    @Binding var familyType: FamilyType?
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepLayout(
            title: "Vem planerar?",
            ctaTitle: "Nästa →",
            ctaEnabled: familyType != nil,
            onCTA: onContinue
        ) {
            VStack(spacing: Spacing.md) {
                SelectionCard(
                    emoji: "👫",
                    title: "Vi är två föräldrar",
                    isSelected: familyType == .twoParents,
                    action: { familyType = .twoParents }
                )

                SelectionCard(
                    emoji: "👤",
                    title: "Jag är ensamstående",
                    isSelected: familyType == .singleParent,
                    action: { familyType = .singleParent }
                )
            }
        }
    }
}

// ──────────────────────────────────────────────
// Step 3: What Stage Are You At?
// ──────────────────────────────────────────────

struct FamilyStageStepView: View {
    @Binding var stage: FamilyStage?
    let isSingleParent: Bool
    let onContinue: () -> Void

    private var questionText: String {
        isSingleParent ? "Var är du i resan?" : "Var är ni i resan?"
    }

    var body: some View {
        OnboardingStepLayout(
            title: questionText,
            ctaTitle: "Nästa →",
            ctaEnabled: stage != nil,
            onCTA: onContinue
        ) {
            VStack(spacing: Spacing.md) {
                SelectionCard(
                    emoji: "🤰",
                    title: isSingleParent ? "Jag väntar barn" : "Vi väntar barn",
                    subtitle: "Beräknad födsel snart",
                    isSelected: stage == .expecting,
                    action: { stage = .expecting }
                )

                SelectionCard(
                    emoji: "👶",
                    title: "Barnet är fött",
                    subtitle: "Redan igång med ledighet",
                    isSelected: stage == .born,
                    action: { stage = .born }
                )

                SelectionCard(
                    emoji: "📋",
                    title: isSingleParent ? "Jag planerar i förväg" : "Vi planerar i förväg",
                    subtitle: isSingleParent ? "Inte gravid än" : "Inte gravida än",
                    isSelected: stage == .planning,
                    action: { stage = .planning }
                )
            }
        }
    }
}
