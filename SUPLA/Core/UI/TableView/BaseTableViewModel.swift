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
import RxCocoa
import RxDataSources

class BaseTableViewModel<S: ViewState, E: ViewEvent>: BaseViewModel<S, E> {
    let listItems = BehaviorRelay<[List]>(value: [])

    @Singleton<ToggleLocationUseCase> private var toggleLocationUseCase

    func toggleLocation(remoteId: Int32) {
        toggleLocationUseCase.invoke(remoteId: remoteId, collapsedFlag: getCollapsedFlag())
            .subscribe(onNext: { self.reloadTable() })
            .disposed(by: self)
    }

    func reloadTable() {
        fatalError("reloadTable() has not been implemented")
    }

    func getCollapsedFlag() -> CollapsedFlag {
        fatalError("getCollapsedFlag() has not been implemented")
    }

    func swapItems(firstItem: Int32, secondItem: Int32, locationCaption: String) {
        fatalError("swapItems(firstItem: secondItem: locationId:) has not been implemented")
    }

    func onClicked(onItem item: Any) {}

    func isAvailableInOffline(_ channel: SAChannelBase, children: [ChannelChild]? = nil) -> Bool {
        switch (channel.func) {
        case SUPLA_CHANNELFNC_THERMOMETER,
             SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
             SUPLA_CHANNELFNC_ELECTRICITY_METER,
             SUPLA_CHANNELFNC_IC_ELECTRICITY_METER,
             SUPLA_CHANNELFNC_IC_GAS_METER,
             SUPLA_CHANNELFNC_IC_WATER_METER,
             SUPLA_CHANNELFNC_IC_HEAT_METER,
             SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER,
             SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
             SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER,
             SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT,
             SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER,
             SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW,
             SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND,
             SUPLA_CHANNELFNC_TERRACE_AWNING,
             SUPLA_CHANNELFNC_PROJECTOR_SCREEN,
             SUPLA_CHANNELFNC_CURTAIN,
             SUPLA_CHANNELFNC_VERTICAL_BLIND,
             SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR:
            return true
        case SUPLA_CHANNELFNC_LIGHTSWITCH,
             SUPLA_CHANNELFNC_POWERSWITCH,
             SUPLA_CHANNELFNC_STAIRCASETIMER:
            if (children?.first(where: { $0.relationType == .meter }) != nil) {
                return true
            } else {
                switch (Int32((channel as? SAChannel)?.value?.sub_value_type ?? 0)) {
                case SUBV_TYPE_IC_MEASUREMENTS,
                     SUBV_TYPE_ELECTRICITY_MEASUREMENTS:
                    return true
                default:
                    return false
                }
            }
        default:
            return false
        }
    }
}

enum List {
    case list(items: [ListItem])
}

enum ListItem: Equatable {
    case location(location: _SALocation)
    case scene(scene: SAScene)
    case channelBase(channelBase: SAChannelBase, children: [ChannelChild])
}

extension List: SectionModelType {
    typealias Item = ListItem

    var items: [ListItem] {
        switch self {
        case .list(let items):
            return items.map { $0 }
        }
    }

    init(original: List, items: [ListItem]) {
        switch original {
        case .list:
            self = .list(items: items)
        }
    }
}
