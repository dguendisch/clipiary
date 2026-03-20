import AppKit
import SwiftUI

struct SettingsView: View {
    private let cooldownOptions = [100, 200, 350, 500, 750, 1_000, 1_500, 2_000]
    private let selectionBufferOptions = [1, 2, 3, 5, 10]
    private let historyLimitOptions = [50, 100, 250, 500, 1_000, 2_500, 5_000, 10_000]

    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if !appState.permissionManager.isTrusted {
                    Button("Grant Accessibility Access") {
                        appState.refreshCopyOnSelectPermissions()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .medium))
                }

                settingsToggleRow(
                    title: "Monitor clipboard",
                    isOn: Binding(
                        get: { appState.settings.isClipboardMonitoringEnabled },
                        set: { appState.settings.isClipboardMonitoringEnabled = $0 }
                    )
                )

                settingsToggleRow(
                    title: "Move to top on paste",
                    isOn: Binding(
                        get: { appState.settings.moveToTopOnPaste },
                        set: { appState.settings.moveToTopOnPaste = $0 }
                    )
                )

                settingsToggleRow(
                    title: "Show item details",
                    isOn: Binding(
                        get: { appState.settings.showItemDetails },
                        set: { appState.settings.showItemDetails = $0 }
                    )
                )

                settingsToggleRow(
                    title: "Show app icons",
                    isOn: Binding(
                        get: { appState.settings.showAppIcons },
                        set: { appState.settings.showAppIcons = $0 }
                    )
                )

                settingsToggleRow(
                    title: "Always show search field",
                    isOn: Binding(
                        get: { appState.settings.alwaysShowSearch },
                        set: { appState.settings.alwaysShowSearch = $0 }
                    )
                )

                settingMetric(
                    title: "Show paste count bar",
                    value: nil
                ) {
                    Picker("", selection: Binding(
                        get: { appState.settings.pasteCountBarScheme },
                        set: { appState.settings.pasteCountBarScheme = $0 }
                    )) {
                        ForEach(PasteCountBarScheme.allSchemes, id: \.id) { scheme in
                            Text(scheme.label).tag(scheme.id)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(width: 130)
                }

                settingsToggleRow(
                    title: "Copy on select (globally, best effort)",
                    isOn: Binding(
                        get: { appState.settings.isCopyOnSelectEnabled },
                        set: { appState.settings.isCopyOnSelectEnabled = $0 }
                    )
                )

                settingMetric(
                    title: "Minimum selection",
                    value: "\(appState.settings.minimumSelectionLength)"
                ) {
                    Stepper("", value: Binding(
                        get: { appState.settings.minimumSelectionLength },
                        set: { appState.settings.minimumSelectionLength = max(1, $0) }
                    ), in: 1...10)
                    .labelsHidden()
                }

                settingMetric(
                    title: "Cooldown",
                    value: nil
                ) {
                    optionPicker(
                        selection: Binding(
                            get: { appState.settings.copyOnSelectCooldownMilliseconds },
                            set: { appState.settings.copyOnSelectCooldownMilliseconds = $0 }
                        ),
                        options: cooldownOptions,
                        label: { value in "\(value) ms" },
                        width: 94
                    )
                }

                settingMetric(
                    title: "Keep unused copy-on-select items",
                    value: nil
                ) {
                    optionPicker(
                        selection: Binding(
                            get: { appState.settings.copyOnSelectBufferLimit },
                            set: { appState.settings.copyOnSelectBufferLimit = $0 }
                        ),
                        options: selectionBufferOptions,
                        label: { value in "\(value)" },
                        width: 94
                    )
                }

                settingMetric(
                    title: "History limit",
                    value: nil
                ) {
                    optionPicker(
                        selection: Binding(
                            get: { appState.settings.historyLimit },
                            set: { appState.settings.historyLimit = $0 }
                        ),
                        options: historyLimitOptions,
                        label: { value in "\(value)" },
                        width: 94
                    )
                }

                settingMetric(
                    title: "Global shortcut",
                    value: appState.isRecordingShortcut ? "Press keys..." : appState.settings.globalShortcut.displayString
                ) {
                    Button(appState.isRecordingShortcut ? "Cancel" : "Record") {
                        appState.isRecordingShortcut.toggle()
                    }
                    .buttonStyle(.borderless)
                    .font(.system(size: 11, weight: .medium))
                }

                settingMetric(
                    title: "Quick paste previous",
                    value: appState.isRecordingQuickPasteShortcut ? "Press keys..." : appState.settings.quickPasteShortcut.displayString
                ) {
                    Button(appState.isRecordingQuickPasteShortcut ? "Cancel" : "Record") {
                        appState.isRecordingQuickPasteShortcut.toggle()
                    }
                    .buttonStyle(.borderless)
                    .font(.system(size: 11, weight: .medium))
                }
            }
            .padding(16)
        }
    }

    private func settingMetric<Control: View>(title: String, value: String?, @ViewBuilder control: () -> Control) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                if let value {
                    Text(value)
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            Spacer()
            control()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.001))
        )
    }

    private func settingsToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.system(size: 12))
        }
        .toggleStyle(.checkbox)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.001))
        )
    }

    private func optionPicker(
        selection: Binding<Int>,
        options: [Int],
        label: @escaping (Int) -> String,
        width: CGFloat
    ) -> some View {
        Picker("", selection: selection) {
            ForEach(options, id: \.self) { option in
                Text(label(option)).tag(option)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .frame(width: width)
    }
}

@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()

    private var window: NSWindow?

    var isVisible: Bool {
        window?.isVisible ?? false
    }

    func open() {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let settingsView = SettingsView()
            .environment(AppState.shared)

        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 380, height: 480)

        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 480),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Clipiary Settings"
        window.contentView = hostingView
        window.minSize = NSSize(width: 340, height: 300)
        window.maxSize = NSSize(width: 500, height: 800)
        window.isReleasedWhenClosed = false
        window.center()
        window.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue + 1)

        self.window = window
        window.makeKeyAndOrderFront(nil)
    }

    func close() {
        window?.close()
        window = nil
    }
}
