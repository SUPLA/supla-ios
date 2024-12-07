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

final class LoadActiveProfileUrlUseCaseTests: UseCaseTest<CloudUrl> {
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    
    private lazy var useCase: LoadActiveProfileUrlUseCase! = {
        LoadActiveProfileUrlUseCaseImpl()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        profileRepository = nil
        useCase = nil
    }
    
    func test_shouldGetSuplaCloud_whenEmailAuth() {
        // given
        let profile = AuthProfileItem.mock()
//        profile.authInfo = AuthInfo.mock(emailAuth: true, serverForEmail: "srv1.supla.org")
        profileRepository.activeProfileObservable = .just(profile)
        
        // when
        useCase.invoke()
            .asObservable()
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(.suplaCloud),
            .completed
        ])
    }
    
    func test_shouldGetPrivateCloud_whenEmailAuth() {
        // given
        let url = "myprivate.cloud.org"
        let profile = AuthProfileItem.mock()
//        profile.authInfo = AuthInfo.mock(emailAuth: true, serverForEmail: url)
        profileRepository.activeProfileObservable = .just(profile)
        
        // when
        useCase.invoke()
            .asObservable()
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(.privateCloud(url: URL(string: "https://\(url)")!)),
            .completed
        ])
    }
    
    func test_shouldGetSuplaCloud_whenAccessId() {
        // given
        let profile = AuthProfileItem.mock()
//        profile.authInfo = AuthInfo.mock(emailAuth: false, serverForAccessID: "srv1.supla.org")
        profileRepository.activeProfileObservable = .just(profile)
        
        // when
        useCase.invoke()
            .asObservable()
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(.suplaCloud),
            .completed
        ])
    }
    
    func test_shouldGetPrivateCloud_whenAccessId() {
        // given
        let url = "myprivate.cloud.org"
        let profile = AuthProfileItem.mock()
//        profile.authInfo = AuthInfo.mock(emailAuth: false, serverForAccessID: url)
        profileRepository.activeProfileObservable = .just(profile)
        
        // when
        useCase.invoke()
            .asObservable()
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([
            .next(.privateCloud(url: URL(string: "https://\(url)")!)),
            .completed
        ])
    }
}
