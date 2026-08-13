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

struct ImpulseCounterDetailFeature {}

extension ImpulseCounterDetailFeature {
    struct Screen: SwiftUI.View {
        @EnvironmentObject private var router: AppRouter

        let item: ItemBundle
        let pages: [DetailPage]

        @StateObject private var viewModel: ImpulseCounterDetailVM
        
        init(item: ItemBundle, pages: [DetailPage]) {
            self.item = item
            self.pages = pages
            self._viewModel = StateObject(wrappedValue: ImpulseCounterDetailVM(item: item))
        }

        var body: some SwiftUI.View {
            DetailBaseFeature.BaseScreen(
                viewModel: viewModel,
                item: item,
                pages: pages,
                topBarActionProvider: topBarAction(state:page:)
            )
        }

        private func topBarAction(
            state: ImpulseCounterDetailViewState,
            page: DetailPage
        ) -> SuplaCore.TopBar.ActionIcon? {
            guard state.hasPhoto, let channelId = state.channelId else { return nil }
            return .icon(String.Icons.ocrPhoto, { router.navigate(to: .counterPhoto(item: item)) })
        }
    }
}
