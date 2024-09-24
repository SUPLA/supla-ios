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

import XCTest
@testable import SUPLA

final class ChannelWithChildrenTests: XCTestCase {
    
    func test_shouldFlattenAllDescendant() {
        // given
        let channel = SAChannel.mock()
        let child3 = ChannelChild(channel: SAChannel.mock(3), relationType: .mainThermometer)
        let child2 = ChannelChild(channel: SAChannel.mock(2), relationType: .masterThermostat, children: [child3])
        let child1 = ChannelChild(channel: SAChannel.mock(1), relationType: .meter)
        let channelWithChildren = ChannelWithChildren(channel: SAChannel.mock(), children: [child1, child2])
        
        // when
        let result = channelWithChildren.allDescendantFlat
        
        // then
        XCTAssertEqual(result.map { $0.channel.remote_id}, [1, 2, 3])
        XCTAssertEqual(result, [child1, child2, child3])
    }
}
