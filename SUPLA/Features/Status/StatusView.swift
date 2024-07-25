//
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

struct StatusView: View {
    @ObservedObject var viewState: StatusFeature.ViewState
    var onProfilesClick: () -> Void = {}
    var onTryAgainClick: () -> Void = {}

    var body: some View {
        BackgroundStack() {
            switch (viewState.viewType) {
            case .connecting:
                ConnectionStatusView(
                    text: viewState.stateText.text,
                    showAccountButton: viewState.stateText.showAccountButton,
                    onProfilesClick: onProfilesClick
                )
            case .error:
                ErrorStatusView(
                    errorDescription: viewState.errorDescription,
                    onTryAgainClick: onTryAgainClick,
                    onProfilesClick: onProfilesClick
                )
            }
        }
    }
}

private struct ConnectionStatusView: View {
    var text: String
    var showAccountButton: Bool
    var onProfilesClick: () -> Void = {}

    var body: some View {
        VStack(spacing: Dimens.distanceSmall) {
            Spacer()
            Image(uiImage: .logoLight!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 140)
                .foregroundColor(.Supla.primary)
            Text.BodyMedium(text: text)
            Spacer()
        }
        .padding(Dimens.distanceDefault)
        if (showAccountButton) {
            VStack {
                Spacer()
                BorderedButton(title: Strings.Profiles.Title.plural, action: onProfilesClick)
            }
            .padding(Dimens.distanceDefault)
        }
    }
}

private struct ErrorStatusView: View {
    var errorDescription: String?
    var onTryAgainClick: () -> Void = {}
    var onProfilesClick: () -> Void = {}

    var body: some View {
        VStack(spacing: Dimens.distanceSmall) {
            Spacer()
            Image(uiImage: .iconStatusError!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 140)
                .foregroundColor(.Supla.primary)
            if let text = errorDescription {
                Text.BodyMedium(text: text)
            }
            TextButton(
                title: Strings.Status.tryAgain,
                normalColor: .Supla.blue,
                pressedColor: .Supla.blue,
                action: onTryAgainClick
            )
            Spacer()
        }
        .padding(Dimens.distanceDefault)
        
        VStack {
            Spacer()
            FilledButton(title: Strings.Profiles.Title.plural, action: onProfilesClick)
        }
        .padding(Dimens.distanceDefault)
    }
}

#Preview("Connecting") {
    let viewState = StatusFeature.ViewState()
    viewState.stateText = .connecting
    
    return StatusView(viewState: viewState)
}

#Preview("Error") {
    let viewState = StatusFeature.ViewState()
    viewState.viewType = .error
    viewState.errorDescription = "Some error text"
    
    return StatusView(viewState: viewState)
}
