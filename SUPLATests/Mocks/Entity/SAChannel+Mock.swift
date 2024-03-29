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
    static func mock(
        _ remoteId: Int32 = 0,
        function: Int32 = 0,
        caption: String? = nil,
        value: SAChannelValue? = nil,
        config: SAChannelConfig? = nil
    ) -> SAChannel {
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = function
        channel.caption = caption
        channel.value = value
        channel.config = config
        return channel
    }
}
