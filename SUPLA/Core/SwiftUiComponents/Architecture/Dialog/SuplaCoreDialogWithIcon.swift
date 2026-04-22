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

extension SuplaCore {
    
    struct DialogWithIcon: View {
        let header: String
        let message: String
        let iconType: Icon.OnCircle.IconType
        let onDismiss: () -> Void
        let primaryButtonData: SuplaCore.Dialog.ButtonData?
        let secondaryButtonText: String?
        let onPrimaryButtonClick: (() -> Void)?
        let onSecondaryButtonClick: (() -> Void)?
        
        init(
            header: String,
            message: String,
            iconType: Icon.OnCircle.IconType,
            onDismiss: @escaping () -> Void,
            primaryButtonData: SuplaCore.Dialog.ButtonData? = nil,
            secondaryButtonText: String? = nil,
            onPrimaryButtonClick: (() -> Void)? = nil,
            onSecondaryButtonClick: (() -> Void)? = nil
        ) {
            self.header = header
            self.message = message
            self.iconType = iconType
            self.onDismiss = onDismiss
            self.primaryButtonData = primaryButtonData
            self.secondaryButtonText = secondaryButtonText
            self.onPrimaryButtonClick = onPrimaryButtonClick
            self.onSecondaryButtonClick = onSecondaryButtonClick
        }
        
        var body: some View {
            SuplaCore.Dialog.Base(onDismiss: onDismiss) {
                
                Icon.OnCircle.View(type: iconType)
                    .padding(.top, Distance.default)
                
                SuplaCore.Dialog.Header(title: header)
                    
                SwiftUI.Text(message)
                    .fontBodyMedium()
                    .textColor(.Supla.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], Distance.default)
                    
                if let primaryButtonData, let secondaryButtonText {
                    SuplaCore.Dialog.DoubleButtons(
                        onSecondaryClick: onSecondaryButtonClick ?? {},
                        onPrimaryClick: onPrimaryButtonClick ?? {},
                        secondaryText: secondaryButtonText,
                        primaryButtonData: primaryButtonData
                    )
                } else if let primaryButtonData {
                    TitleButton(title: primaryButtonData.title, fullWidth: primaryButtonData.fullWidth) {
                        if let onPrimaryButtonClick {
                            onPrimaryButtonClick()
                        }
                    }
                    .filledButtonStyle(colors: primaryButtonData.colors)
                    .padding(Distance.default)
                } else if let secondaryButtonText {
                    TitleButton(title: secondaryButtonText, fullWidth: true) {
                        if let onSecondaryButtonClick {
                            onSecondaryButtonClick()
                        }
                    }
                    .borderedButtonStyle()
                    .padding(Distance.default)
                }
            }
        }
    }
}

#Preview("Info") {
    SuplaCore.DialogWithIcon(
        header: Strings.CarPlay.deleteTitle,
        message: Strings.CarPlay.deleteMessage,
        iconType: .info,
        onDismiss: {},
        primaryButtonData: .default(Strings.CarPlay.confirmDelete),
        secondaryButtonText: Strings.General.cancel
    )
}

#Preview("Warning") {
    SuplaCore.DialogWithIcon(
        header: Strings.CarPlay.deleteTitle,
        message: Strings.CarPlay.deleteMessage,
        iconType: .warning,
        onDismiss: {},
        primaryButtonData: .default(Strings.CarPlay.confirmDelete),
        secondaryButtonText: Strings.General.cancel
    )
}


#Preview("Error") {
    SuplaCore.DialogWithIcon(
        header: Strings.CarPlay.deleteTitle,
        message: Strings.CarPlay.deleteMessage,
        iconType: .error,
        onDismiss: {},
        primaryButtonData: .default(Strings.CarPlay.confirmDelete),
        secondaryButtonText: Strings.General.cancel
    )
}

