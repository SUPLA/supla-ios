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

class BaseCell<T>: MGSwipeTableCell {
    
    @Singleton<GlobalSettings> private var settings
    @Singleton<ListsEventsManager> private var listsEventsManager
    
    var scaleFactor: CGFloat = 1.0 {
        didSet {
            guard oldValue != scaleFactor else { return }
            resetCell()
        }
    }
    var data: T? {
        didSet {
            guard let data = data else { return }
            
            updateContent(data: data)
            provideRefreshData(listsEventsManager, forData: data)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] data in self?.updateContent(data: data) }
                )
                .disposed(by: disposeBag)
        }
    }
    
    var caption: String? {
        get { captionView.text }
        set { captionView.text = newValue }
    }
    
    var timer: String? {
        get { timerView.text }
        set { timerView.text = newValue}
    }
    
    var initiator: String? {
        get { initiatorView.text }
        set { initiatorView.text = newValue }
    }
    
    var container: UIView {
        get { containerView }
    }
    
    var showChannelInfo: Bool {
        get { !infoView.isHidden }
        set { infoView.isHidden = !newValue || !online() }
    }
    
    var issueIcon: IssueIconType? {
        get { nil }
        set {
            if (newValue == nil) {
                issueView.isHidden = true
            } else {
                issueView.isHidden = false
                issueView.image = newValue?.icon()
            }
        }
    }
    
    let leftStatusIndicatorView = CellStatusIndicatorView()
    
    let rightStatusIndicatorView = CellStatusIndicatorView()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var captionLongPressRecongizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(onCaptionLongPress(_:)))
        recognizer.allowableMovement = 5
        recognizer.minimumPressDuration = 0.8
        return recognizer
    } ()
    
    private lazy var captionView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(captionLongPressRecongizer)
        return label
    }()
    
    private lazy var timerView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        return label
    }()
    
    private lazy var initiatorView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var infoView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = .iconInfo
        view.isHidden = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onInfoPress(_:)))
        )
        return view
    }()
    
    private lazy var issueView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        view.isUserInteractionEnabled = true
        view .addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onIssuePress(_:)))
        )
        return view
    }()
    
    private lazy var leftButton: CellButton = {
        let button: CellButton = CellButton(title: "", backgroundColor: .onLine())
        button.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var rightButton: CellButton = {
        let button: CellButton = CellButton(title: "", backgroundColor: .onLine())
        button.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
        return button
    }()
    private var captionTouched = false
    private var currentConstraints: [NSLayoutConstraint] = []
    private var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: Open methods, relevant for child classes
    
    func content() -> UIView { fatalError("content() has not been implemented") }
    
    func getLocationCaption() -> String? { fatalError("getLocationCaption() has not been implemented") }
    
    func leftButtonSettings() -> CellButtonSettings { CellButtonSettings(visible: false) }
    
    func rightButtonSettings() -> CellButtonSettings { CellButtonSettings(visible: false) }
    
    func remoteId() -> Int32? { fatalError("remoteId() has not been implemented") }
    
    func online() -> Bool { false }
    
    func derivedClassControls() -> [UIView] { fatalError("derivedClassControls() has not been implemented") }
    
    func derivedClassConstraints() -> [NSLayoutConstraint] { fatalError("derivedClassConstraints() has not been implemented") }

    func issueMessage() -> String? { nil }
    
    func provideRefreshData(_ listsEventsManager: ListsEventsManager, forData: T) -> Observable<T> {
        fatalError("provideRefreshData(_:) has not been implemented")
    }
    
    func updateContent(data: T) {
        let leftButtonSettings = leftButtonSettings()
        if (leftButtonSettings.visible) {
            leftButton.setTitle(leftButtonSettings.title, for: .normal)
            leftButton.buttonWidth = Dimens.ListItem.buttonWidth
            leftButtons = [ leftButton as Any ]
        } else {
            leftButtons = []
        }
        
        let rightButtonSettings = rightButtonSettings()
        if (rightButtonSettings.visible) {
            rightButton.setTitle(rightButtonSettings.title, for: .normal)
            rightButton.buttonWidth = Dimens.ListItem.buttonWidth
            rightButtons = [ rightButton as Any ]
        } else {
            rightButtons = []
        }
    }
    
    // MARK: Public content
    
    func scale(_ value: CGFloat, limit: CellScalingLimit = .none) -> CGFloat {
        var scale = scaleFactor
        switch (limit) {
        case .lower(let val):
            if (scaleFactor < val) { scale = val }
            break;
        case .upper(let val):
            if (scaleFactor > val) { scale = val }
            break;
        default: break
        }
        
        return value * scale
    }
    
    func isCaptionTouched() -> Bool { captionTouched }
    
    func setupView() {
        contentView.backgroundColor = .listItemBackground
        
        captionView.font = .cellCaptionFont.withSize(scale(Dimens.Fonts.caption, limit: .lower(1)))
        timerView.font = .formLabelFont.withSize(scale(Dimens.Fonts.label))
        initiatorView.font = .formLabelFont.withSize(scale(Dimens.Fonts.label))
        
        self.leftSwipeSettings.transition = MGSwipeTransition.rotate3D
        self.rightSwipeSettings.transition = MGSwipeTransition.rotate3D
        
        contentView.addSubview(captionView)
        contentView.addSubview(timerView)
        contentView.addSubview(initiatorView)
        contentView.addSubview(separatorView)
        contentView.addSubview(leftStatusIndicatorView)
        contentView.addSubview(rightStatusIndicatorView)
        contentView.addSubview(containerView)
        contentView.addSubview(infoView)
        contentView.addSubview(issueView)
        
        currentConstraints.append(contentsOf: setupConstraints())
        currentConstraints.append(contentsOf: derivedClassConstraints())
        NSLayoutConstraint.activate(currentConstraints)
    }
    
    // MARK: Private content
    
    private func setupConstraints() -> [NSLayoutConstraint] {
        let topAnchor = contentView.topAnchor
        let leftMarginAnchor = contentView.layoutMarginsGuide.leftAnchor
        let rightMarginAnchor = contentView.layoutMarginsGuide.rightAnchor
        let leftAnchor = contentView.leftAnchor
        let rightAnchor = contentView.rightAnchor
        let bottomAnchor = contentView.bottomAnchor
        
        var constraints = [
            captionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            captionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -scale(Dimens.ListItem.verticalPadding)),
            
            timerView.topAnchor.constraint(equalTo: topAnchor, constant: scale(Dimens.ListItem.verticalPadding)),
            timerView.rightAnchor.constraint(equalTo: rightMarginAnchor, constant: -Dimens.ListItem.horizontalPadding),
            
            initiatorView.leftAnchor.constraint(equalTo: leftMarginAnchor, constant: Dimens.ListItem.horizontalPadding),
            initiatorView.topAnchor.constraint(equalTo: topAnchor, constant: scale(Dimens.ListItem.verticalPadding)),
            
            separatorView.heightAnchor.constraint(equalToConstant: Dimens.ListItem.separatorHeight),
            separatorView.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.ListItem.separatorInset),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.ListItem.separatorInset),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            
            leftStatusIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightStatusIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftStatusIndicatorView.leftAnchor.constraint(equalTo: leftMarginAnchor, constant: Dimens.ListItem.horizontalPadding),
            rightStatusIndicatorView.rightAnchor.constraint(equalTo: rightMarginAnchor, constant: -Dimens.ListItem.horizontalPadding),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: scale(Dimens.ListItem.verticalPadding)),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.bottomAnchor.constraint(equalTo: captionView.topAnchor),
            
            infoView.widthAnchor.constraint(equalToConstant: Dimens.iconSizeList),
            infoView.heightAnchor.constraint(equalToConstant: Dimens.iconSizeList),
            infoView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoView.leftAnchor.constraint(equalTo: leftStatusIndicatorView.rightAnchor, constant: 20),
            
            issueView.widthAnchor.constraint(equalToConstant: Dimens.iconSizeList),
            issueView.heightAnchor.constraint(equalToConstant: Dimens.iconSizeList),
            issueView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            issueView.rightAnchor.constraint(equalTo: rightStatusIndicatorView.leftAnchor, constant: -30)
        ]
        
        constraints.append(contentsOf: leftStatusIndicatorView.constraints())
        constraints.append(contentsOf: rightStatusIndicatorView.constraints())
        
        return constraints
    }
    
    private func resetCell() {
        if (!currentConstraints.isEmpty) {
            NSLayoutConstraint.deactivate(currentConstraints)
            currentConstraints.removeAll()
        }
        
        allControls().forEach {
            $0.removeFromSuperview()
        }
        
        setupView()
        layoutIfNeeded()
    }
    
    private func allControls() -> [UIView] {
        var controls = [
            containerView,
            captionView,
            timerView,
            initiatorView,
            separatorView,
            leftStatusIndicatorView,
            rightStatusIndicatorView,
            infoView,
            issueView
        ]
        controls.append(contentsOf: derivedClassControls())
        return controls
    }
    
    @objc func onInfoPress(_ gr: UITapGestureRecognizer) { }
    
    @objc private func onCaptionLongPress(_ gr: UILongPressGestureRecognizer) {
        if (gr.state != .began) {
            return
        }
        
        guard
            let delegate = delegate as? BaseCellDelegate,
            let remoteId = remoteId()
        else {
            return
        }
        
        delegate.onCaptionLongPress(remoteId)
    }
    
    @objc private func onIssuePress(_ gr: UITapGestureRecognizer) {
        guard
            let delegate = delegate as? BaseCellDelegate,
            let message = issueMessage()
        else {
            return
        }
        
        delegate.onIssueIconTapped(issueMessage: message)
    }
    
    @objc private func onButtonTap(_ btn: MGSwipeButton) {
        btn.backgroundColor = .btnTouched()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            btn.backgroundColor = .onLine()
            
            if (self.settings.autohideButtons) {
                self.hideSwipe(animated: true)
            }
        }
        
        guard
            let delegate = delegate as? BaseCellDelegate,
            let remoteId = remoteId()
        else { return }
        
        if (btn == leftButton) {
            delegate.onButtonTapped(buttonType: .leftButton, remoteId: remoteId, data: data)
        }
        if (btn == rightButton) {
            delegate.onButtonTapped(buttonType: .rightButton, remoteId: remoteId, data: data)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touchedObject = touches.first
        captionTouched = touchedObject != nil && touchedObject?.view == captionView
    }
}

protocol BaseCellDelegate: MGSwipeTableCellDelegate {
    func onCaptionLongPress(_ remoteId: Int32)
    func onIssueIconTapped(issueMessage: String)
    func onButtonTapped(buttonType: CellButtonType, remoteId: Int32, data: Any?)
}

extension BaseCell: MoveableCell {
    
    func movementEnabled() -> Bool {
        !isCaptionTouched()
    }
    
    func dropAllowed(to destination: MoveableCell) -> Bool {
        getLocationCaption() == destination.getLocationCaption()
    }
}

enum CellScalingLimit {
    case none /// no scale limiting
    case upper(CGFloat) /// upper limit for scaling factor
    case lower(CGFloat) /// lower limit for scaling factor
}

class CellStatusIndicatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func configure(filled: Bool, online: Bool) {
        let color = online ? UIColor.primary : UIColor.error
        if (filled) {
            layer.borderColor = color.cgColor
            backgroundColor = color
        } else {
            layer.borderColor = color.cgColor
            backgroundColor = .clear
        }
    }
    
    func setInvisible() {
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = .clear
    }
    
    func constraints() -> [NSLayoutConstraint] {
        return [
            widthAnchor.constraint(equalToConstant: Dimens.ListItem.statusIndicatorSize),
            heightAnchor.constraint(equalToConstant: Dimens.ListItem.statusIndicatorSize)
        ]
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = Dimens.ListItem.statusIndicatorSize / 2
        layer.borderWidth = 1
        
        setInvisible()
    }
}
