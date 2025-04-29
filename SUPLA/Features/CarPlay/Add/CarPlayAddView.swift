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

extension CarPlayAddFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState

        var onProfileChanged: (ProfileItem) -> Void
        var onSubjectTypeChanged: (SubjectType) -> Void
        var onSubjectChanged: (SubjectItem) -> Void
        var onCaptionChanged: (String) -> Void
        var onActionChanged: (CarPlayAction) -> Void
        var onSave: () -> Void
        var onDelete: () -> Void

        @State private var showDeleteConfirmation = false

        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                VStack(spacing: Distance.small) {
                    if let profiles = viewState.profiles {
                        ProfilePicker(profiles)
                        SuplaCore.SegmentedPicker(selected: $viewState.subjectType, items: SubjectType.allCases)
                            .onChange(of: viewState.subjectType) { onSubjectTypeChanged($0) }
                            .disabled(viewState.showDelete)
                    }

                    if let subjects = viewState.subjects {
                        SubjectsPicker(subjects)
                        CaptionTextField()

                        if let actions = viewState.actions {
                            ActionsPicker(actions)
                        }
                    } else {
                        Spacer().frame(height: Distance.default)
                        EmptyListView()
                    }

                    Spacer()

                    if (viewState.showDelete) {
                        DeleteButton()
                    }
                    SaveButton()
                }
                .padding(Distance.default)

                if (showDeleteConfirmation) {
                    DeleteConfirmationDialog()
                }
            }
        }

        private func ProfilePicker(_ profiles: SelectableList<ProfileItem>) -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: 4) {
                LabelText(text: Strings.General.profile)
                SuplaCore.Picker(profiles, onChange: onProfileChanged)
                    .style(.dialog)
                    .disabled(viewState.showDelete)
            }
        }
        
        private func SubjectsPicker(_ subjects: SelectableList<SubjectItem>) -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: 4) {
                LabelText(text: viewState.subjectType.name)
                SuplaCore.SubjectPicker(subjects, onChange: onSubjectChanged)
                    .disabled(viewState.showDelete)
            }
        }
        
        private func CaptionTextField() -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: 4) {
                LabelText(text: Strings.CarPlay.displayName)
                TextField("", text: $viewState.caption)
                    .fontBodyMedium()
                    .padding(Distance.small)
                    .background(Color.Supla.surface)
                    .cornerRadius(Dimens.buttonRadius)
                    .onChange(of: viewState.caption) { onCaptionChanged($0) }
            }
        }
        
        private func ActionsPicker(_ actions: SelectableList<CarPlayAction>) -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: 4) {
                LabelText(text: Strings.General.action)
                SuplaCore.Picker(actions, onChange: onActionChanged)
                    .style(.dialog)
            }
        }

        private func DeleteButton() -> some SwiftUI.View {
            BorderedButton(
                title: Strings.General.delete,
                fullWidth: true,
                action: { showDeleteConfirmation = true }
            )
        }
        
        private func SaveButton() -> some SwiftUI.View {
            FilledButton(
                title: Strings.General.save,
                fullWidth: true,
                action: onSave
            )
            .disabled(viewState.saveDisabled)
        }

        private func DeleteConfirmationDialog() -> some SwiftUI.View {
            SuplaCore.AlertDialog(
                header: Strings.CarPlay.deleteTitle,
                message: Strings.CarPlay.deleteMessage,
                onDismiss: { showDeleteConfirmation = false },
                positiveButtonText: Strings.CarPlay.confirmDelete,
                negativeButtonText: Strings.General.cancel,
                onPositiveButtonClick: onDelete,
                onNegativeButtonClick: { showDeleteConfirmation = false }
            )
        }
    }

    private struct LabelText: SwiftUI.View {
        let text: String

        var body: some SwiftUI.View {
            Text(text)
                .textCase(.uppercase)
                .fontBodySmall()
                .textColor(.Supla.onSurfaceVariant)
                .padding(.leading, Distance.small)
        }
    }
}

#Preview("All components") {
    let profile = CarPlayAddFeature.ProfileItem(id: 1, label: "Test")
    let location = CarPlayAddFeature.SubjectItem(id: "1", remoteId: 1, label: "Room", actions: [], icon: nil, isLocation: true)
    let subject = CarPlayAddFeature.SubjectItem(id: "2", remoteId: 2, label: "Thermostat", actions: [], icon: .suplaIcon(name: .Icons.fncThermostatDhw), isLocation: false)

    let state = CarPlayAddFeature.ViewState()
    state.profiles = SelectableList(selected: profile, items: [profile])
    state.subjects = SelectableList(selected: subject, items: [location, subject])
    state.actions = SelectableList(selected: .open, items: [.open])
    return CarPlayAddFeature.View(
        viewState: state,
        onProfileChanged: { _ in },
        onSubjectTypeChanged: { _ in },
        onSubjectChanged: { _ in },
        onCaptionChanged: { _ in },
        onActionChanged: { _ in },
        onSave: {},
        onDelete: {}
    )
}

#Preview("No subjects") {
    let profile = CarPlayAddFeature.ProfileItem(id: 1, label: "Test")

    let state = CarPlayAddFeature.ViewState()
    state.profiles = SelectableList(selected: profile, items: [profile])
    return CarPlayAddFeature.View(
        viewState: state,
        onProfileChanged: { _ in },
        onSubjectTypeChanged: { _ in },
        onSubjectChanged: { _ in },
        onCaptionChanged: { _ in },
        onActionChanged: { _ in },
        onSave: {},
        onDelete: {}
    )
}

#Preview("Edit") {
    let profile = CarPlayAddFeature.ProfileItem(id: 1, label: "Test")
    let subject = CarPlayAddFeature.SubjectItem(id: "1", remoteId: 1, label: "Thermostat", actions: [], icon: nil, isLocation: false)

    let state = CarPlayAddFeature.ViewState()
    state.profiles = SelectableList(selected: profile, items: [profile])
    state.subjects = SelectableList(selected: subject, items: [subject])
    state.actions = SelectableList(selected: .open, items: [.open])
    state.showDelete = true
    return CarPlayAddFeature.View(
        viewState: state,
        onProfileChanged: { _ in },
        onSubjectTypeChanged: { _ in },
        onSubjectChanged: { _ in },
        onCaptionChanged: { _ in },
        onActionChanged: { _ in },
        onSave: {},
        onDelete: {}
    )
}
