//
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

enum SuplaResultCode: Int32, CaseIterable {
    case unknwon = -1
    case temporarilyUnavailable = 4
    case badCredentials = 5
    case accessIdDisabled = 9
    case clientDisabled = 11
    case clientLimitExceeded = 12
    case registrationDisabled = 17
    case accessIdNotAssigned = 18
    case accessIdInactive = 31

    func getTextMessage(authDialog: Bool = false) -> String {
        switch (self) {
        case .unknwon: Strings.Status.errorUnknown
        case .temporarilyUnavailable: Strings.Status.errorUnavailable
        case .badCredentials:
            authDialog ? Strings.Status.errorInvalidData : Strings.Status.errorBadCredentials
        case .accessIdDisabled: Strings.Status.errorAccessIdDisabled
        case .clientDisabled: Strings.Status.errorDeviceDisabled
        case .clientLimitExceeded: Strings.Status.errorClientLimitExceeded
        case .registrationDisabled: Strings.Status.errorRegistrationDisabled
        case .accessIdNotAssigned: Strings.Status.errorAccessIdNotAssigned
        case .accessIdInactive: Strings.Status.errorAccessIdInactive
        }
    }

    static func from(value: Int32) -> SuplaResultCode {
        for code in SuplaResultCode.allCases {
            if (code.rawValue == value) {
                return code
            }
        }

        return .unknwon
    }
}
