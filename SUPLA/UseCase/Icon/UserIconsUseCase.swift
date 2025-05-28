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

enum UserIcons {
    private static let iconsDirectoryName = "icons"
    
    protocol UseCase {
        func getIcon(profileId: Int32, iconId: Int32, icon: UserIcon) -> UIImage?
        func storeIconData(_ data: Data, profileId: Int32, iconId: Int32, type: IconType)
        func existingIconIds(profileId: Int32) -> [Int32]
        func removeProfileIcons(_ profileId: Int32)
    }
    
    final class Implementation: UseCase {
        let sharedDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GroupShared.Groups.iOS)
        
        func getIcon(profileId: Int32, iconId: Int32, icon: UserIcon) -> UIImage? {
            guard let url = getIconUrl(profileId: profileId, iconId: iconId, type: icon.type) else { return nil }
            
            var isDir = ObjCBool(false)
            if (!FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) || isDir.boolValue) {
                SALog.debug("Directory for icon not found `\(url.path)`")
                return nil
            }
            
            guard let data = FileManager.default.contents(atPath: url.path) else { return nil }
            
            return UIImage(data: data)
        }
        
        func storeIconData(_ data: Data, profileId: Int32, iconId: Int32, type: IconType) {
            guard let directoryUrl = getIconDirectoryUrl(profileId: profileId, iconId: iconId) else { return }
            
            var isDir = ObjCBool(false)
            do {
                let exists = FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: &isDir)
                if (!exists) {
                    SALog.debug("Directory for icon not found `\(directoryUrl.path)`, creating...")
                    try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true)
                }
                
                if (exists && !isDir.boolValue) {
                    SALog.debug("Found file which should be a directory `\(directoryUrl.path)`, removing...")
                    try FileManager.default.removeItem(at: directoryUrl)
                    try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true)
                }
                
                let fileUrl = directoryUrl.appendFilename(type.rawValue)
                if (FileManager.default.fileExists(atPath: fileUrl.path)) {
                    SALog.debug("Icon already exists `\(fileUrl.path)`, overwritting...")
                    try FileManager.default.removeItem(at: fileUrl)
                }
                
                FileManager.default.createFile(atPath: fileUrl.path, contents: data)
            } catch {
                SALog.error("Could not create icon: \(error)")
            }
        }
        
        func existingIconIds(profileId: Int32) -> [Int32] {
            guard let sharedDirectory else { return [] }
            
            let iconsDirectory = sharedDirectory
                .appendDirname(iconsDirectoryName)
                .appendDirname("\(profileId)")
            
            var isDir = ObjCBool(false)
            if (!FileManager.default.fileExists(atPath: iconsDirectory.path, isDirectory: &isDir) || !isDir.boolValue) {
                SALog.warning("Directory for icon not found `\(iconsDirectory.path)`")
                return []
            }
            
            var result: [Int32] = []
            do {
                let items = try FileManager.default.contentsOfDirectory(atPath: iconsDirectory.path)
                
                for item in items {
                    if let id = Int32(item) {
                        result.append(id)
                    }
                }
            } catch {
                SALog.error("Could not read icons in directory \(iconsDirectory.path): \(error.localizedDescription)")
            }
            
            return result
        }
        
        func removeProfileIcons(_ profileId: Int32) {
            guard let directory = getProfileDirectoryUrl(profileId) else { return }
            
            do {
                try FileManager.default.removeItem(at: directory)
                SALog.info("Removed icons directory for profile \(profileId)")
            } catch {
                SALog.warning("Could not remove icons directory for profile \(profileId): \(error.localizedDescription)")
            }
        }
        
        private func getProfileDirectoryUrl(_ profileId: Int32) -> URL? {
            guard let sharedDirectory else { return nil }
            
            return sharedDirectory
                .appendDirname(iconsDirectoryName)
                .appendDirname("\(profileId)")
        }
        
        private func getIconDirectoryUrl(profileId: Int32, iconId: Int32) -> URL? {
            return getProfileDirectoryUrl(profileId)?
                .appendDirname("\(iconId)")
        }
        
        private func getIconUrl(profileId: Int32, iconId: Int32, type: IconType) -> URL? {
            return getIconDirectoryUrl(profileId: profileId, iconId: iconId)?
                .appendFilename(type.rawValue)
        }
        
        private func iconExists(profileId: Int32, iconId: Int32, type: IconType) -> Bool {
            guard let url = getIconUrl(profileId: profileId, iconId: iconId, type: type) else { return false }
            var isDir = ObjCBool(false)
            return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && !isDir.boolValue
        }
    }
    
    enum IconType: String, CaseIterable {
        case light0, light1, light2, light3
        case night0, night1, night2, night3
        
        var isNightType: Bool {
            switch self {
            case .light0, .light1, .light2, .light3: false
            case .night0, .night1, .night2, .night3: true
            }
        }
        
        var index: Int {
            switch self {
            case .light0: 0
            case .light1: 1
            case .light2: 2
            case .light3: 3
            case .night0: 0
            case .night1: 1
            case .night2: 2
            case .night3: 3
            }
        }
        
        func getData(at index: Int, from data: [String], orFrom nightData: [String]?) -> Data? {
            if (isNightType) {
                if let nightData, nightData.count > index {
                    return Data(base64Encoded: nightData[index])
                }
            } else {
                if (data.count > index) {
                    return Data(base64Encoded: data[index])
                }
            }
            
            return nil
        }
    }
}
