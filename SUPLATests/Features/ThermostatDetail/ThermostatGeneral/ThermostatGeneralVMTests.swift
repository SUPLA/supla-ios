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

final class ThermostatGeneralVMTests: ViewModelTest<ThermostatGeneralViewState, ThermostatGeneralViewEvent> {
    
    private lazy var viewModel: ThermostatGeneralVM! = { ThermostatGeneralVM() }()
    
    private lazy var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCaseMock! = {
        ReadChannelWithChildrenUseCaseMock()
    }()
    private lazy var createTemperaturesListUseCase: CreateTemperaturesListUseCaseMock! = {
        CreateTemperaturesListUseCaseMock()
    }()
    private lazy var configEventsManager: ConfigEventsManagerMock! = {
        ConfigEventsManagerMock()
    }()
    private lazy var getChannelConfigUseCase: GetChannelConfigUseCaseMock! = {
        GetChannelConfigUseCaseMock()
    }()
    private lazy var delayedThermostatActionSubject: DelayedThermostatActionSubjectMock! = {
        DelayedThermostatActionSubjectMock()
    }()
    private lazy var dateProvider: DateProviderMock! = {
        DateProviderMock()
    }()
    private lazy var loadingTimeoutManager: LoadingTimeoutManagerMock! = {
        LoadingTimeoutManagerMock()
    }()
    
    
    override func setUp() {
        DiContainer.shared.register(type: ReadChannelWithChildrenUseCase.self, component: readChannelWithChildrenUseCase!)
        DiContainer.shared.register(type: CreateTemperaturesListUseCase.self, component: createTemperaturesListUseCase!)
        DiContainer.shared.register(type: ConfigEventsManager.self, component: configEventsManager!)
        DiContainer.shared.register(type: GetChannelConfigUseCase.self, component: getChannelConfigUseCase!)
        DiContainer.shared.register(type: DelayedThermostatActionSubject.self, component: delayedThermostatActionSubject!)
        DiContainer.shared.register(type: DateProvider.self, component: dateProvider!)
        DiContainer.shared.register(type: TemperatureFormatter.self, component: TemperatureFormatterMock())
        DiContainer.shared.register(type: LoadingTimeoutManager.self, producer: { self.loadingTimeoutManager! })
    }
    
    override func tearDown() {
        viewModel = nil
        
        readChannelWithChildrenUseCase = nil
        createTemperaturesListUseCase = nil
        configEventsManager = nil
        getChannelConfigUseCase = nil
        delayedThermostatActionSubject = nil
        dateProvider = nil
        loadingTimeoutManager = nil
        
        super.tearDown()
    }
    
    func test_shouldChangeProgramWhenTapped() {
    }
}
