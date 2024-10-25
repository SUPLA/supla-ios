//
//  GpmValueProviderTest.swift
//  SUPLATests
//
//  Created by Michał Polański on 02/02/2024.
//  Copyright © 2024 AC SOFTWARE SP. Z O.O. All rights reserved.
//

@testable import SUPLA
import XCTest

final class GpmValueProviderTest: XCTestCase {
    private lazy var provider: GpmValueProvider! = GpmValueProviderImpl()
    
    override func tearDown() {
        provider = nil
    }
    
    func test_shouldHandleFunctionMeasurement() {
        // given
        let channel = SAChannel.mock(function: SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT)
        
        // when
        let handle = provider.handle(channel)
        
        // then
        XCTAssertTrue(handle)
    }
    
    func test_shouldHandleFunctionMeter() {
        // given
        let channel = SAChannel.mock(function: SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER)
        
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
        XCTAssertTrue((value as! Double).isNaN)
    }
}
