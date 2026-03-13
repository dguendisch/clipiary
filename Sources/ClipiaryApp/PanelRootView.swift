import AppKit
import SwiftUI

struct PanelRootView: View {
    @Environment(AppState.self) private var appState
    @State private var hoveredItemID: HistoryItem.ID?
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .overlay(Color.black.opacity(0.04))
            historyList
            footer
        }
        .frame(width: 352, height: 492)
        .background(panelBackground)
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                searchField
                Spacer()
                iconToggle(
                    systemName: "doc.on.clipboard",
                    isOn: Binding(
                        get: { appState.settings.isClipboardMonitoringEnabled },
                        set: { appState.settings.isClipboardMonitoringEnabled = $0 }
                    ),
                    help: "Clipboard monitoring"
                )
                iconToggle(
                    systemName: "cursorarrow.rays",
                    isOn: Binding(
                        get: { appState.settings.isAutoSelectEnabled },
                        set: { appState.settings.isAutoSelectEnabled = $0 }
                    ),
                    help: "Autoselect"
                )
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: showSettings ? "slider.horizontal.3.circle.fill" : "slider.horizontal.3")
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .background(Circle().fill(buttonFill))
                .help("Settings")
            }

            if showSettings {
                settingsTray
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, showSettings ? 12 : 10)
    }

    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if appState.history.filteredItems.isEmpty {
                    emptyState
                } else {
                    ForEach(appState.history.filteredItems) { item in
                        row(for: item)
                    }
                }
            }
        }
        .background(Color(nsColor: .textBackgroundColor).opacity(0.001))
    }

    private var footer: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(Color.black.opacity(0.04))
            HStack {
                accessibilityStatus
                Spacer()
                Button("Clear") {
                    appState.history.clearUnpinned()
                }
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                Spacer()
                Text("\(appState.history.items.count) items")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 11, weight: .medium))
            }
            .buttonStyle(.plain)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }

    private var accessibilityStatus: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(appState.permissionManager.isTrusted ? Color(nsColor: .systemGreen) : Color(nsColor: .systemOrange))
                .frame(width: 6, height: 6)
            if appState.permissionManager.isTrusted {
                Text(appState.settings.isAutoSelectEnabled ? "Autoselect ready" : "Clipboard only")
                    .font(.system(size: 11, weight: .medium))
            } else {
                Button("Accessibility Required") {
                    appState.refreshAutoSelectPermissions()
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
            }
        }
        .foregroundStyle(.secondary)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            TextField("Search clipboard history", text: Binding(
                get: { appState.history.searchQuery },
                set: { appState.history.searchQuery = $0 }
            ))
            .textFieldStyle(.plain)
        }
        .padding(.horizontal, 10)
        .frame(height: 28)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(buttonFill)
        )
    }

    private var settingsTray: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Toggle("Show status text", isOn: Binding(
                    get: { appState.settings.showRecentItemInStatusBar },
                    set: { appState.settings.showRecentItemInStatusBar = $0 }
                ))
            }
            .toggleStyle(.checkbox)

            HStack(spacing: 12) {
                Stepper("Min \(appState.settings.minimumSelectionLength)", value: Binding(
                    get: { appState.settings.minimumSelectionLength },
                    set: { appState.settings.minimumSelectionLength = max(1, $0) }
                ), in: 1...10)
                Stepper("\(appState.settings.autoSelectCooldownMilliseconds) ms", value: Binding(
                    get: { appState.settings.autoSelectCooldownMilliseconds },
                    set: { appState.settings.autoSelectCooldownMilliseconds = min(max(100, $0), 2000) }
                ), in: 100...2000, step: 50)
            }

            Text("Autoselect reads focused text selection through Accessibility and falls back to Cmd-C for Anki.")
                .foregroundStyle(.secondary)
        }
        .font(.system(size: 11, weight: .medium))
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(buttonFill)
        )
    }

    private func row(for item: HistoryItem) -> some View {
        Button {
            appState.restore(item)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: item.source == .autoSelect ? "cursorarrow.rays" : "doc.on.doc")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(item.source == .autoSelect ? Color.accentColor : .secondary)
                        .frame(width: 14, alignment: .center)

                    Text(item.displayText.isEmpty ? "Untitled" : item.displayText)
                        .font(.system(size: 13))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)

                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 6) {
                    Text(item.appName)
                    Text("·")
                    Text(item.createdAt, style: .time)
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.leading, 22)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(rowBackground(for: item))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered in
            hoveredItemID = isHovered ? item.id : (hoveredItemID == item.id ? nil : hoveredItemID)
        }
        .contextMenu {
            Button(item.isPinned ? "Unpin" : "Pin") {
                appState.history.togglePin(item)
            }
            Button("Copy Back to Clipboard") {
                appState.restore(item)
            }
            Button("Delete") {
                appState.history.delete(item)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "paperclip")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.secondary)
            Text("No clipboard history yet")
                .font(.system(size: 13, weight: .medium))
            Text("Copy something, or enable autoselect to capture highlighted text.")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28)
        .padding(.vertical, 36)
    }

    private func rowBackground(for item: HistoryItem) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(hoveredItemID == item.id ? buttonFill : Color.clear)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
    }

    private func iconToggle(systemName: String, isOn: Binding<Bool>, help: String) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            Image(systemName: isOn.wrappedValue ? "\(systemName).fill" : systemName)
                .font(.system(size: 13, weight: .medium))
                .frame(width: 26, height: 26)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isOn.wrappedValue ? Color.accentColor : .secondary)
        .background(Circle().fill(buttonFill))
        .help(help)
    }

    private var panelBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
        }
        .padding(6)
    }

    private var buttonFill: Color {
        Color(nsColor: .controlBackgroundColor).opacity(0.85)
    }
}
