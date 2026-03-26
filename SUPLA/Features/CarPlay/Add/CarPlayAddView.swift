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
    protocol Delegate {
        func onProfileChanged(_ item: ActionSelection.ProfileItem?)
        func onSubjectTypeChanged(_ type: SubjectType)
        func onSubjectChanged(_ item: ActionSelection.SubjectItem?)
        func onCaptionChanged(_ caption: String)
        func onActionChanged(_ action: ActionId?)
        func onSave()
        func onDelete()
    }

    struct View: SwiftUI.View {
        @StateObject var viewState: ViewState
        let delegate: Delegate?

        @State private var showDeleteConfirmation = false

        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                VStack(spacing: Distance.small) {
                    if let profiles = viewState.profiles {
                        if (profiles.items.count > 1) {
                            ActionSelection.ProfilePicker(
                                profiles: profiles,
                                disabled: viewState.showDelete,
                                onProfileChanged: delegate?.onProfileChanged
                            )
                        }
                        SuplaCore.SegmentedPicker(selected: $viewState.subjectType, items: SubjectType.allCases)
                            .onChange(of: viewState.subjectType) { delegate?.onSubjectTypeChanged($0) }
                            .disabled(viewState.showDelete)
                    }

                    if let subjects = viewState.subjects {
                        ActionSelection.SubjectsPicker(
                            subjectType: viewState.subjectType,
                            subjects: subjects,
                            disabled: viewState.showDelete,
                            onSubjectChanged: delegate?.onSubjectChanged
                        )
                        CaptionTextField()

                        if let actions = viewState.actions {
                            ActionSelection.ActionsPicker(
                                actions: actions,
                                disabled: viewState.showDelete,
                                onActionChanged: delegate?.onActionChanged
                            )
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
        
        @ViewBuilder
        private func CaptionTextField() -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: 4) {
                LabelText(text: Strings.CarPlay.displayName)
                    .padding(.leading, Distance.small)
                TextField("", text: $viewState.caption)
                    .fontBodyMedium()
                    .padding(Distance.small)
                    .background(Color.Supla.surface)
                    .cornerRadius(Dimens.buttonRadius)
                    .onChange(of: viewState.caption) { delegate?.onCaptionChanged($0) }
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
                action: { delegate?.onSave() }
            )
            .disabled(viewState.saveDisabled)
        }

        private func DeleteConfirmationDialog() -> some SwiftUI.View {
            SuplaCore.AlertDialog(
                header: Strings.CarPlay.deleteTitle,
                message: Strings.CarPlay.deleteMessage,
                onDismiss: { showDeleteConfirmation = false },
                primaryButtonSpec: .default(Strings.CarPlay.confirmDelete),
                secondaryButtonText: Strings.General.cancel,
                onPrimaryButtonClick: { delegate?.onDelete() },
                onSecondaryButtonClick: { showDeleteConfirmation = false }
            )
        }
    }
}

#Preview("All components") {
    let profile = ActionSelection.ProfileItem(id: 1, label: "Test")
    let location = ActionSelection.SubjectItem(id: "1", remoteId: 1, label: "Room", actions: [], icon: nil, isLocation: true)
    let subject = ActionSelection.SubjectItem(id: "2", remoteId: 2, label: "Thermostat", actions: [], icon: .suplaIcon(name: .Icons.fncThermostatDhw), isLocation: false)

    let state = CarPlayAddFeature.ViewState()
    state.profiles = SelectableList(selected: profile, items: [profile])
    state.subjects = SelectableList(selected: subject, items: [location, subject])
    state.actions = SelectableList(selected: .open, items: [.open])
    return CarPlayAddFeature.View(
        viewState: state,
        delegate: nil
    )
}

#Preview("No subjects") {
    let profile = ActionSelection.ProfileItem(id: 1, label: "Test")

    let state = CarPlayAddFeature.ViewState()
    state.profiles = SelectableList(selected: profile, items: [profile])
    return CarPlayAddFeature.View(
        viewState: state,
        delegate: nil
    )
}

#Preview("Edit") {
    let profile = ActionSelection.ProfileItem(id: 1, label: "Test")
    let subject = ActionSelection.SubjectItem(id: "1", remoteId: 1, label: "Thermostat", actions: [], icon: nil, isLocation: false)

    let state = CarPlayAddFeature.ViewState()
    state.profiles = SelectableList(selected: profile, items: [profile])
    state.subjects = SelectableList(selected: subject, items: [subject])
    state.actions = SelectableList(selected: .open, items: [.open])
    state.showDelete = true
    return CarPlayAddFeature.View(
        viewState: state,
        delegate: nil
    )
}
