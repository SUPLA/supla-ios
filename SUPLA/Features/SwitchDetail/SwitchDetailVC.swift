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

class SwitchDetailVC : StandardDetailVC<SwitchDetailViewState, SwitchDetailViewEvent, SwitchDetailVM> {
    
    private var navigator: SwitchDetailNavigationCoordinator? {
        get {
            navigationCoordinator as? SwitchDetailNavigationCoordinator
        }
    }
    
    init(navigator: SwitchDetailNavigationCoordinator, remoteId: Int32, pages: [DetailPage]) {
        super.init(navigator: navigator, viewModel: SwitchDetailVM(), remoteId: remoteId, pages: pages)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handle(state: SwitchDetailViewState) {
        if let title = state.title { self.title = title }
    }

    override func handle(event: SwitchDetailViewEvent) {
    }
}
