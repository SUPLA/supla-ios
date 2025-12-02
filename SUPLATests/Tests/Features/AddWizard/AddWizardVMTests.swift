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

final class AddWizardVMTests: XCTestCase {
    private lazy var checkRegistrationUseCaseMock: CheckRegistrationEnabled.Mock! = CheckRegistrationEnabled.Mock()
    private lazy var profileRepositoryMock: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var dateProviderMock: DateProviderMock! = DateProviderMock()
    private lazy var schedulers: SuplaSchedulersMock! = SuplaSchedulersMock()
    
    private lazy var viewModel: AddWizardFeature.ViewModel! = .init()
    
    override func setUp() {
        DiContainer.shared.register(type: CheckRegistrationEnabled.UseCase.self, checkRegistrationUseCaseMock!)
        DiContainer.shared.register(type: DateProvider.self, dateProviderMock!)
        DiContainer.shared.register(type: SuplaSchedulers.self, schedulers!)
    }
    
    override func tearDown() {
        checkRegistrationUseCaseMock = nil
        dateProviderMock = nil
        schedulers = nil
        
        viewModel = nil
    }
    
    func test_shouldMakeSecondRegistrationCheck_whenFirstRegistrationCheckFailsWithTimeout() async {
        // given
        dateProviderMock.currentTimestampReturns =  .many([1, 2, 3, 4])
        checkRegistrationUseCaseMock.invokeMock.returns = .single(.timeout)
        profileRepositoryMock.activeProfileObservable = .empty()
        
        // when
        await MainActor.run {
            viewModel.checkRegistration()
        }
        _ = await viewModel.workingTask?.result
        await MainActor.run {
            viewModel.checkRegistration()
        }
        _ = await viewModel.workingTask?.result
        
        // then
        XCTAssertEqual(checkRegistrationUseCaseMock.invokeMock.parameters.count, 4)
    }
    
    func test_shouldSkipSecondRegistrationCheck_whenFirstRegistrationCheckSucceeded() async {
        // given
        dateProviderMock.currentTimestampReturns =  .many([1, 2, 3, 4])
        checkRegistrationUseCaseMock.invokeMock.returns = .single(.enabled)
        profileRepositoryMock.activeProfileObservable = .empty()
        
        // when
        await MainActor.run {
            viewModel.checkRegistration()
        }
        _ = await viewModel.workingTask?.result
        await MainActor.run {
            viewModel.checkRegistration()
        }
        _ = await viewModel.workingTask?.result
        
        // then
        XCTAssertEqual(checkRegistrationUseCaseMock.invokeMock.parameters.count, 1)
    }
    
    func test_shouldMakeSecondRegistrationCheck_afterOneHour() async {
        // given
        dateProviderMock.currentTimestampReturns =  .many([1, 3610, 3, 4])
        checkRegistrationUseCaseMock.invokeMock.returns = .single(.enabled)
        profileRepositoryMock.activeProfileObservable = .empty()
        
        // when
        await MainActor.run {
            viewModel.checkRegistration()
        }
        _ = await viewModel.workingTask?.result
        await MainActor.run {
            viewModel.checkRegistration()
        }
        _ = await viewModel.workingTask?.result
        
        // then
        XCTAssertEqual(checkRegistrationUseCaseMock.invokeMock.parameters.count, 2)
    }
}
