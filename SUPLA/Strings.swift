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
        static let locationOrdering = NSLocalizedString("Location order", comment: "settings menu label for location order")
        static let showOpeningMode = NSLocalizedString("Roller shutter %", comment: "settings label for reporting opening % rather than closing % in detail views")
        static let showOpeningModeOpening = NSLocalizedString("Opening", comment: "")
        static let showOpeningModeClosing = NSLocalizedString("Closing", comment: "")
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
}
