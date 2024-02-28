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
    let cellIdForHvacThermostat = "HvacThermostatCell"
    
    var cellConstraintalues: [String: CGFloat] = [:]
    
    override func setupTableView() {
        register(nib: Nibs.channelCell, for: cellIdForChannel)
        register(nib: Nibs.thermometerCell, for: cellIdForThermometer)
        register(nib: Nibs.tempHumidityCell, for: cellIdForTempHumidity)
        register(nib: Nibs.distanceCell, for: cellIdForDistance)
        register(nib: Nibs.incrementalMeterCell, for: cellIdForIncremental)
        register(nib: Nibs.homePlusCell, for: cellIdForHomePlus)
        tableView.register(ThermostatCell.self, forCellReuseIdentifier: cellIdForHvacThermostat)
        tableView.register(MeasurementCell.self, forCellReuseIdentifier: cellIdForMeasurement)
        
        super.setupTableView()
    }
    
    override func configureCell(channelBase: SAChannelBase, children: [ChannelChild], indexPath: IndexPath) -> UITableViewCell {
        let cellId = getCellId(channelBase)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        if (cellId == cellIdForHvacThermostat) {
            return setupThermostatCell(cell, channelBase: channelBase, children: children)
        } else if (cellId == cellIdForMeasurement) {
            return setupMeasurementCell(cell, channelBase: channelBase, children: children)
        } else {
            return setupLegacyCell(cell, cellId: cellId, channelBase: channelBase, indexPath: indexPath)
        }
    }
    
    private func setupThermostatCell(_ cell: UITableViewCell, channelBase: SAChannelBase, children: [ChannelChild]) -> UITableViewCell {
        let thermostatCell = cell as! ThermostatCell
        
        thermostatCell.scaleFactor = scaleFactor
        thermostatCell.data = ChannelWithChildren(channel: channelBase as! SAChannel, children: children)
        thermostatCell.showChannelInfo = showChannelInfo
        
        return cell
    }
    
    private func setupMeasurementCell(_ cell: UITableViewCell, channelBase: SAChannelBase, children: [ChannelChild]) -> UITableViewCell {
        let measurementCell = cell as! MeasurementCell
        
        measurementCell.scaleFactor = scaleFactor
        measurementCell.data = ChannelWithChildren(channel: channelBase as! SAChannel, children: children)
        measurementCell.showChannelInfo = showChannelInfo
        
        return cell
    }
    
    private func setupLegacyCell(
        _ cell: UITableViewCell,
        cellId: String,
        channelBase: SAChannelBase,
        indexPath: IndexPath
    ) -> UITableViewCell {
        let channelCell = cell as! SAChannelCell
        
        channelCell.delegate = nil
        channelCell.currentIndexPath = indexPath
        channelCell.setShowChannelInfo(showChannelInfo)
        channelCell.channelBase = channelBase
        channelCell.captionEditable = true
        
        for constraint in channelCell.channelIconScalableConstraints {
            var scaleFactorLocal = scaleFactor
            var value: CGFloat
            let constraintId = cellId.appending(constraint.identifier ?? "")
            if (cellConstraintalues.keys.contains(constraintId)) {
                value = cellConstraintalues[constraintId]!
            } else {
                value = constraint.constant
                if (scaleFactorLocal < 0.7) {
                    value /= scaleFactorLocal
                }
                cellConstraintalues[constraintId] = value
            }

            if (scaleFactorLocal < 1.0 && constraint.identifier == "distanceValueHeight") {
                scaleFactorLocal = 1.0
            }

            if (constraint.identifier == "durationToTop") {
                value = 9
                channelCell.durationTimer.font = channelCell.durationTimer.font.withSize(14 * scaleFactorLocal)
            }
            else if (constraint.firstItem is UILabel || constraint.secondItem is UILabel) {
                let label = (constraint.firstItem is UILabel ? constraint.firstItem : constraint.secondItem) as! UILabel
                var scaleFactorCopy = scaleFactorLocal
                if (label === channelCell.caption) {
                    if (scaleFactorCopy < 1.0) {
                        scaleFactorCopy = 0.8
                    }
                    if (scaleFactorLocal < 1.0) {
                        scaleFactorLocal *= 1.2
                    }
                }
                adjustFontSize(label, scaleFactorCopy, label === channelCell.caption)
            }

            if (constraint.identifier == "captionToBottom") {
                value = 9
            }

            constraint.constant = value * scaleFactorLocal
            if (constraint.firstItem is UIImageView) {
                constraint.firstItem?.setNeedsDisplay()
            }
        }
        
        return cell
    }
    
    private func adjustFontSize(_ item: UILabel, _ scale: CGFloat, _ isCaption: Bool) {
        var originalSize: CGFloat = 12
        let minSize: CGFloat = 12
        var scaleCopy = scale
        
        if (!isCaption) {
            originalSize = 20
            if (scaleCopy < 1.0) {
                scaleCopy = 1.0
            }
        }
        
        let newSize = max(originalSize * scaleCopy, minSize)
        item.font = item.font.withSize(newSize)
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
            SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER,
            SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT,
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
        case SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
        SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER:
            return cellIdForHvacThermostat
        default:
            return cellIdForChannel
        }
    }
    
    private func register(nib name: String, for id: String) {
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: id)
    }
}
