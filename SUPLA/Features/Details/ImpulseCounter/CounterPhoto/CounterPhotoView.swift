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
        var onRefresh: @Sendable () async -> Void = {}
        var onRetry: () -> Void = {}

        var body: some SwiftUI.View {
            BackgroundStack(alignment: .topLeading) {
                if (viewState.loading) {
                    SuplaCore.LoadingScrim()
                } else if (viewState.loadingError) {
                    ErrorView(
                        configurationAddress: viewState.configurationAddress,
                        onUrlClick: onUrlClick,
                        onRetry: onRetry
                    )
                } else {
                    DataView(
                        latestPhoto: viewState.latestPhoto,
                        photos: viewState.photos,
                        configurationAddress: viewState.configurationAddress,
                        onUrlClick: onUrlClick
                    )
                    .onRefresh {
                        await onRefresh()
                    }
                }
            }
        }
    }

    private struct DataView: SwiftUI.View {
        let latestPhoto: OcrPhoto?
        let photos: [OcrPhoto]?
        let configurationAddress: String?

        var onUrlClick: (String) -> Void = { _ in }

        var body: some SwiftUI.View {
            ScrollView {
                VStack(alignment: .leading, spacing: Distance.default) {
                    Text(Strings.CounterPhoto.counterArea)
                        .fontTitleMedium()
                        .padding([.leading, .trailing], Distance.default)
                    PhotoView(data: latestPhoto?.cropped)
                        .padding([.leading, .trailing], Distance.default)

                    Text(Strings.CounterPhoto.originalPhoto)
                        .fontTitleMedium()
                        .padding([.leading, .trailing], Distance.default)
                    PhotoView(data: latestPhoto?.original)
                        .padding([.leading, .trailing], Distance.default)

                    if let date = latestPhoto?.date {
                        HStack {
                            Spacer()
                            Text(date).fontBodyMedium()
                            Spacer()
                        }
                    }

                    Text(Strings.CounterPhoto.history).fontTitleMedium()
                        .padding([.leading, .trailing], Distance.default)
                    if let photos = photos {
                        PhotosView(photos: photos)
                    }

                    if let url = configurationAddress {
                        HStack {
                            Spacer()
                            BorderedButton(title: Strings.CounterPhoto.settings) { onUrlClick(url) }
                            Spacer()
                        }
                    }
                }
                .padding([.top, .bottom], Distance.default)
            }
        }
    }

    private struct ErrorView: SwiftUI.View {
        let configurationAddress: String?
        
        var onUrlClick: (String) -> Void = { _ in }
        var onRetry: () -> Void = {}
        
        var body: some SwiftUI.View {
            VStack(alignment: .center, spacing: Distance.default) {
                Spacer()
                Image(uiImage: .iconStatusError!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .foregroundColor(.Supla.primary)
                Text(Strings.CounterPhoto.loadingError)
                    .font(.Supla.bodyLarge)
                TextButton(
                    title: Strings.Status.tryAgain,
                    normalColor: .Supla.blue,
                    pressedColor: .Supla.blue,
                    action: onRetry
                )
                if let url = configurationAddress {
                    HStack {
                        Spacer()
                        BorderedButton(title: Strings.CounterPhoto.settings) { onUrlClick(url) }
                        Spacer()
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }

    private struct PhotoView: SwiftUI.View {
        var data: Data?

        var body: some SwiftUI.View {
            if let data,
               let image = UIImage(data: data)
            {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                HStack {
                    Spacer()
                    Image(.Icons.noPhoto)
                        .resizable()
                        .frame(width: Dimens.iconSizeVeryBig, height: Dimens.iconSizeVeryBig)
                        .foregroundColor(Color.Supla.outline)
                    Spacer()
                }
            }
        }
    }

    private struct PhotosView: SwiftUI.View {
        var photos: [OcrPhoto]

        var body: some SwiftUI.View {
            VStack(spacing: 4) {
                ForEach(photos) { PhotoRowView(photo: $0) }
            }
            .padding([.leading, .trailing], Distance.default)
            .padding([.top, .bottom], Distance.small)
            .background(Color.Supla.surface)
        }
    }

    private struct PhotoRowView: SwiftUI.View {
        var photo: OcrPhoto

        var body: some SwiftUI.View {
            HStack {
                Text(photo.date ?? "")
                    .font(.Supla.bodyMedium)
                Spacer()
                if let data = photo.cropped,
                   let image = UIImage(data: data)
                {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: Dimens.iconSize)
                }
                Spacer()
                ValueView(value: photo.value)
            }
        }
    }

    private struct ValueView: SwiftUI.View {
        var value: OcrValue

        var body: some SwiftUI.View {
            ZStack {
                Text(value.text)
                    .font(.Supla.bodyMedium)
                    .textColor(.Supla.onPrimary)
                    .padding([.top, .bottom], 4)
                    .padding([.leading, .trailing], 6)
                    .background(value.backgroundColor)
                    .cornerRadius(Dimens.radiusSmall)
            }.frame(minWidth: 90)
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

#Preview("With photo") {
    let state = CounterPhotoFeature.ViewState()
    state.latestPhoto = CounterPhotoFeature.OcrPhoto(
        id: "1",
        date: "10.02.2025 21:02",
        original: UIImage(named: .Icons.arrowClose)?.jpegData(compressionQuality: 1.0),
        cropped: UIImage(named: .Icons.arrowClose)?.jpegData(compressionQuality: 1.0),
        value: .waiting
    )
    state.photos = [
        CounterPhotoFeature.OcrPhoto(
            id: "2",
            date: "10.02.2025 21:02",
            original: nil,
            cropped: UIImage(named: .Icons.arrowClose)?.jpegData(compressionQuality: 1.0),
            value: .waiting
        )
    ]

    return CounterPhotoFeature.View(
        viewState: state
    )
}

#Preview("Without photo") {
    let state = CounterPhotoFeature.ViewState()
    state.latestPhoto = CounterPhotoFeature.OcrPhoto(
        id: "1",
        date: "10.02.2025 21:02",
        original: nil,
        cropped: nil,
        value: .waiting
    )
    state.photos = [
        CounterPhotoFeature.OcrPhoto(
            id: "2",
            date: "10.02.2025 21:02",
            original: nil,
            cropped: UIImage(named: .Icons.arrowClose)?.jpegData(compressionQuality: 1.0),
            value: .waiting
        ),
        CounterPhotoFeature.OcrPhoto(
            id: "3",
            date: "10.02.2025 21:02",
            original: nil,
            cropped: UIImage(named: .Icons.arrowClose)?.jpegData(compressionQuality: 1.0),
            value: .error
        ),
        CounterPhotoFeature.OcrPhoto(
            id: "4",
            date: "10.02.2025 21:02",
            original: nil,
            cropped: UIImage(named: .Icons.arrowClose)?.jpegData(compressionQuality: 1.0),
            value: .warning(value: "123456")
        ),
        CounterPhotoFeature.OcrPhoto(
            id: "5",
            date: "10.02.2025 21:02",
            original: nil,
            cropped: UIImage(named: .Icons.arrowClose)?.jpegData(compressionQuality: 1.0),
            value: .success(value: "123456")
        )
    ]

    return CounterPhotoFeature.View(
        viewState: state
    )
}

#Preview("Error") {
    let state = CounterPhotoFeature.ViewState()
    state.loadingError = true

    return CounterPhotoFeature.View(
        viewState: state
    )
}
