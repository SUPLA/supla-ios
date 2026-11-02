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

struct EventNotificationState: Identifiable {
    let id = UUID()
    let time: Date?
    let device: String?
    let actionText: String
    let subjectIcon: IconResult
    let subjectName: String
}

struct EventNotificationOverlay: SwiftUI.View {
    let state: EventNotificationState
    let onEventRemoved: () -> Void

    @State private var progress: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State private var settledOffset: CGFloat = 0
    @State private var width: CGFloat = 0

    init(
        state: EventNotificationState,
        onEventRemoved: @escaping () -> Void = {}
    ) {
        self.state = state
        self.onEventRemoved = onEventRemoved
    }

    var body: some SwiftUI.View {
        content
            .background(widthReader)
            .offset(x: settledOffset + dragOffset)
            .gesture(dragGesture(width: width))
            .onAppear { startProgress() }
            .onChange(of: state.id) { _ in startProgress() }
    }

    private var content: some SwiftUI.View {
        VStack(spacing: Distance.small) {
            HStack(spacing: Distance.tiny) {
                state.subjectIcon.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimens.iconSize, height: Dimens.iconSize)

                Text(state.subjectName)
                    .fontLabelMedium()
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let time = state.time {
                    Text(timeFormatter.string(from: time))
                        .fontBodySmall()
                }
            }

            Text(message)
                .fontBodyMedium()
                .multilineTextAlignment(.center)
        }
        .padding(Distance.small)
        .frame(maxWidth: .infinity)
        .background(Color.Supla.surface)
        .foregroundColor(Color.Supla.onBackground)
        .overlay(alignment: .bottomLeading) {
            progressView
        }
        .clipShape(RoundedRectangle(cornerRadius: Dimens.radiusDefault))
        .overlay(
            RoundedRectangle(cornerRadius: Dimens.radiusDefault)
                .stroke(Color.Supla.outline, lineWidth: 1)
        )
        .padding(Distance.default)
    }

    private var widthReader: some SwiftUI.View {
        GeometryReader { geometry in
            Color.clear
                .onAppear { width = geometry.size.width }
                .onChange(of: geometry.size.width) { width = $0 }
        }
    }

    private var message: String {
        if let device = state.device {
            return "\(device) - \(state.actionText)"
        }

        return state.actionText
    }

    private var progressView: some SwiftUI.View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.Supla.secondary)
                .frame(width: geometry.size.width * progress, height: 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .allowsHitTesting(false)
    }

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let threshold = width / 2
                let offset = value.translation.width

                if (abs(offset) > threshold) {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        settledOffset = offset > 0 ? width : -width
                    }
                    onEventRemoved()
                } else {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        settledOffset = 0
                    }
                }
            }
    }

    private func startProgress() {
        progress = 0
        withAnimation(.linear(duration: Double(AppRootVM.NOTIFICATION_TIMEOUT_S))) {
            progress = 1
        }
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

#if DEBUG
#Preview {
    ZStack(alignment: .bottom) {
        Color.Supla.background
            .ignoresSafeArea()

        EventNotificationOverlay(
            state: .init(
                time: Date(),
                device: "HTC U11",
                actionText: "turned the power ON/OFF",
                subjectIcon: IconResult.originalSuplaIcon(name: "light-on"),
                subjectName: "Living Room"
            )
        )
    }
}
#endif
