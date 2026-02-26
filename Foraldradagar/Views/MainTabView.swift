import SwiftUI
import SwiftData

// MARK: - Main Tab View
// The app shell after onboarding. 4 tabs, warm design, one-handed friendly.

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @Query private var families: [Family]

    private var family: Family? { families.first }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home / Dashboard
            Group {
                if let family {
                    DashboardView(family: family, selectedTab: $selectedTab)
                } else {
                    emptyState
                }
            }
            .tabItem {
                Label("Hem", systemImage: "house.fill")
            }
            .tag(AppTab.home)

            // Tab 2: Day Tracker / Calendar
            Group {
                if let family {
                    DayTrackerView(family: family)
                } else {
                    emptyState
                }
            }
            .tabItem {
                Label("Dagar", systemImage: "calendar")
            }
            .tag(AppTab.days)

            // Tab 3: AI Advisor
            Group {
                if let family {
                    ChatView(family: family)
                } else {
                    emptyState
                }
            }
            .tabItem {
                Label("Fråga", systemImage: "sparkles")
            }
            .tag(AppTab.ask)

            // Tab 4: Settings / More
            SettingsView()
                .tabItem {
                    Label("Mer", systemImage: "ellipsis.circle")
                }
                .tag(AppTab.more)
        }
        .tint(Color.textAccent)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "figure.and.child.holdinghands")
                .font(.system(size: 48))
                .foregroundStyle(Color.textTertiary)
            Text("Ingen familj hittades")
                .font(.onboardingBody)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgCanvas)
    }
}

// MARK: - Tab Enum

enum AppTab: String, Hashable {
    case home
    case days
    case ask
    case more
}

// MARK: - Placeholder Tab View

struct PlaceholderTabView: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCanvas.ignoresSafeArea()

                VStack(spacing: Spacing.xl) {
                    Image(systemName: icon)
                        .font(.system(size: 48))
                        .foregroundStyle(Color.textAccent.opacity(0.5))

                    VStack(spacing: Spacing.sm) {
                        Text(title)
                            .font(.onboardingSectionTitle)
                            .foregroundStyle(Color.textPrimary)

                        Text(description)
                            .font(.onboardingBody)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.xxl)
                    }

                    Text("Kommer snart")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                        .padding(.horizontal, Spacing.base)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            Capsule()
                                .fill(Color.textTertiary.opacity(0.1))
                        )
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
