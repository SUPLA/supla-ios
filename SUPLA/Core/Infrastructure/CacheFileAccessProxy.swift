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

protocol CacheFileAccessProxy: CacheFileAccess {
    var cacheDir: URL? { get }
}

class CacheFileAccessProxyImpl: CacheFileAccessProxy {
    private let fileManager = FileManager()
    
    var cacheDir: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    func delete(file: CacheFileAccessFile) -> Bool {
        guard let cacheDir = cacheDir else { return false }
        do {
            try fileManager.removeItem(at: file.file(cacheDir))
            return true
        } catch {
            SALog.debug("Could not delete directory \(file.name): \(error.localizedDescription)")
            return false
        }
    }
    
    func dirExists(name: String) -> Bool {
        guard let cacheDir = cacheDir else { return false }
        var isDirectory: ObjCBool = false
        return fileManager.fileExists(atPath: cacheDir.appendDirname(name).path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
    
    func fileExists(file: CacheFileAccessFile) -> Bool {
        guard let cacheDir = cacheDir else { return false }
        var isDirectory: ObjCBool = false
        return fileManager.fileExists(atPath: file.file(cacheDir).path, isDirectory: &isDirectory) && !isDirectory.boolValue
    }
    
    func mkdir(name: String) -> Bool {
        guard let cacheDir = cacheDir else { return false }
        
        do {
            try fileManager.createDirectory(at: cacheDir.appendDirname(name), withIntermediateDirectories: true)
            return true
        } catch {
            SALog.debug("Could not create directory \(name): \(error.localizedDescription)")
            return false
        }
    }
    
    func readBytes(file: CacheFileAccessFile) throws -> KotlinByteArray {
        guard let cacheDir = cacheDir else {
            throw GeneralError.illegalState(message: "Could not get cache directory")
        }
        
        return KotlinByteArray.from(data: try Data(contentsOf: file.file(cacheDir)))
    }
    
    func writeBytes(file: CacheFileAccessFile, bytes: KotlinByteArray) throws {
        guard let cacheDir = cacheDir else {
            throw GeneralError.illegalState(message: "Could not get cache directory")
        }
        try bytes.toData().write(to: file.file(cacheDir))
    }
}

extension URL {
    func appendFilename(_ name: String) -> URL {
        if #available(iOS 16.0, *) {
            appending(path: name, directoryHint: .notDirectory)
        } else {
            appendingPathComponent(name)
        }
    }
    
    func appendDirname(_ name: String) -> URL {
        if #available(iOS 16.0, *) {
            appending(path: name, directoryHint: .isDirectory)
        } else {
            appendingPathComponent(name)
        }
    }
}

extension CacheFileAccessFile {
    func file(_ cacheUrl: URL) -> URL {
        if let dirname = directory {
            return cacheUrl.appendDirname(dirname).appendFilename(name)
        } else {
            return cacheUrl.appendFilename(name)
        }
    }
}
