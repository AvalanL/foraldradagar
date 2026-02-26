import Foundation
import SwiftData

// MARK: - Chat Message
// Persisted conversation history for the AI Advisor.

@Model
final class ChatMessage {
    var id: UUID = UUID()
    var roleRaw: String = ChatRole.user.rawValue
    var content: String = ""
    var timestamp: Date = Date()
    var familyId: UUID? = nil

    @Transient
    var role: ChatRole {
        get { ChatRole(rawValue: roleRaw) ?? .user }
        set { roleRaw = newValue.rawValue }
    }

    init() {}

    init(role: ChatRole, content: String, familyId: UUID? = nil) {
        self.roleRaw = role.rawValue
        self.content = content
        self.familyId = familyId
    }
}

enum ChatRole: String, Codable {
    case user      = "user"
    case assistant = "assistant"
    case system    = "system"
}

// MARK: - Conversation

/// A lightweight grouping of messages for the AI service.
struct Conversation {
    var messages: [ChatMessage]

    /// Returns messages formatted for API consumption.
    var apiMessages: [(role: String, content: String)] {
        messages
            .filter { $0.role != .system }
            .sorted { $0.timestamp < $1.timestamp }
            .map { (role: $0.role.rawValue, content: $0.content) }
    }
}
