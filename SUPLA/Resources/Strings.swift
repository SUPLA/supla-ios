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
    }
    
    struct SwitchDetail {
        static let stateLabel = "switch_detail_state_label".toLocalized()
        static let stateLabelForTimer = "switch_detail_state_label_for_timer".toLocalized()
        static let stateOn = "switch_detail_state_on".toLocalized()
        static let stateOff = "switch_detail_state_off".toLocalized()
        static let stateOffline = "switch_detail_state_offline".toLocalized()
    }
    
    struct General {
        static let cancel = NSLocalizedString("Cancel", comment: "")
        static let close = NSLocalizedString("Close", comment: "")
        static let error = "General.error".toLocalized()
        static let hourFormat = "General.hour_format".toLocalized()
        static let turnOn = "On".toLocalized()
        static let turnOff = "Off".toLocalized()
    }
}

extension String {
    func toLocalized() -> String {
        NSLocalizedString(self, tableName: "Localizable", value: "\(NSLocalizedString(self, tableName: "Default", bundle: .main, comment: ""))", comment: "")
    }
}
