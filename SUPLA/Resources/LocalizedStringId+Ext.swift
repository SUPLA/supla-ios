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

extension LocalizedStringId {
    var value: String {
        switch (self) {
        case .generalClose: Strings.General.close
        case .generalOpen: Strings.General.open
        case .generalOpenClose: Strings.General.openClose
        case .generalTurnOn: Strings.General.turnOn
        case .generalTurnOff: Strings.General.turnOff
        case .generalShut: Strings.General.shut
        case .generalReveal: Strings.General.reveal
        case .generalCollapse: Strings.General.collapse
        case .generalExpand: Strings.General.expand
            
        case .generalYes: Strings.General.yes
        case .generalNo: Strings.General.no

        case .channelCaptionOpenSensorGateway: NSLocalizedString("Gateway opening sensor", comment: "")
        case .channelCaptionControllingTheGatewayLock: NSLocalizedString("Gateway", comment: "")
        case .channelCaptionOpenSensorGate: NSLocalizedString("Gate opening sensor", comment: "")
        case .channelCaptionControllingTheGate: NSLocalizedString("Gate", comment: "")
        case .channelCaptionOpenSensorGarageDoor: NSLocalizedString("Garage door opening sensor", comment: "")
        case .channelCaptionControllingTheGarageDoor: NSLocalizedString("Garage door", comment: "")
        case .channelCaptionOpenSensorDoor: NSLocalizedString("Door opening sensor", comment: "")
        case .channelCaptionControllingTheDoorLock: NSLocalizedString("Door", comment: "")
        case .channelCaptionOpenSensorRollerShutter: NSLocalizedString("Roller shutter opening sensor", comment: "")
        case .channelCaptionOpenSensorRoofWindow: NSLocalizedString("Roof window opening sensor", comment: "")
        case .channelCaptionControllingTheRollerShutter: NSLocalizedString("Roller shutter", comment: "")
        case .channelCaptionControllingTheRoofWindow: NSLocalizedString("Roof window", comment: "")
        case .channelCaptionControllingTheFacadeBlind: Strings.General.Channel.captionFacadeBlinds
        case .channelCaptionPowerSwitch: NSLocalizedString("Power switch", comment: "")
        case .channelCaptionLightswitch: NSLocalizedString("Lighting switch", comment: "")
        case .channelCaptionThermometer: NSLocalizedString("Thermometer", comment: "")
        case .channelCaptionHumidity: Strings.General.Channel.captionHumidity
        case .channelCaptionHumidityAndTemperature: Strings.General.Channel.captionHumidityAndTemperature
        case .channelCaptionWindSensor: NSLocalizedString("Wind sensor", comment: "")
        case .channelCaptionPressureSensor: NSLocalizedString("Pressure sensor", comment: "")
        case .channelCaptionRainSensor: NSLocalizedString("Rain sensor", comment: "")
        case .channelCaptionWeightSensor: NSLocalizedString("Weight sensor", comment: "")
        case .channelCaptionNoLiquidSensor: NSLocalizedString("No liquid sensor", comment: "")
        case .channelCaptionDimmer: NSLocalizedString("Dimmer", comment: "")
        case .channelCaptionRgbLighting: NSLocalizedString("RGB lighting", comment: "")
        case .channelCaptionDimmerAndRgbLighting: NSLocalizedString("Dimmer and RGB lighting", comment: "")
        case .channelCaptionDepthSensor: NSLocalizedString("Depth sensor", comment: "")
        case .channelCaptionDistanceSensor: NSLocalizedString("Distance sensor", comment: "")
        case .channelCaptionOpeningSensorWindow: NSLocalizedString("Window opening sensor", comment: "")
        case .channelCaptionHotelCardSensor: Strings.General.Channel.captionHotelCard
        case .channelCaptionAlarmArmamentSensor: Strings.General.Channel.captionAlarmArmament
        case .channelCaptionMailSensor: NSLocalizedString("Mail sensor", comment: "")
        case .channelCaptionStaircaseTimer: NSLocalizedString("Staircase timer", comment: "")
        case .channelCaptionIcGasMeter: NSLocalizedString("Gas Meter", comment: "")
        case .channelCaptionIcWaterMeter: NSLocalizedString("Water Meter", comment: "")
        case .channelCaptionIcHeatMeter: NSLocalizedString("Heat Meter", comment: "")
        case .channelCaptionThermostatHeatpolHomeplus: NSLocalizedString("Home+ Heater", comment: "")
        case .channelCaptionValve: NSLocalizedString("Valve", comment: "")
        case .channelCaptionGeneralPurposeMeasurement: Strings.General.Channel.captionGeneralPurposeMeasurement
        case .channelCaptionGeneralPurposeMeter: Strings.General.Channel.captionGeneralPurposeMeter
        case .channelCaptionThermostat: NSLocalizedString("Thermostat", comment: "")
        case .channelCaptionElectricityMeter: NSLocalizedString("Electricity Meter", comment: "")
        case .channelCaptionDigiglass: NSLocalizedString("Digiglass", comment: "")
        case .channelCaptionTerraceAwning: Strings.General.Channel.captionTerraceAwning
        case .channelCaptionProjectorScreen: Strings.General.Channel.captionProjectorScreen
        case .channelCaptionCurtain: Strings.General.Channel.captionCurtain
        case .channelCaptionVerticalBlind: Strings.General.Channel.captionVerticalBlind
        case .channelCaptionRollerGarageDoor: Strings.General.Channel.captionGarageDoor
        case .channelCaptionPumpSwitch: Strings.General.Channel.captionPumpSwitch
        case .channelCaptionHeatOrColdSourceSwitch: Strings.General.Channel.captionHeatOrCouldSourceSwitch
        case .channelCaptionContainer: Strings.General.Channel.captionContainer
        case .channelCaptionMotionSensor: Strings.General.Channel.captionMotionSensor
        case .channelCaptionBinarySensor: Strings.General.Channel.captionBinarySensor
        case .channelCaptionUnknown: NSLocalizedString("Not supported function", comment: "")

        case .channelBatteryLevel: Strings.General.Channel.batteryLevel
        case .channelBatteryLevelWithInfo: Strings.General.Channel.batteryLevelWithInfo

        case .motorProblem: Strings.RollerShutterDetail.motorProblem
        case .calibrationLost: Strings.RollerShutterDetail.calibrationLost
        case .calibrationFailed: Strings.RollerShutterDetail.calibrationFailed
            
        case .overcurrentWarning: Strings.SwitchDetail.overcurrentWarning
            
        case .thermostatThermometerError: Strings.ThermostatDetail.thermometerError
        case .thermostatBatterCoverOpen: Strings.ThermostatDetail.batteryCoverOpen
        case .thermostatClockError: Strings.ThermostatDetail.clockError
        case .thermostatCalibrationError: Strings.ThermostatDetail.calibrationError
            
        case .channelCaptionSepticTank: Strings.General.Channel.captionSepticTank
        case .channelCaptionWaterTank: Strings.General.Channel.captionWaterTank
        case .channelCaptionContainerLevelSensor: Strings.General.Channel.captionContainerLevelSensor
        case .channelCaptionFloodSensor: Strings.General.Channel.captionFloodSensor
            
        case .floodSensorActive: Strings.Valve.floodingAlarmMessage
        case .valveManuallyClosed: Strings.Valve.warningManuallyClosedShort
        case .valveFlooding: Strings.Valve.warningFloodingShort
        case .valveMotorProblem: Strings.Valve.warningMotorProblem
        case .valveSensorOffline: Strings.Valve.errorSensorOffline
            
        case .containerAlarmLevel: Strings.Container.alarmLevel
        case .containerWarningLevel: Strings.Container.warningLevel
        case .containerInvalidSensorState: Strings.Container.invalidSensorState
        case .containerSoundAlarm: Strings.Container.soundAlarm
            
        case .channelStatusAwaiting: Strings.General.Channel.statusAwaiting
        case .channelStatusUpdating: Strings.General.Channel.statusUpdating
        case .channelStatusNotAvailable: Strings.General.Channel.statusNotAvailable
        
        case .deviceRegistrationRequestTimeout: Strings.AddWizard.deviceRegistrationRequestTimeout
        case .enablingRegistrationTimeout: Strings.AddWizard.enablingRegistrationTimeout
        case .addWizardScanTimeout: Strings.AddWizard.scanTimeout
        case .addWizardDeviceNotFound: Strings.AddWizard.deviceNotFound
        case .addWizardConnectTimeout: Strings.AddWizard.connectTimeout
        case .addWizardConfigureTimeout: Strings.AddWizard.configureTimeout
        case .addWizardWifiError: Strings.AddWizard.wifiError
        case .addWizardResultNotCompatible: Strings.AddWizard.resultNotCompatible
        case .addWizardResultConnectionError: Strings.AddWizard.resultConnectionError
        case .addWizardResultFailed: Strings.AddWizard.resultFailed
        case .addWizardReconnectTimeout: Strings.AddWizard.reconnectTimeout
        case .addWizardDeviceTemporarilyLocked: Strings.AddWizard.deviceTemporarilyLocked
        case .addWizardStatePreparing: Strings.AddWizard.statePreparing
        case .addWizardStateConnecting: Strings.AddWizard.stateConnecting
        case .addWizardStateConfiguring: Strings.AddWizard.stateConfiguring
        case .addWizardStateFinishing: Strings.AddWizard.stateFinishing
            
        case .channelStateUptime: Strings.State.uptimeValue
        case .channelStateBatteryPowered: Strings.State.batteryPowered
        case .channelStateMainsPowered: Strings.State.mainPowered
        case .lastConnectionResetCauseUnknown: Strings.State.connectionResetCauseUnknown
        case .lastConnectionResetCauseActivityTimeout: Strings.State.connectionResetCauseActivityTimeout
        case .lastConnectionResetCauseWifiConnectionLost: Strings.State.connectionResetCauseWifiConnectionLost
        case .lastConnectionResetCauseServerConnectionLost: Strings.State.connectionResetCauseServerConnectionLost
            
        case .resultCodeTemporarilyUnavailable: Strings.Status.errorUnavailable
        case .resultCodeClientLimitExceeded: Strings.Status.errorClientLimitExceeded
        case .resultCodeDeviceDisabled: Strings.Status.errorDeviceDisabled
        case .resultCodeAccessIdDisabled: Strings.Status.errorAccessIdDisabled
        case .resultCodeRegistrationDisabled: Strings.Status.errorRegistrationDisabled
        case .resultCodeAccessIdNotAssigned: Strings.Status.errorAccessIdNotAssigned
        case .resultCodeInactive: Strings.Status.errorAccessIdInactive
        case .resultCodeIncorrectEmailOrPassword: Strings.Status.errorInvalidData
        case .resultCodeBadCredentials: Strings.Status.errorBadCredentials
        case .resultCodeUnknownError: Strings.Status.errorUnknown
            
        case .lifespanWarningReplace: Strings.General.Channel.uvError
        case .lifespanWarningSchedule: Strings.General.Channel.uvWarning
        case .lifespanWarning: Strings.General.Channel.lightSourceWarning
        case .digiglassPlannedRegeneration: Strings.General.Channel.digiglassPlannedRegeneration
        case .digiglassRegenerationAfter20H: Strings.General.Channel.digiglassRegeneration
        case .digiglassToLongOperation: Strings.General.Channel.digiglassTooLongOperating
        }
    }
}
