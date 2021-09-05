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
@testable import SUPLA

class TemperatureUnitTests: XCTestCase {

    func testCelsiusNumericRepresentation() throws {
        let presenter = TemperaturePresenter(temperatureUnit: .celsius)

        XCTAssertEqual(13.0, presenter.converted(13.0), accuracy: Float.ulpOfOne)
        XCTAssertEqual(-13.0, presenter.converted(-13.0), accuracy: Float.ulpOfOne)
        XCTAssertEqual(0, presenter.converted(0.0), accuracy: Float.ulpOfOne)
        XCTAssertEqual(0.5, presenter.converted(0.5), accuracy: Float.ulpOfOne)
        XCTAssertEqual(-0.5, presenter.converted(-0.5), accuracy: Float.ulpOfOne)
    }
    
    func testCelsiusStringRepresentationDotSeparator() throws {
        let locale = Locale(identifier: "en_US.UTF-8")

        let presenter = TemperaturePresenter(temperatureUnit: .celsius,
                                             locale: locale as Locale)
        XCTAssertEqual("13.0 °C", presenter.stringRepresentation(13.0))
        XCTAssertEqual("-13.0 °C", presenter.stringRepresentation(-13.0))
        XCTAssertEqual("0.0 °C", presenter.stringRepresentation(0.0))
        XCTAssertEqual("0.5 °C", presenter.stringRepresentation(0.5))
        XCTAssertEqual("-0.5 °C", presenter.stringRepresentation(-0.5))
    }
    
    func testCelsiusStringRepresentationCommaSeparator() throws {
        let locale = Locale(identifier: "pl_PL.UT-8")
        let presenter = TemperaturePresenter(temperatureUnit: .celsius,
                                             locale: locale as Locale)
        XCTAssertEqual("13,0 °C", presenter.stringRepresentation(13.0))
        XCTAssertEqual("-13,0 °C", presenter.stringRepresentation(-13.0))
        XCTAssertEqual("0,0 °C", presenter.stringRepresentation(0.0))
        XCTAssertEqual("0,5 °C", presenter.stringRepresentation(0.5))
        XCTAssertEqual("-0,5 °C", presenter.stringRepresentation(-0.5))
    }
    

    func testFahrenheitNumericRepresentation() throws {
        let presenter = TemperaturePresenter(temperatureUnit: .fahrenheit)
        XCTAssertEqual(55.40, presenter.converted(13.0), accuracy: Float.ulpOfOne)
        XCTAssertEqual(8.60, presenter.converted(-13.0), accuracy: Float.ulpOfOne)
        XCTAssertEqual(32, presenter.converted(0.0), accuracy: Float.ulpOfOne)
        XCTAssertEqual(32.90, presenter.converted(0.5), accuracy: Float.ulpOfOne)
        XCTAssertEqual(31.10, presenter.converted(-0.5), accuracy: Float.ulpOfOne)
    }
    
    func testFahrenheitIntersectionPoint() throws {
        let presenter = TemperaturePresenter(temperatureUnit: .fahrenheit)
        XCTAssertEqual(-40.0, presenter.converted(-40.0), accuracy: Float.ulpOfOne)
    }

    func testFahrenheitStringRepresentationDotSeparator() throws {
        let locale = Locale(identifier: "en_US.UTF-8")

        let presenter = TemperaturePresenter(temperatureUnit: .fahrenheit,
                                             locale: locale as Locale)
        XCTAssertEqual("55.4 °F", presenter.stringRepresentation(13.0))
        XCTAssertEqual("8.6 °F", presenter.stringRepresentation(-13.0))
        XCTAssertEqual("32.0 °F", presenter.stringRepresentation(0.0))
        XCTAssertEqual("32.9 °F", presenter.stringRepresentation(0.5))
        XCTAssertEqual("31.1 °F", presenter.stringRepresentation(-0.5))
    }


    func testFahrenheitStringRepresentationCommaSeparator() throws {
        let locale = NSLocale(localeIdentifier: "pl_PL.UTF-8")

      let presenter = TemperaturePresenter(temperatureUnit: .fahrenheit,
                                             locale: locale as Locale)
        XCTAssertEqual("55,4 °F", presenter.stringRepresentation(13.0))
        XCTAssertEqual("8,6 °F", presenter.stringRepresentation(-13.0))
        XCTAssertEqual("32,0 °F", presenter.stringRepresentation(0.0))
        XCTAssertEqual("32,9 °F", presenter.stringRepresentation(0.5))
        XCTAssertEqual("31,1 °F", presenter.stringRepresentation(-0.5))
    }
}
