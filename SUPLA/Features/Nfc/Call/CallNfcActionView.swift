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

extension CallNfcActionFeature {
    protocol ViewDelegate {
        func configureTag(_ uuid: String)
        func addTag(_ uuid: String)
        func onClose()
    }
    
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        let delegate: ViewDelegate?
        
        var body: some SwiftUI.View {
            BackgroundStack {
                VStack(spacing: 0) {
                    LogoWithSentence()
                        .padding(.bottom, Distance.default)
                    HeaderIcon()
                        .padding(.bottom, Distance.default)
                    StepContent()
                        .padding(.bottom, Distance.default)
                        
                    if let tagData = viewState.tagData {
                        TagData(tagData)
                    }
                        
                    Spacer()
                        
                    Buttons()
                }
                .padding(Distance.default)
            }
        }
        
        @ViewBuilder
        private func HeaderIcon() -> some SwiftUI.View {
            let image: String = switch (viewState.step) {
            case .processing: .Image.Nfc.scanningInProgress
            case .failure: .Image.Nfc.scanningError
            case .success: .Image.Nfc.scanningSuccess
            }
            
            ZStack(alignment: .center) {
                Circle()
                    .foregroundColor(Color.Supla.surface)
                Image(image)
            }
            .frame(width: 200, height: 200)
        }
        
        @ViewBuilder
        private func StepContent() -> some SwiftUI.View {
            switch (viewState.step) {
            case .processing: ProcessingStepContent()
            case .success:
                Text(Strings.Nfc.Call.actionSuccess)
                    .multilineTextAlignment(.center)
                    .fontTitleLarge()
            case .failure(let type): FailureInfo(type)
            }
        }
        
        @ViewBuilder
        private func ProcessingStepContent() -> some SwiftUI.View {
            Text(Strings.General.processing)
                .multilineTextAlignment(.center)
                .fontTitleLarge()
                .padding(.bottom, Distance.small)
            DotsLoadingIndicator()
        }
        
        @ViewBuilder
        private func FailureInfo(_ type: CallNfcActionFeature.FailureType) -> some SwiftUI.View {
            Text(type.title)
                .multilineTextAlignment(.center)
                .fontTitleLarge()
            Text(type.message)
                .multilineTextAlignment(.center)
                .fontBodyLarge()
        }
        
        @ViewBuilder
        private func TagData(_ data: CallNfcActionFeature.TagData) -> some SwiftUI.View {
            Text(Strings.Nfc.Call.tagName.arguments(data.name))
                .multilineTextAlignment(.center)
                .fontTitleLarge()
                .lineLimit(1)
            if let action = data.action?.name {
                Text("\(action) - \(data.subjectName)")
                    .multilineTextAlignment(.center)
                    .fontBodyLarge()
                    .lineLimit(1)
            }
        }
        
        @ViewBuilder
        private func Buttons() -> some SwiftUI.View {
            if let failureType = viewState.step.failureType {
                if let primaryActionText = failureType.primaryActionText {
                    FilledButton(
                        title: primaryActionText,
                        fullWidth: true,
                        action: {
                            switch (failureType) {
                            case .channelNotFound(let uuid): delegate?.configureTag(uuid)
                            case .tagNotConfigured(let uuid): delegate?.configureTag(uuid)
                            case .tagNotFound(let uuid): delegate?.addTag(uuid)
                            default: break
                            }
                        }
                    )
                    .padding(.bottom, Distance.default)
                }
                
                BorderedButton(
                    title: failureType.secondaryActionText,
                    fullWidth: true,
                    action: { delegate?.onClose() }
                )
            }
        }
    }
}

private let tagData = CallNfcActionFeature.TagData(
    name: "Living room door",
    action: .toggle,
    subjectName: "Living room light"
)

#Preview("Loading") {
    CallNfcActionFeature.View(
        viewState: CallNfcActionFeature.ViewState(step: .processing, tagData: tagData),
        delegate: nil
    )
}

#Preview("Success") {
    CallNfcActionFeature.View(
        viewState: CallNfcActionFeature.ViewState(step: .success, tagData: tagData),
        delegate: nil
    )
}

#Preview("Error") {
    CallNfcActionFeature.View(
        viewState: CallNfcActionFeature.ViewState(
            step: .failure(type: .actionFailed),
            tagData: tagData
        ),
        delegate: nil
    )
}
