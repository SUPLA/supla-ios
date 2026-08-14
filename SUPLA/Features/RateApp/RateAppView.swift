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

extension RateAppFeature {
    struct Dialog: View {
        @StateObject private var viewModel = ViewModel()

        var body: some View {
            if (viewModel.present) {
                SuplaCore.Dialog.Base(onDismiss: {}) {
                    SuplaCore.Dialog.Header(title: Strings.appName)

                    SuplaCore.Dialog.Content(alignment: .center) {
                        Text(Strings.RateApp.message)
                            .fontBodyMedium()
                            .textColor(.Supla.onBackground)
                            .multilineTextAlignment(.center)
                    }

                    Buttons(viewModel: viewModel)
                }
            }
        }
    }
}

private struct Buttons: View {
    @ObservedObject var viewModel: RateAppFeature.ViewModel

    var body: some View {
        VStack(spacing: Distance.tiny) {
            TitleButton(
                title: Strings.RateApp.rateNow,
                fullWidth: true,
                action: viewModel.onRateNow
            )
            .filledButtonStyle()

            TitleButton(
                title: Strings.RateApp.later,
                fullWidth: true,
                action: viewModel.onLater
            )
            .textButtonStyle(colors: .onBackground)

            TitleButton(
                title: Strings.RateApp.noThanks,
                fullWidth: true,
                action: viewModel.onNoThanks
            )
            .textButtonStyle(colors: .onBackground)
        }
        .padding(Distance.default)
    }
}

#Preview {
    RateAppFeature.Dialog()
}
