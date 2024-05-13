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

extension SAChannel {
    func item() -> ItemBundle {
        ItemBundle(remoteId: remote_id, deviceId: device_id, subjectType: .channel, function: self.func)
    }

    func getTimerEndDate() -> Date? {
        ev?.channelState().countdownEndsAt()
    }

    @objc func isFacadeBlindClosed() -> Bool {
        if (self.func == SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND) {
            value?.asFacadeBlindValue().position ?? 0 >= 100
        } else {
            false
        }
    }

    func hasHistory() -> Bool {
        switch (self.func) {
            case SUPLA_CHANNELFNC_THERMOMETER,
                 SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
                 SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER,
                 SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT: true
            default: false
        }
    }
}
