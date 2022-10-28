//
	

import UIKit

class SceneCell: MGSwipeTableCell {
    
    var scaleFactor: CGFloat = 1.0 {
        didSet {
            guard oldValue != scaleFactor else { return }
            resetCell()
        }
    }
    var sceneData: Scene? {
        didSet {
            _caption.text = sceneData?.caption ?? ""
            _initiator.text = sceneData?.initiatorName ?? ""
            //_timer.text
            if let iconId = sceneData?.usericon_id, iconId < 20 {
                _sceneIcon.image = UIImage(named: "scene_\(iconId)")
            } else if let icon = sceneData?.usericon?.uimage1 as? UIImage {
                _sceneIcon.image = icon
            }
        }
    }
    
    private let iconWidth = CGFloat(60)
    private let iconHeight = CGFloat(60)
    private let topMargin = CGFloat(11)
    private let horizMargin = CGFloat(22)
    private let eltHorizSpacing = CGFloat(6)
    private let swipeButtonWidth = CGFloat(105)
    private static let statusIndicatorDim = CGFloat(12)

    private var _iconContainer: UIView!
    private var _caption: UILabel!
    private var _timer: UILabel!
    private var _initiator: UILabel!
    private var _sceneIcon: UIImageView!
    private let _statusIndicators = [UIView(), UIView()]
    
    private var _longPressGr: UILongPressGestureRecognizer!

    private let _executeButton = MGSwipeButton(title: Strings.Scenes.ActionButtons.execute,
                                               backgroundColor: .onLine())
    private let _abortButton = MGSwipeButton(title: Strings.Scenes.ActionButtons.abort,
                                             backgroundColor: .onLine())

    
    private var allControls: [UIView] {
        return [_caption, _timer, _initiator, _sceneIcon]
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)

        // Configure the view for the selected state
    }

    // MARK: - configure cell layout
    private func setupCell() {
        _iconContainer = UIView()
        _caption = UILabel()
        _timer = UILabel()
        _initiator = UILabel()
        _sceneIcon = UIImageView()
        
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
        
        [_caption, _timer, _initiator].forEach {
            $0.font = .formLabelFont.withSize(self.scaled(14))
        }
        [_timer, _initiator].forEach { $0?.textColor = .formLabelColor }
        _caption.font = .cellCaptionFont.withSize(scaled(14, limit: .lower(1)))
        [_iconContainer, _caption, _timer, _initiator, _sceneIcon]
            .forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [_iconContainer, _timer, _initiator].forEach {
            self.contentView.addSubview($0)
        }
        
        _iconContainer.addSubview(_sceneIcon)
        _iconContainer.addSubview(_caption)
        
        _sceneIcon.heightAnchor.constraint(equalToConstant: scaled(iconWidth))
            .isActive = true
        _sceneIcon.widthAnchor.constraint(equalToConstant: scaled(iconHeight))
            .isActive = true
        _sceneIcon.centerXAnchor.constraint(equalTo: _iconContainer.centerXAnchor)
            .isActive = true
        _sceneIcon.topAnchor.constraint(equalTo: _iconContainer.topAnchor)
            .isActive = true
        
        _caption.topAnchor.constraint(equalTo: _sceneIcon.bottomAnchor)
            .isActive = true
        _caption.centerXAnchor.constraint(equalTo: _iconContainer.centerXAnchor)
            .isActive = true
        _caption.bottomAnchor.constraint(equalTo: _iconContainer.bottomAnchor)
            .isActive = true
        _longPressGr = UILongPressGestureRecognizer(target: self,
                                                    action: #selector(onLongPress(_:)))
        contentView.addGestureRecognizer(_longPressGr)
        
        _iconContainer.widthAnchor.constraint(greaterThanOrEqualTo: _caption.widthAnchor,
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
        
        _timer.topAnchor.constraint(equalTo: contentView.topAnchor,
                                    constant: scaled(topMargin)).isActive = true
        _timer.rightAnchor.constraint(equalTo: contentView.rightAnchor,
                                      constant: -horizMargin).isActive = true
                
        _timer.text = "--:--:--"
        _initiator.text = "pankracy"
        _caption.text = "my fine scene"
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
        guard let delegate = delegate as? SceneCellDelegate,
            let scene = sceneData else { return }
        if _caption.point(inside: gr.location(in: _caption), with: nil) {
            delegate.onCaptionLongPress(scene)
        } else {
            delegate.onAreaLongPress(scene)
        }
    }
    
    // MARK: - swipe buttons handling
    @objc private func onButtonTap(_ btn: MGSwipeButton) {
        btn.backgroundColor = .btnTouched()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            btn.backgroundColor = .onLine()
        }
        // TODO: dispatch requested action
        
        if(Config().autohideButtons) {
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
}

protocol SceneCellDelegate: MGSwipeTableCellDelegate {
    func onAreaLongPress(_ scn: Scene)
    func onCaptionLongPress(_ scn: Scene)
}
