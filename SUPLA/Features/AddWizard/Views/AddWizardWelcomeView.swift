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
    struct AddWizardWelcomeView: SwiftUI.View {
        let processing: Bool
        let onCancel: () -> Void
        let onBack: () -> Void
        let onNext: () -> Void

        var body: some SwiftUI.View {
            AddWizardFeature.AddWizardScaffold(
                icon: .Image.AddWizard.step1,
                onCancel: onCancel,
                onNext: onNext,
                onBack: onBack,
                processing: processing
            ) {
                AddWizardFeature.AddWizardContentText(text: Strings.AddWizard.step1Welcome)
                AddWizardFeature.AddWizardContentText(text: Strings.AddWizard.step1Continue)
                AddWizardFeature.AddWizardWifiNotice {
                    HStack(spacing: Distance.default) {
                        Image(String.Icons.wifi)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimens.iconSizeBig, height: Dimens.iconSizeBig)

                        VStack(alignment: .leading, spacing: 0) {
                            Text(Strings.AddWizard.wifiRequired)
                                .fontBodyMedium()
                            Text(Strings.AddWizard.wifiEnableInSettings)
                                .fontBodyMedium()
                        }

                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, Distance.default)
                .padding(.top, Distance.default)
            }
        }
    }
}

#Preview {
    BackgroundStack(alignment: .top, color: .Supla.primaryContainer) {
        AddWizardFeature.AddWizardWelcomeView(
            processing: false,
            onCancel: {},
            onBack: {},
            onNext: {}
        )
    }
}
