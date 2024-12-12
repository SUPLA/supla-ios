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

extension CounterPhotoFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        
        var onUrlClick: (String) -> Void = { _ in }
        var onRefresh: @Sendable () async -> Void = { }

        var body: some SwiftUI.View {
            BackgroundStack(alignment: .topLeading) {
                ScrollView {
                    VStack(alignment: .leading, spacing: Distance.default) {
                        if let imageCropped = viewState.imageCropped,
                           let uiImageCropped = UIImage(data: imageCropped)
                        {
                            Text(Strings.CounterPhoto.counterArea).fontTitleMedium()
                            Image(uiImage: uiImageCropped)
                                .resizable()
                                .scaledToFit()
                        }
                        if let image = viewState.image,
                           let uiImage = UIImage(data: image)
                        {
                            Text(Strings.CounterPhoto.originalPhoto).fontTitleMedium()
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        }
                        if let date = viewState.date {
                            HStack {
                                Spacer()
                                Text(date).fontBodyMedium()
                                Spacer()
                            }
                        }
                        if let url = viewState.configurationAddress {
                            HStack {
                                Spacer()
                                BorderedButton(title: Strings.CounterPhoto.settings) { onUrlClick(url) }
                                Spacer()
                            }
                        }
                    }
                    .padding(Distance.default)
                }
                .onRefresh {
                    await onRefresh()
                }
            }
        }
    }
}

extension View {
    func onRefresh(_ action: @Sendable @escaping () async -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return refreshable(action: action)
        } else {
            return self
        }
    }
}

#Preview {
    let state = CounterPhotoFeature.ViewState()
    state.imageCropped = UIImage(named: .Icons.arrowClose)?.jpegData(compressionQuality: 1.0)
    state.image = UIImage(named: .Icons.arrowClose)?.jpegData(compressionQuality: 1.0)
    state.configurationAddress = "test"
    return CounterPhotoFeature.View(
        viewState: state
    )
}
