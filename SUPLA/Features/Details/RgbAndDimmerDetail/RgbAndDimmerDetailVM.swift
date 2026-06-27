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

private let ZAM_PRODID_DIW_01 = 2000
private let COM_PRODID_WDIM100 = 2000

class RgbAndDimmerDetailVM: BaseDetailVM<RgbAndDimmerDetailViewState, RgbAndDimmerDetailViewEvent> {
    var showSettings: Bool { currentState()?.showSettings ?? false }

    override func defaultViewState() -> RgbAndDimmerDetailViewState { RgbAndDimmerDetailViewState() }

    override func setTitle(_ title: String) {
        updateView { $0.changing(path: \.title, to: title) }
    }

    override func handleChannel(_ channel: SAChannel) {
        super.handleChannel(channel)
        updateView { $0.changing(path: \.showSettings, to: shouldShowRgbSettings(channel)) }
    }

    private func shouldShowRgbSettings(_ channel: SAChannel) -> Bool {
        let manufacturerId = channel.manufacturer_id
        let productId = channel.product_id

        return manufacturerId == SUPLA_MFR_DOYLETRATT && productId == 1 ||
            manufacturerId == SUPLA_MFR_DOYLETRATT && productId == 10 ||
            manufacturerId == SUPLA_MFR_ZAMEL && productId == ZAM_PRODID_DIW_01 ||
            manufacturerId == SUPLA_MFR_COMELIT && productId == COM_PRODID_WDIM100
    }
}

enum RgbAndDimmerDetailViewEvent: ViewEvent {}

struct RgbAndDimmerDetailViewState: ViewState {
    var title: String? = nil
    var showSettings: Bool = false
}
