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

import UIKit

extension String {
    
    var uiImage: UIImage? { UIImage(named: self) }
    
    struct Icons {
        // MARK: Bars
        static let general = "icon_general"
        static let timer = "icon_timer"
        static let metrics = "icon_metrics"
        static let schedule = "icon_schedule"
        static let history = "icon_history"
        static let settings = "icon_settings"
        
        // MARK: Icons
        static let pencil = "pencil"
        static let info = "icon_info"
        static let heating = "icon_heating"
        static let cooling = "icon_cooling"
        static let standby = "icon_standby"
        static let powerButton = "icon_power_button"
        static let heat = "icon_heat"
        static let cool = "icon_cool"
        static let minus = "icon_minus"
        static let plus = "icon_plus"
        static let manual = "icon_manual"
        static let sensorAlertCircle = "icon_sensor_alert_circle"
        static let sensorAlert = "icon_sensor_alert"
        static let close = "icon_close"
        static let delete = "icon_delete"
        static let calibrate = "icon_calibrate"
        static let offline = "icon_offline"
        static let stop = "icon_stop"
        static let touchHand = "icon_touch_hand"
        static let touchHandFilled = "icon_touch_hand_filled"
        static let visible = "icon_visible"
        static let invisible = "icon_invisible"
        static let empty = "icon_empty"
        static let more = "icon_more"
        static let list = "icon_list"
        static let forwardEnergy = "icon_forward_energy"
        static let reversedEnergy = "icon_reversed_energy"
        static let powerOff = "icon_power_off"
        static let soundOn = "icon_sound_on"
        static let soundOff = "icon_sound_off"
        static let update = "icon_update"
        
        static let warning = "channel_warning_level1"
        static let error = "channel_warning_level2"
        static let statusError = "icon_status_error"
        
        static let arrowRight = "icon_arrow_right"
        static let arrowLeft = "icon_arrow_left"
        static let arrowDoubleRight = "icon_arrow_double_right"
        static let arrowOpen = "icon_arrow_open"
        static let arrowClose = "icon_arrow_close"
        static let arrowUp = "icon_arrow_up"
        static let arrowDown = "icon_arrow_down"
        static let arrowCoverTap = "icon_arrow_cover_tap"
        static let arrowCoverHold = "icon_arrow_cover_hold"
        static let arrowRevealTap = "icon_arrow_reveal_tap"
        static let arrowRevealHold = "icon_arrow_reveal_hold"
        
        static let checkboxEmpty = "icon_checkbox_empty"
        static let checkboxChecked = "icon_checkbox_checked"
        
        static let fingerprint = "icon_fingerprint"
        
        static let battery = "icon_battery"
        static let battery_0 = "icon_battery_0"
        static let battery_25 = "icon_battery_25"
        static let battery_50 = "icon_battery_50"
        static let battery_75 = "icon_battery_75"
        static let battery_100 = "icon_battery_100"
        static let battery_not_used = "icon_battery_not_used"
        
        static let ocrPhoto = "icon_ocr_photo"
        static let noPhoto = "icon_no_photo"
        static let moveHandle = "order"
        
        // MARK: Functions
        static let fncUnknown = "unknown_channel"
        // Electricitymeter
        static let fncElectricitymeter = "fnc_electricitymeter"
        // Gasmeter
        static let fncGasemeter = "fnc_gasmeter"
        // GPM
        static let fncGpm1 = "fnc_gpm_1"
        static let fncGpm2 = "fnc_gpm_2"
        static let fncGpm3 = "fnc_gpm_3"
        static let fncGpm4 = "fnc_gpm_4"
        static let fncGpm5 = "fnc_gpm_5"
        static let fncGpmAir1 = "fnc_gpm_air_1"
        static let fncGpmAir2 = "fnc_gpm_air_2"
        static let fncGpmAir3 = "fnc_gpm_air_3"
        static let fncGpmChimnay = "fnc_gpm_chimnay"
        static let fncGpmCoal = "fnc_gpm_coal"
        static let fncGpmCurrent1 = "fnc_gpm_current_1"
        static let fncGpmCurrent2 = "fnc_gpm_current_2"
        static let fncGpmFan1 = "fnc_gpm_fan_1"
        static let fncGpmFan2 = "fnc_gpm_fan_2"
        static let fncGpmInsolation1 = "fnc_gpm_insolation_1"
        static let fncGpmInsolation2 = "fnc_gpm_insolation_2"
        static let fncGpmKlop = "fnc_gpm_klop"
        static let fncGpmMultimeter = "fnc_gpm_multimeter"
        static let fncGpmPm1 = "fnc_gpm_pm_1"
        static let fncGpmPm2_5 = "fnc_gpm_pm_2_5"
        static let fncGpmPm10 = "fnc_gpm_pm_10"
        static let fncGpmProcessor = "fnc_gpm_processor"
        static let fncGpmSalt = "fnc_gpm_salt"
        static let fncGpmSepticTank1 = "fnc_gpm_septic_tank_1"
        static let fncGpmSepticTank2 = "fnc_gpm_septic_tank_2"
        static let fncGpmSepticTank3 = "fnc_gpm_septic_tank_3"
        static let fncGpmSepticTank4 = "fnc_gpm_septic_tank_4"
        static let fncGpmSmog1 = "fnc_gpm_smog_1"
        static let fncGpmSmog2 = "fnc_gpm_smog_2"
        static let fncGpmSmog3 = "fnc_gpm_smog_3"
        static let fncGpmSmog4 = "fnc_gpm_smog_4"
        static let fncGpmSmog5 = "fnc_gpm_smog_5"
        static let fncGpmSmog6 = "fnc_gpm_smog_6"
        static let fncGpmSound1 = "fnc_gpm_sound_1"
        static let fncGpmSound2 = "fnc_gpm_sound_2"
        static let fncGpmSound3 = "fnc_gpm_sound_3"
        static let fncGpmTransfer = "fnc_gpm_transfer"
        static let fncGpmVoltage1 = "fnc_gpm_voltage_1"
        static let fncGpmVoltage2 = "fnc_gpm_voltage_2"
        static let fncGpmWaterTank1 = "fnc_gpm_water_tank_1"
        static let fncGpmWaterTank2 = "fnc_gpm_water_tank_2"
        static let fncGpmWaterTank3 = "fnc_gpm_water_tank_3"
        // Heatmeter
        static let fncHeatmeter = "fnc_heatmeter"
        // Waterneter
        static let fncWatermeter = "fnc_watermeter"
        // Thermometer
        static let fncThermometerCooling = "fnc_thermometer_cooling"
        static let fncThermometerFloor = "fnc_thermometer_floor"
        static let fncThermometerHeater = "fnc_thermometer_heater"
        static let fncThermometerHeating = "fnc_thermometer_heating"
        static let fncThermometerHome = "fnc_thermometer_home"
        static let fncThermometerTap = "fnc_thermometer_tap"
        static let fncThermometerWater = "fnc_thermometer_water"
        static let fncHumidity = "humidity"
        // Thermostat
        static let fncThermostatHeat = "fnc_thermostat_heat"
        static let fncThermostatCool = "fnc_thermostat_cool"
        static let fncThermostatDhw = "fnc_thermostat_dhw"
        // ShadingSystems
        static let fncTerraceAwning = "fnc_terrace_awning"
        // Pump switch
        static let fncPumpSwitch = "fnc_pump_switch"
        // Heat or cold source switch
        static let fncHeatOrColdSourceSwitch = "fnc_heat_or_cold_source_switch"
        static let fncHeatOrColdSourceSwitch2 = "fnc_heat_or_cold_source_switch_2"
        static let fncHeatOrColdSourceSwitch3 = "fnc_heat_or_cold_source_switch_3"
        static let fncHeatOrColdSourceSwitch4 = "fnc_heat_or_cold_source_switch_4"
        static let fncHeatOrColdSourceSwitch5 = "fnc_heat_or_cold_source_switch_5"
        static let fncHeatOrColdSourceSwitch6 = "fnc_heat_or_cold_source_switch_6"
        // Container
        static let fncContainer = "fnc_container"
        static let fncContainer1 = "fnc_container_1"
        static let fncContainer2 = "fnc_container_2"
        static let fncContainer3 = "fnc_container_3"
        // Septic tank
        static let fncSepticTank = "fnc_septic_tank"
        static let fncSepticTank1 = "fnc_septic_tank_1"
        // Water tank
        static let fncWaterTank = "fnc_water_tank"
        static let fncWaterTank1 = "fnc_water_tank_1"
        static let fncWaterTank2 = "fnc_water_tank_2"
        static let fncWaterTank3 = "fnc_water_tank_3"
        // Flood sensor
        static let fncFloodSensor = "fnc_flood_sensor"
        // Container level sensor
        static let fncContainerLevelSensor = "fnc_container_level_sensor"
        
        // MARK: other
        static let thumbHeat = "thumb_heat"
        static let thumbCool = "thumb_cool"
    }
    
    struct Image {
        static let logo = "logo"
        static let logoLight = "logo_light"
        static let logoWithName = "logo_with_name"
        static let garageContent = "garage_content"
    }
}
