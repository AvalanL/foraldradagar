import SwiftUI
import SwiftData

// MARK: - AI Advisor Chat View
// Premium chat experience: immersive empty state, refined bubbles,
// glass input bar, smooth animations, contextual suggestion cards.

struct ChatView: View {
    let family: Family

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.timestamp) private var allMessages: [ChatMessage]
    @State private var service = AIAdvisorService()
    @State private var inputText = ""
    @State private var showDisclaimer = true
    @State private var appearedMessages: Set<UUID> = []
    @State private var startersVisible = true
    @FocusState private var isInputFocused: Bool

    private var messages: [ChatMessage] {
        allMessages.filter { $0.familyId == family.id }
    }

    private var canAsk: Bool {
        family.isPremium || family.freeAIQuestionsRemaining > 0
    }

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && canAsk
            && !service.isLoading
    }

    private var questionsLabel: String? {
        guard !family.isPremium else { return nil }
        let remaining = family.freeAIQuestionsRemaining
        if remaining <= 0 { return nil }
        return "\(remaining) av 3"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCanvas.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Messages area
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 0) {
                                if messages.isEmpty && startersVisible {
                                    welcomeState
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                } else {
                                    // Inline disclaimer at top of conversation
                                    if showDisclaimer && !messages.isEmpty {
                                        disclaimerInline
                                            .padding(.top, Spacing.md)
                                            .padding(.bottom, Spacing.base)
                                    }

                                    // Conversation
                                    ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                                        messageBubble(for: message, at: index)
                                            .id(message.id)
                                            .transition(.asymmetric(
                                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                                removal: .opacity
                                            ))
                                    }

                                    // Typing indicator
                                    if service.isLoading {
                                        typingIndicator
                                            .id("loading")
                                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.screenH)
                            .padding(.bottom, Spacing.xxl)
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .onChange(of: messages.count) { _, _ in
                            withAnimation(.easeOut(duration: 0.3)) {
                                startersVisible = messages.isEmpty
                            }
                            scrollToBottom(proxy: proxy)
                        }
                        .onChange(of: service.isLoading) { _, isLoading in
                            if isLoading { scrollToBottom(proxy: proxy) }
                        }
                    }

                    // Input area
                    inputBar

                    // Premium upsell
                    if !canAsk {
                        premiumUpsell
                    }
                }
            }
            .navigationTitle("AI-rådgivare")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let label = questionsLabel {
                        Text(label)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.textAccent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color.textAccent.opacity(0.1))
                            )
                    }
                }
            }
        }
    }

    // MARK: - Welcome State (Empty)

    private var welcomeState: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer().frame(height: Spacing.xxxl)

            // Avatar + greeting
            VStack(spacing: Spacing.base) {
                // Animated AI avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.textAccent.opacity(0.15), Color.textAccent.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)

                    Image(systemName: "sparkles")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(Color.textAccent)
                        .symbolEffect(.pulse.byLayer, options: .repeating)
                }

                VStack(spacing: Spacing.sm) {
                    Text(welcomeTitle)
                        .font(.onboardingTitle)
                        .foregroundStyle(Color.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(welcomeSubtitle)
                        .font(.onboardingMeta)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, Spacing.base)
            }

            // Suggestion cards
            VStack(spacing: Spacing.md) {
                ForEach(Array(starterCards.enumerated()), id: \.offset) { index, card in
                    Button {
                        sendMessage(card.question)
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: card.icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.textAccent)
                                .frame(width: 36, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.small)
                                        .fill(Color.textAccent.opacity(0.08))
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(card.question)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.textPrimary)

                                if let subtitle = card.subtitle {
                                    Text(subtitle)
                                        .font(.onboardingCaption)
                                        .foregroundStyle(Color.textTertiary)
                                }
                            }

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.textTertiary)
                        }
                        .padding(Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(Color.bgSurface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                                        .stroke(Color.borderCard, lineWidth: 1)
                                )
                        )
                    }
                    .disabled(!canAsk || service.isLoading)
                }
            }

            // Disclaimer as subtle footnote
            if showDisclaimer {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 11))
                    Text("Vägledning — verifiera alltid med Försäkringskassan")
                        .font(.system(size: 12))
                }
                .foregroundStyle(Color.textTertiary)
                .padding(.top, Spacing.sm)
            }

            Spacer()
        }
    }

    // MARK: - Welcome Content

    private var welcomeTitle: String {
        let name = family.parent1?.name ?? ""
        return name.isEmpty ? "Fråga mig om\nföräldraledighet" : "Hej \(name)"
    }

    private var welcomeSubtitle: String {
        let priority = family.planningPriority ?? ""
        switch priority {
        case "maximize_income":
            return "Jag hjälper dig maximera familjens inkomst\nunder föräldraledigheten."
        case "equal_split":
            return "Jag hjälper er hitta en rättvis uppdelning\nav föräldradagarna."
        case "max_time":
            return "Jag hjälper er maximera tiden\nhemma med barnet."
        default:
            return "Jag kan hela föräldraförsäkringen och\nger svar baserade på just er situation."
        }
    }

    private struct StarterCard {
        let icon: String
        let question: String
        let subtitle: String?
    }

    private var starterCards: [StarterCard] {
        let starters = AIAdvisorService.starterQuestions(for: family)
        let icons = [
            "calendar.badge.clock",
            "arrow.left.arrow.right",
            "shield.lefthalf.filled",
            "clock.badge.exclamationmark",
            "person.2.fill",
            "banknote",
            "briefcase",
        ]
        let subtitles: [String?] = [
            "Se dagar kvar och fördelning",
            "Optimera era föräldradagar",
            "Undvik vanliga misstag",
            "Viktigaste deadlines",
            "Så funkar dubbeldagar",
            "Effekt på din pension",
            "Deltid under ledigheten",
        ]

        return starters.enumerated().map { index, question in
            StarterCard(
                icon: icons[index % icons.count],
                question: question,
                subtitle: subtitles[index % subtitles.count]
            )
        }
    }

    // MARK: - Inline Disclaimer

    private var disclaimerInline: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 12))
            Text("AI-vägledning — verifiera alltid med Försäkringskassan")
                .font(.system(size: 12))
            Spacer()
            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    showDisclaimer = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .foregroundStyle(Color.textTertiary)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.small)
                .fill(Color.bgCream)
        )
    }

    // MARK: - Message Bubbles

    @ViewBuilder
    private func messageBubble(for message: ChatMessage, at index: Int) -> some View {
        let isFirstFromRole = index == 0 || messages[index - 1].role != message.role
        let isLastFromRole = index == messages.count - 1 || messages[index + 1].role != message.role

        switch message.role {
        case .user:
            userBubble(message.content, isFirst: isFirstFromRole, isLast: isLastFromRole)
                .padding(.top, isFirstFromRole ? Spacing.lg : Spacing.xs)
                .padding(.bottom, isLastFromRole ? Spacing.sm : 0)
        case .assistant:
            assistantBubble(message.content, isFirst: isFirstFromRole, isLast: isLastFromRole)
                .padding(.top, isFirstFromRole ? Spacing.lg : Spacing.xs)
                .padding(.bottom, isLastFromRole ? Spacing.sm : 0)
        case .system:
            EmptyView()
        }
    }

    private func userBubble(_ text: String, isFirst: Bool, isLast: Bool) -> some View {
        HStack(alignment: .bottom) {
            Spacer(minLength: 56)

            Text(text)
                .font(.onboardingMeta)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.md)
                .background(
                    UserBubbleShape(isFirst: isFirst, isLast: isLast)
                        .fill(Color.accentBlue)
                )
        }
    }

    private func assistantBubble(_ text: String, isFirst: Bool, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            // Avatar only on first message in group
            if isFirst {
                aiAvatarSmall
            } else {
                Color.clear.frame(width: 28, height: 28)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(markdownToAttributed(text))
                    .font(.onboardingMeta)
                    .foregroundStyle(Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2.5)
                    .padding(.horizontal, Spacing.base)
                    .padding(.vertical, Spacing.md)
                    .background(
                        AssistantBubbleShape(isFirst: isFirst, isLast: isLast)
                            .fill(Color.bgSurface)
                    )
                    .overlay(
                        AssistantBubbleShape(isFirst: isFirst, isLast: isLast)
                            .stroke(Color.borderCard.opacity(0.6), lineWidth: 0.5)
                    )
            }

            Spacer(minLength: Spacing.xxl)
        }
    }

    private var aiAvatarSmall: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color.textAccent)
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(Color.textAccent.opacity(0.1))
            )
    }

    // MARK: - Typing Indicator

    private var typingIndicator: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            aiAvatarSmall

            HStack(spacing: Spacing.sm) {
                TypingDots()

                Text("Tänker...")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.bgSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .stroke(Color.borderCard.opacity(0.6), lineWidth: 0.5)
                    )
            )

            Spacer()
        }
        .padding(.top, Spacing.lg)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider().foregroundStyle(Color.separatorDefault.opacity(0.5))

            HStack(alignment: .bottom, spacing: Spacing.md) {
                // Text field
                TextField("Ställ en fråga...", text: $inputText, axis: .vertical)
                    .font(.onboardingMeta)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1...6)
                    .focused($isInputFocused)
                    .disabled(!canAsk)
                    .padding(.horizontal, Spacing.base)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.bgCream.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        isInputFocused ? Color.textAccent.opacity(0.4) : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )
                    )

                // Send button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        sendMessage(inputText)
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(canSend ? Color.accentBlue : Color.textDisabled)
                        )
                }
                .disabled(!canSend)
                .scaleEffect(canSend ? 1.0 : 0.9)
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: canSend)
            }
            .padding(.horizontal, Spacing.screenH)
            .padding(.vertical, Spacing.md)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    // MARK: - Premium Upsell

    private var premiumUpsell: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textAccent)
                Text("Du har använt alla 3 gratisfrågor")
                    .font(.onboardingCaption)
                    .foregroundStyle(Color.textSecondary)
            }

            Button {
                // TODO: Navigate to paywall
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .medium))
                    Text("Uppgradera till Premium")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.pill)
                        .fill(
                            LinearGradient(
                                colors: [Color.accentBlue, Color.accentBlue.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
        }
        .padding(.horizontal, Spacing.screenH)
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Actions

    private func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        inputText = ""
        isInputFocused = false

        // Save user message
        let userMsg = ChatMessage(role: .user, content: trimmed, familyId: family.id)
        modelContext.insert(userMsg)
        try? modelContext.save()

        // Decrement free questions
        if !family.isPremium {
            family.freeAIQuestionsRemaining = max(0, family.freeAIQuestionsRemaining - 1)
            try? modelContext.save()
        }

        // Build conversation history
        let history = messages
            .filter { $0.role != .system }
            .sorted { $0.timestamp < $1.timestamp }
            .map { (role: $0.role.rawValue, content: $0.content) }

        // Send to AI
        Task {
            do {
                let response = try await service.sendMessage(
                    trimmed,
                    conversationHistory: history,
                    family: family
                )
                let assistantMsg = ChatMessage(role: .assistant, content: response, familyId: family.id)
                modelContext.insert(assistantMsg)
                try? modelContext.save()
            } catch {
                let errorMsg = ChatMessage(
                    role: .assistant,
                    content: "Ursäkta, jag kunde inte svara just nu. Försök igen om en stund.",
                    familyId: family.id
                )
                modelContext.insert(errorMsg)
                try? modelContext.save()
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                if service.isLoading {
                    proxy.scrollTo("loading", anchor: .bottom)
                } else if let lastMsg = messages.last {
                    proxy.scrollTo(lastMsg.id, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Markdown Helper

    private func markdownToAttributed(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(text)
    }
}

// MARK: - Typing Dots Animation

private struct TypingDots: View {
    @State private var active = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.textAccent)
                    .frame(width: 6, height: 6)
                    .scaleEffect(active ? 1.0 : 0.5)
                    .opacity(active ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: active
                    )
            }
        }
        .onAppear { active = true }
    }
}

// MARK: - Bubble Shapes

/// User bubble with rounded corners — top-right is square on consecutive messages.
private struct UserBubbleShape: Shape {
    let isFirst: Bool
    let isLast: Bool

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 18
        let smallR: CGFloat = 6
        return UnevenRoundedRectangle(
            topLeadingRadius: r,
            bottomLeadingRadius: r,
            bottomTrailingRadius: isLast ? r : smallR,
            topTrailingRadius: isFirst ? r : smallR
        ).path(in: rect)
    }
}

/// Assistant bubble with rounded corners — top-left is square on consecutive messages.
private struct AssistantBubbleShape: Shape {
    let isFirst: Bool
    let isLast: Bool

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 18
        let smallR: CGFloat = 6
        return UnevenRoundedRectangle(
            topLeadingRadius: isFirst ? r : smallR,
            bottomLeadingRadius: isLast ? r : smallR,
            bottomTrailingRadius: r,
            topTrailingRadius: r
        ).path(in: rect)
    }
}

// MARK: - Flow Layout (used elsewhere, kept for compatibility)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: totalWidth, height: totalHeight), positions)
    }
}
