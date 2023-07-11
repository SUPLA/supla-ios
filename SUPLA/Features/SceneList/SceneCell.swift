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

class SceneCell: MGSwipeTableCell {
    
    @Singleton<ListsEventsManager> private var listsEventsManager
    @Singleton<GlobalSettings> private var settings
    
    var scaleFactor: CGFloat = 1.0 {
        didSet {
            guard oldValue != scaleFactor else { return }
            resetCell()
        }
    }
    var sceneData: SAScene? {
        didSet {
            guard let scene = sceneData else { return }
            
            displayData(scene: scene)
            listsEventsManager.observeScene(sceneId: Int(scene.sceneId))
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] sceneUpdated in
                        self?.displayData(scene: sceneUpdated)
                    }
                )
                .disposed(by: disposeBag)
        }
    }
    
    private let iconWidth = CGFloat(100)
    private let iconHeight = CGFloat(50)
    private let topMargin = CGFloat(11)
    private let horizMargin = CGFloat(22)
    private let eltHorizSpacing = CGFloat(6)
    private let swipeButtonWidth = CGFloat(105)
    private static let statusIndicatorDim = CGFloat(12)
    
    private var _iconContainer: UIView!
    private var _captionLabel: UILabel!
    private var _timerLabel: UILabel!
    private var _initiator: UILabel!
    private var _sceneIcon: UIImageView!
    private var _separator: UIView!
    private let _statusIndicators = [UIView(), UIView()]
    
    private var _longPressGr: UILongPressGestureRecognizer!
    
    private let _executeButton = MGSwipeButton(title: Strings.Scenes.ActionButtons.execute,
                                               backgroundColor: .onLine())
    private let _abortButton = MGSwipeButton(title: Strings.Scenes.ActionButtons.abort,
                                             backgroundColor: .onLine())
    
    private var _timer: Timer? = nil
    private let _formatter = DateComponentsFormatter()
    
    private var captionTouched = false
    
    private var allControls: [UIView] {
        return [_captionLabel, _timerLabel, _initiator, _sceneIcon]
    }
    
    private var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func isCaptionTouched() -> Bool { captionTouched }
    
    // MARK: - configure cell layout
    private func setupCell() {
        _iconContainer = UIView()
        _captionLabel = UILabel()
        _timerLabel = UILabel()
        _initiator = UILabel()
        _sceneIcon = UIImageView()
        _separator = UIView(frame: .zero)
        
        self.leftSwipeSettings.transition = MGSwipeTransition.rotate3D
        self.rightSwipeSettings.transition = MGSwipeTransition.rotate3D
        
        [_executeButton, _abortButton].forEach {
            $0?.buttonWidth = swipeButtonWidth
            $0?.titleLabel?.font = .suplaSubtitleFont
            $0?.addTarget(self, action: #selector(onButtonTap),
                          for: .touchUpInside)
        }
        _statusIndicators.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = SceneCell.statusIndicatorDim / 2
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.suplaGreen.cgColor
            self.contentView.addSubview($0)
            $0.widthAnchor.constraint(equalToConstant: SceneCell.statusIndicatorDim).isActive = true
            $0.heightAnchor.constraint(equalToConstant: SceneCell.statusIndicatorDim).isActive = true
            $0.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
                .isActive = true
        }
        _statusIndicators[0].leftAnchor.constraint(equalTo: contentView.leftAnchor,
                                                   constant: horizMargin).isActive = true
        _statusIndicators[1].rightAnchor.constraint(equalTo: contentView.rightAnchor,
                                                    constant: -horizMargin).isActive = true
        setActive(false)
        
        self.leftButtons = [ _abortButton as Any ]
        self.rightButtons = [ _executeButton as Any ]
        
        [_timerLabel, _initiator].forEach {
            $0.font = .formLabelFont.withSize(self.scaled(14))
        }
        [_timerLabel, _initiator].forEach { $0?.textColor = .formLabelColor }
        _captionLabel.font = .cellCaptionFont.withSize(scaled(12, limit: .lower(1)))
        [_iconContainer, _captionLabel, _timerLabel, _initiator, _sceneIcon]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
        
        [_iconContainer, _timerLabel, _initiator].forEach {
            self.contentView.addSubview($0)
        }
        
        _iconContainer.addSubview(_sceneIcon)
        _iconContainer.addSubview(_captionLabel)
        
        _sceneIcon.heightAnchor.constraint(equalToConstant: scaled(iconHeight))
            .isActive = true
        _sceneIcon.widthAnchor.constraint(equalToConstant: scaled(iconWidth))
            .isActive = true
        _sceneIcon.centerXAnchor.constraint(equalTo: _iconContainer.centerXAnchor)
            .isActive = true
        _sceneIcon.topAnchor.constraint(equalTo: _iconContainer.topAnchor)
            .isActive = true
        _sceneIcon.contentMode = .scaleAspectFit
        
        _captionLabel.topAnchor.constraint(equalTo: _sceneIcon.bottomAnchor)
            .isActive = true
        _captionLabel.centerXAnchor.constraint(equalTo: _iconContainer.centerXAnchor)
            .isActive = true
        _captionLabel.bottomAnchor.constraint(equalTo: _iconContainer.bottomAnchor)
            .isActive = true
        
        _longPressGr = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        _longPressGr.allowableMovement = 5
        _longPressGr.minimumPressDuration = 0.8
        _captionLabel.isUserInteractionEnabled = true
        _captionLabel.addGestureRecognizer(_longPressGr)
        
        _iconContainer.widthAnchor.constraint(greaterThanOrEqualTo: _captionLabel.widthAnchor,
                                              multiplier: 1).isActive = true
        
        _iconContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            .isActive = true
        _iconContainer.topAnchor.constraint(equalTo: contentView.topAnchor,
                                            constant: scaled(topMargin))
        .isActive = true
        _iconContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                               constant: -scaled(topMargin))
        .isActive = true
        
        _initiator.leftAnchor.constraint(equalTo: contentView.leftAnchor,
                                         constant: horizMargin).isActive = true
        _initiator.topAnchor.constraint(equalTo: contentView.topAnchor,
                                        constant: scaled(topMargin)).isActive = true
        
        _timerLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                         constant: scaled(topMargin)).isActive = true
        _timerLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor,
                                           constant: -horizMargin).isActive = true
        
        self.contentView.addSubview(_separator)
        let separatorInset = CGFloat(8)
        let separatorHeight = CGFloat(1)
        _separator.backgroundColor = .systemGray
        _separator.translatesAutoresizingMaskIntoConstraints = false
        _separator.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
        _separator.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: separatorInset).isActive = true
        _separator.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -separatorInset).isActive = true
        _separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2.0 * separatorHeight).isActive = true
        
        
        _formatter.allowedUnits = [.hour, .minute, .second]
        _formatter.zeroFormattingBehavior = .pad
    }
    
    private func displayData(scene: SAScene) {
        _captionLabel.text = scene.caption ?? ""
        
        if scene.usericon_id != 0 {
            if let data = scene.usericon?.uimage1 as? Data {
                _sceneIcon.image = UIImage(data: data as Data)
            } else {
                _sceneIcon.image = UIImage(named: "scene_0")
            }
        } else if scene.alticon < 20 {
            _sceneIcon.image = UIImage(named: "scene_\(scene.alticon)")
        } else {
            _sceneIcon.image = UIImage(named: "scene_0")
        }
        
        if (_timer != nil) {
            _timerLabel.text = ""
            _timer?.invalidate()
        }
        
        if (scene.estimatedEndDate != nil) {
            _initiator.text = scene.initiatorName ?? ""
            updateTimerLabel()
            _timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
            setActive(true)
        } else {
            _initiator.text = ""
            setActive(false)
        }
    }
    
    private func resetCell() {
        allControls.forEach {
            $0.removeFromSuperview()
        }
        setupCell()
    }
    
    private func setActive(_ act: Bool) {
        _statusIndicators.forEach {
            if act {
                $0.backgroundColor = .suplaGreen
            } else {
                $0.backgroundColor = .clear
            }
        }
    }
    
    @objc private func onLongPress(_ gr: UILongPressGestureRecognizer) {
        if (gr.state != .began) {
            return
        }
        
        guard
            let delegate = delegate as? SceneCellDelegate,
            let scene = sceneData
        else {
            return
        }
        delegate.onCaptionLongPress(scene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touchedObject = touches.first
        captionTouched = touchedObject != nil && touchedObject?.view == _captionLabel
    }
    
    // MARK: - swipe buttons handling
    @objc private func onButtonTap(_ btn: MGSwipeButton) {
        btn.backgroundColor = .btnTouched()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            btn.backgroundColor = .onLine()
        }
        
        guard
            let scene = sceneData
        else {
            return
        }
        
        if (btn == _executeButton) {
            _ = SAApp.suplaClient().executeAction(parameters: .simple(action: .execute, subjectType: .scene, subjectId: scene.sceneId))
        }
        if (btn == _abortButton) {
            _ = SAApp.suplaClient().executeAction(parameters: .simple(action: .interrupt, subjectType: .scene, subjectId: scene.sceneId))
        }
        
        
        if (settings.autohideButtons) {
            hideSwipe(animated: true)
        }
    }
    
    
    // MARK: - scaling support
    private enum ScalingLimit {
        case none /// no scale limiting
        case upper(CGFloat) /// upper limit for scaling factor
        case lower(CGFloat) /// lower limit for scaling factor
    }
    
    private func scaled(_ dimension: CGFloat, limit: ScalingLimit = .none) -> CGFloat {
        var sf = scaleFactor
        switch limit {
        case .lower(let val):
            if(scaleFactor < val) { sf = val }
        case .upper(let val):
            if(scaleFactor > val) { sf = val }
        default: break
        }
        return sf * dimension
    }
    
    @objc private func updateTimerLabel() {
        let currentTime = NSDate().timeIntervalSince1970
        let endTime = sceneData?.estimatedEndDate?.timeIntervalSince1970 ?? 0
        
        if (currentTime > endTime) {
            _timerLabel.text = ""
            _timer?.invalidate()
            _timer = nil
            
            setActive(false)
        }
        else {
            let timeDiff = endTime - currentTime
            _timerLabel.text = _formatter.string(from: timeDiff + 1)
        }
    }
}

protocol SceneCellDelegate: MGSwipeTableCellDelegate {
    func onCaptionLongPress(_ scn: SAScene)
}
