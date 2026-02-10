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

extension EditTagFeature {
    protocol ViewDelegate {
        func onSubjectTypeChanged(_ type: SubjectType)
        func onSubjectChanged(_ item: ActionSelection.SubjectItem?)
        func onActionChanged(_ action: ActionId?)
        func onSave()
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        let delegate: ViewDelegate?

        var body: some SwiftUI.View {
            BackgroundStack {
                VStack {
                    ScrollView {
                        VStack(alignment: .center) {
                            LabeledBodyMedium(viewState.uuid, label: "UUID")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, Distance.small)
                                .padding([.bottom, .top], Distance.default)

                            TagNameTextField()
                                .padding(.bottom, Distance.default)

                            if let profiles = viewState.profiles, profiles.items.count > 0 {
                                if (profiles.items.count > 1) {
                                    ActionSelection.ProfilePicker(
                                        profiles: profiles
                                    )
                                    .padding(.bottom, Distance.tiny)
                                }
                                SuplaCore.SegmentedPicker(
                                    selected: $viewState.subjectType,
                                    items: SubjectType.allCases
                                )
                                .onChange(of: viewState.subjectType) { delegate?.onSubjectTypeChanged($0) }
                                .padding(.bottom, Distance.default)
                            }

                            if let subjects = viewState.subjects {
                                ActionSelection.SubjectsPicker(
                                    subjectType: viewState.subjectType,
                                    subjects: subjects,
                                    onSubjectChanged: delegate?.onSubjectChanged
                                )
                                .padding(.bottom, Distance.default)

                                if let actions = viewState.actions {
                                    ActionSelection.ActionsPicker(
                                        actions: actions,
                                        onActionChanged: delegate?.onActionChanged
                                    )
                                }
                            } else {
                                Spacer().frame(height: Distance.default)
                                EmptyListView()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], Distance.default)
                    }
                    SaveButton()
                        .padding(Distance.default)
                }
            }
        }

        @ViewBuilder
        private func TagNameTextField() -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: 4) {
                LabelText(text: Strings.Nfc.Edit.tagName)
                    .padding(.leading, Distance.small)
                TextField("", text: $viewState.tagName)
                    .fontBodyMedium()
                    .padding(Distance.small)
                    .background(Color.Supla.surface)
                    .cornerRadius(Dimens.buttonRadius)
            }
        }

        private func SaveButton() -> some SwiftUI.View {
            FilledButton(
                title: Strings.General.save,
                fullWidth: true,
                action: { delegate?.onSave() },
            )
            .disabled(viewState.saveDisabled)
        }
    }
}

#Preview("No channel") {
    let profile = ActionSelection.ProfileItem(id: 1, label: "Default")

    return EditTagFeature.View(
        viewState: EditTagFeature.ViewState(
            uuid: UUID().uuidString,
            tagName: "Living room",
            profiles: SelectableList(selected: profile, items: [profile, profile])
        ),
        delegate: nil
    )
}

#Preview("filled") {
    let profile = ActionSelection.ProfileItem(id: 1, label: "Default")
    let channel = ActionSelection.SubjectItem(id: "1", remoteId: 1, label: "Thermometer", actions: [], isLocation: false)

    return EditTagFeature.View(
        viewState: EditTagFeature.ViewState(
            uuid: UUID().uuidString,
            tagName: "Living room",
            profiles: SelectableList(selected: profile, items: [profile]),
            subjects: SelectableList(selected: channel, items: [channel]),
            actions: SelectableList(selected: .open, items: [.open])
        ),
        delegate: nil
    )
}
