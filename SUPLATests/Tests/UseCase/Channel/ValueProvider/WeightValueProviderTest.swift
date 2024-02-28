//
//  WeightValueProviderTest.swift
//  SUPLATests
//
//  Created by Michał Polański on 02/02/2024.
//  Copyright © 2024 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import XCTest
@testable import SUPLA

final class WeightValueProviderTest: XCTestCase {
    
    private lazy var provider: WeightValueProvider! = {
        WeightValueProviderImpl()
    }()
    
    override func tearDown() {
        provider = nil
    }
    
    func test_shouldHandleFunction() {
        // given
        let function = SUPLA_CHANNELFNC_WEIGHTSENSOR
        
        // when
        let handle = provider.handle(function: function)
        
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
        XCTAssertEqual(value as! Double, WeightValueProviderImpl.UNKNOWN_VALUE)
    }
}

