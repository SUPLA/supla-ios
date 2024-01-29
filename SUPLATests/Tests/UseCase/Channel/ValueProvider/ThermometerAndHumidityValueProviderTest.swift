//
//  ThermometerAndHumidityValueProviderTest.swift
//  SUPLATests
//
//  Created by Michał Polański on 02/02/2024.
//  Copyright © 2024 AC SOFTWARE SP. Z O.O. All rights reserved.
//

@testable import SUPLA
import XCTest

final class ThermometerAndHumidityValueProviderTest: XCTestCase {
    private lazy var provider: ThermometerAndHumidityValueProvider! = ThermometerAndHumidityValueProviderImpl()
    
    override func tearDown() {
        provider = nil
    }
    
    func test_shouldHandleFunction() {
        // given
        let function = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
        
        // when
        let handle = provider.handle(function: function)
        
        // then
        XCTAssertTrue(handle)
    }
    
    func test_shouldGetDoubleValueForTemperature() {
        // given
        let intValue: [Int32] = [23100, 55000]
        let channel = SAChannel(testContext: nil)
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = intValue.withUnsafeBufferPointer { Data(buffer: $0) as NSData }
        
        channel.value = channelValue
        
        // when
        let value = provider.value(channel, valueType: .first)
        
        // then
        XCTAssertEqual(value as! Double, 23.1)
    }
    
    func test_shouldGetDoubleValueForHumidity() {
        // given
        let intValue: [Int32] = [23000, 55050]
        let channel = SAChannel(testContext: nil)
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = intValue.withUnsafeBufferPointer { Data(buffer: $0) as NSData }
        
        channel.value = channelValue
        
        // when
        let value = provider.value(channel, valueType: .second)
        
        // then
        XCTAssertEqual(value as! Double, 55.05)
    }
    
    func test_shouldGetUnknownValueForTemperature() {
        // given
        let channel = SAChannel(testContext: nil)
        let channelValue = SAChannelValue(testContext: nil)
        channel.value = channelValue
        
        // when
        let value = provider.value(channel, valueType: .first)
        
        // then
        XCTAssertEqual(value as! Double, ThermometerValueProviderImpl.UNKNOWN_VALUE)
    }
    
    func test_shouldGetUnknownValueForHumidity() {
        // given
        let channel = SAChannel(testContext: nil)
        let channelValue = SAChannelValue(testContext: nil)
        channel.value = channelValue
        
        // when
        let value = provider.value(channel, valueType: .second)
        
        // then
        XCTAssertEqual(value as! Double, HumidityValueProviderImpl.UNKNOWN_VALUE)
    }
}
