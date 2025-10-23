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
    protocol SpacesAlertDialogDelegate: AnyObject {
        func onKeepUnchanged()
        func onRemoveWhiteCharacters()
    }
    
    struct SpacesAlertDialog: SwiftUI.View {
        let networkName: String
        weak var delegate: SpacesAlertDialogDelegate?

        var body: some SwiftUI.View {
            SuplaCore.Dialog.Base(onDismiss: {}) {
                SuplaCore.Dialog.Header(title: Strings.AddWizard.spacesTitle)

                SuplaCore.Dialog.Content(alignment: .center) {
                    SpacesAlertMessage(networkName: networkName)
                }
                
                BorderedButton(
                    title: Strings.AddWizard.spacesAccept,
                    fullWidth: true,
                    action: { delegate?.onKeepUnchanged() }
                )
                .padding([.leading, .trailing], Distance.default)
                .padding([.top], Distance.small)
                
                FilledButton(
                    title: Strings.AddWizard.spacesModify,
                    fullWidth: true,
                    action: { delegate?.onRemoveWhiteCharacters() }
                )
                .padding([.leading, .trailing, .bottom], Distance.default)
                .padding([.top], Distance.small)
            }
        }
    }
    
    private struct SpacesAlertMessage: SwiftUI.View {
        let networkName: String
        
        var body: some SwiftUI.View {
            let message = Strings.AddWizard.spacesMessage.arguments(networkName)
            let networkNameTrimmed = networkName.trimmingCharacters(in: .whitespaces)
            
            let startIndex = message.range(of: networkName)?.lowerBound
            let startIndexTrimmed = message.range(of: networkNameTrimmed)?.lowerBound
            
            guard let start = startIndex else {
                return AnyView(
                    Text(message)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                )
            }
            
            var attributed = AttributedString(message)
            
            let end = message.index(start, offsetBy: networkName.count)
            let endTrimmed = startIndexTrimmed.map { message.index($0, offsetBy: networkNameTrimmed.count) }
            
            if let startTrimmed = startIndexTrimmed, start != startTrimmed {
                let rangeBefore = start..<startTrimmed
                if let attributedRange = Range(rangeBefore, in: attributed) {
                    attributed[attributedRange].backgroundColor = .red
                }
            }
            
            if let endTrimmed, end != endTrimmed {
                let rangeAfter = endTrimmed..<end
                if let attributedRange = Range(rangeAfter, in: attributed) {
                    attributed[attributedRange].backgroundColor = .red
                }
            }
            
            return AnyView(
                Text(attributed)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
            )
        }
    }
}
