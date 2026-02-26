import SwiftUI

// MARK: - Onboarding Background

/// Gradient background that shifts subtly per step.
struct OnboardingBackground: View {
    let step: Int

    var body: some View {
        LinearGradient(
            colors: OnboardingGradient.colors(forStep: step),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(OnboardingAnimation.slideIn, value: step)
    }
}

// MARK: - Progress Bar

/// Thin progress bar at the top — no numbers, feels lighter.
struct OnboardingProgressBar: View {
    let progress: Double // 0.0 ... 1.0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.textPrimary.opacity(0.08))
                    .frame(height: 3)

                Capsule()
                    .fill(Color.textAccent)
                    .frame(width: geo.size.width * max(0.02, progress), height: 3)
                    .animation(OnboardingAnimation.progressBar, value: progress)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, Spacing.screenH)
    }
}

// MARK: - Back Button

struct OnboardingBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.textPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Selection Card

/// Large tappable card with emoji, title, and optional subtitle.
/// Haptic feedback + scale animation on selection.
struct SelectionCard: View {
    let emoji: String
    let title: String
    var subtitle: String? = nil
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: Spacing.md) {
                Text(emoji)
                    .font(.system(size: 28))
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(.onboardingBodyBold)
                        .foregroundStyle(Color.textPrimary)
                        .multilineTextAlignment(.leading)

                    if let subtitle {
                        Text(subtitle)
                            .font(.onboardingCaption)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.textAccent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.base)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.bgSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .stroke(isSelected ? Color.textAccent : Color.borderCard, lineWidth: isSelected ? 2 : 1)
                    )
            )
            .cardShadow()
            .scaleEffect(isSelected ? 1.02 : (isPressed ? 0.97 : 1.0))
            .animation(OnboardingAnimation.cardSelect, value: isSelected)
        }
        .buttonStyle(ScaleButtonStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

/// Button style that provides a subtle press-down scale.
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Primary CTA Button

struct OnboardingCTAButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.onboardingCTA)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .fill(isEnabled ? Color.buttonPrimary : Color.textDisabled)
                )
        }
        .disabled(!isEnabled)
        .sensoryFeedback(.impact(weight: .medium), trigger: isEnabled)
    }
}

// MARK: - Secondary/Text Button

struct OnboardingTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.onboardingMeta)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
    }
}

// MARK: - Onboarding Step Layout

/// Standard layout for an onboarding step: title, optional subtitle, content, CTA at bottom.
struct OnboardingStepLayout<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    let ctaTitle: String
    var ctaEnabled: Bool = true
    let onCTA: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Title
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text(title)
                            .font(.onboardingTitle)
                            .foregroundStyle(Color.textPrimary)

                        if let subtitle {
                            Text(subtitle)
                                .font(.onboardingBody)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }

                    // Step-specific content
                    content()
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, Spacing.xl)
                .padding(.bottom, 120) // Space for bottom button
            }

            Spacer(minLength: 0)

            // Bottom CTA
            VStack(spacing: Spacing.sm) {
                OnboardingCTAButton(
                    title: ctaTitle,
                    isEnabled: ctaEnabled,
                    action: onCTA
                )
            }
            .padding(.horizontal, Spacing.screenH)
            .padding(.bottom, Spacing.lg)
        }
    }
}

// MARK: - Income Slider

struct IncomeSlider: View {
    @Binding var income: Decimal
    let name: String

    private var intValue: Double {
        get { NSDecimalNumber(decimal: income).doubleValue }
    }

    @State private var sliderValue: Double = 35000

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            // Current value display
            Text(ForaldrapenningCalculator.formattedKr(income) + "/mån")
                .font(.onboardingSectionTitle)
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
                .contentTransition(.numericText())

            // Slider
            Slider(value: $sliderValue, in: 15000...85000, step: 1000) {
                Text("Månadslön")
            } minimumValueLabel: {
                Text("15k")
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textTertiary)
            } maximumValueLabel: {
                Text("80k+")
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textTertiary)
            }
            .tint(Color.textAccent)
            .onChange(of: sliderValue) { _, newValue in
                income = Decimal(newValue)
            }
            .onAppear {
                sliderValue = NSDecimalNumber(decimal: income).doubleValue
            }

            // Live calculation
            let daily = ForaldrapenningCalculator.dailyRate(monthlyIncome: income)
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.textAccent)
                    .font(.system(size: 14))
                Text("\(name.isEmpty ? "Din" : "\(name)s") föräldrapenning: ~\(ForaldrapenningCalculator.formatted(dailyRate: daily))")
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
        }
    }
}

// MARK: - Name Text Field

struct OnboardingTextField: View {
    let placeholder: String
    @Binding var text: String
    var caption: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            TextField(placeholder, text: $text)
                .font(.system(size: 22, weight: .medium, design: .default))
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.base)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .fill(Color.bgSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .stroke(isFocused ? Color.textAccent : Color.borderCard, lineWidth: isFocused ? 2 : 1)
                        )
                )
                .cardShadow()
                .focused($isFocused)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()

            if let caption {
                Text(caption)
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textTertiary)
            }
        }
    }
}

// MARK: - Percentage Pill Selector

struct PillSelector<T: Hashable>: View {
    let options: [(value: T, label: String)]
    @Binding var selected: T?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(options, id: \.value) { option in
                Button {
                    selected = option.value
                } label: {
                    Text(option.label)
                        .font(.onboardingMeta)
                        .foregroundStyle(selected == option.value ? .white : Color.textPrimary)
                        .padding(.horizontal, Spacing.base)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            Capsule()
                                .fill(selected == option.value ? Color.textPrimary : Color.bgSurface)
                        )
                        .overlay(
                            Capsule()
                                .stroke(selected == option.value ? Color.clear : Color.borderCard, lineWidth: 1)
                        )
                }
                .sensoryFeedback(.selection, trigger: selected as? AnyHashable)
            }
        }
    }
}

// MARK: - Day Counter Input

struct DayCounterInput: View {
    let label: String
    @Binding var days: Int?

    @State private var text: String = ""

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(label)
                .font(.onboardingBody)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            TextField("0", text: $text)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.textPrimary)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 80)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.small)
                        .fill(Color.bgSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.small)
                                .stroke(Color.borderCard, lineWidth: 1)
                        )
                )
                .onChange(of: text) { _, newValue in
                    days = Int(newValue)
                }
                .onAppear {
                    if let days { text = "\(days)" }
                }

            Text("dagar")
                .font(.onboardingMeta)
                .foregroundStyle(Color.textSecondary)
        }
    }
}

// MARK: - Chat Bubble (for AI Showcase)

struct ChatBubble: View {
    let isUser: Bool
    let text: String

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.sm) {
                    if !isUser {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textAccent)
                    }
                    Text(isUser ? "Du" : "AI-rådgivare")
                        .font(.onboardingCaption)
                        .foregroundStyle(Color.textTertiary)
                }

                Text(text)
                    .font(.onboardingMeta)
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, Spacing.base)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.large)
                            .fill(isUser ? Color.textAccent.opacity(0.1) : Color.bgSurface)
                    )
                    .cardShadow()
            }

            if !isUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Animated Counter

/// Counts up from 0 to a target value over a duration.
struct AnimatedCounter: View {
    let target: Int
    let suffix: String
    var duration: Double = 2.0

    @State private var displayValue: Int = 0

    var body: some View {
        Text("\(displayValue) \(suffix)")
            .font(.onboardingHeroNumber)
            .foregroundStyle(Color.textPrimary)
            .contentTransition(.numericText())
            .onAppear {
                withAnimation(.easeInOut(duration: duration)) {
                    displayValue = target
                }
            }
    }
}

// MARK: - Summary Stat Row

struct SummaryStatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(icon)
                .font(.system(size: 20))
                .frame(width: 32)

            Text(label)
                .font(.onboardingBody)
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text(value)
                .font(.onboardingBodyBold)
                .foregroundStyle(Color.textPrimary)
        }
        .padding(.vertical, Spacing.sm)
    }
}

// MARK: - Confetti Effect (Simple)

struct ConfettiView: View {
    @State private var animate = false

    let colors: [Color] = [.accentBlue, .parent2Color, .accentGreen, .accentGold, .textAccent]

    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(colors[index % colors.count])
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
                    .offset(
                        x: animate ? CGFloat.random(in: -180...180) : 0,
                        y: animate ? CGFloat.random(in: -400...(-100)) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? CGFloat.random(in: 0.3...1.0) : 0.01)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animate = true
            }
        }
    }
}

// MARK: - Date Picker Card

struct OnboardingDatePicker: View {
    let title: String
    @Binding var date: Date?
    var displayedComponents: DatePicker<Text>.Components = [.date]
    var approximateMode: Bool = false // For "planerar i förväg" — month/year only

    @State private var selectedDate = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            if approximateMode {
                // Month + Year picker style
                DatePicker(
                    title,
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
            } else {
                DatePicker(
                    title,
                    selection: $selectedDate,
                    displayedComponents: displayedComponents
                )
                .datePickerStyle(.graphical)
                .tint(Color.textAccent)
                .labelsHidden()
            }
        }
        .padding(Spacing.base)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Color.bgSurface)
        )
        .cardShadow()
        .onChange(of: selectedDate) { _, newValue in
            date = newValue
        }
        .onAppear {
            if let date {
                selectedDate = date
            } else {
                // Default: 3 months from now for expecting
                selectedDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
                date = selectedDate
            }
        }
    }
}
