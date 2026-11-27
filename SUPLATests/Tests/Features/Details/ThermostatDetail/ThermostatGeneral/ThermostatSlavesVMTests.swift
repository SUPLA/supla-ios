/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 */

import XCTest

@testable import SUPLA

final class ThermostatSlavesVMTests: XCTestCase {
    private lazy var getChannelValueStringUseCase: GetChannelValueStringUseCaseMock! = GetChannelValueStringUseCaseMock()
    private lazy var getChannelBaseIconUseCase: GetChannelBaseIconUseCaseMock! = GetChannelBaseIconUseCaseMock()

    private lazy var viewModel = ThermostatSlavesFeature.ViewModel(
        itemBundle: ItemBundle(
            remoteId: 1,
            profileId: 1,
            deviceId: 1,
            subjectType: .channel,
            function: SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        )
    )

    override func setUp() {
        super.setUp()
        DiContainer.shared.register(type: GetChannelValueStringUseCase.self, getChannelValueStringUseCase!)
        DiContainer.shared.register(type: GetChannelBaseIconUseCase.self, getChannelBaseIconUseCase!)
    }

    override func tearDown() {
        getChannelValueStringUseCase = nil
        getChannelBaseIconUseCase = nil
        super.tearDown()
    }

    func test_formatsMasterAndSlavePowerAsPercentagesFromZeroToOneFractions() {
        let master = thermostatChannel(remoteId: 1, power: 50)
        let slave = thermostatChannel(remoteId: 2, power: 25)
        let slaveChild = ChannelChild(
            channel: slave,
            relation: SAChannelRelation.mock(type: .masterThermostat)
        )

        viewModel.onChannelUpdate(ChannelWithChildren(channel: master, children: [slaveChild]))

        XCTAssertEqual(viewModel.state.master?.currentPower, "50%")
        XCTAssertEqual(viewModel.state.slaves.first?.currentPower, "25%")
    }

    private func thermostatChannel(remoteId: Int32, power: UInt8) -> SAChannel {
        var value = THVACValue(
            IsOn: power + 2,
            Mode: UInt8(SuplaHvacMode.off.value),
            SetpointTemperatureHeat: 0,
            SetpointTemperatureCool: 0,
            Flags: 0
        )
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = NSData(bytes: &value, length: MemoryLayout<THVACValue>.size)
        channelValue.online = SUPLA_CHANNEL_ONLINE_FLAG_ONLINE

        return SAChannel.mock(
            remoteId,
            function: SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
            value: channelValue
        )
    }
}
