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
    
extension ProfilesListFeature {
    protocol ViewDelegate: AnyObject {
        func onNewProfile()
        func onEditProfile(_ profile: ProfileDto)
        func onActivateProfile(_ profile: ProfileDto)
        func onMoved(_ from: IndexSet, _ to: Int)
    }
    
    struct View : SwiftUI.View {
        @ObservedObject var viewState: ViewState
        weak var delegate: ViewDelegate?
        
        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(Strings.Profiles.Title.plural.uppercased())
                        .fontBodyMedium()
                        .textColor(.Supla.onSurfaceVariant)
                        .padding([.leading, .trailing, .top], Distance.default)
                    Text(Strings.Profiles.tapMessage)
                        .fontBodySmall()
                        .textColor(.Supla.onBackground)
                        .padding([.leading, .trailing, .bottom], Distance.default)
                    SwiftUI.List {
                        ForEach(viewState.items) { item in
                            ProfileRow(
                                profile: item,
                                onEdit: { delegate?.onEditProfile($0) },
                                onActivate: { delegate?.onActivateProfile($0) }
                            )
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.Supla.surface)
                        }
                        .onMove(perform: { delegate?.onMoved($0, $1) })
                        Spacer()
                            .frame(height: 60)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .environment(\.editMode, Binding.constant(EditMode.active))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .overlay(
                FloatingPlusButton(action: { delegate?.onNewProfile() }),
                alignment: .bottomTrailing
            )
        }
    }
    
    private struct ProfileRow: SwiftUI.View {
        let profile: ProfileDto
        let onEdit: (ProfileDto) -> Void
        let onActivate: (ProfileDto) -> Void
        
        var body: some SwiftUI.View {
            Button(action: { onActivate(profile) }) {
                HStack(spacing: Distance.tiny) {
                    Image(profile.isActive ? String.Icons.profileActive : String.Icons.profileInactive)
                    Text(profile.name)
                        .fontBodyMedium()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if (profile.isActive) {
                        Text(Strings.Profiles.activeIndicator)
                            .fontBodyMedium()
                            .textColor(.Supla.onSurfaceVariant)
                    }
                    EditButton(action: { onEdit(profile) })
                }
                .padding([.leading, .trailing], Distance.default)
                .padding([.top, .bottom], Distance.tiny)
                .background(Color.Supla.surface)
                .padding(.bottom, 1)
                .background(Color.Supla.background)
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct EditButton: SwiftUI.View {
        let action: () -> Void
        
        var body: some SwiftUI.View {
            Button(action: action) {
                Image(String.Icons.pencil)
                    .renderingMode(.template)
                    .foregroundColor(.Supla.primary)
            }
            .buttonStyle(.borderless)
        }
    }
    
}

#Preview {
    let state = ProfilesListFeature.ViewState()
    state.items = [
        ProfileDto(id: 1, name: "Default", isActive: true, email: ""),
        ProfileDto(id: 2, name: "Supla", isActive: false, email: ""),
        ProfileDto(id: 3, name: "Test", isActive: false, email: "")
    ]
    
    return ProfilesListFeature.View(
        viewState: state
    )
}
