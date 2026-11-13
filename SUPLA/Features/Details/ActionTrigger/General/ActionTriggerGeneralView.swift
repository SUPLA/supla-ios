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
import SharedCore

extension ActionTriggerGeneralFeature {
    protocol ViewDelegate: OperationButtonsDelegate {
        func onLock()
        func onUnlock()
        func onAllowTemporaryUnlockChanged(_ allow: Bool)
        func onUnlockDialogDurationChange(_ duration: Int)
        func onUnlockDialogDismiss()
        func onUnlockDialogUnlock()
        func onUnlockDialogTemporaryUnlock()
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        var delegate: ViewDelegate?

        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                VStack {
                    if viewState.channelCurrentStateData != nil || !viewState.channelProgramState.isEmpty {
                        ChannelStateView(currentState: viewState.channelCurrentStateData, programState: viewState.channelProgramState)
                    }
                    Spacer()
                    if viewState.showAllowTemporaryUnlock {
                        HStack {
                            Text(Strings.ActionTrigger.allowTemporaryUnlock)
                                .fontBodyMedium()
                                .textColor(viewState.allowTemporaryUnlockDisabled ? .Supla.disabled : .Supla.onBackground)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Toggle("",isOn: Binding(
                                get: { viewState.allowTemporaryUnlock },
                                set: { delegate?.onAllowTemporaryUnlockChanged($0) }
                            ))
                            .labelsHidden()
                            .disabled(viewState.allowTemporaryUnlockDisabled)
                        }
                        .padding(.horizontal, Distance.default)
                        .padding(.vertical, Distance.small)
                        .frame(maxWidth: 612)
                    }
                    if viewState.manualAllowed || viewState.weeklyAllowed {
                        OperationButtons(
                            manualAllowed: viewState.manualAllowed,
                            manualActive: viewState.manualActive,
                            weeklyAllowed: viewState.weeklyAllowed,
                            weeklyActive: viewState.weeklyActive,
                            autoAllowed: false,
                            autoActive: false,
                            delegate: delegate
                        )
                        .padding([.leading, .trailing], Distance.default)
                        .frame(maxWidth: 612)
                        .disabled(!viewState.online)
                    }
                    
                    if viewState.showLockButtons {
                        HStack(spacing: Distance.tiny) {
                            SwitchButton(
                                state: .init(
                                    icon: .suplaIcon(name: viewState.allowTemporaryUnlock ? .Icons.unlockTemporary : .Icons.lockOpened),
                                    label: Strings.General.unlock.ucFirst(),
                                    active: viewState.unlockActive,
                                    colors: .primaryColors
                                ),
                                onClick: { delegate?.onUnlock() }
                            )
                            .disabled(!viewState.online || viewState.unlockButtonDisabled)
                            .frame(maxWidth: 300)

                            SwitchButton(
                                state: .init(
                                    icon: .suplaIcon(name: .Icons.lock),
                                    label: Strings.General.lock.ucFirst(),
                                    active: viewState.lockActive,
                                    colors: .primaryColors
                                ),
                                onClick: { delegate?.onLock() }
                            )
                            .disabled(!viewState.online || viewState.lockButtonDisabled)
                            .frame(maxWidth: 300)
                        }
                        .padding(EdgeInsets(top: Distance.small, leading: Distance.default, bottom: Distance.default, trailing: Distance.default))
                        .frame(maxWidth: 612)
                    }
                }

                if viewState.unlockDialogPresented {
                    ActionTriggerUnlockDialog(
                        durationS: viewState.unlockDialogDurationS,
                        temporaryUnlockAllowed: viewState.unlockTemporaryAllowed,
                        onDurationChange: { delegate?.onUnlockDialogDurationChange($0) },
                        onDismiss: { delegate?.onUnlockDialogDismiss() },
                        onUnlock: { delegate?.onUnlockDialogUnlock() },
                        onTemporaryUnlock: { delegate?.onUnlockDialogTemporaryUnlock() }
                    )
                }
            }
        }
    }
}

private struct ActionTriggerUnlockDialog: SwiftUI.View {
    let durationS: Int
    let temporaryUnlockAllowed: Bool
    let onDurationChange: (Int) -> Void
    let onDismiss: () -> Void
    let onUnlock: () -> Void
    let onTemporaryUnlock: () -> Void

    var body: some SwiftUI.View {
        GeometryReader { geometry in
            SuplaCore.Dialog.Base(onDismiss: onDismiss) {
                SuplaCore.Dialog.Header(title: Strings.ActionTrigger.unlockDialogTitle)
                SuplaCore.Dialog.Content(
                    spacing: 0,
                    padding: EdgeInsets(top: 0, leading: Distance.default, bottom: 0, trailing: Distance.default)
                ) {
                    LabelText(text: Strings.ActionTrigger.temporaryUnlockDuration)
                        .fontBodyMedium()
                        .textColor(.Supla.onSurfaceVariant)
                    TemporaryUnlockDurationPicker(durationS: durationS, onChange: onDurationChange)
                }
                if geometry.size.width > geometry.size.height {
                    HStack(spacing: Distance.tiny) { buttonsLandscape }
                        .padding(.horizontal, Distance.default)
                        .padding(.bottom, Distance.default)
                } else {
                    VStack(spacing: Distance.tiny) { buttonsPortrait }
                        .padding(Distance.default)
                }
            }
        }
    }

    @ViewBuilder
    private var buttonsLandscape: some SwiftUI.View {
        TitleButton(title: Strings.General.cancel, fullWidth: true, action: onDismiss)
            .textButtonStyle()
        TitleButton(title: Strings.General.unlock.ucFirst(), fullWidth: true, action: onUnlock)
            .borderedButtonStyle()
        TitleButton(title: Strings.ActionTrigger.unlockTemporarily, fullWidth: true, action: onTemporaryUnlock)
            .filledButtonStyle()
            .disabled(!temporaryUnlockAllowed)
    }
    
    @ViewBuilder
    private var buttonsPortrait: some SwiftUI.View {
        TitleButton(title: Strings.ActionTrigger.unlockTemporarily, fullWidth: true, action: onTemporaryUnlock)
            .filledButtonStyle()
            .disabled(!temporaryUnlockAllowed)
        TitleButton(title: Strings.General.unlock.ucFirst(), fullWidth: true, action: onUnlock)
            .borderedButtonStyle()
        TitleButton(title: Strings.General.cancel, fullWidth: true, action: onDismiss)
            .textButtonStyle()
    }

}

#Preview("Action trigger locked") {
    let viewState = ActionTriggerGeneralFeature.ViewState()
    viewState.channelCurrentStateData = .init(
        label: Strings.SwitchDetail.stateLabel,
        icon: nil,
        value: Strings.General.locked
    )
    viewState.manualAllowed = true
    viewState.manualActive = true
    viewState.weeklyAllowed = true
    viewState.showLockButtons = true
    viewState.lockActive = true
    viewState.unlockActive = false
    viewState.showAllowTemporaryUnlock = true
    viewState.allowTemporaryUnlock = true
    viewState.online = true

    return ActionTriggerGeneralFeature.View(viewState: viewState)
}

#Preview("Action trigger weekly schedule") {
    let viewState = ActionTriggerGeneralFeature.ViewState()
    viewState.channelProgramState = [
        .init(
            label: Strings.ThermostatDetail.programCurrent,
            description: Strings.General.locked,
            time: Strings.ThermostatDetail.programTime.arguments(
                Strings.General.time_just_minutes.arguments(12)
            )
        ),
        .init(
            label: Strings.ThermostatDetail.programNext,
            description: Strings.General.unlocked
        )
    ]
    viewState.manualAllowed = true
    viewState.weeklyAllowed = true
    viewState.weeklyActive = true
    viewState.manualActive = false
    viewState.showLockButtons = true
    viewState.lockActive = true
    viewState.unlockActive = false
    viewState.showAllowTemporaryUnlock = true
    viewState.allowTemporaryUnlock = false
    viewState.allowTemporaryUnlockDisabled = true
    viewState.online = true

    return ActionTriggerGeneralFeature.View(viewState: viewState)
}

#Preview("Action trigger unlock dialog") {
    let viewState = ActionTriggerGeneralFeature.ViewState()
    viewState.showLockButtons = true
    viewState.lockActive = true
    viewState.unlockActive = false
    viewState.showAllowTemporaryUnlock = true
    viewState.allowTemporaryUnlock = true
    viewState.unlockDialogPresented = true
    viewState.unlockDialogDurationS = 1_800
    viewState.unlockTemporaryAllowed = true
    viewState.online = true

    return ActionTriggerGeneralFeature.View(viewState: viewState)
}
