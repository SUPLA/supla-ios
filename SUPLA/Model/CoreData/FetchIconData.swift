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
    
struct FetchIconData: Changeable, Equatable {
    let function: Int32
    let altIcon: Int32
    var profileId: Int32
    var state: ChannelState = .notUsed
    var type: IconType = .single
    var userIconId: Int32 = 0
    var subfunction: ThermostatSubfunction? = nil // Thermostat specific parameter
}
