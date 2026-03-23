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

extension ProfileChooserFeature {
    protocol ViewDelegate {
        func onDismiss()
        func onProfileSelected(_ profile: ProfileDto)
    }

    struct View: SwiftUI.View {
        @ObservedObject var state: ViewState
        let delegate: ViewDelegate?

        var body: some SwiftUI.View {
            SuplaCore.Dialog.Base(onDismiss: { delegate?.onDismiss() }) {
                SuplaCore.Dialog.Header(title: Strings.ProfileChooser.title)
                
                if (state.profiles.count < 10) {
                    ProfilesList()
                } else {
                    ScrollView {
                        ProfilesList()
                    }
                    .frame(height: 315)
                }
                
                Spacer().frame(height: Distance.small)
            }
        }

        private func ProfilesList() -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: 1) {
                ForEach(state.profiles) { profile in
                    ProfileRow(profile)
                        .contentShape(Rectangle())
                        .onTapGesture { delegate?.onProfileSelected(profile) }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing], Distance.default)
                .padding([.top, .bottom], Distance.tiny)
                .background(Color.Supla.surface)
            }
            .background(Color.Supla.background)
        }
        
        private func ProfileRow(_ profile: ProfileDto) -> some SwiftUI.View {
            HStack(alignment: .center, spacing: Distance.tiny) {
                Image(profile.isActive ? String.Icons.profileActive : String.Icons.profileInactive)
                Text(profile.name)
                    .fontBodyMedium()
                    .lineLimit(1)
                Spacer()
                if (profile.isActive) {
                    Image(String.Icons.check)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: Dimens.iconSizeSmall,
                            height: Dimens.iconSizeSmall
                        )
                }
            }
        }
    }
}

#Preview("Without scrolling") {
    ProfileChooserFeature.View(
        state: ProfileChooserFeature.ViewState(
            profiles: [
                ProfileDto(id: 1, name: "Default", isActive: false),
                ProfileDto(id: 2, name: "Home", isActive: true),
                ProfileDto(id: 3, name: "Test", isActive: false)
            ]
        ),
        delegate: nil
    )
}

#Preview("Max without scrolling") {
    ProfileChooserFeature.View(
        state: ProfileChooserFeature.ViewState(
            profiles: [
                ProfileDto(id: 1, name: "Default", isActive: false),
                ProfileDto(id: 2, name: "Home", isActive: true),
                ProfileDto(id: 3, name: "Test 1", isActive: false),
                ProfileDto(id: 4, name: "Test 2", isActive: false),
                ProfileDto(id: 5, name: "Test 3", isActive: false),
                ProfileDto(id: 6, name: "Test 4", isActive: false),
                ProfileDto(id: 7, name: "Test 5", isActive: false),
                ProfileDto(id: 8, name: "Test 6", isActive: false),
                ProfileDto(id: 9, name: "Test 7", isActive: false)
            ]
        ),
        delegate: nil
    )
}

#Preview("With scrolling") {
    ProfileChooserFeature.View(
        state: ProfileChooserFeature.ViewState(
            profiles: [
                ProfileDto(id: 1, name: "Default", isActive: false),
                ProfileDto(id: 2, name: "Home", isActive: true),
                ProfileDto(id: 3, name: "Test 1", isActive: false),
                ProfileDto(id: 4, name: "Test 2", isActive: false),
                ProfileDto(id: 5, name: "Test 3", isActive: false),
                ProfileDto(id: 6, name: "Test 4", isActive: false),
                ProfileDto(id: 7, name: "Test 5", isActive: false),
                ProfileDto(id: 8, name: "Test 6", isActive: false),
                ProfileDto(id: 9, name: "Test 7", isActive: false),
                ProfileDto(id: 10, name: "Test 8", isActive: false)
            ]
        ),
        delegate: nil
    )
}
