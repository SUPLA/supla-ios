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
import RxTest
import RxSwift

@testable import SUPLA

final class CreateChannelWithChildrenUseCaseTests: UseCaseTest<Void> {
    
    private lazy var useCase: CreateChannelWithChildrenUseCase! = { CreateChannelWithChildrenUseCaseImpl() }()
    
    override func tearDown() {
        useCase = nil
        super.tearDown()
    }
    
    func test_shouldBuildChannelWithChildren() {
        // given
        let channelId: Int32 = 123
        let channel = SAChannel.mock(channelId)
        let allChannels = [
            channel,
            SAChannel(testContext: nil),
            SAChannel.mock(11),
            SAChannel(testContext: nil),
            SAChannel.mock(12),
            SAChannel.mock(14),
            SAChannel(testContext: nil)
        ]
        let relations = [
            SAChannelRelation.mock(1, channelId: 10, type: .defaultType),
            SAChannelRelation.mock(channelId, channelId: 11, type: .mainThermometer),
            SAChannelRelation.mock(channelId, channelId: 12, type: .meter),
            SAChannelRelation.mock(2, channelId: 13, type: .auxThermometerFloor)
        ]
        
        // when
        let result = useCase.invoke(channel, allChannels: allChannels, relations: relations)
        
        // then
        XCTAssertEqual(result.channel, channel)
        XCTAssertEqual(result.children.count, 2)
        XCTAssertTrue(collectionContains(result.children, item: allChannels[2], relation: .mainThermometer))
        XCTAssertTrue(collectionContains(result.children, item: allChannels[4], relation: .meter))
    }
    
    private func collectionContains(_ collection: [ChannelChild], item: SAChannel, relation: ChannelRelationType) -> Bool {
        var result = false
        
        collection.forEach {
            if ($0.channel == item && $0.relationType == relation) {
                result = true
            }
        }
        
        return result
    }
}
