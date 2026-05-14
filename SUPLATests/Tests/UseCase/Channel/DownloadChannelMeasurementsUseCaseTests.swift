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

import RxTest
@testable import SUPLA
import XCTest

final class DownloadChannelMeasurementsUseCaseTests: UseCaseTest<Void> {
    private lazy var downloadEventsManager: DownloadEventsManagerMock! = DownloadEventsManagerMock()
    private lazy var downloadCurrentLogUseCase: DownloadCurrentLogUseCaseMock! = DownloadCurrentLogUseCaseMock()
    private lazy var downloadVoltageLogUseCase: DownloadVoltageLogUseCaseMock! = DownloadVoltageLogUseCaseMock()
    private lazy var downloadHumidityLogUseCase: DownloadHumidityLogUseCaseMock! = DownloadHumidityLogUseCaseMock()
    private lazy var downloadPowerActiveLogUseCase: DownloadPowerActiveLogUseCaseMock! = DownloadPowerActiveLogUseCaseMock()
    private lazy var downloadImpulseCounterLogUseCase: DownloadImpulseCounterLogUseCaseMock! = DownloadImpulseCounterLogUseCaseMock()
    private lazy var downloadElectricityMeterLogUseCase: DownloadElectricityMeterLogUseCaseMock! = DownloadElectricityMeterLogUseCaseMock()
    private lazy var downloadThermostatHeatpolLogUseCase: DownloadThermostatHeatpolLogUseCaseMock! = DownloadThermostatHeatpolLogUseCaseMock()
    private lazy var downloadGeneralPurposeMeterLogUseCase: DownloadGeneralPurposeMeterLogUseCaseMock! = DownloadGeneralPurposeMeterLogUseCaseMock()
    private lazy var downloadTemperatureMeasurementsUseCase: DownloadTemperatureMeasurementsUseCaseMock! = DownloadTemperatureMeasurementsUseCaseMock()
    private lazy var downloadTempHumidityMeasurementsUseCase: DownloadTempHumidityMeasurementsUseCaseMock! = DownloadTempHumidityMeasurementsUseCaseMock()
    private lazy var downloadGeneralPurposeMeasurementLogUseCase: DownloadGeneralPurposeMeasurementLogUseCaseMock! = DownloadGeneralPurposeMeasurementLogUseCaseMock()

    private lazy var useCase: DownloadChannelMeasurementsUseCaseImpl! = DownloadChannelMeasurementsUseCaseImpl()

    override func setUp() {
        // super.setUp() intentionally commented out
        DiContainer.shared.register(type: SuplaSchedulers.self, SuplaSchedulersImpl())

        DiContainer.shared.register(type: DownloadEventsManager.self, downloadEventsManager!)
        DiContainer.shared.register(type: DownloadCurrentLogUseCase.self, downloadCurrentLogUseCase!)
        DiContainer.shared.register(type: DownloadVoltageLogUseCase.self, downloadVoltageLogUseCase!)
        DiContainer.shared.register(type: DownloadHumidityLogUseCase.self, downloadHumidityLogUseCase!)
        DiContainer.shared.register(type: DownloadPowerActiveLogUseCase.self, downloadPowerActiveLogUseCase!)
        DiContainer.shared.register(type: DownloadImpulseCounterLogUseCase.self, downloadImpulseCounterLogUseCase!)
        DiContainer.shared.register(type: DownloadTemperatureLogUseCase.self, downloadTemperatureMeasurementsUseCase!)
        DiContainer.shared.register(type: DownloadElectricityMeterLogUseCase.self, downloadElectricityMeterLogUseCase!)
        DiContainer.shared.register(type: DownloadTempHumidityLogUseCase.self, downloadTempHumidityMeasurementsUseCase!)
        DiContainer.shared.register(type: DownloadThermostatHeatpolLogUseCase.self, downloadThermostatHeatpolLogUseCase!)
        DiContainer.shared.register(type: DownloadGeneralPurposeMeterLogUseCase.self, downloadGeneralPurposeMeterLogUseCase!)
        DiContainer.shared.register(type: DownloadGeneralPurposeMeasurementLogUseCase.self, downloadGeneralPurposeMeasurementLogUseCase!)
    }

    override func tearDown() {
        useCase = nil
        downloadEventsManager = nil
        downloadCurrentLogUseCase = nil
        downloadVoltageLogUseCase = nil
        downloadHumidityLogUseCase = nil
        downloadPowerActiveLogUseCase = nil
        downloadImpulseCounterLogUseCase = nil
        downloadElectricityMeterLogUseCase = nil
        downloadThermostatHeatpolLogUseCase = nil
        downloadGeneralPurposeMeterLogUseCase = nil
        downloadTemperatureMeasurementsUseCase = nil
        downloadTempHumidityMeasurementsUseCase = nil
        downloadGeneralPurposeMeasurementLogUseCase = nil

        super.tearDown()
    }

    private func runDownload(_ channelWithChildren: SUPLA.ChannelWithChildren, type: DownloadEventsManagerDataType = .default) async {
        useCase.invoke(channelWithChildren, type: type)
        if let lastTask = useCase.lastTask { await lastTask.value }
    }

    private func assertDownloadEvents(remoteId: Int32, type: DownloadEventsManagerDataType = .default) {
        XCTAssertTuples(downloadEventsManager.emitProgressStateMock.parameters, [
            (remoteId, type, .started),
            (remoteId, type, .finished)
        ])
    }

    private func assertNoNewBranchDownloads() {
        XCTAssertEqual(downloadElectricityMeterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadCurrentLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadVoltageLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadPowerActiveLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadImpulseCounterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadHumidityLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadThermostatHeatpolLogUseCase.mock.parameters.count, 0)
    }

    private func makeElectricityMeterChannelWithChildren(remoteId: Int32) -> SUPLA.ChannelWithChildren {
        let value = SAChannelValue.mock()
        value.sub_value_type = Int16(SUBV_TYPE_ELECTRICITY_MEASUREMENTS)
        let channel = SAChannel.mock(remoteId, function: SUPLA_CHANNELFNC_POWERSWITCH, value: value)
        return ChannelWithChildren(channel: channel, children: [])
    }

    private func makeImpulseCounterChannelWithChildren(remoteId: Int32) -> SUPLA.ChannelWithChildren {
        let value = SAChannelValue.mock()
        value.sub_value_type = Int16(SUBV_TYPE_IC_MEASUREMENTS)
        let channel = SAChannel.mock(remoteId, function: SUPLA_CHANNELFNC_POWERSWITCH, value: value)
        return ChannelWithChildren(channel: channel, children: [])
    }

    func test_shouldStartThermometerDownload() async {
        // given
        let remoteId: Int32 = 123
        let function = SUPLA_CHANNELFNC_THERMOMETER
        let channel = SAChannel.mock(remoteId, function: function)
        let channelWithChildren = ChannelWithChildren(channel: channel, children: [])

        // when
        await runDownload(channelWithChildren)

        // then
        XCTAssertTuples(downloadTemperatureMeasurementsUseCase.mock.parameters, [(remoteId, channel.profile)])
        assertDownloadEvents(remoteId: remoteId)
        XCTAssertEqual(downloadTempHumidityMeasurementsUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadGeneralPurposeMeasurementLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadGeneralPurposeMeterLogUseCase.mock.parameters.count, 0)
        assertNoNewBranchDownloads()
    }

    func test_shouldStartThermometerAndHumidityDownload() async {
        // given
        let remoteId: Int32 = 123
        let function = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
        let channel = SAChannel.mock(remoteId, function: function)
        let channelWithChildren = ChannelWithChildren(channel: channel, children: [])

        // when
        await runDownload(channelWithChildren)

        // then
        XCTAssertTuples(downloadTempHumidityMeasurementsUseCase.mock.parameters, [(remoteId, channel.profile)])
        assertDownloadEvents(remoteId: remoteId)
        XCTAssertEqual(downloadTemperatureMeasurementsUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadGeneralPurposeMeasurementLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadGeneralPurposeMeterLogUseCase.mock.parameters.count, 0)
        assertNoNewBranchDownloads()
    }

    func test_shouldStartGeneralPurposeMeasurementDownload() async {
        // given
        let remoteId: Int32 = 123
        let function = SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
        let channel = SAChannel.mock(remoteId, function: function)
        let channelWithChildren = ChannelWithChildren(channel: channel, children: [])

        // when
        await runDownload(channelWithChildren)

        // then
        XCTAssertTuples(downloadGeneralPurposeMeasurementLogUseCase.mock.parameters, [(remoteId, channel.profile)])
        assertDownloadEvents(remoteId: remoteId)
        XCTAssertEqual(downloadTemperatureMeasurementsUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadTempHumidityMeasurementsUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadGeneralPurposeMeterLogUseCase.mock.parameters.count, 0)
        assertNoNewBranchDownloads()
    }

    func test_shouldStartGeneralPurposeMeterDownload() async {
        // given
        let remoteId: Int32 = 123
        let function = SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
        let channel = SAChannel.mock(remoteId, function: function)
        let channelWithChildren = ChannelWithChildren(channel: channel, children: [])

        // when
        await runDownload(channelWithChildren)

        // then
        XCTAssertTuples(downloadGeneralPurposeMeterLogUseCase.mock.parameters, [(remoteId, channel.profile)])
        assertDownloadEvents(remoteId: remoteId)
        XCTAssertEqual(downloadTemperatureMeasurementsUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadTempHumidityMeasurementsUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadGeneralPurposeMeasurementLogUseCase.mock.parameters.count, 0)
        assertNoNewBranchDownloads()
    }

    func test_shouldStartElectricityMeterDownload() async {
        // given
        let remoteId: Int32 = 123
        let channelWithChildren = makeElectricityMeterChannelWithChildren(remoteId: remoteId)

        // when
        await runDownload(channelWithChildren)

        // then
        XCTAssertTuples(downloadElectricityMeterLogUseCase.mock.parameters, [(remoteId, channelWithChildren.channel.profile)])
        assertDownloadEvents(remoteId: remoteId)
        XCTAssertEqual(downloadCurrentLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadVoltageLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadPowerActiveLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadImpulseCounterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadHumidityLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadThermostatHeatpolLogUseCase.mock.parameters.count, 0)
    }

    func test_shouldStartElectricityCurrentDownload() async {
        // given
        let remoteId: Int32 = 123
        let channelWithChildren = makeElectricityMeterChannelWithChildren(remoteId: remoteId)

        // when
        await runDownload(channelWithChildren, type: .electricityCurrent)

        // then
        XCTAssertTuples(downloadCurrentLogUseCase.mock.parameters, [(remoteId, channelWithChildren.channel.profile)])
        assertDownloadEvents(remoteId: remoteId, type: .electricityCurrent)
        XCTAssertEqual(downloadElectricityMeterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadVoltageLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadPowerActiveLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadImpulseCounterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadHumidityLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadThermostatHeatpolLogUseCase.mock.parameters.count, 0)
    }

    func test_shouldStartElectricityVoltageDownload() async {
        // given
        let remoteId: Int32 = 123
        let channelWithChildren = makeElectricityMeterChannelWithChildren(remoteId: remoteId)

        // when
        await runDownload(channelWithChildren, type: .electricityVoltage)

        // then
        XCTAssertTuples(downloadVoltageLogUseCase.mock.parameters, [(remoteId, channelWithChildren.channel.profile)])
        assertDownloadEvents(remoteId: remoteId, type: .electricityVoltage)
        XCTAssertEqual(downloadElectricityMeterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadCurrentLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadPowerActiveLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadImpulseCounterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadHumidityLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadThermostatHeatpolLogUseCase.mock.parameters.count, 0)
    }

    func test_shouldStartElectricityPowerActiveDownload() async {
        // given
        let remoteId: Int32 = 123
        let channelWithChildren = makeElectricityMeterChannelWithChildren(remoteId: remoteId)

        // when
        await runDownload(channelWithChildren, type: .electricityPowerActive)

        // then
        XCTAssertTuples(downloadPowerActiveLogUseCase.mock.parameters, [(remoteId, channelWithChildren.channel.profile)])
        assertDownloadEvents(remoteId: remoteId, type: .electricityPowerActive)
        XCTAssertEqual(downloadElectricityMeterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadCurrentLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadVoltageLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadImpulseCounterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadHumidityLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadThermostatHeatpolLogUseCase.mock.parameters.count, 0)
    }

    func test_shouldStartImpulseCounterDownload() async {
        // given
        let remoteId: Int32 = 123
        let channelWithChildren = makeImpulseCounterChannelWithChildren(remoteId: remoteId)

        // when
        await runDownload(channelWithChildren)

        // then
        XCTAssertTuples(downloadImpulseCounterLogUseCase.mock.parameters, [(remoteId, channelWithChildren.channel.profile)])
        assertDownloadEvents(remoteId: remoteId)
        XCTAssertEqual(downloadElectricityMeterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadCurrentLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadVoltageLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadPowerActiveLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadHumidityLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadThermostatHeatpolLogUseCase.mock.parameters.count, 0)
    }

    func test_shouldStartHumidityDownload() async {
        // given
        let remoteId: Int32 = 123
        let function = SUPLA_CHANNELFNC_HUMIDITY
        let channel = SAChannel.mock(remoteId, function: function)
        let channelWithChildren = ChannelWithChildren(channel: channel, children: [])

        // when
        await runDownload(channelWithChildren)

        // then
        XCTAssertTuples(downloadHumidityLogUseCase.mock.parameters, [(remoteId, channel.profile)])
        assertDownloadEvents(remoteId: remoteId)
        XCTAssertEqual(downloadElectricityMeterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadCurrentLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadVoltageLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadPowerActiveLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadImpulseCounterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadThermostatHeatpolLogUseCase.mock.parameters.count, 0)
    }

    func test_shouldStartThermostatHeatpolDownload() async {
        // given
        let remoteId: Int32 = 123
        let function = SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
        let channel = SAChannel.mock(remoteId, function: function)
        let channelWithChildren = ChannelWithChildren(channel: channel, children: [])

        // when
        await runDownload(channelWithChildren)
        // then
        XCTAssertTuples(downloadThermostatHeatpolLogUseCase.mock.parameters, [(remoteId, channel.profile)])
        assertDownloadEvents(remoteId: remoteId)
        XCTAssertEqual(downloadElectricityMeterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadCurrentLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadVoltageLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadPowerActiveLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadImpulseCounterLogUseCase.mock.parameters.count, 0)
        XCTAssertEqual(downloadHumidityLogUseCase.mock.parameters.count, 0)
    }
}
