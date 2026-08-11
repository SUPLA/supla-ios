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

extension LightSourceLifespanSettingsFeature {
    struct DialogView: View {
        @ObservedObject var viewModel: ViewModel

        var body: some View {
            SuplaCore.Dialog.Base(onDismiss: viewModel.hide) {
                SuplaCore.Dialog.Header(title: viewModel.title)

                SuplaCore.Dialog.Content {
                    Toggle(isOn: $viewModel.resetCounter) {
                        Text(Strings.LightSourceLifespan.resetCounter)
                            .fontBodyMedium()
                            .textColor(.Supla.onBackground)
                            .multilineTextAlignment(.leading)
                    }
                    .toggleStyle(iOSCheckboxToggleStyle(color: .primary, textFirst: false))

                    SuplaCore.Dialog.TextField(
                        value: $viewModel.lifespan,
                        label: Strings.LightSourceLifespan.lifespan
                    )
                    .keyboardType(.numberPad)
                }

                SuplaCore.Dialog.DoubleButtons(
                    onSecondaryClick: { viewModel.hide() },
                    onPrimaryClick: { viewModel.onApply() }
                )
            }
        }
    }
}

#Preview {
    LightSourceLifespanSettingsFeature.DialogView(
        viewModel: LightSourceLifespanSettingsFeature.ViewModel(
            title: "Kitchen light",
            lifespan: 1200
        )
    )
}
