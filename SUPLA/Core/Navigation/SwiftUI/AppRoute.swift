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

import CoreData
import Foundation

enum AppRoot: Hashable {
    case status
    case main
    case unlockApp(action: LockScreenFeature.UnlockAction)
}

enum MainTab: Hashable {
    case channels
    case groups
    case scenes
}

enum ConnectionTakeoverPolicy: Hashable {
    case allowed
    case deferred
}

enum AppRoute: Hashable {
    case settings
    case locationOrdering
    case profiles
    case addWizard
    case about
    case notificationsLog
    case deviceCatalog
    case profile(profileId: Int32, withLockCheck: Bool)
    case createAccountWeb
    case removeAccountWeb(needsRestart: Bool, serverAddress: String?)
    case legacyDetail(type: LegacyDetailType, channelRemoteId: Int32)
    case standardDetail(item: ItemBundle, pages: [DetailPage])
    case impulseCounterDetail(item: ItemBundle, pages: [DetailPage])
    case rgbwDetail(item: ItemBundle, pages: [DetailPage])
    case pinSetup(scope: LockScreenScope)
    case lockScreen(action: LockScreenFeature.UnlockAction)
    case counterPhoto(channelId: Int32)
    case carPlayList
    case carPlayAdd
    case carPlayEdit(id: NSManagedObjectID)
    case developerOptions
    case legacyDimmerSettings(channelId: Int32)
    case callNfcAction(url: URL)
    case nfcTagsList
    case editNfcTag(uuid: String, readOnly: Bool?)
    case nfcTagDetail(uuid: String)
}

extension AppRoute {
    var connectionTakeoverPolicy: ConnectionTakeoverPolicy {
        switch self {
        case .addWizard:
            .deferred

        default:
            .allowed
        }
    }
}

extension AppRoot {
    var connectionTakeoverPolicy: ConnectionTakeoverPolicy {
        switch self {
        case .unlockApp:
            .deferred

        case .status,
             .main:
            .allowed
        }
    }
}
