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

extension CaptionChangeDialogFeature {
    protocol ViewDelegate: AnyObject {
        func onCaptionChanged(_ caption: String)
        func onCaptionDialogDismiss()
        func onApply()
    }

    struct Dialog: View {
        @ObservedObject var viewState: ViewState
        let delegate: ViewDelegate?

        init(viewState: ViewState, delegate: ViewDelegate?) {
            self.viewState = viewState
            self.delegate = delegate
        }

        var body: some View {
            SuplaCore.Dialog.Base(onDismiss: { delegate?.onCaptionDialogDismiss() }) {
                SuplaCore.Dialog.Header(title: Strings.ChangeCaption.header)
                
                SuplaCore.Dialog.Content(spacing: 0) {
                    SuplaCore.Dialog.TextField(
                        value: Binding(
                            get: { viewState.caption },
                            set: { delegate?.onCaptionChanged($0) }
                        ),
                        label: viewState.label
                    )
                    
                    if let error = viewState.error {
                        SuplaCore.Dialog.FieldErrorText(error)
                    }
                }
                
                SuplaCore.Dialog.DoubleButtons(
                    onSecondaryClick: { delegate?.onCaptionDialogDismiss() },
                    onPrimaryClick: { delegate?.onApply() },
                    processing: viewState.processing
                )
            }
        }
    }
}

extension CaptionChangeDialogFeature.Dialog {
    init(viewModel: CaptionChangeDialogFeature.ViewModel) {
        self.init(viewState: viewModel.viewState, delegate: viewModel)
    }
}

#Preview {
    CaptionChangeDialogFeature.Dialog(
        viewState: CaptionChangeDialogFeature.ViewState(
            caption: "Thermostat",
            label: Strings.ChangeCaption.channelName,
            error: "Change failed!"
        ),
        delegate: nil
    )
}
