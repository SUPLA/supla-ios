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

import Foundation
import RxSwift

final class UpdateSceneStateUseCase {
    
    @Singleton<SceneRepository> private var sceneRepository
    @Singleton<ListsEventsManager> private var listsEventsManager
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke(state: TSC_SuplaSceneState, clientId: Int) -> Bool {
        var saved = false
        
        do {
            saved = try sceneRepository
                .getScene(remoteId: Int(state.SceneId))
                .map { scene in self.updateScene(scene: scene, state: state, clientId: clientId) }
                .flatMapFirst { tuple in
                    if (tuple.0) {
                        return self.sceneRepository.save(tuple.1).map { true }
                    }
                    
                    return Observable.just(tuple.0)
                }
                .toBlocking()
                .first() ?? false
            
            if (saved) {
                listsEventsManager.emitSceneChange(sceneId: Int(state.SceneId))
            }
            
        } catch {
            saved = false
        }
        
        return saved
    }
    
    private func updateScene(scene: SAScene, state: TSC_SuplaSceneState, clientId: Int) -> (Bool, SAScene) {
        var saved = false
        
        if (state.InitiatorId != clientId) {
            if (scene.initiatorId != state.InitiatorId) {
                scene.initiatorId = Int64(state.InitiatorId)
                saved = true
            }
            
            let initiatorName = String.fromC(state.InitiatorId)
            if (scene.initiatorName != initiatorName) {
                scene.initiatorName = initiatorName
                saved = true
            }
        }
        else if (scene.initiatorId != 0) {
            scene.initiatorId = 0
            scene.initiatorName = nil
            saved = true
        }
        
        if (state.MillisecondsFromStart > 0) {
            let startDate = Date(timeIntervalSinceNow: -Double(Int(state.MillisecondsFromStart)/1000))
            if (scene.startedAt == nil || startDate.compare(scene.startedAt!) != .orderedSame) {
                scene.startedAt = startDate
                saved = true
            }
        } else if (scene.startedAt != nil) {
            scene.startedAt = nil
            saved = true
        }
        
        if (state.MillisecondsLeft > 0) {
            let endDate = Date(timeIntervalSinceNow: Double(Int(state.MillisecondsLeft)/1000))
            if (scene.estimatedEndDate == nil || endDate.compare(scene.estimatedEndDate!) != .orderedSame) {
                scene.estimatedEndDate = endDate
                saved = true
            }
        } else if (scene.estimatedEndDate != nil) {
            scene.estimatedEndDate = nil
            saved = true
        }
        
        return (saved, scene)
    }
}

extension String {
    static func fromC<T>(_ address: T) -> String {
        return withUnsafePointer(to: address) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                String(cString: $0)
            }
        }
    }
}
