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

extension LockScreenFeature {
    enum FocusedField: Hashable {
        case pin
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState

        var onPinChange: (String) -> Void = { _ in }
        var onBiometricShow: () -> Void = {}
        var onPinForgotten: () -> Void = {}

        @State private var focused: FocusedField? = nil
        @State private var lockTimeString: String? = nil

        private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

        var body: some SwiftUI.View {
            BackgroundStack {
                VStack(spacing: Dimens.distanceSmall) {
                    if (viewState.unlockAction?.showLogo == true) {
                        Image(BrandingConfiguration.LockScreen.LOGO)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 144)
                    }
                    if let message = viewState.unlockAction?.message {
                        Text.HeadlineSmall(text: message)
                    }
                    Text.BodyMedium(text: Strings.LockScreen.enterPin)
                    
                    if let timeString = lockTimeString {
                        Text.BodyLarge(text: Strings.LockScreen.pinLocked.arguments(timeString))
                    } else {
                        PinEntry(
                            pin: $viewState.pin,
                            wrongPin: $viewState.wrongPin,
                            biometricAllowed: $viewState.biometricAllowed,
                            onPinChange: onPinChange
                        )
                    }
                    
                    Spacer().frame(maxHeight: Dimens.buttonHeight)
                    TextButton(title: Strings.LockScreen.forgottenCode, action: onPinForgotten)
                    Spacer()

                    if (viewState.biometricAllowed && lockTimeString == nil) {
                        Button(action: onBiometricShow, label: { Image(uiImage: .iconFingerprint!) })
                    }
                }
                .padding(.all, Dimens.distanceDefault)
            }
            .onAppear {
                if (!viewState.biometricAllowed) {
                    focused = .pin
                }
            }
            .onReceive(timer) { time in
                if let lockedTime = viewState.lockedTime,
                   lockedTime > time.timeIntervalSince1970
                {
                    lockTimeString = formatRemaingTime(lockedTime - time.timeIntervalSince1970)
                } else {
                    lockTimeString = nil
                }
            }
        }
        
        private func formatRemaingTime(_ time: TimeInterval) -> String {
            @Singleton var formater: ValuesFormatter
            
            return formater.secondsToString(time)
        }
    }

    private struct PinEntry: SwiftUI.View {
        @Binding var pin: String
        @Binding var wrongPin: Bool
        @Binding var biometricAllowed: Bool
        
        var onPinChange: (String) -> Void = { _ in }

        @State private var focused: FocusedField? = nil

        var body: some SwiftUI.View {
            VStack {
                TextField("", text: $pin)
                    .modifier(
                        PinTextFieldModifier<FocusedField>($pin)
                            .focused($focused, equals: .pin)
                            .error(wrongPin)
                            .onChange(onPinChange)
                    )
                if (wrongPin) {
                    Text.BodySmall(text: Strings.LockScreen.wrongPin)
                        .textColor(.Supla.error)
                        .frame(height: 16)
                } else {
                    Spacer().frame(height: 16)
                }
            }
            .onAppear {
                if (!biometricAllowed) {
                    focused = .pin
                }
            }
        }
    }
}

#Preview {
    let viewState = LockScreenFeature.ViewState()
    viewState.unlockAction = .authorizeApplication
    return LockScreenFeature.View(viewState: viewState)
}

#Preview("Error") {
    let viewState = LockScreenFeature.ViewState()
    viewState.unlockAction = .turnOffPin
    viewState.wrongPin = true
    return LockScreenFeature.View(viewState: viewState)
}
