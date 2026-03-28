import Foundation
import SwiftUI

struct Theme: Codable, Sendable, Equatable {
    var id: String
    var name: String
    var options: Options
    var colors: Colors
    var cornerRadii: CornerRadii
    var spacing: Spacing

    struct Options: Codable, Sendable, Equatable {
        var useMaterial: Bool
        var useSystemAccent: Bool
        var appearance: String

        static let `default` = Options(
            useMaterial: true,
            useSystemAccent: true,
            appearance: "dark"
        )

        init(useMaterial: Bool = Self.default.useMaterial,
             useSystemAccent: Bool = Self.default.useSystemAccent,
             appearance: String = Self.default.appearance) {
            self.useMaterial = useMaterial
            self.useSystemAccent = useSystemAccent
            self.appearance = appearance
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let d = Self.default
            useMaterial = try container.decodeIfPresent(Bool.self, forKey: .useMaterial) ?? d.useMaterial
            useSystemAccent = try container.decodeIfPresent(Bool.self, forKey: .useSystemAccent) ?? d.useSystemAccent
            appearance = try container.decodeIfPresent(String.self, forKey: .appearance) ?? d.appearance
        }
    }

    struct Colors: Codable, Sendable, Equatable {
        var accent: String?
        var panelFill: String?
        var panelFillOpacity: Double?
        var tabBarBackground: String?
        var tabBarBackgroundOpacity: Double?
        var rowSelected: String?
        var rowSelectedOpacity: Double?
        var rowHovered: String?
        var rowHoveredOpacity: Double?
        var overlayBackdrop: String?
        var overlayBackdropOpacity: Double?
        var pillBackground: String?
        var pillBackgroundOpacity: Double?
        var shortcutKeyBackground: String?
        var shortcutKeyBackgroundOpacity: Double?
        var cardBackground: String?
        var cardBackgroundOpacity: Double?
        var cardStroke: String?
        var cardStrokeOpacity: Double?
        var textPrimary: String?
        var textSecondary: String?
        var textTertiary: String?
        var imageIndicator: String?
        var statusReady: String?
        var statusWarning: String?
        var gaugeUnfilled: String?
        var gaugeUnfilledOpacity: Double?

        static let `default` = Colors(
            accent: "#007AFF",
            panelFill: "#1E1E1E",
            panelFillOpacity: 0.85,
            tabBarBackground: "#000000",
            tabBarBackgroundOpacity: 0.05,
            rowSelected: nil,
            rowSelectedOpacity: 0.18,
            rowHovered: nil,
            rowHoveredOpacity: 0.09,
            overlayBackdrop: "#000000",
            overlayBackdropOpacity: 0.15,
            pillBackground: nil,
            pillBackgroundOpacity: 0.12,
            shortcutKeyBackground: "#000000",
            shortcutKeyBackgroundOpacity: 0.06,
            cardBackground: "#000000",
            cardBackgroundOpacity: 0.15,
            cardStroke: "#FFFFFF",
            cardStrokeOpacity: 0.08,
            textPrimary: nil,
            textSecondary: nil,
            textTertiary: nil,
            imageIndicator: "#FF9500",
            statusReady: "#34C759",
            statusWarning: "#FF9500",
            gaugeUnfilled: nil,
            gaugeUnfilledOpacity: 0.15
        )

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let d = Self.default
            accent = try container.decodeIfPresent(String.self, forKey: .accent) ?? d.accent
            panelFill = try container.decodeIfPresent(String.self, forKey: .panelFill) ?? d.panelFill
            panelFillOpacity = try container.decodeIfPresent(Double.self, forKey: .panelFillOpacity) ?? d.panelFillOpacity
            tabBarBackground = try container.decodeIfPresent(String.self, forKey: .tabBarBackground) ?? d.tabBarBackground
            tabBarBackgroundOpacity = try container.decodeIfPresent(Double.self, forKey: .tabBarBackgroundOpacity) ?? d.tabBarBackgroundOpacity
            rowSelected = try container.decodeIfPresent(String.self, forKey: .rowSelected) ?? d.rowSelected
            rowSelectedOpacity = try container.decodeIfPresent(Double.self, forKey: .rowSelectedOpacity) ?? d.rowSelectedOpacity
            rowHovered = try container.decodeIfPresent(String.self, forKey: .rowHovered) ?? d.rowHovered
            rowHoveredOpacity = try container.decodeIfPresent(Double.self, forKey: .rowHoveredOpacity) ?? d.rowHoveredOpacity
            overlayBackdrop = try container.decodeIfPresent(String.self, forKey: .overlayBackdrop) ?? d.overlayBackdrop
            overlayBackdropOpacity = try container.decodeIfPresent(Double.self, forKey: .overlayBackdropOpacity) ?? d.overlayBackdropOpacity
            pillBackground = try container.decodeIfPresent(String.self, forKey: .pillBackground) ?? d.pillBackground
            pillBackgroundOpacity = try container.decodeIfPresent(Double.self, forKey: .pillBackgroundOpacity) ?? d.pillBackgroundOpacity
            shortcutKeyBackground = try container.decodeIfPresent(String.self, forKey: .shortcutKeyBackground) ?? d.shortcutKeyBackground
            shortcutKeyBackgroundOpacity = try container.decodeIfPresent(Double.self, forKey: .shortcutKeyBackgroundOpacity) ?? d.shortcutKeyBackgroundOpacity
            cardBackground = try container.decodeIfPresent(String.self, forKey: .cardBackground) ?? d.cardBackground
            cardBackgroundOpacity = try container.decodeIfPresent(Double.self, forKey: .cardBackgroundOpacity) ?? d.cardBackgroundOpacity
            cardStroke = try container.decodeIfPresent(String.self, forKey: .cardStroke) ?? d.cardStroke
            cardStrokeOpacity = try container.decodeIfPresent(Double.self, forKey: .cardStrokeOpacity) ?? d.cardStrokeOpacity
            textPrimary = try container.decodeIfPresent(String.self, forKey: .textPrimary) ?? d.textPrimary
            textSecondary = try container.decodeIfPresent(String.self, forKey: .textSecondary) ?? d.textSecondary
            textTertiary = try container.decodeIfPresent(String.self, forKey: .textTertiary) ?? d.textTertiary
            imageIndicator = try container.decodeIfPresent(String.self, forKey: .imageIndicator) ?? d.imageIndicator
            statusReady = try container.decodeIfPresent(String.self, forKey: .statusReady) ?? d.statusReady
            statusWarning = try container.decodeIfPresent(String.self, forKey: .statusWarning) ?? d.statusWarning
            gaugeUnfilled = try container.decodeIfPresent(String.self, forKey: .gaugeUnfilled) ?? d.gaugeUnfilled
            gaugeUnfilledOpacity = try container.decodeIfPresent(Double.self, forKey: .gaugeUnfilledOpacity) ?? d.gaugeUnfilledOpacity
        }

        init(
            accent: String? = nil, panelFill: String? = nil, panelFillOpacity: Double? = nil,
            tabBarBackground: String? = nil, tabBarBackgroundOpacity: Double? = nil,
            rowSelected: String? = nil, rowSelectedOpacity: Double? = nil,
            rowHovered: String? = nil, rowHoveredOpacity: Double? = nil,
            overlayBackdrop: String? = nil, overlayBackdropOpacity: Double? = nil,
            pillBackground: String? = nil, pillBackgroundOpacity: Double? = nil,
            shortcutKeyBackground: String? = nil, shortcutKeyBackgroundOpacity: Double? = nil,
            cardBackground: String? = nil, cardBackgroundOpacity: Double? = nil,
            cardStroke: String? = nil, cardStrokeOpacity: Double? = nil,
            textPrimary: String? = nil, textSecondary: String? = nil, textTertiary: String? = nil,
            imageIndicator: String? = nil, statusReady: String? = nil, statusWarning: String? = nil,
            gaugeUnfilled: String? = nil, gaugeUnfilledOpacity: Double? = nil
        ) {
            self.accent = accent
            self.panelFill = panelFill
            self.panelFillOpacity = panelFillOpacity
            self.tabBarBackground = tabBarBackground
            self.tabBarBackgroundOpacity = tabBarBackgroundOpacity
            self.rowSelected = rowSelected
            self.rowSelectedOpacity = rowSelectedOpacity
            self.rowHovered = rowHovered
            self.rowHoveredOpacity = rowHoveredOpacity
            self.overlayBackdrop = overlayBackdrop
            self.overlayBackdropOpacity = overlayBackdropOpacity
            self.pillBackground = pillBackground
            self.pillBackgroundOpacity = pillBackgroundOpacity
            self.shortcutKeyBackground = shortcutKeyBackground
            self.shortcutKeyBackgroundOpacity = shortcutKeyBackgroundOpacity
            self.cardBackground = cardBackground
            self.cardBackgroundOpacity = cardBackgroundOpacity
            self.cardStroke = cardStroke
            self.cardStrokeOpacity = cardStrokeOpacity
            self.textPrimary = textPrimary
            self.textSecondary = textSecondary
            self.textTertiary = textTertiary
            self.imageIndicator = imageIndicator
            self.statusReady = statusReady
            self.statusWarning = statusWarning
            self.gaugeUnfilled = gaugeUnfilled
            self.gaugeUnfilledOpacity = gaugeUnfilledOpacity
        }
    }

    struct CornerRadii: Codable, Sendable, Equatable {
        var panel: CGFloat
        var contentArea: CGFloat
        var card: CGFloat
        var tabBar: CGFloat
        var row: CGFloat
        var searchField: CGFloat
        var tabButton: CGFloat
        var pickerRow: CGFloat
        var shortcutRecordField: CGFloat
        var keyBadge: CGFloat
        var gauge: CGFloat

        static let `default` = CornerRadii(
            panel: 14, contentArea: 12, card: 10, tabBar: 10,
            row: 8, searchField: 8, tabButton: 8,
            pickerRow: 6, shortcutRecordField: 6, keyBadge: 3, gauge: 1
        )

        init(
            panel: CGFloat = Self.default.panel,
            contentArea: CGFloat = Self.default.contentArea,
            card: CGFloat = Self.default.card,
            tabBar: CGFloat = Self.default.tabBar,
            row: CGFloat = Self.default.row,
            searchField: CGFloat = Self.default.searchField,
            tabButton: CGFloat = Self.default.tabButton,
            pickerRow: CGFloat = Self.default.pickerRow,
            shortcutRecordField: CGFloat = Self.default.shortcutRecordField,
            keyBadge: CGFloat = Self.default.keyBadge,
            gauge: CGFloat = Self.default.gauge
        ) {
            self.panel = panel
            self.contentArea = contentArea
            self.card = card
            self.tabBar = tabBar
            self.row = row
            self.searchField = searchField
            self.tabButton = tabButton
            self.pickerRow = pickerRow
            self.shortcutRecordField = shortcutRecordField
            self.keyBadge = keyBadge
            self.gauge = gauge
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let d = Self.default
            panel = try container.decodeIfPresent(CGFloat.self, forKey: .panel) ?? d.panel
            contentArea = try container.decodeIfPresent(CGFloat.self, forKey: .contentArea) ?? d.contentArea
            card = try container.decodeIfPresent(CGFloat.self, forKey: .card) ?? d.card
            tabBar = try container.decodeIfPresent(CGFloat.self, forKey: .tabBar) ?? d.tabBar
            row = try container.decodeIfPresent(CGFloat.self, forKey: .row) ?? d.row
            searchField = try container.decodeIfPresent(CGFloat.self, forKey: .searchField) ?? d.searchField
            tabButton = try container.decodeIfPresent(CGFloat.self, forKey: .tabButton) ?? d.tabButton
            pickerRow = try container.decodeIfPresent(CGFloat.self, forKey: .pickerRow) ?? d.pickerRow
            shortcutRecordField = try container.decodeIfPresent(CGFloat.self, forKey: .shortcutRecordField) ?? d.shortcutRecordField
            keyBadge = try container.decodeIfPresent(CGFloat.self, forKey: .keyBadge) ?? d.keyBadge
            gauge = try container.decodeIfPresent(CGFloat.self, forKey: .gauge) ?? d.gauge
        }
    }

    struct Spacing: Codable, Sendable, Equatable {
        var panelPadding: CGFloat
        var sectionSpacing: CGFloat
        var rowHorizontalPadding: CGFloat
        var rowVerticalPadding: CGFloat
        var contentAreaPadding: CGFloat
        var rowSpacing: CGFloat

        static let `default` = Spacing(
            panelPadding: 12, sectionSpacing: 12,
            rowHorizontalPadding: 8, rowVerticalPadding: 8,
            contentAreaPadding: 10, rowSpacing: 2
        )

        init(
            panelPadding: CGFloat = Self.default.panelPadding,
            sectionSpacing: CGFloat = Self.default.sectionSpacing,
            rowHorizontalPadding: CGFloat = Self.default.rowHorizontalPadding,
            rowVerticalPadding: CGFloat = Self.default.rowVerticalPadding,
            contentAreaPadding: CGFloat = Self.default.contentAreaPadding,
            rowSpacing: CGFloat = Self.default.rowSpacing
        ) {
            self.panelPadding = panelPadding
            self.sectionSpacing = sectionSpacing
            self.rowHorizontalPadding = rowHorizontalPadding
            self.rowVerticalPadding = rowVerticalPadding
            self.contentAreaPadding = contentAreaPadding
            self.rowSpacing = rowSpacing
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let d = Self.default
            panelPadding = try container.decodeIfPresent(CGFloat.self, forKey: .panelPadding) ?? d.panelPadding
            sectionSpacing = try container.decodeIfPresent(CGFloat.self, forKey: .sectionSpacing) ?? d.sectionSpacing
            rowHorizontalPadding = try container.decodeIfPresent(CGFloat.self, forKey: .rowHorizontalPadding) ?? d.rowHorizontalPadding
            rowVerticalPadding = try container.decodeIfPresent(CGFloat.self, forKey: .rowVerticalPadding) ?? d.rowVerticalPadding
            contentAreaPadding = try container.decodeIfPresent(CGFloat.self, forKey: .contentAreaPadding) ?? d.contentAreaPadding
            rowSpacing = try container.decodeIfPresent(CGFloat.self, forKey: .rowSpacing) ?? d.rowSpacing
        }
    }

    static let `default` = Theme(
        id: "default",
        name: "Default",
        options: .default,
        colors: .default,
        cornerRadii: .default,
        spacing: .default
    )

    // MARK: - Built-in Themes

    static let moonlight = Theme(
        id: "moonlight",
        name: "Moonlight",
        options: Options(useMaterial: false, useSystemAccent: false),
        colors: Colors(
            accent: "#B4A7D6",
            panelFill: "#2D2B3D",
            panelFillOpacity: 1.0,
            tabBarBackground: "#232136",
            tabBarBackgroundOpacity: 0.6,
            rowSelected: "#B4A7D6",
            rowSelectedOpacity: 0.18,
            rowHovered: "#B4A7D6",
            rowHoveredOpacity: 0.08,
            overlayBackdrop: "#1A1829",
            overlayBackdropOpacity: 0.5,
            pillBackground: "#9590AD",
            pillBackgroundOpacity: 0.15,
            shortcutKeyBackground: "#232136",
            shortcutKeyBackgroundOpacity: 0.5,
            cardBackground: "#232136",
            cardBackgroundOpacity: 0.6,
            cardStroke: "#B4A7D6",
            cardStrokeOpacity: 0.08,
            imageIndicator: "#E0AF68",
            statusReady: "#9ECE6A",
            statusWarning: "#E0AF68",
            gaugeUnfilled: "#9590AD",
            gaugeUnfilledOpacity: 0.12
        )
    )

    static let rose = Theme(
        id: "rose",
        name: "Rose",
        options: Options(useMaterial: false, useSystemAccent: false),
        colors: Colors(
            accent: "#E8A0BF",
            panelFill: "#2A2025",
            panelFillOpacity: 1.0,
            tabBarBackground: "#231C20",
            tabBarBackgroundOpacity: 0.6,
            rowSelected: "#E8A0BF",
            rowSelectedOpacity: 0.16,
            rowHovered: "#E8A0BF",
            rowHoveredOpacity: 0.07,
            overlayBackdrop: "#1A1418",
            overlayBackdropOpacity: 0.5,
            pillBackground: "#C4909A",
            pillBackgroundOpacity: 0.14,
            shortcutKeyBackground: "#3A2A30",
            shortcutKeyBackgroundOpacity: 0.5,
            cardBackground: "#231C20",
            cardBackgroundOpacity: 0.6,
            cardStroke: "#E8A0BF",
            cardStrokeOpacity: 0.08,
            imageIndicator: "#F0C987",
            statusReady: "#A8D8A8",
            statusWarning: "#F0C987",
            gaugeUnfilled: "#8A7580",
            gaugeUnfilledOpacity: 0.15
        )
    )

    static let nord = Theme(
        id: "nord",
        name: "Nord",
        options: Options(useMaterial: false, useSystemAccent: false),
        colors: Colors(
            accent: "#88C0D0",
            panelFill: "#2E3440",
            panelFillOpacity: 1.0,
            tabBarBackground: "#272C36",
            tabBarBackgroundOpacity: 0.6,
            rowSelected: "#88C0D0",
            rowSelectedOpacity: 0.16,
            rowHovered: "#88C0D0",
            rowHoveredOpacity: 0.07,
            overlayBackdrop: "#1D2128",
            overlayBackdropOpacity: 0.55,
            pillBackground: "#7B88A0",
            pillBackgroundOpacity: 0.14,
            shortcutKeyBackground: "#272C36",
            shortcutKeyBackgroundOpacity: 0.5,
            cardBackground: "#272C36",
            cardBackgroundOpacity: 0.6,
            cardStroke: "#88C0D0",
            cardStrokeOpacity: 0.06,
            imageIndicator: "#EBCB8B",
            statusReady: "#A3BE8C",
            statusWarning: "#EBCB8B",
            gaugeUnfilled: "#616E88",
            gaugeUnfilledOpacity: 0.2
        ),
        cornerRadii: CornerRadii(
            panel: 12, contentArea: 10, card: 8, tabBar: 8,
            row: 6, searchField: 6, tabButton: 6,
            pickerRow: 5, shortcutRecordField: 5, keyBadge: 3, gauge: 1
        )
    )

    static let emerald = Theme(
        id: "emerald",
        name: "Emerald",
        options: Options(useMaterial: false, useSystemAccent: false),
        colors: Colors(
            accent: "#50C878",
            panelFill: "#1A2420",
            panelFillOpacity: 1.0,
            tabBarBackground: "#15201C",
            tabBarBackgroundOpacity: 0.6,
            rowSelected: "#50C878",
            rowSelectedOpacity: 0.15,
            rowHovered: "#50C878",
            rowHoveredOpacity: 0.07,
            overlayBackdrop: "#0E1612",
            overlayBackdropOpacity: 0.55,
            pillBackground: "#6B8F7A",
            pillBackgroundOpacity: 0.16,
            shortcutKeyBackground: "#15201C",
            shortcutKeyBackgroundOpacity: 0.5,
            cardBackground: "#15201C",
            cardBackgroundOpacity: 0.6,
            cardStroke: "#50C878",
            cardStrokeOpacity: 0.06,
            imageIndicator: "#E0AF68",
            statusReady: "#50C878",
            statusWarning: "#E0AF68",
            gaugeUnfilled: "#5A7A68",
            gaugeUnfilledOpacity: 0.18
        )
    )

    static let neonNoir = Theme(
        id: "neon-noir",
        name: "Neon Noir",
        options: Options(useMaterial: false, useSystemAccent: false),
        colors: Colors(
            accent: "#FF2D6F",
            panelFill: "#0D0D12",
            panelFillOpacity: 1.0,
            tabBarBackground: "#08080C",
            tabBarBackgroundOpacity: 0.7,
            rowSelected: "#FF2D6F",
            rowSelectedOpacity: 0.18,
            rowHovered: "#FF2D6F",
            rowHoveredOpacity: 0.08,
            overlayBackdrop: "#000000",
            overlayBackdropOpacity: 0.65,
            pillBackground: "#FF2D6F",
            pillBackgroundOpacity: 0.12,
            shortcutKeyBackground: "#FF2D6F",
            shortcutKeyBackgroundOpacity: 0.08,
            cardBackground: "#08080C",
            cardBackgroundOpacity: 0.7,
            cardStroke: "#FF2D6F",
            cardStrokeOpacity: 0.12,
            imageIndicator: "#00E5FF",
            statusReady: "#00E676",
            statusWarning: "#FFD600",
            gaugeUnfilled: "#FF2D6F",
            gaugeUnfilledOpacity: 0.1
        ),
        cornerRadii: CornerRadii(
            panel: 10, contentArea: 8, card: 6, tabBar: 6,
            row: 4, searchField: 4, tabButton: 4,
            pickerRow: 3, shortcutRecordField: 3, keyBadge: 2, gauge: 1
        ),
        spacing: Spacing(
            panelPadding: 10, sectionSpacing: 10,
            rowHorizontalPadding: 8, rowVerticalPadding: 6,
            contentAreaPadding: 8, rowSpacing: 1
        )
    )

    static let vapor = Theme(
        id: "vapor",
        name: "Vapor",
        options: Options(useMaterial: false, useSystemAccent: false),
        colors: Colors(
            accent: "#FF71CE",
            panelFill: "#1A1028",
            panelFillOpacity: 1.0,
            tabBarBackground: "#140C22",
            tabBarBackgroundOpacity: 0.6,
            rowSelected: "#FF71CE",
            rowSelectedOpacity: 0.15,
            rowHovered: "#B967FF",
            rowHoveredOpacity: 0.1,
            overlayBackdrop: "#0D0818",
            overlayBackdropOpacity: 0.6,
            pillBackground: "#B967FF",
            pillBackgroundOpacity: 0.14,
            shortcutKeyBackground: "#B967FF",
            shortcutKeyBackgroundOpacity: 0.08,
            cardBackground: "#140C22",
            cardBackgroundOpacity: 0.6,
            cardStroke: "#B967FF",
            cardStrokeOpacity: 0.1,
            imageIndicator: "#05FFA1",
            statusReady: "#05FFA1",
            statusWarning: "#FFFB96",
            gaugeUnfilled: "#B967FF",
            gaugeUnfilledOpacity: 0.12
        ),
        cornerRadii: CornerRadii(
            panel: 16, contentArea: 14, card: 12, tabBar: 12,
            row: 10, searchField: 10, tabButton: 10,
            pickerRow: 8, shortcutRecordField: 8, keyBadge: 4, gauge: 2
        )
    )

    static let macOSLight = Theme(
        id: "macos-light",
        name: "macOS Light",
        options: Options(useMaterial: true, useSystemAccent: true, appearance: "light"),
        colors: Colors(
            panelFill: "#FFFFFF",
            panelFillOpacity: 0.92,
            tabBarBackground: "#000000",
            tabBarBackgroundOpacity: 0.04,
            rowSelected: nil,
            rowSelectedOpacity: 0.12,
            rowHovered: nil,
            rowHoveredOpacity: 0.06,
            overlayBackdrop: "#000000",
            overlayBackdropOpacity: 0.12,
            pillBackground: nil,
            pillBackgroundOpacity: 0.08,
            shortcutKeyBackground: "#000000",
            shortcutKeyBackgroundOpacity: 0.04,
            cardBackground: "#000000",
            cardBackgroundOpacity: 0.04,
            cardStroke: "#000000",
            cardStrokeOpacity: 0.06,
            imageIndicator: "#FF9500",
            statusReady: "#34C759",
            statusWarning: "#FF9500",
            gaugeUnfilled: nil,
            gaugeUnfilledOpacity: 0.1
        )
    )

    static let builtInThemes: [Theme] = [
        .default, .macOSLight, .moonlight, .rose, .nord, .emerald, .neonNoir, .vapor,
    ]

    init(
        id: String = Self.default.id,
        name: String = Self.default.name,
        options: Options = .default,
        colors: Colors = .default,
        cornerRadii: CornerRadii = .default,
        spacing: Spacing = .default
    ) {
        self.id = id
        self.name = name
        self.options = options
        self.colors = colors
        self.cornerRadii = cornerRadii
        self.spacing = spacing
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        options = try container.decodeIfPresent(Options.self, forKey: .options) ?? .default
        colors = try container.decodeIfPresent(Colors.self, forKey: .colors) ?? .default
        cornerRadii = try container.decodeIfPresent(CornerRadii.self, forKey: .cornerRadii) ?? .default
        spacing = try container.decodeIfPresent(Spacing.self, forKey: .spacing) ?? .default
    }
}

// MARK: - Hex Color Parsing

extension Color {
    init?(hex: String?) {
        guard let hex else { return nil }
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }

        var rgb: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&rgb) else { return nil }

        switch cleaned.count {
        case 6:
            self.init(
                red: Double((rgb >> 16) & 0xFF) / 255.0,
                green: Double((rgb >> 8) & 0xFF) / 255.0,
                blue: Double(rgb & 0xFF) / 255.0
            )
        case 8:
            self.init(
                red: Double((rgb >> 24) & 0xFF) / 255.0,
                green: Double((rgb >> 16) & 0xFF) / 255.0,
                blue: Double((rgb >> 8) & 0xFF) / 255.0,
                opacity: Double(rgb & 0xFF) / 255.0
            )
        default:
            return nil
        }
    }
}

// MARK: - Appearance

extension Theme {
    var colorScheme: ColorScheme? {
        switch options.appearance {
        case "light": .light
        case "dark": .dark
        default: nil
        }
    }
}

// MARK: - Resolved Color Accessors

extension Theme {
    var resolvedAccent: Color {
        if options.useSystemAccent { return .accentColor }
        return Color(hex: colors.accent) ?? .accentColor
    }

    var resolvedPanelFill: Color {
        let base = Color(hex: colors.panelFill) ?? Color(nsColor: .controlBackgroundColor)
        return base.opacity(colors.panelFillOpacity ?? 0.85)
    }

    var resolvedTabBarBackground: Color {
        let base = Color(hex: colors.tabBarBackground) ?? .black
        return base.opacity(colors.tabBarBackgroundOpacity ?? 0.05)
    }

    var resolvedRowSelected: Color {
        let base = Color(hex: colors.rowSelected) ?? resolvedAccent
        return base.opacity(colors.rowSelectedOpacity ?? 0.18)
    }

    var resolvedRowHovered: Color {
        let base = Color(hex: colors.rowHovered) ?? resolvedAccent
        return base.opacity(colors.rowHoveredOpacity ?? 0.09)
    }

    var resolvedOverlayBackdrop: Color {
        let base = Color(hex: colors.overlayBackdrop) ?? .black
        return base.opacity(colors.overlayBackdropOpacity ?? 0.15)
    }

    var resolvedPillBackground: Color {
        let base = Color(hex: colors.pillBackground) ?? .secondary
        return base.opacity(colors.pillBackgroundOpacity ?? 0.12)
    }

    var resolvedShortcutKeyBackground: Color {
        let base = Color(hex: colors.shortcutKeyBackground) ?? .black
        return base.opacity(colors.shortcutKeyBackgroundOpacity ?? 0.06)
    }

    var resolvedCardBackground: Color {
        let base = Color(hex: colors.cardBackground) ?? .black
        return base.opacity(colors.cardBackgroundOpacity ?? 0.15)
    }

    var resolvedCardStroke: Color {
        let base = Color(hex: colors.cardStroke) ?? .white
        return base.opacity(colors.cardStrokeOpacity ?? 0.08)
    }

    var resolvedTextPrimary: Color {
        Color(hex: colors.textPrimary) ?? .primary
    }

    var resolvedTextSecondary: Color {
        Color(hex: colors.textSecondary) ?? .secondary
    }

    var resolvedTextTertiary: Color {
        Color(hex: colors.textTertiary) ?? Color(nsColor: .tertiaryLabelColor)
    }

    var resolvedImageIndicator: Color {
        Color(hex: colors.imageIndicator) ?? .orange
    }

    var resolvedStatusReady: Color {
        Color(hex: colors.statusReady) ?? Color(nsColor: .systemGreen)
    }

    var resolvedStatusWarning: Color {
        Color(hex: colors.statusWarning) ?? Color(nsColor: .systemOrange)
    }

    var resolvedGaugeUnfilled: Color {
        let base = Color(hex: colors.gaugeUnfilled) ?? .secondary
        return base.opacity(colors.gaugeUnfilledOpacity ?? 0.15)
    }
}
