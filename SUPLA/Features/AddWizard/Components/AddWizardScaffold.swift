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
    struct AddWizardScaffold<Content: SwiftUI.View>: SwiftUI.View {
        let icon: String
        let onCancel: () -> Void
        let onNext: () -> Void
        let onBack: (() -> Void)?
        let nextButtonTitle: String
        let processing: Bool
        let content: () -> Content

        init(
            icon: String,
            onCancel: @escaping () -> Void,
            onNext: @escaping () -> Void,
            onBack: (() -> Void)? = nil,
            nextButtonTitle: String = Strings.General.next,
            processing: Bool = false,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.icon = icon
            self.onCancel = onCancel
            self.onNext = onNext
            self.onBack = onBack
            self.nextButtonTitle = nextButtonTitle
            self.processing = processing
            self.content = content
        }

        var body: some SwiftUI.View {
            VStack(spacing: Distance.small) {
                Header(onBack: onCancel)

                ScrollView {
                    VStack(spacing: Distance.small) {
                        Image(icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 140)

                        content()
                    }
                }

                HStack {
                    if let onBack {
                        TextButton(
                            title: Strings.General.back,
                            normalColor: .Supla.onPrimaryContainer,
                            pressedColor: .Supla.onSurfaceVariant,
                            action: onBack
                        )
                    }
                    Spacer()
                    NextButton(
                        title: nextButtonTitle,
                        processing: processing,
                        action: onNext
                    )
                }
                .padding([.top], Distance.tiny)
                .padding([.leading, .trailing, .bottom], Distance.default)
            }
        }
    }
}

private extension AddWizardFeature {
    struct Header: SwiftUI.View {
        let onBack: () -> Void

        var body: some SwiftUI.View {
            HStack {
                IconButton(
                    name: .Icons.arrowLeft,
                    color: .Supla.onPrimary,
                    action: onBack
                )
                Text(Strings.appName)
                    .fontLabelLarge()
                    .textColor(.Supla.onPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.trailing, 60)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct NextButton: SwiftUI.View {
    let title: String
    let processing: Bool
    let action: () -> Void

    var body: some SwiftUI.View {
        Button(
            action: {
                if (!processing) {
                    action()
                }
            }
        ) {
            if (processing) {
                ProcessingText()
            } else {
                HStack(alignment: .center, spacing: 4) {
                    Text(title)
                        .fontLabelLarge()
                    Image(.Icons.arrowRight)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimens.iconSizeSmall, height: Dimens.iconSizeSmall)
                        .foregroundColor(.Supla.primary)
                }
            }
        }
        .buttonStyle(
            BorderedButtonStyle(
                backgroundColor: .Supla.background,
                padding: processing ? EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24) : EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 16)
            )
        )
    }
}

private struct ProcessingText: View {
    @State private var barPosition: Int = 0
    private let totalPositions: Int = 10
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var displayedString: String {
        var characters: [String] = Array(repeating: ".", count: totalPositions)
        characters[barPosition] = "|"
        return characters.joined()
    }

    var body: some View {
        Text(displayedString)
            .fontBodySmall()
            .onReceive(timer) { _ in
                barPosition = (barPosition + 1) % totalPositions
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
    }
}

#Preview {
    BackgroundStack(alignment: .top, color: .Supla.primaryContainer) {
        AddWizardFeature.AddWizardScaffold(
            icon: .Image.AddWizard.step1,
            onCancel: {},
            onNext: {},
            onBack: {}
        ) {
            VStack {}
        }
    }
}

#Preview("Processing") {
    BackgroundStack(alignment: .top, color: .Supla.primaryContainer) {
        AddWizardFeature.AddWizardScaffold(
            icon: .Image.AddWizard.step1,
            onCancel: {},
            onNext: {},
            onBack: {},
            processing: true
        ) {
            VStack {}
        }
    }
}
