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

import UIKit

class SceneCaptionEditor: SACaptionEditor {
    
    @Singleton<SceneRepository> private var sceneRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    init() {
        super.init(nibName: "SACaptionEditor", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getTitle() -> String {
        return Strings.Scenes.RenameDialog.sceneName
    }
    
    override func getCaption() -> String {
        try! profileRepository.getActiveProfile()
            .flatMapFirst { self.sceneRepository.getScene(for: $0, with: self.recordId) }
            .subscribeSynchronous()?.caption ?? ""
    }
    
    override func applyChanges(_ caption: String) {
        try! profileRepository.getActiveProfile()
            .flatMapFirst { self.sceneRepository.getScene(for: $0, with: self.recordId) }
            .map { scene in
                scene.caption = caption
                return scene
            }
            .flatMapFirst { self.sceneRepository.save($0) }
            .subscribeSynchronous()
        
        SAApp.suplaClient().setSceneCaption(recordId, caption: caption)
        
        delegate?.captionEditorDidFinish(self)
    }
}
