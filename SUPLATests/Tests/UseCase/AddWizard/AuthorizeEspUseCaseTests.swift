/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can freely redistribute it and/or
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

final class AuthorizeEspUseCaseTests: XCTestCase {
    private lazy var espRepositoryMock: EspRepositoryMock! = EspRepositoryMock()
    private lazy var useCase: AuthorizeEsp.UseCase! = AuthorizeEsp.Implementation()

    private lazy var exampleHtml: String! = {
        let testBundle = Bundle(for: type(of: self))
        let file = testBundle.url(forResource: "device_login", withExtension: "html")!
        let data = try! Data(contentsOf: file)
        return String(data: data, encoding: .utf8)
    }()

    override func setUp() {
        super.setUp()

        DiContainer.shared.register(type: (any EspRepository).self, espRepositoryMock!)
    }

    override func tearDown() {
        espRepositoryMock = nil
        useCase = nil

        super.tearDown()
    }

    func test_shouldAuthorizeDevice() async {
        // given
        let password = "secret"
        guard let html = exampleHtml else { XCTFail("Could not load teste data"); return }

        espRepositoryMock.loginMock.returns = .single(.success(200, html))
        espRepositoryMock.loginWithPasswordMock.returns = .single(.success(200, ""))

        // when
        let result = await useCase.invoke(password: password)

        // then
        switch result {
        case .success:
            break
        default:
            XCTFail("Expected success, got \(result)")
        }

        XCTAssertEqual(espRepositoryMock.loginMock.parameters.count, 1)
        XCTAssertEqual(espRepositoryMock.loginWithPasswordMock.parameters.count, 1)
        XCTAssertEqual(espRepositoryMock.loginWithPasswordMock.parameters[0].0, password)
        XCTAssertEqual(espRepositoryMock.loginWithPasswordMock.parameters[0].1, ["cfg_pwd": ""])
    }

    func test_shouldReturnTemporarilyLocked_whenDeviceIsLocked() async {
        // given
        espRepositoryMock.loginMock.returns = .single(.temporarilyLocked)

        // when
        let result = await useCase.invoke(password: "secret")

        // then
        switch result {
        case .temporarilyLocked:
            break
        default:
            XCTFail("Expected temporarilyLocked, got \(result)")
        }

        XCTAssertEqual(espRepositoryMock.loginMock.parameters.count, 1)
        XCTAssertEqual(espRepositoryMock.loginWithPasswordMock.parameters.count, 0)
    }

    func test_shouldReturnFailureWrongPassword_whenCredentialsAreInvalid() async {
        // given
        let error = InvalidCredentialsError()
        let html = """
        <html>
            <body>
                <input name="ssid" value="My WiFi">
            </body>
        </html>
        """

        espRepositoryMock.loginMock.returns = .single(.success(200, html))
        espRepositoryMock.loginWithPasswordMock.returns = .single(.failure(401, error))

        // when
        let result = await useCase.invoke(password: "wrong-password")

        // then
        switch result {
        case .failureWrongPassword:
            break
        default:
            XCTFail("Expected failureWrongPassword, got \(result)")
        }

        XCTAssertEqual(espRepositoryMock.loginMock.parameters.count, 1)
        XCTAssertEqual(espRepositoryMock.loginWithPasswordMock.parameters.count, 1)
    }

    func test_shouldReturnFailureUnknown_whenInitialLoginFails() async {
        // given
        espRepositoryMock.loginMock.returns = .single(.failure(500, URLError(.badServerResponse)))

        // when
        let result = await useCase.invoke(password: "secret")

        // then
        switch result {
        case .failureUnknown:
            break
        default:
            XCTFail("Expected failureUnknown, got \(result)")
        }

        XCTAssertEqual(espRepositoryMock.loginMock.parameters.count, 1)
        XCTAssertEqual(espRepositoryMock.loginWithPasswordMock.parameters.count, 0)
    }
}
