import SwiftUI

// MARK: - BLOCK 2: BARNET (Steps 4-6) — The Child

// ──────────────────────────────────────────────
// Step 4: When Is/Was the Baby Born?
// ──────────────────────────────────────────────

struct ChildDateStepView: View {
    @Binding var childDate: Date?
    let stage: FamilyStage?
    let onContinue: () -> Void

    private var title: String {
        switch stage {
        case .expecting:
            return "När är beräknat födelsedatum (BF)?"
        case .born:
            return "När föddes ert barn?"
        case .planning:
            return "Ungefär när planerar ni att få barn?"
        case .none:
            return "När är beräknat födelsedatum?"
        }
    }

    private var subtitle: String? {
        stage == .planning ? "Ungefärligt datum räcker." : nil
    }

    var body: some View {
        OnboardingStepLayout(
            title: title,
            subtitle: subtitle,
            ctaTitle: "Nästa →",
            ctaEnabled: childDate != nil,
            onCTA: onContinue
        ) {
            OnboardingDatePicker(
                title: "Datum",
                date: $childDate,
                approximateMode: stage == .planning
            )
        }
    }
}

// ──────────────────────────────────────────────
// Step 5: Multiple Births?
// ──────────────────────────────────────────────

struct MultipleBirthsStepView: View {
    @Binding var multipleType: MultipleType?
    let isSingleParent: Bool
    let onContinue: () -> Void

    private var title: String {
        isSingleParent ? "Väntar du fler än ett barn?" : "Väntar ni fler än ett barn?"
    }

    var body: some View {
        OnboardingStepLayout(
            title: title,
            ctaTitle: "Nästa →",
            ctaEnabled: multipleType != nil,
            onCTA: onContinue
        ) {
            VStack(spacing: Spacing.md) {
                SelectionCard(
                    emoji: "👶",
                    title: "Ett barn",
                    isSelected: multipleType == .single,
                    action: { multipleType = .single }
                )

                SelectionCard(
                    emoji: "👶👶",
                    title: "Tvillingar",
                    subtitle: "+180 extra dagar!",
                    isSelected: multipleType == .twins,
                    action: { multipleType = .twins }
                )

                SelectionCard(
                    emoji: "👶👶👶",
                    title: "Trillingar eller fler",
                    subtitle: "Ännu fler dagar",
                    isSelected: multipleType == .triplets,
                    action: { multipleType = .triplets }
                )
            }
        }
    }
}

// ──────────────────────────────────────────────
// Step 6: Is This Your First Child?
// ──────────────────────────────────────────────

struct FirstChildStepView: View {
    @Binding var isFirstChild: Bool?
    let isSingleParent: Bool
    let onContinue: () -> Void

    private var title: String {
        isSingleParent ? "Är detta ditt första barn?" : "Är detta ert första barn?"
    }

    var body: some View {
        OnboardingStepLayout(
            title: title,
            ctaTitle: "Nästa →",
            ctaEnabled: isFirstChild != nil,
            onCTA: onContinue
        ) {
            VStack(spacing: Spacing.md) {
                SelectionCard(
                    emoji: "🌟",
                    title: isSingleParent ? "Ja, mitt första!" : "Ja, vårt första!",
                    isSelected: isFirstChild == true,
                    action: { isFirstChild = true }
                )

                SelectionCard(
                    emoji: "👨‍👩‍👧",
                    title: isSingleParent ? "Nej, jag har barn sedan innan" : "Nej, vi har barn sedan innan",
                    isSelected: isFirstChild == false,
                    action: { isFirstChild = false }
                )
            }
        }
    }
}
