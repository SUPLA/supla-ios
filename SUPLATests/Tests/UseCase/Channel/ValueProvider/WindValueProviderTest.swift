//
//  WindValueProviderTest.swift
//  SUPLATests
//
//  Created by Michał Polański on 02/02/2024.
//  Copyright © 2024 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import XCTest
@testable import SUPLA

final class WindValueProviderTest: XCTestCase {
    
    private lazy var provider: WindValueProvider! = {
        WindValueProviderImpl()
    }()
    
    override func tearDown() {
        provider = nil
    }
    
    func test_shouldHandleFunction() {
        // given
        let channel = SAChannel.mock(function: SUPLA_CHANNELFNC_WINDSENSOR)
        
        // when
        let handle = provider.handle(channel)
        
        // then
        XCTAssertTrue(handle)
    }
    
    func test_shouldGetDoubleValue() {
        // given
        var doubleValue = 23.5
        let channel = SAChannel(testContext: nil)
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = withUnsafeBytes(of: &doubleValue) { Data($0) as NSData }
        
        channel.value = channelValue
        
        // when
        let value = provider.value(channel, valueType: .first)
        
        // then
        XCTAssertEqual(value as! Double, doubleValue)
    }
    
    func test_shouldGetUnknownValue() {
        // given
        let channel = SAChannel(testContext: nil)
        let channelValue = SAChannelValue(testContext: nil)
        channel.value = channelValue
        
        // when
        let value = provider.value(channel, valueType: .first)
        
        // then
        XCTAssertEqual(value as! Double, WindValueProviderImpl.UNKNOWN_VALUE)
    }
}
