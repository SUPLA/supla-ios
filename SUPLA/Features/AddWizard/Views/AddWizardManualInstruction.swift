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
    struct AddWizardManualInstruction: SwiftUI.View {
        let processing: Bool
        let onCancel: () -> Void
        let onBack: () -> Void
        let onNext: () -> Void
        let onSettings: () -> Void

        var body: some SwiftUI.View {
            AddWizardFeature.AddWizardScaffold(
                icon: .Icons.settings,
                onCancel: onCancel,
                onBack: onBack,
                onNext: onNext,
                nextButtonTitle: Strings.General.start,
                processing: processing
            ) {
                AddWizardFeature.AddWizardContentText(text: Strings.AddWizard.manualModeMessge)

                SettingsButton(action: onSettings)
            }
        }
    }
}

private struct SettingsButton: SwiftUI.View {
    let action: () -> Void

    var body: some SwiftUI.View {
        Button(
            action: action
        ) {
            HStack(alignment: .center, spacing: Distance.tiny) {
                Image(.Icons.wifiSettings)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimens.iconSizeSmall, height: Dimens.iconSizeSmall)
                    .foregroundColor(.Supla.primary)
                Text(Strings.AddWizard.goToSettings)
                    .fontBodySmall()
            }
        }
        .buttonStyle(
            BorderedButtonStyle(
                backgroundColor: .Supla.background,
                padding: EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 24)
            )
        )
    }
}

#Preview {
    BackgroundStack(alignment: .top, color: .Supla.primaryContainer) {
        AddWizardFeature.AddWizardManualInstruction(
            processing: false,
            onCancel: {},
            onBack: {},
            onNext: {},
            onSettings: {}
        )
    }
}
