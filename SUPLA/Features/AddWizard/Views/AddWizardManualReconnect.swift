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
    struct AddWizardManualReconnect: SwiftUI.View {
        let onCancel: () -> Void
        let onNext: () -> Void
        let onSettings: () -> Void

        var body: some SwiftUI.View {
            AddWizardFeature.AddWizardScaffold(
                icon: .Image.AddWizard.settings,
                onCancel: onCancel,
                onNext: onNext,
            ) {
                Text(Strings.AddWizard.manualReconnectTitle)
                    .fontLabelLarge()
                    .textColor(.Supla.onPrimaryContainer)
                    .padding(.horizontal, Distance.default)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: Distance.tiny) {
                    AddWizardFeature.InstructionStep(
                        number: 1,
                        title: Strings.AddWizard.manualModeStep1Title,
                        message: Strings.AddWizard.manualModeStep1Message
                    )
                    AddWizardFeature.InstructionStep(
                        number: 2,
                        title: Strings.AddWizard.manualReconnectStep2Title,
                        message: Strings.AddWizard.manualReconnectStep2Message
                    )
                    AddWizardFeature.InstructionStep(
                        number: 3,
                        title: Strings.AddWizard.manualModeStep3Title,
                        message: Strings.AddWizard.manualReconnectStep3Message
                    )
                }
                .padding(.horizontal, Distance.default)
                .padding(.top, Distance.small)
            }
        }
    }
}

#Preview {
    BackgroundStack(alignment: .top, color: .Supla.primaryContainer) {
        AddWizardFeature.AddWizardManualReconnect(
            onCancel: {},
            onNext: {},
            onSettings: {}
        )
    }
}
