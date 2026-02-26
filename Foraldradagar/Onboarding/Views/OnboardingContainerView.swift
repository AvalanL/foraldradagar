import SwiftUI
import SwiftData

// MARK: - Onboarding Container View
// Orchestrates the entire 20-step onboarding flow + paywall.

struct OnboardingContainerView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.modelContext) private var modelContext

    /// Called when onboarding finishes (after paywall choice).
    var onComplete: ((OnboardingData, Bool) -> Void)? = nil

    var body: some View {
        ZStack {
            // Shifting gradient background
            OnboardingBackground(step: viewModel.stepIndexForGradient)

            if viewModel.showPaywall {
                paywallView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                VStack(spacing: 0) {
                    // Progress bar (hidden on welcome step)
                    if !viewModel.isFirstStep {
                        VStack(spacing: 0) {
                            // Back button + progress
                            HStack {
                                OnboardingBackButton(action: viewModel.goBack)
                                Spacer()
                            }
                            .padding(.horizontal, Spacing.sm)

                            OnboardingProgressBar(progress: viewModel.progress)
                        }
                        .transition(.opacity)
                    }

                    // Step content
                    currentStepView
                        .id(viewModel.currentStep) // Forces view recreation on step change
                        .transition(.asymmetric(
                            insertion: .move(edge: viewModel.direction == .forward ? .trailing : .leading)
                                .combined(with: .opacity),
                            removal: .move(edge: viewModel.direction == .forward ? .leading : .trailing)
                                .combined(with: .opacity)
                        ))
                }
                .animation(OnboardingAnimation.slideIn, value: viewModel.currentStepIndex)
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    // MARK: - Step Router

    @ViewBuilder
    private var currentStepView: some View {
        switch viewModel.currentStep {

        // BLOCK 1: Welcome
        case .welcome:
            WelcomeStepView(onContinue: viewModel.advance)

        case .familyType:
            FamilyTypeStepView(
                familyType: $viewModel.data.familyType,
                onContinue: viewModel.advance
            )

        case .stage:
            FamilyStageStepView(
                stage: $viewModel.data.stage,
                isSingleParent: viewModel.data.familyType == .singleParent,
                onContinue: viewModel.advance
            )

        // BLOCK 2: Child
        case .childDate:
            ChildDateStepView(
                childDate: $viewModel.data.childDate,
                stage: viewModel.data.stage,
                onContinue: viewModel.advance
            )

        case .multipleBirths:
            MultipleBirthsStepView(
                multipleType: $viewModel.data.multipleType,
                isSingleParent: viewModel.data.familyType == .singleParent,
                onContinue: viewModel.advance
            )

        case .firstChild:
            FirstChildStepView(
                isFirstChild: $viewModel.data.isFirstChild,
                isSingleParent: viewModel.data.familyType == .singleParent,
                onContinue: viewModel.advance
            )

        // BLOCK 3: Parents
        case .parent1Name:
            Parent1NameStepView(
                name: $viewModel.data.parent1.name,
                onContinue: viewModel.advance
            )

        case .parent1Income:
            Parent1IncomeStepView(
                income: $viewModel.data.parent1.monthlyIncome,
                name: viewModel.data.parent1.name,
                onContinue: viewModel.advance
            )

        case .parent1TopUp:
            Parent1TopUpStepView(
                hasTopUp: $viewModel.data.parent1.hasEmployerTopUp,
                topUpPercentage: $viewModel.data.parent1.topUpPercentage,
                topUpMonths: $viewModel.data.parent1.topUpMonths,
                onContinue: viewModel.advance
            )

        case .parent2Name:
            Parent2NameStepView(
                name: Binding(
                    get: { viewModel.data.parent2?.name ?? "" },
                    set: { viewModel.data.parent2?.name = $0 }
                ),
                onContinue: viewModel.advance
            )

        case .parent2Income:
            Parent2IncomeStepView(
                income: Binding(
                    get: { viewModel.data.parent2?.monthlyIncome ?? 35000 },
                    set: { viewModel.data.parent2?.monthlyIncome = $0 }
                ),
                partnerName: viewModel.data.parent2?.name ?? "",
                parent1Income: viewModel.data.parent1.monthlyIncome,
                onContinue: viewModel.advance
            )

        case .parent2TopUp:
            Parent2TopUpStepView(
                hasTopUp: Binding(
                    get: { viewModel.data.parent2?.hasEmployerTopUp },
                    set: { viewModel.data.parent2?.hasEmployerTopUp = $0 }
                ),
                topUpPercentage: Binding(
                    get: { viewModel.data.parent2?.topUpPercentage },
                    set: { viewModel.data.parent2?.topUpPercentage = $0 }
                ),
                topUpMonths: Binding(
                    get: { viewModel.data.parent2?.topUpMonths },
                    set: { viewModel.data.parent2?.topUpMonths = $0 }
                ),
                partnerName: viewModel.data.parent2?.name ?? "",
                onContinue: viewModel.advance
            )

        // BLOCK 4: Plan
        case .daysTaken:
            DaysTakenStepView(
                hasStarted: $viewModel.data.hasStartedTakingDays,
                daysTakenParent1: $viewModel.data.daysTakenParent1,
                daysTakenParent2: $viewModel.data.daysTakenParent2,
                parent1Name: viewModel.data.parent1.name,
                parent2Name: viewModel.data.parent2?.name,
                onContinue: viewModel.advance
            )

        case .priority:
            PriorityStepView(
                priority: $viewModel.data.priority,
                isSingleParent: viewModel.data.familyType == .singleParent,
                onContinue: viewModel.advance
            )

        case .childcare:
            ChildcareStepView(
                childcarePlan: $viewModel.data.childcarePlan,
                isSingleParent: viewModel.data.familyType == .singleParent,
                onContinue: viewModel.advance
            )

        case .knowledgeLevel:
            KnowledgeLevelStepView(
                knowledgeLevel: $viewModel.data.knowledgeLevel,
                onContinue: viewModel.advance
            )

        // BLOCK 5: Summary
        case .summary:
            SummaryStepView(
                data: viewModel.data,
                parent1DailyRate: viewModel.parent1DailyRate,
                parent2DailyRate: viewModel.parent2DailyRate,
                expiryDateFormatted: viewModel.formattedExpiryDate,
                onContinue: viewModel.advance
            )

        case .aiInsight:
            AIInsightStepView(
                insightText: viewModel.personalizedInsight,
                onContinue: viewModel.advance
            )

        case .featureShowcase:
            FeatureShowcaseStepView(
                data: viewModel.data,
                onContinue: viewModel.advance
            )

        case .notifications:
            NotificationsStepView(
                notificationsEnabled: $viewModel.data.notificationsEnabled,
                onContinue: viewModel.advance
            )
        }
    }

    // MARK: - Paywall

    private var paywallView: some View {
        PaywallView(
            data: viewModel.data,
            parent1DailyRate: viewModel.parent1DailyRate,
            optimizationCount: viewModel.optimizationCount,
            expiryDateFormatted: viewModel.formattedExpiryDate,
            onSubscribe: { plan in
                handleSubscription(plan: plan)
            },
            onSkip: {
                handleSkip()
            }
        )
    }

    // MARK: - Actions

    private func handleSubscription(plan: PaywallPlan) {
        // TODO: Integrate StoreKit 2 subscription purchase
        viewModel.markCompleted()
        onComplete?(viewModel.data, true)
    }

    private func handleSkip() {
        viewModel.markCompleted()
        onComplete?(viewModel.data, false)
    }
}

// MARK: - Preview

#Preview {
    OnboardingContainerView()
        .modelContainer(for: OnboardingProgress.self, inMemory: true)
}
