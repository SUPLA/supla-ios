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
import os
import RxSwift

final class SceneCell: BaseCell<SAScene> {
    
    @Singleton<GlobalSettings> private var settings
    
    private lazy var sceneIconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let executeButton = CellButton(title: Strings.Scenes.ActionButtons.execute, backgroundColor: .primary)
    private let abortButton = CellButton(title: Strings.Scenes.ActionButtons.abort, backgroundColor: .primary)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func leftButtonSettings() -> CellButtonSettings {
        CellButtonSettings(visible: true, title: Strings.Scenes.ActionButtons.abort)
    }
    
    override func rightButtonSettings() -> CellButtonSettings {
        CellButtonSettings(visible: true, title: Strings.Scenes.ActionButtons.execute)
    }
    
    override func getLocationCaption() -> String? { data?.location?.caption }
    
    override func getRemoteId() -> Int32? { data?.sceneId }
    
    override func derivedClassControls() -> [UIView] { return [sceneIconView] }
    
    override func provideRefreshData(_ updateEventsManager: UpdateEventsManager, forData: SAScene) -> Observable<SAScene> {
        updateEventsManager.observeScene(sceneId: Int(forData.sceneId))
    }
    
    override func timerEndDate() -> Date? { data?.estimatedEndDate }
    
    override func onTimerStopped() { setActive(false) }
    
    // MARK: - configure cell layout
    
    override func setupView() {
        setActive(false)
        
        container.addSubview(sceneIconView)
        
        super.setupView()
    }
    
    override func derivedClassConstraints() -> [NSLayoutConstraint] {
        return [
            sceneIconView.widthAnchor.constraint(equalToConstant: scale(Dimens.ListItem.iconWidth)),
            sceneIconView.heightAnchor.constraint(equalToConstant: scale(Dimens.ListItem.iconHeight)),
            sceneIconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            sceneIconView.topAnchor.constraint(equalTo: container.topAnchor)
        ]
    }
    
    override func updateContent(data: SAScene) {
        super.updateContent(data: data)
        
        caption = data.caption ?? "" 
        
        if data.usericon_id != 0 {
            let darkMode = settings.darkMode == .always || (settings.darkMode == .auto && UITraitCollection.current.userInterfaceStyle == .dark)
            
            if let imageData = data.usericon?.getIcon(.icon1, darkMode: darkMode) as? Data {
                sceneIconView.image = UIImage(data: imageData as Data)
            } else {
                sceneIconView.image = UIImage(named: "scene_0")
            }
        } else if data.alticon < 20 {
            sceneIconView.image = UIImage(named: "scene_\(data.alticon)")
        } else {
            sceneIconView.image = UIImage(named: "scene_0")
        }
        
        setActive(data.estimatedEndDate != nil)
    }
    
    private func setActive(_ active: Bool) {
        leftStatusIndicatorView.configure(filled: active, online: true)
        rightStatusIndicatorView.configure(filled: active, online: true)
    }
}

protocol SceneCellDelegate: BaseCellDelegate {
}
