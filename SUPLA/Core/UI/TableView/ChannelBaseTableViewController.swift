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

class ChannelBaseTableViewController<S : ViewState, E : ViewEvent, VM : BaseTableViewModel<S, E>>: BaseTableViewController<S, E, VM> {
    
    let cellIdForChannel = "ChannelCell"
    let cellIdForThermometer = "ThermometerCell"
    let cellIdForTempHumidity = "TempHumidityCell"
    let cellIdForMeasurement = "MeasurementCell"
    let cellIdForDistance = "DistanceCell"
    let cellIdForIncremental = "IncrementalCell"
    let cellIdForHomePlus = "HomePlusCell"
    
    override func setupTableView() {
        register(nib: Nibs.channelCell, for: cellIdForChannel)
        register(nib: Nibs.thermometerCell, for: cellIdForThermometer)
        register(nib: Nibs.tempHumidityCell, for: cellIdForTempHumidity)
        register(nib: Nibs.measurementCell, for: cellIdForMeasurement)
        register(nib: Nibs.distanceCell, for: cellIdForDistance)
        register(nib: Nibs.incrementalMeterCell, for: cellIdForIncremental)
        register(nib: Nibs.homePlusCell, for: cellIdForHomePlus)
        
        
        super.setupTableView()
    }
    
    override func configureCell(channelBase: SAChannelBase, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: getCellId(channelBase), for: indexPath) as! SAChannelCell
        
        cell.delegate = nil
        cell.currentIndexPath = indexPath
        cell.channelBase = channelBase
        cell.captionEditable = true
        
        return cell
    }
    
    private func getCellId(_ channelBase: SAChannelBase) -> String {
        switch(channelBase.func) {
        case SUPLA_CHANNELFNC_POWERSWITCH,
            SUPLA_CHANNELFNC_LIGHTSWITCH,
        SUPLA_CHANNELFNC_STAIRCASETIMER:
            if let channel = channelBase as? SAChannel,
               let channelValue = channel.value {
                if (channelValue.sub_value_type == SUBV_TYPE_IC_MEASUREMENTS
                    || channelValue.sub_value_type == SUBV_TYPE_ELECTRICITY_MEASUREMENTS) {
                    return cellIdForIncremental
                }
            }
            return cellIdForChannel
        case SUPLA_CHANNELFNC_THERMOMETER:
            return cellIdForThermometer
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            return cellIdForTempHumidity
        case SUPLA_CHANNELFNC_DEPTHSENSOR,
            SUPLA_CHANNELFNC_WINDSENSOR,
            SUPLA_CHANNELFNC_WEIGHTSENSOR,
            SUPLA_CHANNELFNC_PRESSURESENSOR,
            SUPLA_CHANNELFNC_RAINSENSOR,
        SUPLA_CHANNELFNC_HUMIDITY:
            return cellIdForMeasurement
        case SUPLA_CHANNELFNC_DISTANCESENSOR:
            return cellIdForDistance
        case SUPLA_CHANNELFNC_ELECTRICITY_METER,
            SUPLA_CHANNELFNC_IC_ELECTRICITY_METER,
            SUPLA_CHANNELFNC_IC_GAS_METER,
            SUPLA_CHANNELFNC_IC_WATER_METER,
        SUPLA_CHANNELFNC_IC_HEAT_METER:
            return cellIdForIncremental
        case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
            return cellIdForHomePlus
        default:
            return cellIdForChannel
        }
    }
    
    private func register(nib name: String, for id: String) {
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: id)
    }
}
