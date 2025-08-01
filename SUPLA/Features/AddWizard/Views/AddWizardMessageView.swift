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
    struct AddWizardMessageView: SwiftUI.View {
        let messages: [String]
        let action: MessageAction?
        let onCancel: () -> Void
        let onBack: () -> Void
        let onNext: () -> Void
        let onAction: (MessageAction) -> Void

        var body: some SwiftUI.View {
            AddWizardFeature.AddWizardScaffold(
                icon: .Image.AddWizard.error,
                onCancel: onCancel,
                onBack: onBack,
                onNext: onNext,
                nextButtonTitle: Strings.General.exit
            ) {
                ForEach(messages, id: \.self) { message in
                    AddWizardFeature.AddWizardContentText(text: message)
                }

                if let action {
                    switch (action) {
                    case .repeat:
                        AddWizardFeature.RepeatButton(
                            title: Strings.AddWizard.tryAgain,
                            action: { onAction(action) }
                        )
                        .padding(.top, 75)
                    case .location:
                        LocationButton(action: { onAction(action) })
                            .padding(.top, 75)
                    }
                }
            }
        }
    }

    enum MessageAction {
        case `repeat`, location
    }
}

private struct LocationButton: SwiftUI.View {
    let action: () -> Void

    var body: some SwiftUI.View {
        Button(
            action: action
        ) {
            HStack(alignment: .center, spacing: Distance.tiny) {
                Image(.Icons.locationProblem)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimens.iconSizeSmall, height: Dimens.iconSizeSmall)
                    .foregroundColor(.Supla.primary)
                Text(Strings.AddWizard.goToSettings)
                    .fontLabelLarge()
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
        AddWizardFeature.AddWizardMessageView(
            messages: [LocalizedStringId.addWizardConfigureTimeout.value],
            action: .repeat,
            onCancel: {},
            onBack: {},
            onNext: {},
            onAction: { _ in }
        )
    }
}
