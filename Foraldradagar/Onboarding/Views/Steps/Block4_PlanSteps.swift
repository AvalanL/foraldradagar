import SwiftUI

// MARK: - BLOCK 4: ER PLAN (Steps 13-16) — Current Situation & Preferences

// ──────────────────────────────────────────────
// Step 13: Have You Already Taken Any Days?
// (only shown if stage == .born)
// ──────────────────────────────────────────────

struct DaysTakenStepView: View {
    @Binding var hasStarted: Bool?
    @Binding var daysTakenParent1: Int?
    @Binding var daysTakenParent2: Int?
    let parent1Name: String
    let parent2Name: String?
    let onContinue: () -> Void

    private var title: String {
        parent2Name != nil ? "Har ni redan tagit ut föräldradagar?" : "Har du redan tagit ut föräldradagar?"
    }

    var body: some View {
        OnboardingStepLayout(
            title: title,
            ctaTitle: "Nästa →",
            ctaEnabled: hasStarted != nil,
            onCTA: onContinue
        ) {
            VStack(spacing: Spacing.md) {
                SelectionCard(
                    emoji: "📅",
                    title: "Ja, \(parent2Name != nil ? "vi har" : "jag har") börjat",
                    isSelected: hasStarted == true,
                    action: { hasStarted = true }
                )

                SelectionCard(
                    emoji: "🔜",
                    title: "Nej, inte än",
                    isSelected: hasStarted == false,
                    action: {
                        hasStarted = false
                        daysTakenParent1 = nil
                        daysTakenParent2 = nil
                    }
                )

                // Follow-up: day counts
                if hasStarted == true {
                    VStack(alignment: .leading, spacing: Spacing.base) {
                        Text("Ungefär hur många dagar har \(parent2Name != nil ? "ni" : "du") tagit?")
                            .font(.onboardingBodyBold)
                            .foregroundStyle(Color.textPrimary)

                        DayCounterInput(
                            label: parent1Name.isEmpty ? "Förälder 1" : parent1Name,
                            days: $daysTakenParent1
                        )

                        if let p2Name = parent2Name {
                            DayCounterInput(
                                label: p2Name.isEmpty ? "Förälder 2" : p2Name,
                                days: $daysTakenParent2
                            )
                        }

                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(Color.textAccent)
                                .font(.system(size: 14))
                            Text("Du kan justera detta senare. Vi hjälper dig räkna ut exakt antal.")
                                .font(.onboardingCaption)
                                .foregroundStyle(Color.textTertiary)
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
// Step 14: What's Your Priority?
// ──────────────────────────────────────────────

struct PriorityStepView: View {
    @Binding var priority: PlanningPriority?
    let isSingleParent: Bool
    let onContinue: () -> Void

    private var title: String {
        isSingleParent ? "Vad är viktigast för dig?" : "Vad är viktigast för er?"
    }

    var body: some View {
        OnboardingStepLayout(
            title: title,
            subtitle: "Välj det som stämmer bäst:",
            ctaTitle: "Nästa →",
            ctaEnabled: priority != nil,
            onCTA: onContinue
        ) {
            VStack(spacing: Spacing.md) {
                SelectionCard(
                    emoji: "💰",
                    title: "Maximera inkomsten",
                    subtitle: "Tappa så lite pengar som möjligt",
                    isSelected: priority == .maximizeIncome,
                    action: { priority = .maximizeIncome }
                )

                if !isSingleParent {
                    SelectionCard(
                        emoji: "⚖️",
                        title: "Dela lika",
                        subtitle: "Båda ska vara hemma ungefär lika länge",
                        isSelected: priority == .equalSplit,
                        action: { priority = .equalSplit }
                    )
                }

                SelectionCard(
                    emoji: "🏠",
                    title: "Längsta möjliga ledighet",
                    subtitle: "Maximera tiden hemma oavsett pengar",
                    isSelected: priority == .maxTime,
                    action: { priority = .maxTime }
                )

                SelectionCard(
                    emoji: "🤔",
                    title: "Vet inte — hjälp mig!",
                    subtitle: "Jag vill se alla alternativ",
                    isSelected: priority == .unsure,
                    action: { priority = .unsure }
                )
            }
        }
    }
}

// ──────────────────────────────────────────────
// Step 15: Childcare Plans?
// ──────────────────────────────────────────────

struct ChildcareStepView: View {
    @Binding var childcarePlan: ChildcarePlan?
    let isSingleParent: Bool
    let onContinue: () -> Void

    private var title: String {
        isSingleParent ? "Planerar du förskola?" : "Planerar ni förskola?"
    }

    var body: some View {
        OnboardingStepLayout(
            title: title,
            ctaTitle: "Nästa →",
            ctaEnabled: childcarePlan != nil,
            onCTA: onContinue
        ) {
            VStack(spacing: Spacing.md) {
                SelectionCard(
                    emoji: "🏫",
                    title: "Ja, så tidigt som möjligt",
                    subtitle: "Från ~1 år",
                    isSelected: childcarePlan == .early,
                    action: { childcarePlan = .early }
                )

                SelectionCard(
                    emoji: "🏡",
                    title: isSingleParent ? "Jag vill vara hemma längre" : "Vi vill vara hemma längre",
                    subtitle: "2-3 år",
                    isSelected: childcarePlan == .extended,
                    action: { childcarePlan = .extended }
                )

                SelectionCard(
                    emoji: "🤷",
                    title: "Har inte bestämt",
                    isSelected: childcarePlan == .undecided,
                    action: { childcarePlan = .undecided }
                )
            }
        }
    }
}

// ──────────────────────────────────────────────
// Step 16: What Do You Know About Föräldrapenning?
// ──────────────────────────────────────────────

struct KnowledgeLevelStepView: View {
    @Binding var knowledgeLevel: KnowledgeLevel?
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepLayout(
            title: "Hur bra koll har du på reglerna för föräldrapenning?",
            ctaTitle: "Nästa →",
            ctaEnabled: knowledgeLevel != nil,
            onCTA: onContinue
        ) {
            VStack(spacing: Spacing.md) {
                SelectionCard(
                    emoji: "😅",
                    title: "Nybörjare",
                    subtitle: "Jag vet typ ingenting",
                    isSelected: knowledgeLevel == .beginner,
                    action: { knowledgeLevel = .beginner }
                )

                SelectionCard(
                    emoji: "📖",
                    title: "Lite koll",
                    subtitle: "Jag vet grunderna",
                    isSelected: knowledgeLevel == .some,
                    action: { knowledgeLevel = .some }
                )

                SelectionCard(
                    emoji: "🧠",
                    title: "Ganska bra koll",
                    subtitle: "Har läst på en del",
                    isSelected: knowledgeLevel == .good,
                    action: { knowledgeLevel = .good }
                )
            }
        }
    }
}
