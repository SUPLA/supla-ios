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
    struct AddWizardConfigurationView: SwiftUI.View {
        @Binding var autoMode: Bool
        let processing: Bool
        let onCancel: () -> Void
        let onBack: () -> Void
        let onNext: () -> Void
        
        var body: some SwiftUI.View {
            AddWizardFeature.AddWizardScaffold(
                icon: .Image.AddWizard.step3,
                onCancel: onCancel,
                onBack: onBack,
                onNext: onNext,
                nextButtonTitle: Strings.General.start.uppercased(),
                processing: processing
            ) {
                AddWizardFeature.AddWizardContentText(text: Strings.AddWizard.step3Message1)
                HStack {
                    Spacer()
                    BlinkingDot()
                }.padding([.leading, .trailing], Distance.default)
                AddWizardFeature.AddWizardContentText(text: Strings.AddWizard.step3Message2)
                AddWizardFeature.AddWizardContentText(text: Strings.AddWizard.step3Message3)
                
                Toggle(isOn: $autoMode) {
                    Text(Strings.AddWizard.autoMode)
                        .fontBodyMedium()
                        .textColor(.Supla.onPrimaryContainer)
                }
                .toggleStyle(iOSCheckboxToggleStyle(color: .onPrimaryContainer))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top], Distance.default)
                .padding(.leading, Distance.small)
            }
        }
    }
}

private struct BlinkingDot: View {
    @State private var isVisible = true
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        Circle()
            .frame(width: 20, height: 20)
            .foregroundColor(Color(UIColor(argb: 0xFF50F949)))
            .opacity(isVisible ? 1.0 : 0.0)
            .onReceive(timer) { _ in
                isVisible.toggle()
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
    }
}

#Preview {
    BackgroundStack(alignment: .top, color: .Supla.primaryContainer) {
        AddWizardFeature.AddWizardConfigurationView(
            autoMode: .constant(false),
            processing: false,
            onCancel: {},
            onBack: {},
            onNext: {}
        )
    }
}
