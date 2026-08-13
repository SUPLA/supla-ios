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

struct LegacyDimmerSettingsScreen: View {
    @StateObject private var holder: ControllerHolder

    init(channelId: Int32) {
        self._holder = StateObject(wrappedValue: ControllerHolder(channelId: channelId))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.Supla.primaryContainer
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                SuplaCore.TopBar(
                    navigationIcon: .back,
                    title: "Dimmer settings".toLocalized(),
                    onNavigationIconTap: holder.viewController.handleBack
                )

                SuplaCore.ViewControllerHost {
                    holder.viewController.navigationBarMaintainedByParent = true
                    return holder.viewController
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private extension LegacyDimmerSettingsScreen {
    final class ControllerHolder: ObservableObject {
        let viewController: LegacyDimmerSettingsVC

        init(channelId: Int32) {
            self.viewController = LegacyDimmerSettingsVC(remoteId: channelId)
        }
    }
}
