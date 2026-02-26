import SwiftUI

// MARK: - Design Tokens
// Source of truth for the entire app's visual language.
// Palette: Modern Scandinavian — one hero accent (indigo), semantic secondaries,
// clean near-white backgrounds, cool grays for text. Calm, confident, premium.

// MARK: - Color Tokens

extension Color {
    // --- Backgrounds ---
    static let bgCanvas          = Color(hex: 0xFAFAF8) // clean warm white
    static let bgSurface         = Color.white            // cards, modals
    static let bgSurfaceElevated = Color.white
    static let bgCream           = Color(hex: 0xF2F1ED)  // subtle warm gray — sections

    // --- Hero Accent — One strong color ---
    static let accentBlue  = Color(hex: 0x4F46E5) // indigo-600 — primary actions
    static let accentGold  = Color(hex: 0xD97706) // amber-600 — warning states only
    static let accentCoral = Color(hex: 0xDC2626) // red-600 — urgent/danger

    // --- Success ---
    static let accentGreen = Color(hex: 0x059669) // emerald-600 — positive states

    // --- Text ---
    static let textPrimary   = Color(hex: 0x111827) // gray-900
    static let textSecondary = Color(hex: 0x6B7280) // gray-500
    static let textTertiary  = Color(hex: 0x9CA3AF) // gray-400
    static let textDisabled  = Color(hex: 0xD1D5DB) // gray-300
    static let textAccent    = Color(hex: 0x4F46E5) // indigo-600 (hero color for highlights)

    // --- Parent Colors ---
    static let parent1Color = Color(hex: 0x4F46E5) // indigo — Förälder 1
    static let parent2Color = Color(hex: 0xE879A4) // soft pink — Förälder 2
    static let vabColor     = Color(hex: 0xDC2626) // red — VAB days

    // --- Interactive / Status ---
    static let buttonPrimary   = Color(hex: 0x4F46E5) // indigo
    static let buttonSecondary = Color(hex: 0xF2F1ED) // cream
    static let selectedBorder  = Color(hex: 0x4F46E5) // indigo
    static let checkboxFilled  = Color(hex: 0x4F46E5) // indigo
    static let checkboxEmpty   = Color(hex: 0xD1D5DB) // gray-300

    // --- Separators ---
    static let separatorDefault = Color(hex: 0xE5E7EB) // gray-200
    static let separatorList    = Color(hex: 0xF3F4F6) // gray-100
    static let borderCard       = Color(hex: 0xE5E7EB) // gray-200

    // --- Calendar ---
    static let calendarToday = Color(hex: 0x4F46E5) // indigo
    static let calendarOther = Color(hex: 0xD1D5DB) // gray-300

    // --- Deadline / Warning ---
    static let deadlineUrgent  = Color(hex: 0xDC2626) // red
    static let deadlineWarning = Color(hex: 0xD97706) // amber

    // --- Progress Bar ---
    static let progressFill  = Color(hex: 0x4F46E5) // indigo
    static let progressTrack = Color(hex: 0xF2F1ED) // cream
}

// MARK: - Hex Initializer

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Onboarding Gradient Palette
// Subtle background shifts across blocks — barely noticeable, just enough warmth.

struct OnboardingGradient {
    // Block 1: Welcome (Steps 1-3) — clean white
    static let warmWhite = [
        Color(hex: 0xFAFAF8),
        Color(hex: 0xF8F8F5),
    ]

    // Block 2: Child (Steps 4-6) — hint of warmth
    static let warmCream = [
        Color(hex: 0xF8F8F5),
        Color(hex: 0xF5F4F0),
    ]

    // Block 3: Parents (Steps 7-12) — subtle cream
    static let cream = [
        Color(hex: 0xF5F4F0),
        Color(hex: 0xF2F1ED),
    ]

    // Block 4: Plan (Steps 13-16) — slightly deeper
    static let creamGold = [
        Color(hex: 0xF2F1ED),
        Color(hex: 0xEFEEEA),
    ]

    // Block 5: Summary (Steps 17-20) — subtle indigo tint
    static let goldGlow = [
        Color(hex: 0xEFEEEA),
        Color(hex: 0xEEEDF5),
    ]

    // Paywall — soft indigo glow
    static let paywall = [
        Color(hex: 0xEEEDF5),
        Color(hex: 0xFAFAF8),
    ]

    /// Returns the gradient colors for a given step (0-indexed).
    static func colors(forStep step: Int) -> [Color] {
        switch step {
        case 0...2:   return warmWhite
        case 3...5:   return warmCream
        case 6...11:  return cream
        case 12...15: return creamGold
        case 16...19: return goldGlow
        default:      return paywall
        }
    }
}

// MARK: - Spacing (4pt grid)

enum Spacing {
    static let xs:   CGFloat = 4
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let base: CGFloat = 16
    static let lg:   CGFloat = 20
    static let xl:   CGFloat = 24
    static let xxl:  CGFloat = 32
    static let xxxl: CGFloat = 40
    static let xxxxl: CGFloat = 48

    /// Screen horizontal padding (design system: 20pt)
    static let screenH: CGFloat = 20
}

// MARK: - Corner Radii

enum CornerRadius {
    static let small:  CGFloat = 8
    static let medium: CGFloat = 14
    static let large:  CGFloat = 18
    static let pill:   CGFloat = 999
}

// MARK: - Shadows

extension View {
    func cardShadow() -> some View {
        self.shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 1)
    }

    func elevatedShadow() -> some View {
        self.shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
    }
}

// MARK: - Typography Helpers
// Headings: New York serif (SF Serif / .serif design)
// Body: SF Pro (.default design)

extension Font {
    /// Large heading — New York serif, 28pt bold
    static let onboardingTitle = Font.system(size: 28, weight: .bold, design: .serif)

    /// Subtitle — New York serif, 18pt regular
    static let onboardingSubtitle = Font.system(size: 18, weight: .regular, design: .serif)

    /// Section heading — SF Pro, 22pt semibold
    static let onboardingSectionTitle = Font.system(size: 22, weight: .semibold, design: .default)

    /// Body text — SF Pro, 17pt regular
    static let onboardingBody = Font.system(size: 17, weight: .regular, design: .default)

    /// Body text emphasized — SF Pro, 17pt semibold
    static let onboardingBodyBold = Font.system(size: 17, weight: .semibold, design: .default)

    /// Small metadata — SF Pro, 15pt regular
    static let onboardingMeta = Font.system(size: 15, weight: .regular, design: .default)

    /// Caption — SF Pro, 13pt regular
    static let onboardingCaption = Font.system(size: 13, weight: .regular, design: .default)

    /// CTA button — SF Pro, 17pt semibold
    static let onboardingCTA = Font.system(size: 17, weight: .semibold, design: .default)

    /// Large number display (for summary) — New York serif, 48pt bold
    static let onboardingHeroNumber = Font.system(size: 48, weight: .bold, design: .serif)

    /// Income amount display — New York serif, 32pt bold
    static let incomeAmount = Font.system(size: 32, weight: .bold, design: .serif)

    /// Price card title — SF Pro, 13pt bold
    static let priceLabel = Font.system(size: 13, weight: .bold, design: .default)

    /// Price amount — SF Pro, 24pt bold
    static let priceAmount = Font.system(size: 24, weight: .bold, design: .default)

    /// Price subtitle — SF Pro, 13pt regular
    static let priceSubtitle = Font.system(size: 13, weight: .regular, design: .default)
}

// MARK: - Animation Constants

enum OnboardingAnimation {
    static let cardSelect    = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let slideIn       = Animation.easeInOut(duration: 0.35)
    static let fadeIn        = Animation.easeInOut(duration: 0.3)
    static let countUp       = Animation.easeInOut(duration: 2.0)
    static let progressBar   = Animation.easeInOut(duration: 0.4)
    static let confetti      = Animation.easeOut(duration: 0.6)
}
