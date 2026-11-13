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

import SharedCore
import SwiftUI

enum AtProgramSettings {
    protocol ViewDelegate {
        func onProgramSettingsDismiss()
        func onProgramSettingsModeChange(_ mode: SuplaButtonMode)
        func onProgramSettingsDurationOptionChange(_ option: DurationOption)
        func onProgramSettingsDurationChange(_ value: Int)
        func onProgramSettingsSave()
    }

    struct State: Equatable {
        let program: SuplaScheduleProgram
        var mode: SuplaButtonMode
        var durationOption: DurationOption
        var duration: Int
        private(set) var savedDuration: Int
        let defaultDuration: Int

        var timePickerEnabled: Bool {
            durationOption == .custom
        }

        var saveEnabled: Bool {
            mode != .lockedTemporaryUnlockAllowed || durationOption == .default || duration > 0
        }

        var selectedDuration: Int {
            if (mode == .lockedTemporaryUnlockAllowed && durationOption == .custom) {
                ActionTriggerTemporaryUnlockDuration.clamp(duration)
            } else {
                0
            }
        }

        init(
            program: SuplaScheduleProgram,
            mode: SuplaButtonMode,
            duration: Int,
            defaultDuration: Int = 0
        ) {
            self.program = program
            self.mode = mode
            self.defaultDuration = ActionTriggerTemporaryUnlockDuration.clamp(defaultDuration)
            let storedDuration = ActionTriggerTemporaryUnlockDuration.clamp(duration)
            self.savedDuration = storedDuration
            self.durationOption = storedDuration == 0 ? .default : .custom
            self.duration = storedDuration == 0 ? self.defaultDuration : storedDuration
        }

        mutating func selectDurationOption(_ option: DurationOption) {
            durationOption = option
            duration = option == .default ? defaultDuration : savedDuration
        }

        mutating func updateDuration(_ value: Int) {
            duration = ActionTriggerTemporaryUnlockDuration.clamp(value)
            if durationOption == .custom {
                savedDuration = duration
            }
        }
    }

    struct Dialog: SwiftUI.View {
        let state: State
        let delegate: ViewDelegate?

        private let modes: [SuplaButtonMode] = [.notSet, .locked, .lockedTemporaryUnlockAllowed]
        @ObservedObject private var orientationObserver = OrientationObserver()

        var body: some SwiftUI.View {
            SuplaCore.Dialog.Base(
                onDismiss: { delegate?.onProgramSettingsDismiss() },
                alignment: .leading
            ) {
                ScheduleProgramDialogHeader(program: state.program)
                if orientationObserver.orientation.isLandscape {
                    HStack(alignment: .top, spacing: Distance.small) {
                        VStack(alignment: .leading, spacing: 0) {
                            modePicker
                            if (state.mode == .lockedTemporaryUnlockAllowed) {
                                durationLabel(topPadding: Distance.small)
                                durationOptions
                            } else {
                                Spacer().frame(height: Distance.small)
                            }
                        }.frame(maxWidth: .infinity)

                        if state.mode == .lockedTemporaryUnlockAllowed {
                            durationPicker.frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, Distance.default)

                    buttons(horizontal: true)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        modePicker
                        if (state.mode == .lockedTemporaryUnlockAllowed) {
                            durationLabel(topPadding: Distance.default)
                            durationOptions
                            durationPicker
                        } else {
                            Spacer().frame(height: Distance.small)
                        }
                    }
                    .padding(.horizontal, Distance.default)

                    buttons(horizontal: false)
                }
            }
        }

        @ViewBuilder
        private var modePicker: some SwiftUI.View {
            LabelText(text: Strings.ActionTrigger.scheduleButtonMode)
                .padding(.horizontal, Distance.small)
                .padding(.bottom, Distance.tiny)

            SuplaCore.Picker(
                selected: Binding<ModePickerItem?>(
                    get: { ModePickerItem(mode: state.mode) },
                    set: { if let mode = $0 { delegate?.onProgramSettingsModeChange(mode.mode) } }
                ),
                items: modes.map(ModePickerItem.init(mode:))
            )
            .style(.dialog)
        }

        private func durationLabel(topPadding: CGFloat) -> some SwiftUI.View {
            LabelText(text: Strings.ActionTrigger.temporaryUnlockDuration)
                .padding(.horizontal, Distance.small)
                .padding(.top, topPadding)
                .padding(.bottom, Distance.tiny)
        }

        private var durationOptions: some SwiftUI.View {
            SuplaCore.SegmentedPicker(
                selected: Binding(
                    get: { state.durationOption },
                    set: { delegate?.onProgramSettingsDurationOptionChange($0) }
                ),
                items: DurationOption.allCases
            )
        }

        @ViewBuilder
        private var durationPicker: some SwiftUI.View {
            TemporaryUnlockDurationPicker(
                durationS: state.duration,
                onChange: { delegate?.onProgramSettingsDurationChange($0) }
            )
            .disabled(!state.timePickerEnabled)
            .padding(.vertical, Distance.tiny)
        }

        @ViewBuilder
        private func buttons(horizontal: Bool) -> some SwiftUI.View {
            SuplaCore.Dialog.Buttons(
                onNegativeClick: { delegate?.onProgramSettingsDismiss() },
                onPositiveClick: { delegate?.onProgramSettingsSave() },
                positiveDisabled: !state.saveEnabled,
                positiveButtonText: Strings.General.save,
                padding: buttonPadding
            )
        }

        private let buttonPadding = EdgeInsets(
            top: Distance.tiny,
            leading: Distance.default,
            bottom: Distance.default,
            trailing: Distance.default
        )
    }

    enum DurationOption: String, CaseIterable, PickerItem {
        case `default`
        case custom

        var id: String { rawValue }
        var label: String {
            switch self {
            case .default: Strings.ActionTrigger.defaultTemporaryUnlockDuration
            case .custom: Strings.ActionTrigger.customTemporaryUnlockDuration
            }
        }
    }
}

private struct ModePickerItem: PickerItem {
    let mode: SuplaButtonMode
    var id: Int32 { mode.value }
    var label: String {
        switch mode {
        case .notSet: Strings.General.unlocked
        case .locked: Strings.General.locked
        case .lockedTemporaryUnlockAllowed: Strings.ActionTrigger.lockedTemporaryUnlockAllowed
        default: NO_VALUE_TEXT
        }
    }
}

#Preview("locked temporary unlock allowed") {
    AtProgramSettings.Dialog(
        state: .init(program: .program1, mode: .lockedTemporaryUnlockAllowed, duration: 3_723, defaultDuration: 900),
        delegate: nil
    )
}

#if swift(>=5.9)
@available(iOS 17.0, *)
#Preview("locked", traits: .landscapeRight) {
    AtProgramSettings.Dialog(
        state: .init(program: .program1, mode: .locked, duration: 3_723, defaultDuration: 900),
        delegate: nil
    )
}
#endif
