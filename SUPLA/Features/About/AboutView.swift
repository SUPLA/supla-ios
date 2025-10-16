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

extension AboutFeature {
    
    protocol ViewDelegate {
        func onHomePageClicked()
        func onBuildTimeClicked()
    }
    
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        let delegate: ViewDelegate?
        
        var body: some SwiftUI.View {
            BackgroundStack {
                ZStack {
                    VStack(spacing: Dimens.distanceDefault) {
                        Spacer()
                        Image(BrandingConfiguration.About.LOGO)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 100)
                            .foregroundColor(BrandingConfiguration.About.COLOR_FILLER)
                        Text(Strings.appName).fontHeadlineLarge()
                        Text(Strings.About.version.arguments(viewState.version)).fontBodyMedium()
                        if (BrandingConfiguration.SHOW_LICENCE) {
                            Text(Strings.About.license)
                                .fontLabelSmall()
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                        TextButton(
                            title: Strings.About.address,
                            normalColor: Color.Supla.onBackground,
                            action: { delegate?.onHomePageClicked() }
                        )
                        if let buildTime = viewState.buildTime {
                            Text(Strings.About.buildTime.arguments(buildTime))
                                .fontBodySmall()
                                .onTapGesture { delegate?.onBuildTimeClicked() }
                        }
                    }
                    .padding(.all, Dimens.distanceDefault)
                    
                    if (viewState.showToast) {
                        ToastView(message: Strings.DeveloperInfo.activated)
                            .padding(.bottom, Distance.default)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                }
            }
        }
    }
}

struct ToastView: View {
    let message: String
    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(Dimens.radiusDefault)
            .transition(.opacity)
    }
}


#Preview {
    let viewState = AboutFeature.ViewState()
    viewState.version = "24.06"
    viewState.buildTime = "08.07.2024 12:16"
    return AboutFeature.View(viewState: viewState, delegate: nil)
}
