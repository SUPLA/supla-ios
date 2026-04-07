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

struct AccessoryTextField<Prefix: View, Suffix: View>: View {
    @Binding var text: String

    @ViewBuilder let prefix: () -> Prefix
    @ViewBuilder let suffix: () -> Suffix

    init(
        text: Binding<String>,
        @ViewBuilder prefix: @escaping () -> Prefix = { EmptyView() },
        @ViewBuilder suffix: @escaping () -> Suffix = { EmptyView() }
    ) {
        self._text = text
        self.prefix = prefix
        self.suffix = suffix
    }

    var body: some View {
        HStack(spacing: Distance.tiny) {
            prefix()

            TextField("", text: $text)
                .fontBodyLarge()
                .textFieldStyle(.plain)
                .foregroundColor(.Supla.onBackground)

            suffix()
        }
        .padding(Distance.small)
        .background(
            RoundedRectangle(cornerRadius: Dimens.radiusDefault)
                .fill(Color.Supla.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Dimens.radiusDefault)
                .stroke(Color.Supla.grayLighter)
        )
    }
}

struct AccessoryText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .fontBodyMedium()
            .textColor(.Supla.gray)
    }
}


@available(iOS 17.0, *)
#Preview {
    BackgroundStack {
        VStack {
            AccessoryTextField(text: .constant("test"))
            AccessoryTextField(
                text: .constant("test"),
                suffix: { AccessoryText("°C") }
            )
            AccessoryTextField(
                text: .constant("test"),
                prefix: { AccessoryText("min")},
                suffix: { AccessoryText("°C") }
            )
        }
    }
    .safeAreaPadding()
}
