//
	

import UIKit

class SceneCell: UITableViewCell {
    
    var scaleFactor: CGFloat = 1.0 {
        didSet {
            guard oldValue != scaleFactor else { return }
            resetCell()
        }
    }
    var sceneData: Scene? {
        didSet {
            _caption.text = sceneData?.caption ?? ""
            _initiator.text = sceneData?.initiatorName ?? "pankracy"
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

    private var _iconContainer: UIView!
    private var _caption: UILabel!
    private var _timer: UILabel!
    private var _initiator: UILabel!
    private var _onOffButton: UIButton!
    private var _sceneIcon: UIImageView!
    
    private var allControls: [UIView] {
        return [_caption, _timer, _initiator, _onOffButton, _sceneIcon]
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
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - configure cell layout
    private func setupCell() {
        _iconContainer = UIView()
        _caption = UILabel()
        _timer = UILabel()
        _initiator = UILabel()
        _onOffButton = UIButton()
        _sceneIcon = UIImageView()
        
        [_caption, _timer, _initiator].forEach {
            $0.font = .formLabelFont.withSize(self.scaled(14))
        }
        [_timer, _initiator].forEach { $0?.textColor = .formLabelColor }
        _caption.font = .cellCaptionFont.withSize(scaled(14, limit: .lower(1)))
        [_iconContainer, _caption, _timer, _initiator, _onOffButton, _sceneIcon]
            .forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [_iconContainer, _timer, _initiator, _onOffButton].forEach {
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
        _onOffButton.rightAnchor.constraint(equalTo: contentView.rightAnchor,
                                            constant: -horizMargin).isActive = true
        _onOffButton.centerYAnchor.constraint(equalTo: _initiator.centerYAnchor)
            .isActive = true
        _onOffButton.centerYAnchor.constraint(equalTo: _timer.centerYAnchor)
            .isActive = true
        
        _timer.rightAnchor.constraint(equalTo: _onOffButton.leftAnchor,
                                      constant: -eltHorizSpacing).isActive = true
        _timer.topAnchor.constraint(equalTo: contentView.topAnchor,
                                    constant: scaled(topMargin)).isActive = true
                
        _onOffButton.setBackgroundImage(UIImage(named: "on-off"))
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
