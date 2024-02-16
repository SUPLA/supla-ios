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

final class GeneralPurposeMeasurementIconNameProducer: IconNameProducer {
    func accepts(function: Int32) -> Bool {
        return function == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
    }
    
    func produce(iconData: IconData) -> String {
        return addStateSufix(name: altIcon(iconData.altIcon), state: iconData.state)
    }
    
    private func altIcon(_ altIcon: Int32) -> String {
        switch (altIcon) {
        case 1: .Icons.fncGpm1
        case 2: .Icons.fncGpm2
        case 3: .Icons.fncGpm3
        case 4: .Icons.fncGpm4
        case 5: .Icons.fncGpmAir1
        case 6: .Icons.fncGpmAir2
        case 7: .Icons.fncGpmAir3
        case 8: .Icons.fncGpmChimnay
        case 9: .Icons.fncGpmCurrent1
        case 10: .Icons.fncGpmCurrent2
        case 11: .Icons.fncGpmFan1
        case 12: .Icons.fncGpmFan2
        case 13: .Icons.fncGpmInsolation1
        case 14: .Icons.fncGpmInsolation2
        case 15: .Icons.fncGpmMultimeter
        case 16: .Icons.fncGpmPm1
        case 17: .Icons.fncGpmPm2_5
        case 18: .Icons.fncGpmPm10
        case 19: .Icons.fncGpmProcessor
        case 20: .Icons.fncGpmSmog1
        case 21: .Icons.fncGpmSmog2
        case 22: .Icons.fncGpmSmog3
        case 23: .Icons.fncGpmSmog4
        case 24: .Icons.fncGpmSmog5
        case 25: .Icons.fncGpmSmog6
        case 26: .Icons.fncGpmSound1
        case 27: .Icons.fncGpmSound2
        case 28: .Icons.fncGpmSound3
        case 29: .Icons.fncGpmTransfer
        case 30: .Icons.fncGpmVoltage1
        case 31: .Icons.fncGpmVoltage2
        default: .Icons.fncGpm5
        }
    }
    
}
