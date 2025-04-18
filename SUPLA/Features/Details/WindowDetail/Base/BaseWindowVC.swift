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
import SharedCore

private let TOP_VIEW_HEIGHT: CGFloat = 80

class BaseWindowVC<WS: WindowState, WV: BaseWindowView<WS>, S: BaseWindowViewState, VM: BaseWindowVM<S>>: BaseViewControllerVM<S, BaseWindowViewEvent, VM> {
    let itemBundle: ItemBundle
    
    lazy var windowControls: WindowControls = { getWindowControls() }()
    
    lazy var topView: BlindsTopView = .init()
    
    lazy var windowView: WV = getWindowView()
    
    private lazy var issuesView: IssuesView = {
        let view = IssuesView()
        return view
    }()
    
    lazy var slatTiltSlider: SlatTiltSlider = {
        let slider = SlatTiltSlider()
        slider.isHidden = true
        return slider
    }()
    
    private lazy var dynamicConstraints: [NSLayoutConstraint] = []
    
    init(itemBundle: ItemBundle, viewModel: VM) {
        self.itemBundle = itemBundle
        super.init(viewModel: viewModel)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getWindowView() -> WV {
        fatalError("getWindowView() needs to be implemented")
    }
    
    func getWindowControls() -> WindowControls { WindowVerticalControls() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func handle(event: BaseWindowViewEvent) {
        switch (event) {
        case .showCalibrationDialog:
            let dialog = SAAlertDialogVC(
                title: Strings.RollerShutterDetail.calibration,
                message: Strings.RollerShutterDetail.startCalibrationMessage
            )
            viewModel.bind(dialog.rx.positiveTap) { [weak self, unowned dialog] in
                dialog.dismiss(animated: true)
                self?.viewModel.showAuthorizationDialog()
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
    
    override func handle(state: S) {
        issuesView.setIssues(state.issues)
        topView.loading = state.calibrating
        topView.calibrationHidden = !state.calibrationPossible
        topView.onlineStatus = state.onlineStatusString
        if (state.calibrating) {
            topView.labelTop = "\(Strings.RollerShutterDetail.calibration)..."
            topView.valueTop = nil
            topView.valueBottom = nil
        } else if (!state.positionUnknown) {
            topView.labelTop = state.positionPresentation.string()
            topView.valueTop = state.windowState.positionText
        } else if (state.isGroup) {
            topView.labelTop = state.positionPresentation.string()
            topView.valueTop = "---"
            topView.valueBottom = nil
        } else {
            topView.labelTop = Strings.RollerShutterDetail.calibrationNeeded
            topView.valueTop = nil
            topView.valueBottom = nil
        }
        
        windowControls.isEnabled = !state.offline
        topView.offline = state.offline
        windowView.isEnabled = !state.offline
        
        windowControls.moveTime = state.touchTime
        
        updateDynamicConstraints()
    }
    
    private func setupView() {
        view.addSubview(topView)
        view.addSubview(windowView)
        view.addSubview(windowControls)
        view.addSubview(issuesView)
        view.addSubview(slatTiltSlider)
        
        setupWindowGesturesObservers()
        
        windowView.rxPosition
            .subscribe(onNext: { [weak self] in self?.topView.valueTop = self?.viewModel.positionToString($0) })
            .disposed(by: self)
        viewModel.bind(windowControls.action) { [weak self] action in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(action, remoteId: bundle.remoteId, type: bundle.subjectType)
        }
        viewModel.bind(topView.rx.calibrate) { [weak self] in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(.calibrate, remoteId: bundle.remoteId, type: bundle.subjectType)
        }
        viewModel.bind(slatTiltSlider.rx.value) { [weak self] value in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(.tiltTo(tilt: CGFloat(value)), remoteId: bundle.remoteId, type: bundle.subjectType)
        }
        viewModel.bind(slatTiltSlider.rx.tiltSet) { [weak self] value in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(.tiltSetTo(tilt: CGFloat(value)), remoteId: bundle.remoteId, type: bundle.subjectType)
        }
        
        setupLayout()
    }
    
    func setupWindowGesturesObservers() {
        viewModel.bind(windowView.rxPositionChange) { [weak self] position in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(
                .openAt(position: position),
                remoteId: bundle.remoteId,
                type: bundle.subjectType
            )
        }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            topView.leftAnchor.constraint(equalTo: view.leftAnchor),
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.rightAnchor.constraint(equalTo: view.rightAnchor),
            topView.heightAnchor.constraint(equalToConstant: TOP_VIEW_HEIGHT),
            
            windowView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 42),
            windowView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: Dimens.distanceDefault),
            windowView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -42),
            
            windowControls.topAnchor.constraint(equalTo: windowView.bottomAnchor, constant: Dimens.distanceSmall),
            windowControls.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            windowControls.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            
            issuesView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            issuesView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            issuesView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Dimens.distanceDefault)
        ])
    }
    
    private func updateDynamicConstraints() {
        if (!dynamicConstraints.isEmpty) {
            NSLayoutConstraint.deactivate(dynamicConstraints)
            dynamicConstraints.removeAll()
        }
        
        if (issuesView.issuesCount > 0) {
            dynamicConstraints.append(
                issuesView.heightAnchor.constraint(equalToConstant: issuesView.intrinsicContentSize.height)
            )
        }
        
        if (slatTiltSlider.isHidden) {
            dynamicConstraints.append(
                issuesView.topAnchor.constraint(equalTo: windowControls.bottomAnchor, constant: Dimens.distanceSmall)
                
            )
        } else {
            dynamicConstraints.append(contentsOf: [
                slatTiltSlider.topAnchor.constraint(equalTo: windowControls.bottomAnchor, constant: Dimens.distanceSmall),
                slatTiltSlider.widthAnchor.constraint(equalToConstant: 240),
                slatTiltSlider.heightAnchor.constraint(equalToConstant: 40),
                slatTiltSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                issuesView.topAnchor.constraint(equalTo: slatTiltSlider.bottomAnchor, constant: Dimens.distanceSmall)
            ])
        }
        
        if (!dynamicConstraints.isEmpty) {
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

class BlindsTopView: TopView {
    var offline: Bool {
        get { fatalError("Getter not implemented") }
        set {
            leftTopContainer.isHidden = newValue
            leftBottomContainer.isHidden = newValue
            rightContainer.isHidden = newValue
            calibrateButton.isHidden = newValue ? true : calibrationHidden
            offlineView.isHidden = !newValue
        }
    }
    
    var labelTop: String? {
        get { leftTopLabel.text }
        set { leftTopLabel.text = newValue?.uppercased() }
    }
    
    var valueTop: String? {
        get { leftTopValueLabel.text }
        set { leftTopValueLabel.text = newValue }
    }
    
    var valueBottom: String? {
        get { leftBottomValueLabel.text }
        set {
            leftBottomValueLabel.text = newValue?.uppercased()
            leftBottomLabel.isHidden = newValue == nil
            leftBottomContainer.isHidden = newValue == nil
            
            updateDynamicConstraints()
        }
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
    
    private lazy var leftTopLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.textColor = .gray
        return label
    }()
    
    private lazy var leftTopValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2Bold
        label.textColor = .onBackground
        return label
    }()
    
    private lazy var leftBottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.textColor = .gray
        label.text = Strings.FacadeBlindsDetail.slatTilt.uppercased()
        return label
    }()
    
    private lazy var leftBottomValueLabel: UILabel = {
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
        view.icon = .suplaIcon(name: .Icons.calibrate)
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
    
    private lazy var leftTopContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [calibrationIndicator, leftTopLabel, leftTopValueLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 4
        view.distribution = .fill
        return view
    }()
    
    private lazy var leftBottomContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [leftBottomLabel, leftBottomValueLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 4
        view.isHidden = true
        view.distribution = .fill
        return view
    }()
    
    private lazy var rightContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [rightLabel, rightValueLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 4
        return view
    }()
    
    private var dynamicConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(leftTopContainer)
        addSubview(leftBottomContainer)
        addSubview(calibrateButton)
        addSubview(rightContainer)
        addSubview(offlineView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            leftTopContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
            leftBottomContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
            
            calibrateButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            calibrateButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),
            calibrateButton.heightAnchor.constraint(equalToConstant: calibrateButtonSize),
            calibrateButton.widthAnchor.constraint(equalToConstant: calibrateButtonSize),
            
            rightContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),
            
            offlineView.centerXAnchor.constraint(equalTo: centerXAnchor),
            offlineView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        updateDynamicConstraints()
    }
    
    private func updateDynamicConstraints() {
        if (!dynamicConstraints.isEmpty) {
            NSLayoutConstraint.deactivate(dynamicConstraints)
            dynamicConstraints.removeAll()
        }
        
        if (leftBottomContainer.isHidden) {
            dynamicConstraints.append(contentsOf: [
                leftTopContainer.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        } else {
            dynamicConstraints.append(contentsOf: [
                leftTopContainer.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -2),
                leftBottomContainer.topAnchor.constraint(equalTo: centerYAnchor, constant: 2)
            ])
        }
        
        NSLayoutConstraint.activate(dynamicConstraints)
    }
}

extension Reactive where Base: BlindsTopView {
    var calibrate: Observable<Void> { base.calibrateButton.tapObservable }
}

class TopView: UIView {
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
        ShadowValues.apply(toLayer: layer)
        backgroundColor = .surface
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

private class IssuesView: UIStackView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Dimens.iconSizeList * CGFloat(issues.count))
    }
    
    var issuesCount: Int { issues.count }
    
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
            view.icon = issueItem.icon.resource
            view.text = issueItem.message.string
            
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
    var holdAction: RollerShutterAction {
        switch (self) {
        case .up, .left: .moveUp
        case .down, .right: .moveDown
        case .middle: .stop
        }
    }
    
    var pressAction: RollerShutterAction {
        switch (self) {
        case .up, .left: .open
        case .down, .right: .close
        case .middle: .stop
        }
    }
}
