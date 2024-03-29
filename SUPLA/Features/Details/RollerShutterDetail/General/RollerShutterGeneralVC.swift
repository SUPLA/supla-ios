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

import RxRelay
import RxSwift

private let TOP_VIEW_HEIGHT: CGFloat = 80

class RollerShutterGeneralVC: BaseViewControllerVM<RollerShutterGeneralViewState, RollerShutterGeneralViewEvent, RollerShutterGeneralVM> {
    private let itemBundle: ItemBundle
    
    private lazy var topView: BlindsTopView = .init()
    
    private lazy var rollerShutterView: BaseWindowView = {
        switch (itemBundle.toWindowType()) {
        case .rollerShutter: RollerShutterView()
        case .roofWindow: RoofWindowView()
        }
    }()
    
    private let buttonsPositionGuide: UILayoutGuide = .init()
    
    private lazy var leftControlButton: UpDownControlButton = {
        let button = UpDownControlButton()
        button.upIcon = .iconArrowUp
        button.downIcon = .iconArrowDown
        return button
    }()
    
    private lazy var rightControlButton: UpDownControlButton = {
        let button = UpDownControlButton()
        button.upIcon = .iconArrowOpen
        button.downIcon = .iconArrowClose
        return button
    }()
    
    private lazy var stopControlButton: CircleControlButtonView = {
        let button = CircleControlButtonView(size: 64)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .suplaIcon(icon: .iconStop)
        return button
    }()
    
    private lazy var moveTimeView: MoveTimeView = {
        let view = MoveTimeView()
        return view
    }()
    
    private lazy var issuesView: IssuesView = {
        let view = IssuesView()
        return view
    }()
    
    private lazy var dynamicConstraints: [NSLayoutConstraint] = []
    
    init(itemBundle: ItemBundle) {
        self.itemBundle = itemBundle
        super.init(nibName: nil, bundle: nil)
        viewModel = RollerShutterGeneralVM()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarBackgroundView.isHidden = true
        view.backgroundColor = .background
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadData(remoteId: itemBundle.remoteId, type: itemBundle.subjectType)
        
        observeNotification(
            name: NSNotification.Name.saChannelValueChanged,
            selector: #selector(handleChannelValueChange)
        )
    }
    
    override func handle(event: RollerShutterGeneralViewEvent) {
        switch (event) {
        case .showCalibrationDialog:
            let dialog = SAAlertDialogVC(
                title: Strings.RollerShutterDetail.calibration,
                message: Strings.RollerShutterDetail.startCalibrationMessage
            )
            viewModel.bind(dialog.rx.positiveTap) { [weak self, unowned dialog] in
                dialog.dismiss(animated: true)
                self?.viewModel.showCalibrationDialog()
            }
            present(dialog, animated: true)
        case .showAuthorizationDialog:
            let dialog = SAAuthorizationDialogVC { [weak self] in
                guard let self = self else { return }
                self.viewModel.startCalibration(self.itemBundle.remoteId, self.itemBundle.subjectType)
            }
            dialog.showAuthorization(self)
        }
    }
    
    override func handle(state: RollerShutterGeneralViewState) {
        rollerShutterView.position = state.windowState.position
        rollerShutterView.bottomPosition = state.windowState.bottomPosition
        rollerShutterView.markers = state.windowState.markers
        issuesView.setIssues(state.issues)
        topView.loading = state.calibrating
        topView.calibrationHidden = !state.calibrationPossible
        topView.onlineStatus = state.onlineStatusString
        if (state.calibrating) {
            topView.label = "\(Strings.RollerShutterDetail.calibration)..."
            topView.value = nil
        } else if (!state.positionUnknown) {
            topView.label = state.showClosingPercentage ? Strings.RollerShutterDetail.closingPercentage : Strings.RollerShutterDetail.openingPercentage
            topView.value = state.positionText
        } else if (state.isGroup) {
            topView.label = state.showClosingPercentage ? Strings.RollerShutterDetail.closingPercentage : Strings.RollerShutterDetail.openingPercentage
            topView.value = "---"
        } else {
            topView.label = Strings.RollerShutterDetail.calibrationNeeded
            topView.value = nil
        }
        
        leftControlButton.isEnabled = !state.offline
        rightControlButton.isEnabled = !state.offline
        stopControlButton.isEnabled = !state.offline
        topView.offline = state.offline
        rollerShutterView.isEnabled = !state.offline
        
        moveTimeView.isHidden = state.touchTime == nil
        if let touchTime = state.touchTime {
            moveTimeView.value = String(format: "%.1fs", touchTime)
        }
    }
    
    private func setupView() {
        view.addSubview(topView)
        view.addSubview(rollerShutterView)
        view.addSubview(leftControlButton)
        view.addSubview(rightControlButton)
        view.addSubview(stopControlButton)
        view.addSubview(moveTimeView)
        view.addSubview(issuesView)
        view.addLayoutGuide(buttonsPositionGuide)
        
        viewModel.bind(rollerShutterView.rx.positionChange) { [weak self] positin in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(
                .openAt(position: positin),
                remoteId: bundle.remoteId,
                type: bundle.subjectType
            )
        }
        rollerShutterView.rx.position
            .subscribe(onNext: { [weak self] in self?.topView.value = self?.viewModel.positionToString($0) })
            .disposed(by: self)
        viewModel.bind(leftControlButton.rx.touchDown) { [weak self] type in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(type.leftAction, remoteId: bundle.remoteId, type: bundle.subjectType)
        }
        viewModel.bind(leftControlButton.rx.touchUp) { [weak self] _ in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(.stop, remoteId: bundle.remoteId, type: bundle.subjectType)
        }
        viewModel.bind(rightControlButton.rx.tap) { [weak self] type in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(type.rightAction, remoteId: bundle.remoteId, type: bundle.subjectType)
        }
        viewModel.bind(stopControlButton.tapObservable) { [weak self] in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(.stop, remoteId: bundle.remoteId, type: bundle.subjectType)
        }
        viewModel.bind(topView.rx.calibrate) { [weak self] in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(.calibrate, remoteId: bundle.remoteId, type: bundle.subjectType)
        }
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            topView.leftAnchor.constraint(equalTo: view.leftAnchor),
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.rightAnchor.constraint(equalTo: view.rightAnchor),
            topView.heightAnchor.constraint(equalToConstant: TOP_VIEW_HEIGHT),
            
            rollerShutterView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 42),
            rollerShutterView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: Dimens.distanceDefault),
            rollerShutterView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -42),
            
            buttonsPositionGuide.topAnchor.constraint(equalTo: rollerShutterView.bottomAnchor, constant: Dimens.distanceSmall),
            buttonsPositionGuide.heightAnchor.constraint(equalToConstant: UP_DOWN_CONTROLL_BUTTON_HEIGHT),
            
            leftControlButton.centerYAnchor.constraint(equalTo: buttonsPositionGuide.centerYAnchor),
            leftControlButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -56),
            
            rightControlButton.centerYAnchor.constraint(equalTo: buttonsPositionGuide.centerYAnchor),
            rightControlButton.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 56),
            
            stopControlButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopControlButton.centerYAnchor.constraint(equalTo: buttonsPositionGuide.centerYAnchor),
            
            moveTimeView.topAnchor.constraint(equalTo: rollerShutterView.bottomAnchor, constant: Dimens.distanceDefault),
            moveTimeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            issuesView.topAnchor.constraint(equalTo: buttonsPositionGuide.bottomAnchor, constant: Dimens.distanceSmall),
            issuesView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            issuesView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            issuesView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Dimens.distanceDefault)
        ])
    }
    
    private func setIssues(_ issues: [ChannelIssueItem]) {
        if (!dynamicConstraints.isEmpty) {
            NSLayoutConstraint.deactivate(dynamicConstraints)
            dynamicConstraints.removeAll()
        }
        
        issuesView.setIssues(issues)
        
        if (!issues.isEmpty) {
            dynamicConstraints.append(
                issuesView.heightAnchor.constraint(equalToConstant: issuesView.intrinsicContentSize.height)
            )
            NSLayoutConstraint.activate(dynamicConstraints)
        }
    }
    
    @objc
    private func handleChannelValueChange(notification: Notification) {
        if let remoteId = notification.userInfo?["remoteId"] as? NSNumber,
           remoteId.int32Value == itemBundle.remoteId
        {
            viewModel.loadData(remoteId: itemBundle.remoteId, type: itemBundle.subjectType)
        }
    }
}

private class BlindsTopView: TopView {
    var offline: Bool {
        get { fatalError("Getter not implemented") }
        set {
            leftContainer.isHidden = newValue
            rightContainer.isHidden = newValue
            calibrateButton.isHidden = newValue ? true : calibrationHidden
            offlineView.isHidden = !newValue
        }
    }
    
    var label: String? {
        get { leftLabel.text }
        set { leftLabel.text = newValue?.uppercased() }
    }
    
    var value: String? {
        get { leftValueLabel.text }
        set { leftValueLabel.text = newValue }
    }
    
    var loading: Bool {
        get { !calibrationIndicator.isHidden }
        set {
            calibrationIndicator.isHidden = !newValue
            if (newValue) {
                calibrationIndicator.startAnimating()
            } else {
                calibrationIndicator.stopAnimating()
            }
        }
    }
    
    var calibrationHidden: Bool = false {
        didSet { calibrateButton.isHidden = calibrationHidden }
    }
    
    var onlineStatus: String? {
        get { rightValueLabel.text }
        set {
            rightContainer.isHidden = newValue == nil
            rightLabel.isHidden = newValue == nil
            rightValueLabel.isHidden = newValue == nil
            rightValueLabel.text = newValue
        }
    }
    
    private let calibrateButtonSize: CGFloat = 48
    
    private lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.textColor = .gray
        return label
    }()
    
    private lazy var leftValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2Bold
        label.textColor = .onBackground
        return label
    }()
    
    private lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.textColor = .gray
        label.text = "ONLINE:"
        return label
    }()
    
    private lazy var rightValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2Bold
        label.textColor = .onBackground
        return label
    }()
    
    fileprivate lazy var calibrateButton: CircleControlButtonView = {
        let view = CircleControlButtonView(size: calibrateButtonSize)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.type = .positive
        view.icon = .suplaIcon(icon: .iconCalibrate)
        return view
    }()
    
    private lazy var offlineView: UIView = {
        let icon = UIImageView(image: .iconOffline?.withTintColor(.gray))
        icon.constrainWidth(Dimens.iconSize)
        icon.constrainHeight(Dimens.iconSize)
        
        let label = UILabel()
        label.font = .body2
        label.textColor = .gray
        label.text = "OFFLINE"
        
        let view = UIStackView(arrangedSubviews: [icon, label])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Dimens.distanceTiny
        view.alignment = .center
        return view
    }()
    
    private lazy var calibrationIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var leftContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [calibrationIndicator, leftLabel, leftValueLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 4
        return view
    }()
    
    private lazy var rightContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [rightLabel, rightValueLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 4
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(leftContainer)
        addSubview(calibrateButton)
        addSubview(rightContainer)
        addSubview(offlineView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            leftContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
            
            calibrateButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            calibrateButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),
            calibrateButton.heightAnchor.constraint(equalToConstant: calibrateButtonSize),
            calibrateButton.widthAnchor.constraint(equalToConstant: calibrateButtonSize),
            
            rightContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),
            
            offlineView.centerXAnchor.constraint(equalTo: centerXAnchor),
            offlineView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

extension Reactive where Base: BlindsTopView {
    var calibrate: Observable<Void> { base.calibrateButton.tapObservable }
}

private class TopView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: TOP_VIEW_HEIGHT)
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = Dimens.Shadow.radius
        layer.shadowOpacity = Dimens.Shadow.opacity
        layer.shadowOffset = Dimens.Shadow.offset
        backgroundColor = .surface
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

private class MoveTimeView: UIView {
    var value: String? {
        get { label.text }
        set {
            label.text = newValue
            setNeedsLayout() // because label width will change
        }
    }
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .iconTouchHand?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .black
        return view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconView)
        addSubview(label)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor),
            
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

private class IssuesView: UIStackView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Dimens.iconSizeList * CGFloat(issues.count))
    }
    
    private var issues: [IssueView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setIssues(_ issueItems: [ChannelIssueItem]) {
        if (!issues.isEmpty) {
            issues.forEach { $0.removeFromSuperview() }
            issues.removeAll()
        }
        
        for issueItem in issueItems {
            let view = IssueView()
            view.icon = issueItem.issueIconType.icon()
            view.text = issueItem.description
            
            addArrangedSubview(view)
            issues.append(view)
        }
        
        setNeedsLayout()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        spacing = Dimens.distanceTiny
        alignment = .leading
        axis = .vertical
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension ControlButtonType {
    var leftAction: RollerShutterAction {
        switch (self) {
        case .up: .moveUp
        case .down: .moveDown
        }
    }
    
    var rightAction: RollerShutterAction {
        switch (self) {
        case .up: .open
        case .down: .close
        }
    }
}

private extension ItemBundle {
    func toWindowType() -> WindowType {
        switch (function) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
            .rollerShutter
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
            .roofWindow
        default: fatalError("No window for function \(function)")
        }
    }
}
