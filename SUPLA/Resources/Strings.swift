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

struct Strings {
    static let appName = NSLocalizedString("supla", comment: "Application name")
    
    struct Cfg {
        static let appConfigTitle = NSLocalizedString("App Settings", comment: "title headline for settings view")
        static let channelHeight = NSLocalizedString("Channel height", comment: "label for channel height setting")
        static let temperatureUnit = NSLocalizedString("Temperature unit", comment: "label for temperature unit setting")
        static let buttonAutoHide  = NSLocalizedString("Auto-hide buttons", comment: "label for button auto-hide setting")
        static let showChannelInfo = NSLocalizedString("Show ⓘ button", comment: "label for show channel info setting")
        
        static let locationOrdering = NSLocalizedString("Location order", comment: "settings menu label for location order")
        static let showOpeningModeOpening = NSLocalizedString("Opening", comment: "")
        static let showOpeningModeClosing = NSLocalizedString("Closing", comment: "")
        static let rsDisplayMode = "rs_display_mode".toLocalized()

        static let removalConfirmationTitle = "Cfg.removal.title".toLocalized()
        static let removalActionLogout = "Cfg.removal.action.logout".toLocalized()
        static let removalActionRemove = "Cfg.removal.action.remove".toLocalized()
        
        struct Dialogs {
            struct Failed {
                static let title = "Cfg.removal.action.remove".toLocalized()
                static let message = "Cfg.removal.dialog.failed.message".toLocalized()
            }
            static let missing_name = "Cfg.removal.dialog.missing_name".toLocalized()
            static let duplicated_name = "Cfg.removal.dialog.duplicated_name".toLocalized()
            static let incomplete = "Cfg.removal.dialog.incomplete".toLocalized()
        }
    }
    
    struct AppSettings {
        static let permissionsHeader = "app_settings.permissions_header".toLocalized()
        static let notificationsLabel = "app_settings.notifications_label".toLocalized()
        static let locationLabel = "app_settings.location_label".toLocalized()
        static let showBottomMenu = "settings_show_bottom_menu".toLocalized()
        static let showLabels = "settings_show_labels".toLocalized()
        static let nightMode = "settings_dark_mode".toLocalized()
        static let lockScreen = "settings_lock_screen".toLocalized()
        static let lockScreenNone = "settings_lock_screen_none".toLocalized()
        static let lockScreenApp = "settings_lock_screen_app".toLocalized()
        static let lockScreenAccounts = "settings_lock_screen_accounts".toLocalized()
    }
    
    struct AccountCreation {
        static let creationTitle = "AccountCreation.title".toLocalized()
        static let modificationTitle = "AccountCreation.modificationTitle".toLocalized()
        
        static let yourAccountLabel = NSLocalizedString("Your account", comment: "account configuration settings screen")
        static let profileNameLabel = NSLocalizedString("NAME", comment: "label for profile name")
        static let basicModeNotAvailableTitle = NSLocalizedString("Setting not available", comment: "alert box title when basic authentication mode is not available")
        static let basicModeNotAvailableMessage = NSLocalizedString("Before turning advanced mode off you need to switch to email authentication and enable automatic server detection.", comment: "alert box message when basic authentication mode is not available")
        static let advancedSettings = NSLocalizedString("Advanced settings", comment: "Label for advanced settings toggle on authentication screen")
        static let accessIdSegment = NSLocalizedString("Access ID", comment: "")
        static let emailSegment = NSLocalizedString("Email", comment: "")
        static let accessIdLabel = NSLocalizedString("ACCESS IDENTIFIER", comment: "")
        static let emailLabel = NSLocalizedString("E-MAIL ADDRESS", comment: "")
        static let serverLabel = NSLocalizedString("SERVER ADDRESS", comment: "")
        static let passwordLabel = NSLocalizedString("PASSWORD", comment: "")
        static let wizardWarningText = NSLocalizedString("In Access ID authentication mode you won't be able to use automatic Add device wizard. However you will still be able to add it by manual Add device procedure.", comment: "")
        static let createAccountPrompt = NSLocalizedString("Don't have an account in Supla Cloud yet?", comment: "")
        static let createAccountButton = NSLocalizedString("Create", comment: "")
    }
    
    struct AccountRemoval {
        static let url = "AccountRemoval.url".toLocalized()
    }

    struct Profiles {
        struct Title {
            static let singular = NSLocalizedString("Your account", comment: "")
            static let plural = NSLocalizedString("Your accounts", comment: "")
            static let short = NSLocalizedString("Accounts", comment: "")
        }

        static let tapMessage = NSLocalizedString("Tap the account to log in.", comment: "")
        static let addNew = NSLocalizedString("Add new", comment: "add new profile")
        static let activeIndicator = NSLocalizedString("active", comment: "indicator for active profile")

        static let defaultProfileName = NSLocalizedString("Default", comment: "name for default profile")
        static let delete = NSLocalizedString("Delete account", comment: "button label to delete profile")
    }

    struct ProfileChooser {
        static let title = NSLocalizedString("Select active account", comment: "title for profile chooser")
    }

    struct Charts {
        static let rangeLabel = "history_range_label".toLocalized()
        static let aggregationLabel = "history_aggregation_label".toLocalized()
        static let lastDay = "history_range_last_day".toLocalized()
        static let lastWeek = "history_range_last_week".toLocalized()
        static let last30Days = "history_range_last_30_days".toLocalized()
        static let last90Days = "history_range_last_90_days".toLocalized()
        static let last365Days = "history_range_last_365_days".toLocalized()
        static let day = "history_range_current_day".toLocalized()
        static let week = "history_range_current_week".toLocalized()
        static let month = "history_range_current_month".toLocalized()
        static let quarter = "history_range_current_quarter".toLocalized()
        static let year = "history_range_current_year".toLocalized()
        static let custom = "history_range_custom".toLocalized()
        static let allHistory = "All available history".toLocalized()
        static let refreshing = "history_refreshing".toLocalized()
        static let refreshingFailed = "history_refreshing_failed".toLocalized()
        static let noDataSelected = "history_no_data_selected".toLocalized()
        static let noDataAvailable = "history_no_data_available".toLocalized()
        static let noDataInSelectedPeriod = "history_no_data_in_selected_period".toLocalized()
        static let loading = "Retrieving data from the server...".toLocalized()
        static let historyDisabled = "history_disabled".toLocalized()
        static let historyDeleteData = "history_delete_data".toLocalized()
        static let historyWaitForDownload = "history_wait_for_download_completed".toLocalized()
        
        static let minutes = "Minutes".toLocalized()
        static let hours = "Hours".toLocalized()
        static let days = "Days".toLocalized()
        static let months = "Months".toLocalized()
        static let years = "Years".toLocalized()
        static let rankOfHours = "Ranking of hours".toLocalized()
        static let rankOfWeekdays = "Ranking of weekdays".toLocalized()
        static let rankOfMonths = "Ranking of months".toLocalized()
        
        static let markerOpening = "chart_marker_opening".toLocalized()
        static let markerClosing = "chart_marker_closing".toLocalized()
        
        struct Electricity {
            static let selPhaseTitle = NSLocalizedString("Phase %d", comment: "")
        }
    }
    
    struct Scenes {
        struct ActionButtons {
            static let execute = "Scenes.ActionButtons.execute".toLocalized()
            static let abort = "Scenes.ActionButtons.abort".toLocalized()
        }
        struct RenameDialog {
            static let sceneName = NSLocalizedString("scene name", comment: "")
        }
        static let emptyListButton = "scenes_empty_list_button".toLocalized()
    }
    
    struct Main {
        static let channels = NSLocalizedString("Channels", comment: "")
        static let groups = NSLocalizedString("Groups", comment: "")
        static let scenes = NSLocalizedString("Scenes", comment: "")
        static let newGestureInfo = "dialog_new_gesture_info_text".toLocalized()
        static let noEntries = "main_no_entries".toLocalized()
    }
    
    struct Groups {
        static let emptyListButton = "groups_empty_list_button".toLocalized()
    }
    
    struct StandardDetail {
        static let tabGeneral = "standard_detail_general_tab".toLocalized()
        static let tabTimer = "standard_detail_timer_tab".toLocalized()
        static let tabMetrics = "standard_detail_metrics_tab".toLocalized()
        static let tabSchedule = "standard_detail_schedule_tab".toLocalized()
        static let tabHistory = "standard_detail_history_tab".toLocalized()
        static let tabList = "standard_detail_list_tab".toLocalized()
        static let tabSettings = "standard_detail_settings_tab".toLocalized()
    }
    
    struct SwitchDetail {
        static let stateLabel = "switch_detail_state_label".toLocalized()
        static let stateLabelForTimer = "switch_detail_state_label_for_timer".toLocalized()
        static let stateOn = "switch_detail_state_on".toLocalized()
        static let stateOff = "switch_detail_state_off".toLocalized()
        static let stateOffline = "switch_detail_state_offline".toLocalized()
    }
    
    struct TimerDetail {
        static let header = "timer_detail_header".toLocalized()
        static let editHeader = "timer_detail_edit_header".toLocalized()
        static let editHeaderOn = "timer_detail_edit_header_on".toLocalized()
        static let editHeaderOff = "timer_detail_edit_header_off".toLocalized()
        static let turnedOn = "timer_detail_turned_on".toLocalized()
        static let turnedOff = "timer_detail_turned_off".toLocalized()
        static let dayPattern = "timer_detail_day_pattern".toLocalized()
        static let daysPattern = "timer_detail_days_pattern".toLocalized()
        static let hourPattern = "timer_detail_hour_pattern".toLocalized()
        static let hoursPattern = "timer_detail_hours_pattern".toLocalized()
        static let minutePattern = "timer_detail_minute_pattern".toLocalized()
        static let secondPattern = "timer_detail_second_pattern".toLocalized()
        static let info = "timer_detail_info".toLocalized()
        static let infoOn = "timer_detail_info_on".toLocalized()
        static let infoOff = "timer_detail_info_off".toLocalized()
        static let infoNextOn = "timer_detail_info_next_on".toLocalized()
        static let infoNextOff = "timer_detail_info_next_off".toLocalized()
        static let start = "timer_detail_start".toLocalized()
        static let stop = "timer_detail_stop".toLocalized()
        static let cancel = "timer_detail_cancel".toLocalized()
        static let cancelOn = "timer_detail_cancel_on".toLocalized()
        static let cancelOff = "timer_detail_cancel_off".toLocalized()
        static let editTime = "timer_detail_edit_time".toLocalized()
        static let save = "timer_detail_save".toLocalized()
        static let editCancel = "timer_detail_edit_cancel".toLocalized()
        static let endHour = "timer_detail_end_hour".toLocalized()
        static let format = "timer_detail_format".toLocalized()
        static let wrongTimeTitle = "timer_detail_wrong_time_title".toLocalized()
        static let wrongTimeMessage = "timer_detail_wrong_time_message".toLocalized()
        static let cancelThermostat = "timer_detail_cancel_thermostat".toLocalized()
        static let selectMode = "timer_detail_select_mode".toLocalized()
        static let manualMode = "timer_detail_manual_mode".toLocalized()
        static let minTemp = "timer_detail_min_temp".toLocalized()
        static let maxTemp = "timer_detail_max_temp".toLocalized()
        static let selectTime = "timer_detail_select_time".toLocalized()
        static let counter = "timer_detail_counter".toLocalized()
        static let calendar = "timer_detail_calendar".toLocalized()
        static let infoThermostatOff = "timer_detail_info_thermostat_off".toLocalized()
        static let infoThermostatHeating = "timer_detail_info_thermostat_heating".toLocalized()
        static let infoThermostatCooling = "timer_detail_info_thermostat_cooling".toLocalized()
        static let stateLabelForTimerDays = "timer_detail_state_label_for_timer_days".toLocalized()
    }
    
    struct ThermostatDetail {
        static let thermometerError = "thermostat_thermometer_error".toLocalized()
        static let clockError = "thermostat_clock_error".toLocalized()
        static let batteryCoverOpen = "thermostat_battery_cover_open".toLocalized()
        
        static let modeManual = "thermostat_detail_mode_manual".toLocalized()
        static let modeWeeklySchedule = "thermostat_detail_mode_weekly_schedule".toLocalized()
        
        static let editProgramDialogHeader = "schedule_detail_program_dialog_header".toLocalized()
        static let heatingTemperature = "hvac_mode_temperature_heating".toLocalized()
        static let coolingTemperature = "hvac_mode_temperature_cooling".toLocalized()
        
        static let editQuartersDialogHeader = "schedule_detail_quarters_dialog_header".toLocalized()
        static let configurationFailure = "schedule_detail_configuration_failure".toLocalized()
        
        static let programTime = "thermostat_detail_program_time".toLocalized()
        static let programCurrent = "thermostat_detail_program_current".toLocalized()
        static let programNext = "thermostat_detail_program_next".toLocalized()
        
        static let offByWindow = "thermostat_detail_off_by_window".toLocalized()
        static let offByCard = "thermostat_detail_off_by_card".toLocalized()
        static let offBySensor = "thermostat_detail_off_by_sensor".toLocalized()
        
        static let programInfo = "thermostat_detail_program_info".toLocalized()
        static let boxInfo = "thermostat_detail_box_info".toLocalized()
        static let arrowInfo = "thermostat_detail_arrow_info".toLocalized()
        
        static let list = "thermostat_detail_list".toLocalized()
        static let mainThermostat = "thermostat_detail_main_thermostat".toLocalized()
        static let otherThermostats = "thermostat_detail_other_thermostats".toLocalized()
    }
    
    struct Notifications {
        static let menu = "menu_notifications".toLocalized()
        static let profile = "notifications_log_profile".toLocalized()
        static let date = "notifications_log_date".toLocalized()
        static let deleteAllTitile = "notification_delete_all_title".toLocalized()
        static let deleteAllMessage = "notification_delete_all_message".toLocalized()
        static let buttonDeleteAll = "notification_delete_button_delete_all".toLocalized()
        static let buttonDeleteOlderThanMonth = "notification_delete_button_delete_older_than_month".toLocalized()
    }
    
    struct General {
        static let cancel = NSLocalizedString("Cancel", comment: "")
        static let close = NSLocalizedString("Close", comment: "")
        static let open = NSLocalizedString("Open", comment: "")
        static let shut = "general_shut".toLocalized()
        static let reveal = "general_reveal".toLocalized()
        static let collapse = "general_collapse".toLocalized()
        static let expand = "general_expand".toLocalized()
        static let save = "save".toLocalized()
        
        static let hourFormat = "general_hour_format".toLocalized()
        
        static let error = "general_error".toLocalized()
        static let ok = "general_ok".toLocalized()
        static let on = "On".toLocalized()
        static let off = "Off".toLocalized()
        static let yes = NSLocalizedString("Yes", comment: "")
        static let no = NSLocalizedString("No", comment: "")
        static let turnOn = "turn_on".toLocalized()
        static let turnOff = "turn_off".toLocalized()
        
        static let monday = "monday".toLocalized()
        static let tuesday = "tuesday".toLocalized()
        static let wednesday = "wednesday".toLocalized()
        static let thursday = "thursday".toLocalized()
        static let friday = "friday".toLocalized()
        static let saturday = "saturday".toLocalized()
        static let sunday = "sunday".toLocalized()
        
        static let mondayShort = "monday_short".toLocalized()
        static let tuesdayShort = "tuesday_short".toLocalized()
        static let wednesdayShort = "wednesday_short".toLocalized()
        static let thursdayShort = "thursday_short".toLocalized()
        static let fridayShort = "friday_short".toLocalized()
        static let saturdayShort = "saturday_short".toLocalized()
        static let sundayShort = "sunday_short".toLocalized()
        
        static let time_just_minutes = "time_just_mintes".toLocalized()
        static let time_hours_and_mintes = "time_hours_and_minutes".toLocalized()
        
        static let channelOffline = "channel_offline".toLocalized()
        
        struct Channel {
            static let captionHotelCard = "channel_caption_hotelcard".toLocalized()
            static let captionAlarmArmament = "channel_caption_alarm_armament".toLocalized()
            static let captionGeneralPurposeMeasurement = "channel_caption_general_purpose_measurment".toLocalized()
            static let captionGeneralPurposeMeter = "channel_caption_general_purpose_meter".toLocalized()
            static let captionFacadeBlinds = "channel_caption_facade_blinds".toLocalized()
            static let captionTerraceAwning = "channel_caption_terrace_awning".toLocalized()
            static let captionProjectorScreen = "channel_caption_projector_screen".toLocalized()
            static let captionCurtain = "channel_caption_curtain".toLocalized()
            static let captionVerticalBlind = "channel_caption_vertical_blind".toLocalized()
            static let captionGarageDoor = "channel_caption_garage_door".toLocalized()
            static let captionPumpSwitch = "channel_caption_pump_switch".toLocalized()
            static let captionHeatOrCouldSourceSwitch = "channel_caption_heat_or_cold_source_switch".toLocalized()
        }
    }
    
    struct Menu {
        static let addDevice = NSLocalizedString("Add I/O device", comment: "")
    }
    
    struct RollerShutterDetail {
        static let motorProblem = "roller_shutter_motor_problem".toLocalized()
        static let calibrationLost = "roller_shutter_calibration_lost".toLocalized()
        static let calibrationFailed = "roller_shutter_calibration_failed".toLocalized()
        static let calibration = "roller_shutter_calibration".toLocalized()
        static let startCalibrationMessage = "roller_shutter_start_calibration_message".toLocalized()
        static let closingPercentage = "roller_shutter_closing_percentage".toLocalized()
        static let openingPercentage = "roller_shutter_opening_percentage".toLocalized()
        static let extensionPercentage = "roller_shutter_extension_percentage".toLocalized()
        static let calibrationNeeded = "roller_shutter_calibration_needed".toLocalized()
    }
    
    struct FacadeBlindsDetail {
        static let slatTilt = "facade_blinds_slat_tilt".toLocalized()
        static let noTilt = "facade_blinds_no_tilt".toLocalized()
    }
    
    struct AuthorizationDialog {
        static let timeout = NSLocalizedString("Time exceeded. Try again.", comment: "")
        static let cloudTitle = NSLocalizedString("Please enter your Supla Cloud login details.", comment: "")
        static let privateTitle = NSLocalizedString("Enter superuser credentials", comment: "")
        
        static let emailAddress = NSLocalizedString("E-MAIL ADDRESS", comment: "")
        static let password = NSLocalizedString("PASSWORD", comment: "")
    }
    
    struct DeviceCatalog {
        static let menu = "menu_device_catalog".toLocalized()
        static let url = "device_list_url".toLocalized()
    }
    
    struct Status {
        static let initializing = "status_initializing".toLocalized()
        static let connecting = "status_connecting".toLocalized()
        static let disconnecting = "status_disconnecting".toLocalized()
        static let awaitingNetwork = "status_awaiting_network".toLocalized()
        static let tryAgain = "status_try_again".toLocalized()
        static let errorUnknown = "status_unknown_error".toLocalized()
        static let errorUnavailable = "status_temporarily_unavailable".toLocalized()
        static let errorInvalidData = "status_incorrect_data".toLocalized()
        static let errorBadCredentials = "status_bad_credentials".toLocalized()
        static let errorClientLimitExceeded = "status_client_limit_exceeded".toLocalized()
        static let errorDeviceDisabled = "status_device_disabled".toLocalized()
        static let errorAccessIdDisabled = "status_access_id_disabled".toLocalized()
        static let errorRegistrationDisabled = "status_registration_disabled".toLocalized()
        static let errorAccessIdNotAssigned = "status_access_id_not_assigned".toLocalized()
        static let errorAccessIdInactive = "status_access_id_inactive".toLocalized()
        static let errorHostNotFound = "status_host_not_found".toLocalized()
    }
    
    struct PinSetup {
        static let title = "pin_setup_title".toLocalized()
        static let header = "pin_setup_header".toLocalized()
        static let repeatPin = "pin_setup_repeat".toLocalized()
        static let different = "pin_setup_entry_different".toLocalized()
        static let useBiometric = "pin_setup_use_biometric".toLocalized()
        static let biometricNotEnrolled = "pin_setup_biometric_not_enrolled".toLocalized()
    }
    
    struct LockScreen {
        static let hello = "lock_screen_hello".toLocalized()
        static let enterPin = "lock_screen_enter_pin".toLocalized()
        static let removePin = "lock_screen_remove_pin".toLocalized()
        static let confirmAuthorizeApp = "lock_screen_confirm_authorize_app".toLocalized()
        static let confirmAuthorizeAccounts = "lock_screen_confirm_authorize_accounts".toLocalized()
        static let wrongPin = "lock_screen_wrong_pin".toLocalized()
        static let forgottenCode = "lock_screen_forgotten_code".toLocalized()
        static let forgottenCodeTitle = "lock_screen_forgotten_code_title".toLocalized()
        static let forgottenCodeMessage = "lock_screen_forgotten_code_message".toLocalized()
        static let forgottenCodeButton = "lock_screen_forgotten_code_button".toLocalized()
        static let biometricPromptReason = "biometric_prompt_subtitle".toLocalized()
        static let pinLocked = "lock_screen_pin_locked".toLocalized()
    }
    
    struct About {
        static let version = "about_version".toLocalized()
        static let license = "about_license".toLocalized()
        static let address = "about_address".toLocalized()
        static let buildTime = "about_build_time".toLocalized()
    }
    
    struct ElectricityMeter {
        static let forwardActiveEnergy = "details_em_forward_active_energy".toLocalized()
        static let reverseActiveEnergy = "details_em_reverse_active_energy".toLocalized()
        static let forwardReactiveEnergy = "details_em_forward_reactive_energy".toLocalized()
        static let reverseReactiveEnergy = "details_em_reverse_reactive_energy".toLocalized()
        static let forwardActiveEnergyShort = "details_em_forward_active_energy_short".toLocalized()
        static let reverseActiveEnergyShort = "details_em_reverse_active_energy_short".toLocalized()
        static let forwardReactiveEnergyShort = "details_em_forward_reactive_energy_short".toLocalized()
        static let reverseReactiveEnergyShort = "details_em_reverse_reactive_energy_short".toLocalized()
        static let frequency = "details_em_frequency".toLocalized()
        static let voltage = "details_em_voltage".toLocalized()
        static let current = "details_em_current".toLocalized()
        static let powerActive = "details_em_power_active".toLocalized()
        static let powerReactive = "details_em_power_reactive".toLocalized()
        static let powerFactor = "details_em_power_factor".toLocalized()
        static let phaseAngle = "details_em_phase_angle".toLocalized()
        static let powerApparent = "details_em_power_apparent".toLocalized()
        static let phase1 = "details_em_phase1".toLocalized()
        static let phase2 = "details_em_phase2".toLocalized()
        static let phase3 = "details_em_phase3".toLocalized()
        static let balanceArithmetic = "details_em_balance_arithmetic".toLocalized()
        static let balanceVector = "details_em_balance_vector".toLocalized()
        static let chartDataType = "details_em_chart_data_type".toLocalized()
        static let phases = "details_em_phases".toLocalized()
        static let balanceHourly = "details_em_balance_hourly".toLocalized()
        static let balanceChartAggregated = "details_em_balance_chart_aggregated".toLocalized()
        static let sum = "details_em_sum".toLocalized()
        static let selectRange = "details_em_select_range".toLocalized()
        static let activeEnergy = "details_em_active_energy".toLocalized()
        static let forwardedEnergy = "details_em_forwarded_energy".toLocalized()
        static let reversedEnergy = "details_em_reversed_energy".toLocalized()
        static let cost = "details_em_cost".toLocalized()
        static let settingsListItem = "details_em_settings_list_item".toLocalized()
        static let settingsTitle = "details_em_settings_title".toLocalized()
        static let totalSufix = "details_em_total_suffix".toLocalized()
        static let currentMonthSuffix = "details_em_current_month_suffix".toLocalized()
        static let lastMonthBalancing = "details_em_last_month_balancing".toLocalized()
        static let phaseToPhaseBalance = "em_phase_to_phase_balance".toLocalized()
        static let allPhases = "em_chart_all_phases".toLocalized()
        static let energyLabel = "details_em_energy_label".toLocalized()
        static let hourMarkerTitle = "details_em_hour_marker_title".toLocalized()
    }
}

extension String {
    func toLocalized() -> String {
        NSLocalizedString(self, tableName: "Localizable", value: "\(NSLocalizedString(self, tableName: "Default", bundle: .main, comment: ""))", comment: "")
    }
    
    func arguments(_ args: CVarArg...) -> String {
        String.init(format: self, args)
    }
}

class LegacyStrings: NSObject {
    @objc
    static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Localizable", value: "\(NSLocalizedString(key, tableName: "Default", bundle: .main, comment: ""))", comment: "")
    }
}
