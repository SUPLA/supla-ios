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
    struct AddWizardSuccessView: SwiftUI.View {
        let parameters: [DeviceParameter]
        let onCancel: () -> Void
        let onBack: () -> Void
        let onNext: () -> Void
        let onAgain: () -> Void
        
        var body: some SwiftUI.View {
            AddWizardFeature.AddWizardScaffold(
                icon: .Image.AddWizard.success,
                onCancel: onCancel,
                onNext: onNext,
                onBack: onBack,
                nextButtonTitle: Strings.General.exit
            ) {
                AddWizardFeature.AddWizardContentText(text: Strings.AddWizard.done)
                
                VStack(alignment: .leading, spacing: Distance.tiny) {
                    Text(Strings.AddWizard.deviceParameters)
                        .fontBodyMedium()
                    DeviceParametersTable(rowData: parameters)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Distance.tiny)
                .background(Color.Supla.surface)
                .padding([.leading, .trailing], Distance.default)
                    
                AddWizardFeature.AddWizardContentText(text: Strings.AddWizard.doneExplanation)
                AddWizardFeature.RepeatButton(title: Strings.AddWizard.addMore, action: onAgain)
                    .padding(.top, Distance.default)
                
            }
        }
    }
}

#Preview {
    BackgroundStack(alignment: .top, color: .Supla.primaryContainer) {
        AddWizardFeature.AddWizardSuccessView(
            parameters: [
                DeviceParameter(label: Strings.AddWizard.deviceName, value: "MEW-01"),
                DeviceParameter(label: Strings.AddWizard.deviceFirmware, value: "25.07"),
                DeviceParameter(label: Strings.AddWizard.deviceMac, value: "00:00:00:00:00:00"),
                DeviceParameter(label: Strings.AddWizard.lastState, value: "Last state")
            ],
            onCancel: {},
            onBack: {},
            onNext: {},
            onAgain: {}
        )
    }
}
