//
	

import UIKit

class SceneCaptionEditor: SACaptionEditor {
    
    weak var delegate: SceneCaptionEditorDelegate?
    let scene: SAScene
    
    init(_ scene: SAScene) {
        self.scene = scene
        super.init(nibName: "SACaptionEditor", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func edit() {
        editCaption(withRecordId: scene.sceneId)
    }
    
    override func getTitle() -> String {
        return Strings.Scenes.RenameDialog.sceneName
    }
    
    override func getCaption() -> String {
        SAApp.db().fetchScene(byId: recordId)?.caption ?? ""
    }
    
    override func applyChanges(_ caption: String) {
        scene.caption = caption
        delegate?.sceneCaptionEditorDidFinish(self)
    }
}

protocol SceneCaptionEditorDelegate: AnyObject {
    func sceneCaptionEditorDidFinish(_ ed: SceneCaptionEditor)
}

