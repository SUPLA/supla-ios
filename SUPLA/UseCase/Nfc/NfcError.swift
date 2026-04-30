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
    
enum NfcError: Error {
    // iOS specific
    case cancelled
    case timeout
    // Common with Android
    case unsupported
    case writeProtected
    case notEnoughSpace
    case wrong
    case protectionFailed
    case writeFailed
    
    var message: String {
        switch (self) {
        case .cancelled: ""
        case .timeout: ""
            
        case .unsupported: Strings.Nfc.Add.errorUnsupported
        case .writeProtected: Strings.Nfc.Add.errorWriteProtected
        case .notEnoughSpace: Strings.Nfc.Add.errorNotEnoughMemory
        case .wrong: Strings.Nfc.Detail.errorWrongTag
        case .protectionFailed: Strings.Nfc.Detail.errorProtectionFailed
        case .writeFailed: Strings.Nfc.Add.errorWriteFailed
        }
    }
}
