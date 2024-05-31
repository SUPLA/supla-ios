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
    struct NavBar {
        static let titleSupla = NSLocalizedString("supla", comment: "generic title, app name")
    }
    struct Cfg {
        static let appConfigTitle = NSLocalizedString("App Settings", comment: "title headline for settings view")
        static let channelHeight = NSLocalizedString("Channel height", comment: "label for channel height setting")
        static let temperatureUnit = NSLocalizedString("Temperature unit", comment: "label for temperature unit setting")
        static let buttonAutoHide  = NSLocalizedString("Auto-hide buttons", comment: "label for button auto-hide setting")
        static let showChannelInfo = NSLocalizedString("Show ⓘ button", comment: "label for show channel info setting")
        
        static let locationOrdering = NSLocalizedString("Location order", comment: "settings menu label for location order")
        static let showOpeningMode = NSLocalizedString("Roller shutter %", comment: "settings label for reporting opening % rather than closing % in detail views")
        static let showOpeningModeOpening = NSLocalizedString("Opening", comment: "")
        static let showOpeningModeClosing = NSLocalizedString("Closing", comment: "")

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
        static let showLabels = "settings_show_labels".toLocalized()
        static let nightMode = "settings_dark_mode".toLocalized()
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
        
        static let markerOpening = "chart_marker_opening".toLocalized()
        static let markerClosing = "chart_marker_closing".toLocalized()
        
        struct Electricity {
            static let allPhasesTitle = NSLocalizedString("Phase 1+2+3", comment: "")
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
        static let unknownError = NSLocalizedString("Unknown error", comment: "")
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
        static let calibrationNeeded = "roller_shutter_calibration_needed".toLocalized()
    }
    
    struct FacadeBlindsDetail {
        static let slatTilt = "facade_blinds_slat_tilt".toLocalized()
        static let noTilt = "facade_blinds_no_tilt".toLocalized()
    }
    
    struct AuthorizationDialog {
        static let unauthorized = NSLocalizedString("Incorrect Email Address or Password", comment: "")
        static let unavailable = NSLocalizedString("Service temporarily unavailable", comment: "")
        static let timeout = NSLocalizedString("Time exceeded. Try again.", comment: "")
        static let cloudTitle = NSLocalizedString("Please enter your Supla Cloud login details.", comment: "")
        static let privateTitle = NSLocalizedString("Enter superuser credentials", comment: "")
        
        static let emailAddress = NSLocalizedString("E-MAIL ADDRESS", comment: "")
        static let password = NSLocalizedString("PASSWORD", comment: "")
    }
    
    struct DeviceCatalog {
        static let menu = "menu_device_catalog".toLocalized()
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
