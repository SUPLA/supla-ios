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

extension PinSetupFeature {
    enum FocusedField: Hashable {
        case pin
        case secondPin
    }
    
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState

        var onPinChange: (String) -> Void = { _ in }
        var onSecondPinChange: (String) -> Void = { _ in }
        var onSave: () -> Void = {}
        var onAppear: () -> Void = {}

        var body: some SwiftUI.View {
            BackgroundStack {
                VStack {
                    Text(Strings.PinSetup.header).fontBodyMedium()
                    TextField("", text: $viewState.pin)
                        .modifier(
                            PinTextFieldModifier<FocusedField>($viewState.pin)
                                .focused($viewState.focused, equals: .pin)
                                .onChange(onPinChange)
                        )
                    Text(Strings.PinSetup.repeatPin).fontBodyMedium()
                    TextField("", text: $viewState.secondPin)
                        .modifier(
                            PinTextFieldModifier<FocusedField>($viewState.secondPin)
                                .focused($viewState.focused, equals: .secondPin)
                                .onChange(onSecondPinChange)
                                .error(viewState.errorString != nil)
                        )
                    if let errorString = viewState.errorString {
                        Text(errorString)
                            .fontBodyMedium()
                            .textColor(Color.Supla.error)
                    }
                    Spacer()
                        .frame(maxHeight: Dimens.distanceDefault)
                    if (viewState.biometricPossible) {
                        HStack {
                            Toggle(isOn: $viewState.biometricAllowed, label: {
                                Text(Strings.PinSetup.useBiometric)
                                    .fontBodyMedium()
                            })
                        }
                    } else {
                        Text(Strings.PinSetup.biometricNotEnrolled)
                            .fontBodySmall()
                            .textColor(.Supla.error)
                    }
                    Spacer()
                    FilledButton(
                        title: Strings.General.save,
                        fullWidth: true,
                        action: onSave
                    )
                    .disabled(viewState.saveDisabled)
                }
                .padding(.all, Dimens.distanceDefault)
            }
            .onAppear {
                onAppear()
            }
        }
    }
}

#Preview("Without biometrics") {
    let viewState = PinSetupFeature.ViewState()
    viewState.errorString = Strings.PinSetup.different
    return PinSetupFeature.View(viewState: viewState)
}

#Preview("View biometrics") {
    let viewState = PinSetupFeature.ViewState()
    viewState.errorString = Strings.PinSetup.different
    viewState.biometricPossible = true
    return PinSetupFeature.View(viewState: viewState)
}
