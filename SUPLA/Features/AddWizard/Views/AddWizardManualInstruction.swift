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
        let progress: Float
        let progressLabel: String?
        let onCancel: () -> Void
        let onBack: () -> Void
        let onNext: () -> Void

        var body: some SwiftUI.View {
            AddWizardFeature.AddWizardScaffold(
                icon: .Image.AddWizard.settings,
                onCancel: onCancel,
                onNext: onNext,
                onBack: onBack,
                nextButtonTitle: Strings.General.start.uppercased(),
                processing: processing
            ) {
                AddWizardFeature.AddWizardContentText(text: Strings.AddWizard.manualModeMessage)
                VStack(alignment: .leading, spacing: Distance.tiny) {
                    InstructionStep(
                        number: 1,
                        title: Strings.AddWizard.manualModeStep1Title,
                        message: Strings.AddWizard.manualModeStep1Message
                    )
                    InstructionStep(
                        number: 2,
                        title: Strings.AddWizard.manualModeStep2Title,
                        message: Strings.AddWizard.manualModeStep2Message,
                        exampleNetwork: Strings.AddWizard.manualModeExampleNetwork
                    )
                    InstructionStep(
                        number: 3,
                        title: Strings.AddWizard.manualModeStep3Title,
                        message: Strings.AddWizard.manualModeStep3Message
                    )
                }
                .padding(.horizontal, Distance.default)
                .padding(.top, Distance.small)
                
                if (processing) {
                    AddWizardFeature.ProgressInformationView(
                        progress: progress,
                        label: progressLabel
                    )
                    .padding([.top, .bottom], Distance.default)
                }
            }
        }
    }
}

private struct InstructionStep: SwiftUI.View {
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

#Preview {
    BackgroundStack(alignment: .top, color: .Supla.primaryContainer) {
        AddWizardFeature.AddWizardManualInstruction(
            processing: false,
            progress: 0,
            progressLabel: nil,
            onCancel: {},
            onBack: {},
            onNext: {}
        )
    }
}

#Preview("Processing") {
    BackgroundStack(alignment: .top, color: .Supla.primaryContainer) {
        AddWizardFeature.AddWizardManualInstruction(
            processing: true,
            progress: 0.2,
            progressLabel: Strings.AddWizard.statePreparing,
            onCancel: {},
            onBack: {},
            onNext: {}
        )
    }
}
