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

import Foundation

class LegacyDetailNavigationCoordinator: BaseNavigationCoordinator {
    
    private let detailType: LegacyDetailType
    private let channelBase: SAChannelBase
    
    private lazy var _viewController: DetailViewController = {
        DetailViewController(detailViewType: detailType, channelBase: channelBase)
    }()
    
    override var viewController: UIViewController { _viewController }
    
    init(detailType: LegacyDetailType, channelBase: SAChannelBase) {
        self.detailType = detailType
        self.channelBase = channelBase
    }
    
}

