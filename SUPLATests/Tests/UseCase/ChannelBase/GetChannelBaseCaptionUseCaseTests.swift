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

final class GetChannelBaseCaptionUseCaseTests: XCTestCase {
    
    private lazy var useCase: GetChannelBaseCaptionUseCase! = {
        GetChannelBaseCaptionUseCaseImpl()
    }()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        useCase = nil
        
        super.tearDown()
    }
    
    func test_shouldGetDefaultCaption() {
        // given
        let channel = SAChannel.mock(function: SUPLA_CHANNELFNC_THERMOMETER)
        
        // when
        let caption = useCase.invoke(channelBase: channel)
        
        // then
        XCTAssertEqual(caption, "Thermometer")
    }
    
    func test_shouldGetCustomCaption() {
        // given
        let channel = SAChannel.mock(caption: "custom caption")
        
        // when
        let caption = useCase.invoke(channelBase: channel)
        
        // then
        XCTAssertEqual(caption, "custom caption")
    }
}
