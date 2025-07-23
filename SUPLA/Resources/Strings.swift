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
        static let batteryLevelWarning = "settings_battery_level_warnign".toLocalized()
    }
    
    struct CreateProfile {
        static let creationTitle = "create_profile_title_create".toLocalized()
        static let modificationTitle = "create_profile_title_modify".toLocalized()
        
        static let yourAccountLabel = NSLocalizedString("Your account", comment: "account configuration settings screen")
        static let profileNameLabel = NSLocalizedString("NAME", comment: "label for profile name")
        static let advancedSettings = NSLocalizedString("Advanced settings", comment: "Label for advanced settings toggle on authentication screen")
        static let accessIdSegment = NSLocalizedString("Access ID", comment: "")
        static let emailSegment = NSLocalizedString("Email", comment: "")
        static let accessIdLabel = NSLocalizedString("ACCESS IDENTIFIER", comment: "")
        static let emailLabel = NSLocalizedString("E-MAIL ADDRESS", comment: "")
        static let serverLabel = NSLocalizedString("SERVER ADDRESS", comment: "")
        static let passwordLabel = General.password.uppercased()
        static let wizardWarningText = NSLocalizedString("In Access ID authentication mode you won't be able to use automatic Add device wizard. However you will still be able to add it by manual Add device procedure.", comment: "")
        static let createAccountPrompt = NSLocalizedString("Don't have an account in Supla Cloud yet?", comment: "")
        static let createAccountButton = NSLocalizedString("Create", comment: "")
        
        static let basicWarningTitle = "create_profile_basic_warning_title".toLocalized()
        static let basicWarningMessage = "create_profile_basic_warning_message".toLocalized()
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
        static let dataTypeLabel = "history_data_type".toLocalized()
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
            static let execute = "scenes_action_buttons_execute".toLocalized()
            static let abort = "scenes_action_buttons_abort".toLocalized()
            static let abortAndExecute = "scenes_action_buttons_abort_and_execute".toLocalized()
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
        static let tabOcr = "OCR"
    }
    
    struct SwitchDetail {
        static let stateLabel = "switch_detail_state_label".toLocalized()
        static let stateLabelForTimer = "switch_detail_state_label_for_timer".toLocalized()
        static let stateOn = "switch_detail_state_on".toLocalized()
        static let stateOff = "switch_detail_state_off".toLocalized()
        static let stateOffline = "switch_detail_state_offline".toLocalized()
        static let overcurrentWarning = "overcurrent_warning".toLocalized()
        static let overcurrentQuestion = "overcurrent_question".toLocalized()
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
        static let calibrationError = "thermostat_calibration_error".toLocalized()
        
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
        static let openClose = NSLocalizedString("Open Close", comment: "")
        static let shut = "general_shut".toLocalized()
        static let reveal = "general_reveal".toLocalized()
        static let collapse = "general_collapse".toLocalized()
        static let expand = "general_expand".toLocalized()
        static let stop = "general_stop".toLocalized()
        static let toggle = "general_toggle".toLocalized()
        static let save = "save".toLocalized()
        static let next = "next".toLocalized()
        static let password = "password".toLocalized()
        static let start = "start".toLocalized()
        static let exit = "exit".toLocalized()
        static let back = "general_back".toLocalized()
        static let stateOpened = "general_state_opened".toLocalized()
        static let stateClosed = "general_state_closed".toLocalized()
        
        static let hourFormat = "general_hour_format".toLocalized()
        
        static let error = "general_error".toLocalized()
        static let ok = "general_ok".toLocalized()
        static let warning = "general_warning".toLocalized()
        static let on = "On".toLocalized()
        static let off = "Off".toLocalized()
        static let yes = NSLocalizedString("Yes", comment: "")
        static let no = NSLocalizedString("No", comment: "")
        static let turnOn = "turn_on".toLocalized()
        static let turnOff = "turn_off".toLocalized()
        static let delete = "general_delete".toLocalized()
        
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
        static let channelNotFound = "channel_not_found".toLocalized()
        static let sceneInactive = "scene_inactive".toLocalized()
        
        static let channel = "general_channel".toLocalized()
        static let group = "general_group".toLocalized()
        static let scene = "general_scene".toLocalized()
        static let function = "general_function".toLocalized()
        static let profile = "general_profile".toLocalized()
        static let action = "general_action".toLocalized()
        static let select = "general_select".toLocalized()
        
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
            static let captionHumidity = "channel_caption_humidity".toLocalized()
            static let captionHumidityAndTemperature = "channel_caption_humidityandtemperature".toLocalized()
            static let captionContainer = "channel_caption_container".toLocalized()
            static let captionWaterTank = "channel_caption_water_tank".toLocalized()
            static let captionSepticTank = "channel_caption_septic_tank".toLocalized()
            static let captionContainerLevelSensor = "channel_caption_container_level_sensor".toLocalized()
            static let captionFloodSensor = "channel_caption_flood_sensor".toLocalized()
            
            static let batteryLevel = "channel_battery_level".toLocalized()
            
            static let statusAwaiting = "channel_status_awaiting".toLocalized()
            static let statusUpdating = "channel_status_updating".toLocalized()
            static let statusNotAvailable = "channel_status_not_available".toLocalized()
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
        static let password = General.password.uppercased()
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
        static let errorCantConnectToHost = "status_cant_connect_to_host".toLocalized()
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
        static let confirmAuthorizeRangeChange = "lock_screen_confirm_authorize_range_change".toLocalized()
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
        static let voltagePhaseAngle12 = "details_em_voltage_phase_angle_12".toLocalized()
        static let voltagePhaseAngle13 = "details_em_voltage_phase_angle_13".toLocalized()
        static let voltagePhaseSequence = "details_em_voltage_phase_sequence".toLocalized()
        static let currentPhaseSequence = "details_em_current_phase_sequence".toLocalized()
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
        static let electricGridParameters = "em_electric_grid_parameters".toLocalized()
        static let allPhases = "em_chart_all_phases".toLocalized()
        static let energyLabel = "details_em_energy_label".toLocalized()
        static let hourMarkerTitle = "details_em_hour_marker_title".toLocalized()
        static let infoSwipe = "details_em_info_swipe".toLocalized()
        static let infoDataType = "details_em_info_data_type".toLocalized()
        static let infoRange = "details_em_info_range".toLocalized()
        static let infoDataSetSinglePhase = "details_em_info_data_set_single_phase".toLocalized()
        static let infoDataSetMultiplePhase = "details_em_info_data_set_multiple_phase".toLocalized()
    }
    
    struct ImpulseCounter {
        static let meterValue = "details_em_meter_value".toLocalized()
        static let currentMonthConsumption = "details_em_current_month_consumption".toLocalized()
    }
    
    struct CounterPhoto {
        static let toolbar = "counter_photo_toolbar".toLocalized()
        static let counterArea = "counter_photo_counter_area".toLocalized()
        static let originalPhoto = "counter_photo_original_photo".toLocalized()
        static let settings = "counter_photo_settings".toLocalized()
        static let history = "counter_photo_history".toLocalized()
        static let error = "counter_photo_error".toLocalized()
        static let loadingError = "counter_photo_loading_error".toLocalized()
    }
    
    struct Valve {
        static let warningManuallyClosed = "valve_warning_manually_closed".toLocalized()
        static let warningFlooding = "valve_warning_flooding".toLocalized()
        static let floodingAlarmMessage = "flooding_alarm_message".toLocalized()
        static let warningManuallyClosedShort = "valve_warning_manually_closed_short".toLocalized()
        static let warningFloodingShort = "valve_warning_flooding_short".toLocalized()
        static let warningMotorProblem = "valve_warning_motor_problem".toLocalized()
        static let warningMotorProblemOpening = "valve_warning_motor_problem_opening".toLocalized()
        static let warningMotorProblemClosing = "valve_warning_motor_problem_closing".toLocalized()
        static let detailSensors = "valve_detail_sensors".toLocalized()
        static let actionError = "valve_action_error".toLocalized()
        static let errorSensorOffline = "valve_error_sensor_offline".toLocalized()
    }
    
    struct State {
        static let channelId = "state_channel_id".toLocalized()
        static let ipAddress = "state_ip_address".toLocalized()
        static let macAddress = "state_mac_address".toLocalized()
        static let batteryLevel = "state_battery_level".toLocalized()
        static let batteryPowered = "state_battery_powered".toLocalized()
        static let wifiRssi = "state_wifi_rssi".toLocalized()
        static let wifiSignalStrength = "state_wifi_signal_strength".toLocalized()
        static let bridgeNodeOnline = "state_bridge_node_online".toLocalized()
        static let bridgeNodeSignal = "state_bridge_node_signal".toLocalized()
        static let uptime = "state_uptime".toLocalized()
        static let connectionTime = "state_connection_time".toLocalized()
        static let batteryHealth = "state_battery_health".toLocalized()
        static let connectionResetCause = "state_connection_reset_cause".toLocalized()
        static let lightSourceLifespan = "state_light_source_lifespan".toLocalized()
        static let sourceOperatingTime = "state_source_operating_time".toLocalized()
        static let dialogIndex = "state_dialog_index".toLocalized()
        static let lightsourceSettings = "state_dialog_lightsource_settings".toLocalized()
        static let switchCycleCount = "state_switch_cycle_count".toLocalized()
        static let uptimeValue = "channel_state_uptime".toLocalized()
        static let connectionResetCauseUnknown = "lastconnectionresetcause_unknown".toLocalized()
        static let connectionResetCauseActivityTimeout = "lastconnectionresetcause_activity_timeout".toLocalized()
        static let connectionResetCauseWifiConnectionLost = "lastconnectionresetcause_wifi_connection_lost".toLocalized()
        static let connectionResetCauseServerConnectionLost = "lastconnectionresetcause_server_connection_lost".toLocalized()
    }
    
    struct ChangeCaption {
        static let header = "change_caption_header".toLocalized()
        static let channelName = "change_caption_channel_name".toLocalized()
        static let groupName = "change_caption_group_name".toLocalized()
        static let sceneName = "change_caption_scene_name".toLocalized()
        static let locationName = "change_caption_location_name".toLocalized()
    }
    
    struct Container {
        static let fillLevel = "container_fill_level".toLocalized()
        static let warningLevel = "container_warning_level".toLocalized()
        static let alarmLevel = "container_alarm_level".toLocalized()
        static let invalidSensorState = "container_invalid_sensor_state".toLocalized()
        static let soundAlarm = "container_sound_alarm".toLocalized()
    }
    
    struct CarPlay {
        static let label = "car_play_label".toLocalized()
        static let voiceMessages = "car_play_voice_messages".toLocalized()
        static let action = "car_play_action".toLocalized()
        static let displayName = "car_play_display_name".toLocalized()
        static let executionError = "car_play_execution_error".toLocalized()
        static let executing = "car_play_executing".toLocalized()
        static let deleteTitle = "car_play_delete_title".toLocalized()
        static let deleteMessage = "car_play_delete_message".toLocalized()
        static let confirmDelete = "car_play_confirm_delete".toLocalized()
        static let empty = "car_play_empty".toLocalized()
    }
    
    struct Widget {
        static let emptyHint = "widget_empty_hint".toLocalized()
        static let controlHint = "widget_control_hint".toLocalized()
        static var actionsName = "widgets_actions_name".toLocalized()
        static let actionsDescription = "widgets_actions_description".toLocalized()
        static let unknownAction = "widgets_unknown_action".toLocalized()
        static let valueTitle = "widgets_value_title".toLocalized()
        static let valueDescription = "widgets_value_description".toLocalized()
        static let configurationError = "widget_configuration_error".toLocalized()
        static let singleActionTitle = "widgets_single_action_title".toLocalized()
        static let singleActionDescription = "widgets_single_action_description".toLocalized()
        static let doubleActionTitle = "widgets_double_action_title".toLocalized()
        static let doubleActionDescription = "widgets_double_action_description".toLocalized()
    }
    
    struct AddWizard {
        static let deviceRegistrationRequestTimeout = "device_reg_request_timeout".toLocalized()
        static let enablingRegistrationTimeout = "enabling_registration_timeout".toLocalized()
        static let scanTimeout = "wizard_scan_timeout".toLocalized()
        static let deviceNotFound = "wizard_iodevice_notfound".toLocalized()
        static let connectTimeout = "wizard_connect_timeout".toLocalized()
        static let configureTimeout = "wizard_configure_timeout".toLocalized()
        static let wifiError = "wizard_wifi_error".toLocalized()
        static let resultNotCompatible = "wizard_result_compat_error".toLocalized()
        static let resultConnectionError = "wizard_result_conn_error".toLocalized()
        static let resultFailed = "wizard_result_failed".toLocalized()
        static let reconnectTimeout = "wizard_reconnect_timeout".toLocalized()
        static let step1Welcome = "add_wizard_step_1_welcome".toLocalized()
        static let step1Continue = "add_wizard_step_1_continue".toLocalized()
        static let step2Message = "add_wizard_step_2_message".toLocalized()
        static let networkName = "add_wizard_network_name".toLocalized()
        static let step3Message1 = "add_wizard_step_3_message_1".toLocalized()
        static let step3Message2 = "add_wizard_step_3_message_2".toLocalized()
        static let step3Message3 = "add_wizard_step_3_message_3".toLocalized()
        static let done = "wizard_done".toLocalized()
        static let doneExplanation = "wizard_done_explanations".toLocalized()
        static let addMore = "add_wizard_add_more".toLocalized()
        static let tryAgain = "add_wizard_repeat".toLocalized()
        static let deviceParameters = "wizard_iodev_data".toLocalized()
        static let deviceName = "wizard_iodev_name".toLocalized()
        static let deviceFirmware = "wizard_iodev_firmware".toLocalized()
        static let deviceMac = "wizard_iodev_mac".toLocalized()
        static let lastState = "wizard_iodev_laststate".toLocalized()
        static let notAvailable = "add_wizard_is_not_available".toLocalized()
        static let rememberPassword = "add_wizard_remember_passwd".toLocalized()
        static let autoMode = "add_wizard_auto_mode".toLocalized()
        static let manualModeMessage = "add_wizard_manual_mode_message".toLocalized()
        static let goToSettings = "add_wizard_manual_mode_settings".toLocalized()
        static let missingLocation = "add_wizard_missing_location".toLocalized()
        static let cloudFollowupTitle = "add_device_needs_cloud_title".toLocalized()
        static let cloudFollowupMessage = "add_device_needs_cloud_message".toLocalized()
        static let cloudFollowupClose = "add_device_needs_cloud_close".toLocalized()
        static let cloudFollowupGoToCloud = "add_device_needs_cloud_go_to_cloud".toLocalized()
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

@objc
class LegacyStrings: NSObject {
    @objc
    static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Localizable", value: "\(NSLocalizedString(key, tableName: "Default", bundle: .main, comment: ""))", comment: "")
    }
    
    @objc static let stateChannelId = Strings.State.channelId
    @objc static let stateIpAddress = Strings.State.ipAddress
    @objc static let stateMacAddress = Strings.State.macAddress
    @objc static let stateBatteryLevel = Strings.State.batteryLevel
    @objc static let stateBatteryPowered = Strings.State.batteryPowered
    @objc static let stateWifiRssi = Strings.State.wifiRssi
    @objc static let stateWifiSignalStrength = Strings.State.wifiSignalStrength
    @objc static let stateBridgeNodeOnline = Strings.State.bridgeNodeOnline
    @objc static let stateBridgeNodeSignal = Strings.State.bridgeNodeSignal
    @objc static let stateUptime = Strings.State.uptime
    @objc static let stateConnectionUptime = Strings.State.connectionTime
    @objc static let stateBatteryHealth = Strings.State.batteryHealth
    @objc static let stateConnectionResetCause = Strings.State.connectionResetCause
    @objc static let stateLightSourceLifespan = Strings.State.lightSourceLifespan
    @objc static let stateSourceOperatingTime = Strings.State.sourceOperatingTime
    
    @objc static let stateConnectionResetCauseUnknown = Strings.State.connectionResetCauseUnknown
    @objc static let stateConnectionResetCauseActivityTimeout = Strings.State.connectionResetCauseActivityTimeout
    @objc static let stateConnectionResetCauseWifiConnectionLost = Strings.State.connectionResetCauseWifiConnectionLost
    @objc static let stateConnectionResetCauseServerConnectionLost = Strings.State.connectionResetCauseServerConnectionLost
}
