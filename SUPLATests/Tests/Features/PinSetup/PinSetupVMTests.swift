//
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

final class PinSetupVMTests: XCTestCase {
    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()
    private lazy var coordinator: SuplaAppCoordinatorMock! = SuplaAppCoordinatorMock()
    
    private lazy var viewModel: PinSetupFeature.ViewModel! = PinSetupFeature.ViewModel()
    
    override func setUp() {
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
        DiContainer.shared.register(type: SuplaAppCoordinator.self, coordinator!)
    }
    
    override func tearDown() {
        settings = nil
        coordinator = nil
        viewModel = nil
    }

    func test_shouldInformAboutDifferentPins() {
        // given
        viewModel.state.pin = "1234"
        viewModel.state.secondPin = "2345"
        
        // when
        viewModel.onSaveClick(.application)
        
        // then
        XCTAssertEqual(viewModel.state.pin, "")
        XCTAssertEqual(viewModel.state.secondPin, "")
        XCTAssertEqual(viewModel.state.errorString, Strings.PinSetup.different)
        
        coordinator.verifyPopViewController([])
    }
    
    func test_shouldSetPin() {
        // given
        let pin = "1234"
        viewModel.state.pin = pin
        viewModel.state.secondPin = pin
        
        // when
        viewModel.onSaveClick(.application)
        
        // then
        XCTAssertEqual(settings.lockScreenSettingsValues, [LockScreenSettings(scope: .application, pinSum: pin.sha1(), biometricAllowed: false)])
        
        coordinator.verifyPopViewController([true])
    }
    
    func test_shouldChangeFocus_whenPinFilled() {
        // when
        viewModel.onPinChange("1234")
        
        // then
        XCTAssertEqual(viewModel.state.focused, .secondPin)
    }
}
