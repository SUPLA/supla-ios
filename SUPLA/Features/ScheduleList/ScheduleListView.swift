/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

import SwiftUI

extension ScheduleListFeature {
    protocol ViewDelegate: CaptionChangeDialogFeature.ViewDelegate, CredentialsFeature.ViewDelegate {
        func onRefresh() async
        func onTryAgain()
        func onTitleLongPress(_ item: ScheduleListItem)
        func onEnabledChanged(_ item: ScheduleListItem, enabled: Bool)
    }

    struct View: SwiftUI.View {
        @ObservedObject var state: ViewState
        let delegate: ViewDelegate?

        var body: some SwiftUI.View {
            ZStack {
                content

                if let captionChangeViewState = state.captionChangeDialogViewState {
                    CaptionChangeDialogFeature.Dialog(
                        viewState: captionChangeViewState,
                        delegate: delegate
                    )
                }
                if let credentialsViewState = state.credentialsViewState {
                    CredentialsFeature.View(
                        state: credentialsViewState,
                        delegate: delegate
                    )
                }
            }
        }

        private var content: some SwiftUI.View {
            ScrollView {
                VStack(spacing: 0) {
                    if state.loadingError {
                        MessageContent(
                            message: Strings.Status.errorUnknown,
                            buttonTitle: Strings.Status.tryAgain,
                            action: { delegate?.onTryAgain() }
                        )
                    } else if state.showsLoginRequiredMessage {
                        MessageContent(
                            message: Strings.ScheduleList.loginRequired,
                            buttonTitle: Strings.Status.tryAgain,
                            action: { delegate?.onTryAgain() }
                        )
                    } else if let items = state.items, items.isEmpty == false {
                        SettingsView.Block(items: items) { item in
                            SettingsView.Row {
                                scheduleContents(item)
                                Spacer(minLength: Distance.small)
                                scheduleToggle(item)
                            }
                        }
                    } else {
                        EmptyListView()
                            .padding(Distance.default)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Distance.tiny)
            }
            .refreshable { await delegate?.onRefresh() }
            .overlay {
                if state.loading && state.items == nil {
                    ZStack {
                        Color.Supla.loadingScrim.ignoresSafeArea()
                        ProgressView()
                            .padding(Distance.default)
                            .background(Color.Supla.surface, in: RoundedRectangle(cornerRadius: Dimens.radiusDefault))
                    }
                }
            }
        }

        private func scheduleContents(_ item: ScheduleListItem) -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.caption)
                    .fontBodyMedium()
                    .lineLimit(2)
                    .onLongPressGesture { delegate?.onTitleLongPress(item) }

                if let execution = item.lastExecution {
                    executionText(execution, label: Strings.ScheduleList.lastExecution, showsResult: true)
                }
                if let execution = item.nextExecution {
                    executionText(execution, label: Strings.ScheduleList.nextExecution, showsResult: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        @ViewBuilder
        private func executionText(_ execution: ScheduleListExecutionItem, label: String, showsResult: Bool) -> some SwiftUI.View {
            if let date = execution.date {
                HStack(spacing: Distance.tiny) {
                    Text(label.arguments(Self.timestampFormatter.string(from: date)))
                        .fontBodySmall()
                        .textColor(Color.Supla.onSurfaceVariant)

                    if showsResult, let failed = execution.failed {
                        Text(failed ? "𐄂" : "✓")
                            .fontBodySmall()
                            .foregroundColor(failed ? Color.Supla.error : Color.Supla.primary)
                    }
                }
            }
        }

        @ViewBuilder
        private func scheduleToggle(_ item: ScheduleListItem) -> some SwiftUI.View {
            if state.loading && state.updatingScheduleId == item.id {
                ProgressView()
                    .frame(width: 48, height: 32)
            } else {
                Toggle(
                    "",
                    isOn: Binding(
                        get: { item.enabled },
                        set: { delegate?.onEnabledChanged(item, enabled: $0) }
                    )
                )
                .labelsHidden()
                .tint(Color.Supla.primary)
                .disabled(state.loading)
            }
        }

        private static var timestampFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }
    }
}

private struct MessageContent: SwiftUI.View {
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some SwiftUI.View {
        VStack(spacing: Distance.default) {
            Text(message)
                .fontBodyMedium()
                .multilineTextAlignment(.center)
            TitleButton(title: buttonTitle, action: action)
                .filledButtonStyle()
        }
        .frame(maxWidth: .infinity)
        .padding(Distance.default)
    }
}

#Preview {
    let now = Date()
    let state = ScheduleListFeature.ViewState(items: [
        ScheduleListItem(
            id: 1,
            caption: "Porch light",
            userCaption: "Porch light",
            enabled: true,
            lastExecution: ScheduleListExecutionItem(date: Date(timeIntervalSinceNow: -3600), failed: false),
            nextExecution: ScheduleListExecutionItem(date: now.addingTimeInterval(3600), failed: nil)
        ),
        ScheduleListItem(
            id: 2,
            caption: "Garden irrigation",
            userCaption: "Garden irrigation",
            enabled: false,
            lastExecution: ScheduleListExecutionItem(date: Date(timeIntervalSinceNow: -86400), failed: true),
            nextExecution: nil
        )
    ])
    state.loading = false

    return ZStack {
        Color.Supla.background.ignoresSafeArea()
        ScheduleListFeature.View(state: state, delegate: nil)
    }
}

#Preview("Empty") {
    let now = Date()
    let state = ScheduleListFeature.ViewState(items: [])
    state.loading = false

    return ZStack {
        Color.Supla.background.ignoresSafeArea()
        ScheduleListFeature.View(state: state, delegate: nil)
    }
}
