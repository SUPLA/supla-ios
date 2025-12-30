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

import CommonCrypto
import Foundation
import SwiftUI

extension String {
    func substringIndexed(to: Int) -> String {
        let index = if (to < 0) {
            self.index(self.startIndex, offsetBy: self.count + to)
        } else {
            self.index(self.startIndex, offsetBy: to)
        }
        return String(self[..<index])
    }
    
    func substring(range: NSRange) -> String? {
        if let range = Swift.Range(range, in: self) {
            return String(self[range])
        } else {
            return nil
        }
    }
    
    func copyToCharArray<T>(array: inout T, capacity: Int) {
        withUnsafeMutablePointer(to: &array) {
            $0.withMemoryRebound(to: Int8.self, capacity: capacity) { pointer in
                var lenght = count + 1
                if (lenght > capacity) {
                    lenght = capacity
                }
                
                withCString {
                    _ = snprintf(ptr: pointer, lenght, $0)
                }
            }
        }
    }
    
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest) }
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func utf8StringToBuffer(_ buffer: UnsafeMutablePointer<CChar>, withSize size: Int) {
        memset(buffer, 0, size)
         
        var len = self.count
        if len > size - 1 {
            len = size - 1
        }
         
        while len > 0 {
            let substring = String(self.prefix(len))
            guard let cstring = substring.cString(using: .utf8) else {
                len = 0
                continue
            }
             
            let cstringLength = strnlen(cstring, size)
            if cstringLength < size {
                memcpy(buffer, cstring, cstringLength)
                len = 0
            } else {
                len -= 1
            }
        }
    }
    
    func toColorOrNull() -> UIColor? {
        var hex = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
            
        if hex.count == 6 {
            guard
                let r = Int(String(hex.prefix(2)), radix: 16),
                let g = Int(String(hex.dropFirst(2).prefix(2)), radix: 16),
                let b = Int(String(hex.dropFirst(4).prefix(2)), radix: 16)
            else {
                return nil
            }
                
            return UIColor(red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0, alpha: 1)
        }
            
        if hex.count == 3 {
            let chars = Array(hex)
            guard
                let r = Int(String(repeating: chars[0], count: 2), radix: 16),
                let g = Int(String(repeating: chars[1], count: 2), radix: 16),
                let b = Int(String(repeating: chars[2], count: 2), radix: 16)
            else {
                return nil
            }
                
            return UIColor(red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0, alpha: 1)
        }
            
        return nil
    }
    
    static func fromC<T>(_ address: T) -> String {
        return withUnsafePointer(to: address) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                String(cString: $0)
            }
        }
    }
}

extension String? {
    func ifEmptyOrNil(_ elseValue: String) -> String {
        if let self, !self.isEmpty {
            self
        } else {
            elseValue
        }
    }
}

@objc extension NSString {
    func utf8StringToBuffer(_ buffer: UnsafeMutablePointer<CChar>, withSize size: Int) {
        let str = self as String
        str.utf8StringToBuffer(buffer, withSize: size)
    }
}
