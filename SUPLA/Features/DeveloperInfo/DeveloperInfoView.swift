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

extension DeveloperInfoFeature {
    protocol ViewDelegate {
        func onOrientationChange(_ enabled: Bool)
        func onDevInfoChange(_ enabled: Bool)
    }
    
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        var delegate: ViewDelegate?
        
        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(Strings.DeveloperInfo.settings)
                        .fontTitleLarge()
                        .padding([.leading, .trailing, .top], Distance.default)
                        .padding(.bottom, Distance.small)
                    
                    SettingsListView {
                        SettingsItemWithCheckbox(
                            label: Strings.DeveloperInfo.screenOrientation,
                            checked: $viewState.screenRotationEnabled,
                            onChange: { delegate?.onOrientationChange($0) }
                        )
                        SettingsItemWithCheckbox(
                            label: Strings.DeveloperInfo.title,
                            checked: $viewState.developerInfoEnabled,
                            onChange: { delegate?.onDevInfoChange($0) }
                        )
                    }
                }
            }
        }
    }
}

#Preview("Empty") {
    let state = DeveloperInfoFeature.ViewState()
    return DeveloperInfoFeature.View(
        viewState: state
    )
}
