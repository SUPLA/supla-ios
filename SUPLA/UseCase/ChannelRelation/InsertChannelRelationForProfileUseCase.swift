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

final class InsertChannelRelationForProfileUseCase {
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRelationRepository> private var channelRelationRepository
    
    func invoke(suplaRelation: TSC_SuplaChannelRelation) {
        do {
            try profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    let relationType = ChannelRelationType.from(suplaRelation.Type)
                    return self.channelRelationRepository
                        .getRelation(for: profile, with: suplaRelation.Id, with: suplaRelation.ParentId, and: relationType)
                        .ifEmpty(switchTo: self.createRelation(profile, suplaRelation.Id, relationType))
                }
                .modify { relation in
                    relation.parent_id = suplaRelation.ParentId
                    relation.delete_flag = false
                }
                .flatMapFirst { self.channelRelationRepository.save($0) }
                .toBlocking()
                .first()
        } catch {
            NSLog("Could not insert relation `\(suplaRelation)` because of `\(error)`")
        }
    }
    
    private func createRelation(_ profile: AuthProfileItem, _ channelId: Int32, _ relationType: ChannelRelationType) -> Observable<SAChannelRelation> {
        return channelRelationRepository.create()
            .modify { relation in
                relation.profile = profile
                relation.channel_id = channelId
                relation.channel_relation_type = relationType.rawValue
            }
    }
}
