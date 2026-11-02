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

extension AddWizardFeature {
    struct InstructionStep: SwiftUI.View {
        let number: Int
        let title: String
        let message: String
        var exampleNetwork: String? = nil

        var body: some SwiftUI.View {
            HStack(alignment: .top, spacing: Distance.tiny) {
                AddWizardFeature.AddWizardStepNumber(number: number)

                VStack(alignment: .leading, spacing: Distance.tiny) {
                    Text(title)
                        .fontLabelMedium()
                    Text(.init(message))
                        .fontBodyMedium()

                    if let exampleNetwork {
                        AddWizardFeature.AddWizardWifiNotice(
                            padding: EdgeInsets(top: 4, leading: Distance.tiny, bottom: 4, trailing: Distance.tiny)
                        ) {
                            HStack(spacing: Distance.tiny) {
                                Image(String.Icons.wifi)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: Dimens.iconSizeSmall, height: Dimens.iconSizeSmall)

                                Text(exampleNetwork)
                                    .fontBodyMedium()

                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
                .padding(.top, Distance.tiny)
                .textColor(.Supla.onPrimaryContainer)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .combine)
        }
    }
}
