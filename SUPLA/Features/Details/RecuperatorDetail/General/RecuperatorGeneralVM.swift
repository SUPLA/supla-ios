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

import SharedCore

extension RecuperatorGeneralFeature {
    final class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        private let item: ItemBundle

        init(item: ItemBundle) {
            self.item = item
            super.init(state: ViewState())
        }

        override func onViewWillAppear() {
            state.isOff = false
            state.mode = .manual
            state.supplyOutsideTemperature = "14.0°"
            state.supplyInsideTemperature = "22.2°"
            state.exhaustOutsideTemperature = "15.0°"
            state.exhaustInsideTemperature = "23.2°"
            state.supplyPowerPercent = "50%"
            state.exhaustPowerPercent = "50%"
        }

        func onVentilationClick() {}

        func onEmptyHouseClick() {}

        func onOpenWindowClick() {}

        func onPowerClick() {
            if state.isOff {
                state.isOff = false
                state.mode = .manual
            } else {
                state.isOff = true
                state.mode = nil
            }
        }

        func onManualClick() {
            state.isOff = false
            state.mode = .manual
        }

        func onProgramClick() {
            state.isOff = false
            state.mode = .program
        }

        func onSpeedChanged() {}
    }
}
