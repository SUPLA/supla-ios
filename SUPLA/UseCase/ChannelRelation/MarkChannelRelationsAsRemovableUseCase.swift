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

final class MarkChannelRelationsAsRemovableUseCase {
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRelationRepository> private var channelRelationRepository
    
    func invoke() -> Observable<Void> {
        profileRepository.getActiveProfile()
            .flatMapFirst { self.channelRelationRepository.getAllRelations(for: $0)}
            .modify { relations in
                relations.forEach { $0.delete_flag = true }
            }
            .flatMapFirst { _ in self.channelRelationRepository.save() }
    }
}