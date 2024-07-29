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

@testable import SUPLA
import XCTest

final class ReadGroupTiltingDetailsUseCaseTests: UseCaseTest<TiltingDetails> {
    private lazy var groupRelationRepository: ChannelGroupRelationRepositoryMock! = ChannelGroupRelationRepositoryMock()
    private lazy var channelConfigRepository: ChannelConfigRepositoryMock! = ChannelConfigRepositoryMock()
    
    private lazy var useCase: ReadGroupTiltingDetailsUseCase! = ReadGroupTiltingDetailsUseCaseImpl()
    
    private var jsonEncoder = JSONEncoder()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ChannelGroupRelationRepository).self, groupRelationRepository!)
        DiContainer.shared.register(type: (any ChannelConfigRepository).self, channelConfigRepository!)
    }
    
    override func tearDown() {
        groupRelationRepository = nil
        channelConfigRepository = nil
        
        useCase = nil
        
        super.tearDown()
    }
    
    func test_shouldGetUnknownWhenGroupIsEmpty() {
        // given
        let remoteId: Int32 = 123
        groupRelationRepository.getRelationsForGroupReturns = .just([])
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(.unknown), .completed])
        XCTAssertEqual(groupRelationRepository.getRelationsForGroupParameters, [remoteId])
    }
    
    func test_shouldGetUnknownWhenConfigNotSupported() {
        // given
        let remoteId: Int32 = 123
        let relation = SAChannelGroupRelation(testContext: nil)
        relation.channel_id = 234
        
        groupRelationRepository.getRelationsForGroupReturns = .just([relation])
        channelConfigRepository.getConfigReturns = .just(SAChannelConfig(testContext: nil))
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(.unknown), .completed])
        XCTAssertEqual(groupRelationRepository.getRelationsForGroupParameters, [remoteId])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [234])
    }
    
    func test_shouldGetSimilarWhenBothConfigsAreSimilar() {
        // given
        let remoteId: Int32 = 123
        let relation1 = SAChannelGroupRelation(testContext: nil)
        relation1.channel_id = 234
        let relation2 = SAChannelGroupRelation(testContext: nil)
        relation2.channel_id = 345
        
        groupRelationRepository.getRelationsForGroupReturns = .just([relation1, relation2])
        
        let config1 = mockConfig()
        let config2 = mockConfig()
        channelConfigRepository.getConfigReturnsMap[234] = .just(config1)
        channelConfigRepository.getConfigReturnsMap[345] = .just(config2)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(.similar(tilt0Angle: 0, tilt100Angle: 180, tiltControlType: .changesPositionWhileTilting)),
            .completed
        ])
        XCTAssertEqual(groupRelationRepository.getRelationsForGroupParameters, [remoteId])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [234, 345])
    }
    
    func test_shouldGetDifferentWhenConfigsAreDifferent() {
        // given
        let remoteId: Int32 = 123
        let relation1 = SAChannelGroupRelation(testContext: nil)
        relation1.channel_id = 234
        let relation2 = SAChannelGroupRelation(testContext: nil)
        relation2.channel_id = 345
        
        groupRelationRepository.getRelationsForGroupReturns = .just([relation1, relation2])
        
        let config1 = mockConfig()
        let config2 = mockConfig(tilt0: 90)
        channelConfigRepository.getConfigReturnsMap[234] = .just(config1)
        channelConfigRepository.getConfigReturnsMap[345] = .just(config2)
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(.different), .completed])
        XCTAssertEqual(groupRelationRepository.getRelationsForGroupParameters, [remoteId])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [234, 345])
    }
    
    func test_shouldGetDifferentWhenFirstConfigsAreDifferentAndThenComesThirdOneSimilar() {
        // given
        let remoteId: Int32 = 123
        let relation1 = SAChannelGroupRelation(testContext: nil)
        relation1.channel_id = 234
        let relation2 = SAChannelGroupRelation(testContext: nil)
        relation2.channel_id = 345
        let relation3 = SAChannelGroupRelation(testContext: nil)
        relation3.channel_id = 456
        
        groupRelationRepository.getRelationsForGroupReturns = .just([relation1, relation2, relation3])
        
        channelConfigRepository.getConfigReturnsMap[234] = .just(mockConfig())
        channelConfigRepository.getConfigReturnsMap[345] = .just(mockConfig(tilt0: 90))
        channelConfigRepository.getConfigReturnsMap[456] = .just(mockConfig())
        
        // when
        useCase.invoke(remoteId: remoteId).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(.different), .completed])
        XCTAssertEqual(groupRelationRepository.getRelationsForGroupParameters, [remoteId])
        XCTAssertEqual(channelConfigRepository.getConfigParameters, [234, 345, 456])
    }
    
    private func mockConfig(
        tilt0: UInt16 = 0,
        tilt100: UInt16 = 180,
        type: SuplaTiltControlType = .changesPositionWhileTilting
    ) -> SAChannelConfig {
        let suplaConfig = SuplaChannelFacadeBlindConfig(
            remoteId: 123,
            channelFunc: nil,
            crc32: 0,
            closingTimeMs: 0,
            openingTimeMs: 0,
            motorUpsideDown: false,
            buttonUpsideDown: false,
            timeMargin: 0,
            tiltingTimeMs: 0,
            tilt0Angle: tilt0,
            tilt100Angle: tilt100,
            type: type
        )
        
        let config = SAChannelConfig(testContext: nil)
        config.config_type = 5
        if let configData = try? jsonEncoder.encode(suplaConfig) {
            config.config = String(data: configData, encoding: .utf8)
        }
        
        return config
    }
}
