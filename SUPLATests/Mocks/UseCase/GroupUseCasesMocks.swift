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

import RxSwift

@testable import SUPLA

extension CreateProfileGroupsList {
    final class Mock: CreateProfileGroupsList.UseCase {
        var invokeMock: FunctionMock<Void, Observable<[MainListItem]>> = .init()

        func invoke() -> Observable<[MainListItem]> {
            invokeMock.handle(())
        }
    }
}

extension GroupToMainListItem {
    final class Mock: GroupToMainListItem.UseCase {
        var invokeMock: FunctionMock<SAChannelGroup, MainListItem?> = .init()
        var invokeWithLocationMock: FunctionMock<(SAChannelGroup, _SALocation), MainListItem> = .init()

        func invoke(_ group: SAChannelGroup) -> MainListItem? {
            invokeMock.handle(group)
        }

        func invoke(_ group: SAChannelGroup, location: _SALocation) -> MainListItem {
            invokeWithLocationMock.handle((group, location))
        }
    }
}

final class SwapGroupPositionsUseCaseMock: SwapGroupPositionsUseCase {
    
    var observable: Observable<Void> = Observable.empty()
    var firstRemoteIdArray: [Int32] = []
    var secondRemoteIdArray: [Int32] = []
    var locationCaptionArray: [String] = []
    
    func invoke(firstRemoteId: Int32, secondRemoteId: Int32, locationCaption: String) -> Observable<Void> {
        firstRemoteIdArray.append(firstRemoteId)
        secondRemoteIdArray.append(secondRemoteId)
        locationCaptionArray.append(locationCaption)
        
        return observable
    }
}

final class ReadGroupByRemoteIdUseCaseMock: ReadGroupByRemoteIdUseCase {
    
    var returns: Observable<SAChannelGroup> = Observable.empty()
    var remoteIdArray: [Int32] = []
    func invoke(remoteId: Int32) -> Observable<SAChannelGroup> {
        remoteIdArray.append(remoteId)
        return returns
    }
}

final class GetGroupOnlineSummaryUseCaseMock: GetGroupOnlineSummaryUseCase {
    
    var returns: Observable<GroupOnlineSummary> = .empty()
    var parameters: [Int32] = []
    func invoke(remoteId: Int32) -> Observable<GroupOnlineSummary> {
        parameters.append(remoteId)
        return returns
    }
}

final class ReadGroupTiltingDetailsUseCaseMock: ReadGroupTiltingDetailsUseCase {
    var returns: Observable<TiltingDetails> = .empty()
    var parameters: [Int32] = []
    func invoke(remoteId: Int32) -> Observable<TiltingDetails> {
        parameters.append(remoteId)
        return returns
    }
}
