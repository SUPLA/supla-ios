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


extension SAChannelConfig {
    
    var channelConfigType: ChannelConfigType {
        ChannelConfigType.from(value: UInt8(config_type))
    }
    
    func configAsSuplaConfig() -> SuplaChannelConfig? {
        guard let configData = config?.data(using: .utf8) else { return nil }
            
        if (channelConfigType == .generalPurposeMeter) {
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode(SuplaChannelGeneralPurposeMeterConfig.self, from: configData)
        }
        
        if (channelConfigType == .generalPurposeMeasurement) {
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode(SuplaChannelGeneralPurposeMeasurementConfig.self, from: configData)
        }
        
        if (channelConfigType == .facadeBlind) {
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode(SuplaChannelFacadeBlindConfig.self, from: configData)
        }
        
        if (channelConfigType == .container) {
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode(SuplaChannelContainerConfig.self, from: configData)
        }
        
        if let channel = channel {
            return SuplaChannelConfig(remoteId: channel.remote_id, channelFunc: channel.func, crc32: 0)
        } else {
            return nil
        }
    }
    
}
