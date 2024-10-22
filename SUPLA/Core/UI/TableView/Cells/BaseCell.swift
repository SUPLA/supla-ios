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

protocol BaseCellData {
    var infoSupported: Bool { get }
}

class BaseCell<T: BaseCellData>: MGSwipeTableCell {
    @Singleton<GlobalSettings> private var settings
    @Singleton<UpdateEventsManager> private var updateEventsManager
    @Singleton<GetChannelActionStringUseCase> private var getChannelActionStringUseCase
    
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
            provideRefreshData(updateEventsManager, forData: data)
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
    
    var initiator: String? {
        get { initiatorView.text }
        set { initiatorView.text = newValue }
    }
    
    var container: UIView { containerView }
    
    var showChannelInfo: Bool = false {
        didSet {
            guard let data = data else {
                infoView.isHidden = !showChannelInfo
                return
            }
            infoView.isHidden = !showChannelInfo || !data.infoSupported || !online()
        }
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
    }()
    
    private lazy var captionView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(captionLongPressRecongizer)
        label.textColor = .onBackground
        label.textAlignment = .center
        return label
    }()
    
    private lazy var timerView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.textColor = .onBackground
        return label
    }()
    
    private lazy var initiatorView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.textColor = .onBackground
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
        view.tintColor = .onSurface
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
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onIssuePress(_:)))
        )
        return view
    }()
    
    private lazy var leftButton: CellButton = {
        let button = CellButton(title: "", backgroundColor: .primary)!
        button.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var rightButton: CellButton = {
        let button = CellButton(title: "", backgroundColor: .primary)!
        button.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
        return button
    }()
    
    private var captionTouched = false
    private var currentConstraints: [NSLayoutConstraint] = []
    private var disposeBag = DisposeBag()
    private var timer: Timer? = nil
    
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
    
    func getRemoteId() -> Int32? { fatalError("getRemoteId() has not been implemented") }
    
    func leftButtonSettings() -> CellButtonSettings { CellButtonSettings(visible: false) }
    
    func rightButtonSettings() -> CellButtonSettings { CellButtonSettings(visible: false) }
    
    func online() -> Bool { false }
    
    func derivedClassControls() -> [UIView] { fatalError("derivedClassControls() has not been implemented") }
    
    func derivedClassConstraints() -> [NSLayoutConstraint] { fatalError("derivedClassConstraints() has not been implemented") }

    func issueMessage() -> String? { nil }
    
    func provideRefreshData(_ updateEventsManager: UpdateEventsManager, forData: T) -> Observable<T> {
        fatalError("provideRefreshData(_:) has not been implemented")
    }
    
    func updateContent(data: T) {
        let leftButtonSettings = leftButtonSettings()
        if (leftButtonSettings.visible) {
            leftButton.setTitle(leftButtonSettings.title, for: .normal)
            leftButton.buttonWidth = Dimens.ListItem.buttonWidth
            leftButtons = [leftButton as Any]
        } else {
            leftButtons = []
        }
        
        let rightButtonSettings = rightButtonSettings()
        if (rightButtonSettings.visible) {
            rightButton.setTitle(rightButtonSettings.title, for: .normal)
            rightButton.buttonWidth = Dimens.ListItem.buttonWidth
            rightButtons = [rightButton as Any]
        } else {
            rightButtons = []
        }
        
        if (timer != nil) {
            timerView.text = nil
            timer?.invalidate()
            timer = nil
        }
        
        if let timerEndDate = timerEndDate(),
           timerEndDate.timeIntervalSinceNow > 0
        {
            updateTimerLabel(endTime: timerEndDate)
            timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(timerTick(timer:)),
                userInfo: timerEndDate,
                repeats: true
            )
        }
    }
    
    func timerEndDate() -> Date? { nil }
    
    func onTimerStopped() {}
    
    // MARK: Public content
    
    func scale(_ value: CGFloat, limit: CellScalingLimit = .none) -> CGFloat {
        var scale = scaleFactor
        switch (limit) {
        case .lower(let val):
            if (scaleFactor < val) { scale = val }
        case .upper(let val):
            if (scaleFactor > val) { scale = val }
        default: break
        }
        
        return value * scale
    }
    
    func isCaptionTouched() -> Bool { captionTouched }
    
    func setupView() {
        contentView.backgroundColor = .surface
        
        captionView.font = .cellCaptionFont.withSize(scale(Dimens.Fonts.caption, limit: .lower(1)))
        timerView.font = .formLabelFont.withSize(scale(Dimens.Fonts.label, limit: .upper(1)))
        initiatorView.font = .formLabelFont.withSize(scale(Dimens.Fonts.label))
        
        leftSwipeSettings.transition = MGSwipeTransition.rotate3D
        rightSwipeSettings.transition = MGSwipeTransition.rotate3D
        
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
    
    func getRightButtonText(_ function: Int32?) -> String? {
        guard let function else { return nil }
        return getChannelActionStringUseCase.rightButton(function: function.suplaFuntion)?.value
    }
    
    func getLeftButtonText(_ function: Int32?) -> String? {
        guard let function else { return nil }
        return getChannelActionStringUseCase.leftButton(function: function.suplaFuntion)?.value
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
            captionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -scale(Dimens.ListItem.verticalPadding)),
            captionView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Dimens.distanceDefault),
            captionView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Dimens.distanceDefault),
            
            timerView.topAnchor.constraint(equalTo: topAnchor, constant: scale(10)),
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
            containerView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.6),
            
            infoView.widthAnchor.constraint(equalToConstant: Dimens.iconInfoSize),
            infoView.heightAnchor.constraint(equalToConstant: Dimens.iconInfoSize),
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
        
        for control in allControls() {
            control.removeFromSuperview()
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
    
    @objc func onInfoPress(_ gr: UITapGestureRecognizer) {}
    
    @objc private func onCaptionLongPress(_ gr: UILongPressGestureRecognizer) {
        if (gr.state != .began) {
            return
        }
        
        guard
            let delegate = delegate as? BaseCellDelegate,
            let remoteId = getRemoteId()
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
        btn.backgroundColor = .buttonPressed
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            btn.backgroundColor = .primary
            
            if (self.settings.autohideButtons) {
                self.hideSwipe(animated: true)
            }
        }
        
        guard
            let delegate = delegate as? BaseCellDelegate,
            let remoteId = getRemoteId()
        else { return }
        
        if (btn == leftButton) {
            delegate.onButtonTapped(buttonType: .leftButton, remoteId: remoteId, data: data)
        }
        if (btn == rightButton) {
            delegate.onButtonTapped(buttonType: .rightButton, remoteId: remoteId, data: data)
        }
    }
    
    @objc private func timerTick(timer: Timer) {
        guard let endTime = timer.userInfo as? Date else {
            timerView.text = nil
            self.timer?.invalidate()
            self.timer = nil
            
            return
        }
        
        updateTimerLabel(endTime: endTime)
    }
    
    private func updateTimerLabel(endTime: Date) {
        if (endTime.timeIntervalSinceNow < 0) {
            timerView.text = nil
            timer?.invalidate()
            timer = nil
            
            onTimerStopped()
        } else {
            @Singleton<ValuesFormatter> var formatter
            let timeDiff = endTime.differenceInSeconds(Date())
            
            let days = timeDiff.days
            if (days == 0) {
                timerView.text = formatter.getTimeString(
                    hour: timeDiff.hoursInDay,
                    minute: timeDiff.minutesInHour,
                    second: timeDiff.secondsInMinute
                )
            } else if (days == 1) {
                let daysString = Strings.TimerDetail.dayPattern.arguments(days)
                timerView.text = "\(daysString) ⏱️"
            } else {
                let daysString = Strings.TimerDetail.daysPattern.arguments(days)
                timerView.text = "\(daysString) ⏱️"
            }
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
    func onInfoIconTapped(_ channel: SAChannel)
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
    private lazy var topLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.cornerRadius = Dimens.ListItem.statusIndicatorSize / 2
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.borderWidth = 1
        layer.borderColor = UIColor.primary.cgColor
        layer.backgroundColor = UIColor.primary.cgColor
        return layer
    }()
    
    private lazy var bottomLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.cornerRadius = Dimens.ListItem.statusIndicatorSize / 2
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.borderWidth = 1
        layer.borderColor = UIColor.error.cgColor
        layer.backgroundColor = UIColor.error.cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 2)
        bottomLayer.frame = CGRect(x: 0, y: frame.height / 2, width: frame.width, height: frame.height / 2)
    }
    
    func configure(filled: Bool, onlineState: ListOnlineState) {
        let color = onlineState.online ? UIColor.primary : UIColor.error
        
        switch (onlineState) {
        case .online, .offline, .unknown:
            topLayer.isHidden = true
            bottomLayer.isHidden = true
            
            if (filled) {
                layer.borderColor = color.cgColor
                backgroundColor = color
            } else {
                layer.borderColor = color.cgColor
                backgroundColor = .clear
            }
        case .partiallyOnline:
            layer.borderColor = UIColor.clear.cgColor
            backgroundColor = .clear
            topLayer.isHidden = false
            bottomLayer.isHidden = false
        }
    }
    
    func setInvisible() {
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = .clear
        topLayer.isHidden = true
        bottomLayer.isHidden = true
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
        
        layer.addSublayer(topLayer)
        layer.addSublayer(bottomLayer)
    }
}
