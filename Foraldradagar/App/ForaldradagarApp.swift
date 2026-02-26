import SwiftUI
import SwiftData

@main
struct ForaldradagarApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            OnboardingProgress.self,
            Family.self,
            Parent.self,
            Child.self,
            LeaveDay.self,
            ChatMessage.self,
            Scenario.self,
            LeaveBlock.self,
        ])
    }
}

// MARK: - Root View
// Routes between onboarding and main app based on completion state.

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var families: [Family]
    @Query private var onboardingProgress: [OnboardingProgress]

    @State private var showOnboarding: Bool? = nil // nil = loading

    var body: some View {
        Group {
            if let showOnboarding {
                if showOnboarding {
                    OnboardingContainerView(onComplete: handleOnboardingComplete)
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            } else {
                // Brief loading state
                ZStack {
                    Color.bgCanvas.ignoresSafeArea()
                    ProgressView()
                        .tint(Color.textAccent)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showOnboarding)
        .onAppear {
            determineRoute()
        }
    }

    private func determineRoute() {
        // If a Family exists, onboarding is done
        if !families.isEmpty {
            showOnboarding = false
            return
        }

        // If onboarding progress exists and is completed but no family was created
        // (edge case — re-run conversion)
        if let progress = onboardingProgress.first, progress.isCompleted {
            let data = progress.onboardingData
            OnboardingConverter.convert(from: data, isPremium: false, in: modelContext)
            showOnboarding = false
            return
        }

        // No family, no completed onboarding → show onboarding
        showOnboarding = true
    }

    private func handleOnboardingComplete(data: OnboardingData, isPremium: Bool) {
        // Convert onboarding data into core models
        OnboardingConverter.convert(from: data, isPremium: isPremium, in: modelContext)

        // Transition to main app
        withAnimation(.easeInOut(duration: 0.5)) {
            showOnboarding = false
        }
    }
}
