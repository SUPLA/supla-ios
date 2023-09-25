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
    }
    
    struct Main {
        static let channels = NSLocalizedString("Channels", comment: "")
        static let groups = NSLocalizedString("Groups", comment: "")
        static let scenes = NSLocalizedString("Scenes", comment: "")
        static let newGestureInfo = "dialog_new_gesture_info_text".toLocalized()
    }
    
    struct StandardDetail {
        static let tabGeneral = "standard_detail_general_tab".toLocalized()
        static let tabTimer = "standard_detail_timer_tab".toLocalized()
        static let tabMetrics = "standard_detail_metrics_tab".toLocalized()
        static let tabSchedule = "standard_detail_schedule_tab".toLocalized()
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
    }
    
    struct General {
        static let cancel = NSLocalizedString("Cancel", comment: "")
        static let close = NSLocalizedString("Close", comment: "")
        static let save = "save".toLocalized()
        static let error = "General.error".toLocalized()
        static let hourFormat = "General.hour_format".toLocalized()
        static let ok = "General.ok".toLocalized()
        
        static let on = "On".toLocalized()
        static let off = "Off".toLocalized()
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
