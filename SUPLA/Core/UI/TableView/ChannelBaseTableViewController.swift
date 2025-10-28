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
import SharedCore

class ChannelBaseTableViewController<S: ViewState, E: ViewEvent, VM: BaseTableViewModel<S, E>>: BaseTableViewController<S, E, VM> {
    let cellIdForChannel = "ChannelCell"
    let cellIdForIconValue = "IconValueCell"
    let cellIdForDoubleIconValue = "DoubleIconValueCell"
    let cellIdForIcon = "IconCell"
    let cellIdForHomePlus = "HomePlusCell"
    let cellIdForHomePlusGroup = "HomePlusCellGroup"
    let cellIdForHvacThermostat = "HvacThermostatCell"
    
    var cellConstraintalues: [String: CGFloat] = [:]
    
    override func setupTableView() {
        register(nib: Nibs.channelCell, for: cellIdForChannel)
        register(nib: Nibs.homePlusCell, for: cellIdForHomePlusGroup)
        tableView.register(HeatpolThermostatCell.self, forCellReuseIdentifier: cellIdForHomePlus)
        tableView.register(ThermostatCell.self, forCellReuseIdentifier: cellIdForHvacThermostat)
        tableView.register(IconValueCell.self, forCellReuseIdentifier: cellIdForIconValue)
        tableView.register(IconCell.self, forCellReuseIdentifier: cellIdForIcon)
        tableView.register(DoubleIconValueCell.self, forCellReuseIdentifier: cellIdForDoubleIconValue)
        
        super.setupTableView()
    }
    
    override func configureCell(channelBase: SAChannelBase, children: [ChannelChild], indexPath: IndexPath) -> UITableViewCell {
        let cellId = getCellId(channelBase)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        switch (cellId) {
        case cellIdForHvacThermostat,
             cellIdForIconValue,
             cellIdForIcon,
             cellIdForDoubleIconValue,
             cellIdForHomePlus:
            return setupBaseCell(cell, channelBase: channelBase, children: children)
        default:
            return setupLegacyCell(cell, cellId: cellId, channelBase: channelBase, indexPath: indexPath)
        }
    }
    
    private func setupBaseCell(_ cell: UITableViewCell, channelBase: SAChannelBase, children: [ChannelChild]) -> UITableViewCell {
        let measurementCell = cell as! BaseCell<ChannelWithChildren>
        
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
            } else if (constraint.firstItem is UILabel || constraint.secondItem is UILabel) {
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
        if (channelBase is SAChannelGroup) {
            if (channelBase.func == SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS) {
                return cellIdForHomePlusGroup
            } else {
                return cellIdForChannel
            }
        }
        
        let function = SuplaFunction.companion.from(value: channelBase.func)
        switch (function) {
        case .hvacThermostat,
             .hvacThermostatHeatCool,
             .hvacDomesticHotWater:
            return cellIdForHvacThermostat
        case .thermostatHeatpolHomeplus:
            return cellIdForHomePlus
        case .humidityAndTemperature:
            return cellIdForDoubleIconValue
            
        case .unknown,
             .none,
             .thermometer,
             .humidity,
             .controllingTheGatewayLock,
             .controllingTheGate,
             .controllingTheGarageDoor,
             .openSensorGateway,
             .openSensorGate,
             .openSensorGarageDoor,
             .noLiquidSensor,
             .controllingTheDoorLock,
             .openSensorDoor,
             .controllingTheRollerShutter,
             .controllingTheRoofWindow,
             .openSensorRollerShutter,
             .openSensorRoofWindow,
             .powerSwitch,
             .lightswitch,
             .ring,
             .alarm,
             .notification,
             .dimmer,
             .rgbLighting,
             .dimmerAndRgbLighting,
             .depthSensor,
             .distanceSensor,
             .openingSensorWindow,
             .hotelCardSensor,
             .alarmArmamentSensor,
             .mailSensor,
             .windSensor,
             .pressureSensor,
             .rainSensor,
             .weightSensor,
             .weatherStation,
             .staircaseTimer,
             .electricityMeter,
             .icElectricityMeter,
             .icGasMeter,
             .icWaterMeter,
             .icHeatMeter,
             .valveOpenClose,
             .valvePercentage,
             .generalPurposeMeasurement,
             .generalPurposeMeter,
             .digiglassHorizontal,
             .digiglassVertical,
             .controllingTheFacadeBlind,
             .terraceAwning,
             .projectorScreen,
             .curtain,
             .verticalBlind,
             .rollerGarageDoor,
             .pumpSwitch,
             .heatOrColdSourceSwitch,
             .container,
             .septicTank,
             .waterTank,
             .containerLevelSensor,
             .floodSensor,
             .motionSensor,
             .binarySensor:
            return cellIdForIconValue
        }
    }
    
    private func register(nib name: String, for id: String) {
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: id)
    }
}
