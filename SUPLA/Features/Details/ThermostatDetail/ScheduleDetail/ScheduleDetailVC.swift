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
import RxRelay
import RxCocoa

class ScheduleDetailVC: BaseViewControllerVM<ScheduleDetailViewState, ScheduleDetailViewEvent, ScheduleDetailVM> {
    
    private let item: ItemBundle
    
    private lazy var buttonsRowView: ButtonsRowView = {
        let view = ButtonsRowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scheduleDetailTableView: ScheduleDetailTableView = {
        let view = ScheduleDetailTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scheduleInfoView: ScheduleInfoView = {
        let view = ScheduleInfoView()
        view.isHidden = true
        return view
    }()
    
    init(item: ItemBundle) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        viewModel = ScheduleDetailVM()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.observeConfig(remoteId: item.remoteId, deviceId: item.deviceId)
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadConfig()
    }
    
    override func viewDidLayoutSubviews() {
        scheduleInfoView.itemSize = scheduleDetailTableView.itemSize
    }
    
    override func handle(event: ScheduleDetailViewEvent) {
        switch(event) {
        case .editProgram(let state):
            let dialog = EditProgramDialogVC(initialState: state)
            dialog.onFinishCallback = { [weak self] in
                self?.viewModel.onProgramChanged($0)
            }
            present(dialog, animated: true)
        case .editScheduleBox(let state):
            let dialog = EditQuartersDialogVC(initialState: state)
            dialog.onFinishCallback = { [weak self] in
                self?.viewModel.onQuartersChanged(key: state.key, value: $0, activeProgram: $1)
            }
            present(dialog, animated: true)
        }
    }
    
    override func handle(state: ScheduleDetailViewState) {
        buttonsRowView.activeProgram = state.activeProgram
        buttonsRowView.programs = state.programs
        scheduleDetailTableView.showDayIndicator = state.showDayIndicator
        scheduleDetailTableView.updateBoxes(schedule: state.schedule)
        scheduleInfoView.isHidden = !state.showHelp
    }
    
    private func setupView() {
        view.addSubview(buttonsRowView)
        view.addSubview(scheduleDetailTableView)
        view.addSubview(scheduleInfoView)
        
        viewModel.bind(buttonsRowView.tapEvents) { [weak self] in self?.viewModel.onProgramTap($0) }
        viewModel.bind(buttonsRowView.longPressEvents) { [weak self] in
            self?.viewModel.onProgramLongPress($0)
        }
        viewModel.bind(scheduleDetailTableView.longPressEvents) { [weak self] in
            self?.viewModel.onBoxLongPress($0)
        }
        viewModel.bind(scheduleDetailTableView.panningEvents) { [weak self] in
            self?.viewModel.onBoxEvent($0)
        }
        viewModel.bind(scheduleInfoView.closeTap) { [weak self] in
            self?.viewModel.onHelpClosed()
        }
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(([
            buttonsRowView.topAnchor.constraint(equalTo: view.topAnchor),
            buttonsRowView.leftAnchor.constraint(equalTo: view.leftAnchor),
            buttonsRowView.rightAnchor.constraint(equalTo: view.rightAnchor),
            buttonsRowView.heightAnchor.constraint(equalToConstant: 64),
            
            scheduleDetailTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scheduleDetailTableView.topAnchor.constraint(equalTo: buttonsRowView.bottomAnchor),
            scheduleDetailTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scheduleDetailTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scheduleInfoView.topAnchor.constraint(equalTo: view.topAnchor),
            scheduleInfoView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scheduleInfoView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scheduleInfoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]))
    }
}

enum PanningEvent: Equatable {
    case panning(boxKey: ScheduleDetailBoxKey)
    case finished
}

// MARK: - Buttons row

fileprivate class ButtonsRowView: HorizontalyScrollableView<RoundedControlButtonView> {
    
    var tapEvents: Observable<SuplaScheduleProgram> {
        get { tapRelay.asObservable() }
    }
    var longPressEvents: Observable<SuplaScheduleProgram> {
        get { longPressRelay.asObservable() }
    }
    var activeProgram: SuplaScheduleProgram? = nil {
        didSet {
            items.forEach { $0.active = false }
            
            for (index, program) in programs.enumerated() {
                if (program.scheduleProgram.program == activeProgram) {
                    items[index].active = true
                }
            }
        }
    }
    var programs: [ScheduleDetailProgram] = [] {
        didSet {
            if (oldValue != programs) {
                setNeedsLayout()
            }
        }
    }
    
    private let tapRelay: PublishRelay<SuplaScheduleProgram> = PublishRelay()
    private let longPressRelay: PublishRelay<SuplaScheduleProgram> = PublishRelay()
    private var changableConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createItems() -> [RoundedControlButtonView] {
        var items: [RoundedControlButtonView] = []
        
        for program in programs {
            let buttonView = RoundedControlButtonView(height: Dimens.buttonSmallHeight)
            buttonView.backgroundColor = program.scheduleProgram.program.color()
            buttonView.translatesAutoresizingMaskIntoConstraints = false
            buttonView.icon = program.icon != nil ? .suplaIcon(icon: program.icon) : nil
            buttonView.text = program.text
            buttonView.iconColor = .black
            buttonView.active = false
            buttonView.textFont = .scheduleDetailButton
            buttonView.type = .neutral
            buttonView.tapObservable
                .subscribe(onNext: { [weak self] in
                    self?.tapRelay.accept(program.scheduleProgram.program)
                })
                .disposed(by: disposeBag)
            if (program.scheduleProgram.program != .off) {
                buttonView.longPress
                    .subscribe(onNext: { [weak self] in
                        self?.longPressRelay.accept(program.scheduleProgram.program)
                    })
                    .disposed(by: disposeBag)
            }
            items.append(buttonView)
        }
        
        return items
    }
    
    override func horizontalConstraint(item: RoundedControlButtonView) -> NSLayoutConstraint {
        item.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimens.distanceSmall)
    }
}

// MARK: - Schedul detail table

fileprivate class ScheduleDetailTableView: UIView {
    
    var longPressEvents: Observable<ScheduleDetailBoxKey> {
        get { longPressRelay.asObservable() }
    }
    var panningEvents: Observable<PanningEvent> {
        get { tapRelay.asObservable().distinctUntilChanged() }
    }
    var showDayIndicator: Bool = true {
        didSet {
            if (!showDayIndicator) {
                currentDayIndicatorLayer.frame = .zero
                currentHourIndicatorLayer.frame = .zero
                currentItemIndicatorLayer.path = UIBezierPath().cgPath
            }
            if (showDayIndicator != oldValue) {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    var itemSize: CGSize = .zero
    
    private let itemPadding: CGFloat = 2
    
    private var boxes: [BoxShapeLayerWrapper] = []
    private var dayLabels: [CATextLayer] = []
    private var hourLabels: [CATextLayer] = []
    private lazy var currentDayIndicatorLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.ctrlBorder.cgColor
        return layer
    }()
    private lazy var currentHourIndicatorLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.ctrlBorder.cgColor
        return layer
    }()
    private lazy var currentItemIndicatorLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.black.cgColor
        return layer
    }()
    private let longPressRelay: PublishRelay<ScheduleDetailBoxKey> = PublishRelay()
    private let tapRelay: PublishRelay<PanningEvent> = PublishRelay()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateBoxes(schedule: [ScheduleDetailBoxKey:ScheduleDetailBoxValue]) {
        var idx = 0
        for day in DayOfWeek.allCases {
            for hour in HoursRange {
                let box = boxes[idx]
                if let value = schedule[ScheduleDetailBoxKey(dayOfWeek: day, hour: hour)] {
                    box.setBackgrounds(value)
                }
                idx += 1
            }
        }
    }
    
    private func setupView() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onPan(_:))))
        
        for day in DayOfWeek.allCases {
            dayLabels.append(createRegularLabel(text: day.shortText()))
            for _ in HoursRange {
                boxes.append(BoxShapeLayerWrapper())
            }
        }
        
        for hour in HoursRange {
            hourLabels.append(createRegularLabel(text: hour.toHour()))
        }
        
        boxes.forEach { layer.addSublayer($0) }
        dayLabels.forEach { layer.addSublayer($0) }
        layer.addSublayer(currentDayIndicatorLayer)
        layer.addSublayer(currentHourIndicatorLayer)
        layer.addSublayer(currentItemIndicatorLayer)
    }
    
    override func layoutSubviews() {
        let date = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.weekday, from: date) - 1
        let currentHour = calendar.component(.hour, from: date)
        
        let boxColumns = DayOfWeek.allCases.count
        let allRows: CGFloat = 25 // 24 hours + 1
        
        let firstColumnWidth: CGFloat = 25
        let verticalPaddings: CGFloat = 16 // top: 0, bottom 16
        let horizontalPaddings: CGFloat = Dimens.distanceDefault * 2 // left and right: 24
        
        let gridWidth = (self.frame.width - horizontalPaddings - firstColumnWidth) / CGFloat(boxColumns)
        let gridHeight = (self.frame.height - verticalPaddings) / allRows
        itemSize = CGSize(
            width: gridWidth - (itemPadding * 2),
            height: gridHeight - (itemPadding * 2)
        )
        
        setupTable(gridWidth, gridHeight, currentDay, currentHour, firstColumnWidth)
        setupHourLabels(gridHeight, firstColumnWidth, currentHour)
        
        currentItemIndicatorLayer.frame = bounds
    }
    
    private func setupTable(_ gridWidth: CGFloat, _ gridHeight: CGFloat, _ currentDay: Int, _ currentHour: Int, _ firstColumnWidth: CGFloat) {
        var idx = 0
        var x = Dimens.distanceDefault + firstColumnWidth
        for day in DayOfWeek.allCases {
            let isCurrentDay = day.rawValue == currentDay && showDayIndicator
            if (isCurrentDay) {
                currentDayIndicatorLayer.frame = CGRect(
                    x: x + itemPadding,
                    y: itemPadding,
                    width: itemSize.width,
                    height: itemSize.height
                )
                currentDayIndicatorLayer.cornerRadius = itemSize.height / 2
            }
            
            let dayLabel = dayLabels[idx / 24]
            dayLabel.font = isCurrentDay ? createFont("OpenSans-Bold") : createFont("OpenSans-Regular")
            let labelSize = dayLabel.preferredFrameSize()
            let top = (gridHeight - labelSize.height) / 2
            if (top < 0) {
                dayLabel.frame = CGRect(x: x, y: 0, width: gridWidth, height: gridHeight)
            } else {
                dayLabel.frame = CGRect(x: x, y: top, width: gridWidth, height: gridHeight)
            }
            
            
            var y = gridHeight
            for hour in 0...23 {
                let rect = CGRect(
                    x: x + itemPadding,
                    y: y + itemPadding,
                    width: itemSize.width,
                    height: itemSize.height
                )
                
                let box = boxes[idx]
                box.frame = rect
                
                if (day.rawValue == currentDay && hour == currentHour && showDayIndicator) {
                    currentItemIndicatorLayer.path = setupCurrentBoxIndicatorPath(x, y, itemSize.height)
                }
                
                y += gridHeight
                idx += 1
            }
            x += gridWidth
        }
    }
    
    private func setupHourLabels(_ gridHeight: CGFloat, _ firstColumnWidth: CGFloat, _ currentHour: Int) {
        var y = gridHeight
        var hour = 0
        hourLabels.forEach {
            let isCurrentHour = hour == currentHour && showDayIndicator
            if (isCurrentHour) {
                currentHourIndicatorLayer.frame = CGRect(
                    x: Dimens.distanceDefault + itemPadding,
                    y: y + itemPadding,
                    width: firstColumnWidth - (itemPadding * 2),
                    height: itemSize.height
                )
                currentHourIndicatorLayer.cornerRadius = itemSize.height / 2
            }
            $0.font = isCurrentHour ? createFont("OpenSans-Bold") : createFont("OpenSans-Regular")
            let labelSize = $0.preferredFrameSize()
            let x = Dimens.distanceDefault
            let top = (gridHeight - labelSize.height) / 2
            if (top < 0) {
                $0.frame = CGRect(x: x, y: y + top, width: firstColumnWidth, height: gridHeight)
            } else {
                $0.frame = CGRect(x: x, y: y + top, width: firstColumnWidth, height: gridHeight)
            }
            layer.addSublayer($0)
            
            y += gridHeight
            hour += 1
        }
    }
    
    private func createRegularLabel(text: String) -> CATextLayer {
        return createLabel(text: text, fontName: "OpenSans-Regular")
    }
    
    private func setupCurrentBoxIndicatorPath(_ x: CGFloat, _ y: CGFloat, _ itemHeight: CGFloat) -> CGPath {
        let halfHeight = itemHeight / 2
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x + itemPadding, y: y + itemPadding + Dimens.radiusSmall + halfHeight))
        path.addLine(to: CGPoint(x: x + itemPadding, y: y + itemPadding + Dimens.radiusSmall))
        path.addLine(to: CGPoint(x: x + itemPadding + Dimens.radiusSmall, y: y + itemPadding))
        path.addLine(to: CGPoint(x: x + itemPadding + Dimens.radiusSmall + halfHeight, y: y + itemPadding))
        path.close()
        
        return path.cgPath
    }
    
    private func createLabel(text: String, fontName: String) -> CATextLayer {
        let label = CATextLayer()
        label.font = createFont(fontName)
        label.fontSize = 12
        label.string = text
        label.alignmentMode = .center
        label.foregroundColor = UIColor.onBackground.cgColor
        label.contentsScale = UIScreen.main.scale
        
        return label
    }
    
    private func createFont(_ name: String) -> CFTypeRef {
        CTFontCreateWithName(name as CFString, 12, nil)
    }
    
    @objc private func onTap(_ recognizer: UITapGestureRecognizer) {
        if let (day, hour) = findTouchedPoint(recognizer.location(in: self)) {
            tapRelay.accept(.panning(boxKey: ScheduleDetailBoxKey(dayOfWeek: day, hour: hour)))
            tapRelay.accept(.finished)
        }
    }
    
    @objc private func onLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if (recognizer.state == .began) {
            if let (day, hour) = findTouchedPoint(recognizer.location(in: self)) {
                longPressRelay.accept(ScheduleDetailBoxKey(dayOfWeek: day, hour: hour))
            }
        }
    }
    
    @objc private func onPan(_ recognizer: UIPanGestureRecognizer) {
        if let (day, hour) = findTouchedPoint(recognizer.location(in: self)),
           recognizer.state == .changed {
            tapRelay.accept(.panning(boxKey: ScheduleDetailBoxKey(dayOfWeek: day, hour: hour)))
        }
        
        if (recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed) {
            tapRelay.accept(.finished)
        }
    }
    
    private func findTouchedPoint(_ point: CGPoint) -> (day: DayOfWeek, hour: Int)? {
        var idx = 0
        for day in DayOfWeek.allCases {
            for hour in 0...23 {
                let box = boxes[idx]
                if (box.frame.contains(point)) {
                    return (day, hour)
                }
                idx += 1
            }
        }
        
        return nil
    }
}

// MARK: - Box shape layer wrapper

fileprivate class BoxShapeLayerWrapper: LayerGroup {
    
    lazy var firstQuarterLayer = {
        let box = CAShapeLayer()
        box.backgroundColor = UIColor.disabled.cgColor
        box.cornerRadius = Dimens.radiusSmall
        box.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        return box
    }()
    
    lazy var secondQuarterLayer = {
        let box = CAShapeLayer()
        box.backgroundColor = UIColor.disabled.cgColor
        return box
    }()
    
    lazy var thirdQuarterLayer = {
        let box = CAShapeLayer()
        box.backgroundColor = UIColor.disabled.cgColor
        return box
    }()
    
    lazy var fourthQuarterLayer = {
        let box = CAShapeLayer()
        box.backgroundColor = UIColor.disabled.cgColor
        box.cornerRadius = Dimens.radiusSmall
        box.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        return box
    }()
    
    var frame: CGRect = .zero {
        didSet {
            setFrame(frame)
        }
    }
    
    func setBackgrounds(_ programs: ScheduleDetailBoxValue?) {
        if let programs = programs {
            firstQuarterLayer.backgroundColor = programs.firstQuarterProgram.color().cgColor
            secondQuarterLayer.backgroundColor = programs.secondQuarterProgram.color().cgColor
            thirdQuarterLayer.backgroundColor = programs.thirdQuarterProgram.color().cgColor
            fourthQuarterLayer.backgroundColor = programs.fourthQuarterProgram.color().cgColor
        } else {
            let defaultColor = SuplaScheduleProgram.off.color().cgColor
            firstQuarterLayer.backgroundColor = defaultColor
            secondQuarterLayer.backgroundColor = defaultColor
            thirdQuarterLayer.backgroundColor = defaultColor
            fourthQuarterLayer.backgroundColor = defaultColor
        }
    }
    
    func sublayers() -> [CALayer] {
        [firstQuarterLayer, secondQuarterLayer, thirdQuarterLayer, fourthQuarterLayer]
    }
    
    private func setFrame(_ frame: CGRect) {
        let quarterWidth = frame.width / 4
        var x = frame.minX
        firstQuarterLayer.frame = CGRect(x: x, y: frame.minY , width: quarterWidth + 1, height: frame.height)
        x += quarterWidth
        secondQuarterLayer.frame = CGRect(x: x, y: frame.minY , width: quarterWidth + 1, height: frame.height)
        x += quarterWidth
        thirdQuarterLayer.frame = CGRect(x: x, y: frame.minY , width: quarterWidth + 1, height: frame.height)
        x += quarterWidth
        fourthQuarterLayer.frame = CGRect(x: x, y: frame.minY , width: quarterWidth, height: frame.height)
    }
}

fileprivate class ScheduleInfoView: UIView {
    
    @Singleton<ValuesFormatter> private var formatter
    
    var itemSize: CGSize = .zero {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var closeTap: ControlEvent<Void> {
        closeButton.rx.tap
    }
    
    private lazy var closeButton: UIIconButton = {
        let button = UIIconButton(
            config: .transparent(
                size: Dimens.buttonHeight,
                contentColor: .white,
                contentPressedColor: .disabled
            )
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .iconClose
        return button
    }()
    
    private lazy var sampleProgramButton: RoundedControlButtonView = {
        let buttonView = RoundedControlButtonView(height: Dimens.buttonSmallHeight)
        buttonView.backgroundColor = SuplaScheduleProgram.program1.color()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.text = formatter.temperatureToString(CGFloat(19), withUnit: false)
        buttonView.textFont = .scheduleDetailButton
        buttonView.type = .neutral
        buttonView.isClickable = false
        buttonView.alpha = 0
        
        return buttonView
    }()
    
    private lazy var sampleProgramButtonArrow: UIView = {
        let view = makeArrowView()
        view.alpha = 0
        return view
    }()
    
    private lazy var sampleProgramButtonText: UILabel = {
        let label = makeLabelView()
        label.text = Strings.ThermostatDetail.programInfo
        label.alpha = 0
        return label
    }()
    
    private lazy var sampleProgramBox: BoxShapeLayerWrapper = {
        let box = BoxShapeLayerWrapper()
        box.setBackgrounds(ScheduleDetailBoxValue(oneProgram: .program1))
        return box
    }()
    
    private lazy var sampleProgramBoxView: UIView = {
        let view = UIView()
        view.layer.addSublayer(sampleProgramBox)
        view.alpha = 0
        return view
    }()
    
    private lazy var sampleProgramBoxArrow: UIView = {
        let view = makeArrowView()
        view.layer.transform = CATransform3DMakeRotation(.pi/2, 0, 0, 1)
        view.alpha = 0
        return view
    }()
    
    private lazy var sampleProgramBoxText: UILabel = {
        let label = makeLabelView()
        label.text = Strings.ThermostatDetail.boxInfo
        label.alpha = 0
        return label
    }()
    
    private lazy var sampleDarkCornerBox: BoxShapeLayerWrapper = {
        let box = BoxShapeLayerWrapper()
        box.setBackgrounds(ScheduleDetailBoxValue(oneProgram: .program2))
        return box
    }()
    
    private lazy var sampleDarkCorner = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.black.cgColor
        return layer
    }()
    
    private lazy var sampleDarkCornerBoxView: UIView = {
        let view = UIView()
        view.layer.addSublayer(sampleDarkCornerBox)
        view.layer.addSublayer(sampleDarkCorner)
        view.alpha = 0
        return view
    }()
    
    private lazy var sampleDarkCornerArrow: UIView = {
        let view = makeArrowView()
        view.layer.transform = CATransform3DMakeRotation(.pi/2, 0, 0, 1)
        view.alpha = 0
        return view
    }()
    
    private lazy var sampleDarkCornerText: UILabel = {
        let label = makeLabelView()
        label.text = Strings.ThermostatDetail.arrowInfo
        label.alpha = 0
        return label
    }()
    
    private var dynamicConstraints: [NSLayoutConstraint] = []
    private var presented = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if (!dynamicConstraints.isEmpty) {
            NSLayoutConstraint.deactivate(dynamicConstraints)
            dynamicConstraints.removeAll()
        }
        
        setupSampleProgramBox()
        setupSampleDarkCornerBox()
        
        NSLayoutConstraint.activate(dynamicConstraints)
        
        if (itemSize != .zero && !presented) {
            UIView.animate(withDuration: 1) {
                self.sampleProgramButton.alpha = 1
                self.sampleProgramButtonArrow.alpha = 1
                self.sampleProgramButtonText.alpha = 1
            }
            UIView.animate(withDuration: 1, delay: 0.25) {
                self.sampleProgramBoxView.alpha = 1
                self.sampleProgramBoxArrow.alpha = 1
                self.sampleProgramBoxText.alpha = 1
            }
            UIView.animate(withDuration: 1, delay: 0.5) {
                self.sampleDarkCornerBoxView.alpha = 1
                self.sampleDarkCornerArrow.alpha = 1
                self.sampleDarkCornerText.alpha = 1
            }
            presented = true
        }
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .onBackground.copy(alpha: 0.8)
        
        addSubview(closeButton)
        addSubview(sampleProgramButton)
        addSubview(sampleProgramButtonArrow)
        addSubview(sampleProgramButtonText)
        
        addSubview(sampleProgramBoxView)
        addSubview(sampleProgramBoxArrow)
        addSubview(sampleProgramBoxText)
        
        addSubview(sampleDarkCornerBoxView)
        addSubview(sampleDarkCornerArrow)
        addSubview(sampleDarkCornerText)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: Dimens.distanceSmall),
            closeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceDefault),
            
            sampleProgramButton.topAnchor.constraint(equalTo: topAnchor, constant: Dimens.distanceSmall),
            sampleProgramButton.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
            
            sampleProgramButtonArrow.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Dimens.distanceSmall + Dimens.buttonSmallHeight / 2
            ),
            sampleProgramButtonArrow.leftAnchor.constraint(
                equalTo: leftAnchor,
                constant: Dimens.distanceDefault + sampleProgramButton.intrinsicContentSize.width + 4
            ),
            sampleProgramButtonArrow.widthAnchor.constraint(equalToConstant: 50),
            sampleProgramButtonArrow.heightAnchor.constraint(equalToConstant: 50),
            
            sampleProgramButtonText.topAnchor.constraint(equalTo: sampleProgramButtonArrow.bottomAnchor, constant: 4),
            sampleProgramButtonText.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceDefault),
            sampleProgramButtonText.widthAnchor.constraint(equalToConstant: 200),
            
            sampleProgramBoxArrow.widthAnchor.constraint(equalToConstant: 50),
            sampleProgramBoxArrow.heightAnchor.constraint(equalToConstant: 50),
            sampleProgramBoxText.widthAnchor.constraint(equalToConstant: 200),
            
            sampleDarkCornerArrow.widthAnchor.constraint(equalToConstant: 50),
            sampleDarkCornerArrow.heightAnchor.constraint(equalToConstant: 50),
            sampleDarkCornerText.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupSampleProgramBox() {
        let x = frame.width - Dimens.distanceDefault - itemSize.width-2
        let y = (Dimens.distanceSmall * 2) + sampleProgramButton.intrinsicContentSize.height + 26 + itemSize.height * 6
        
        CALayer.performWithoutAnimation {
            sampleProgramBox.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
        }
        
        if (itemSize != .zero) {
            dynamicConstraints.append(contentsOf: [
                sampleProgramBoxArrow.topAnchor.constraint(equalTo: topAnchor, constant: y + itemSize.height + 6),
                sampleProgramBoxArrow.rightAnchor.constraint(equalTo: rightAnchor, constant: -(itemSize.width / 2 + Dimens.distanceDefault)),
                
                sampleProgramBoxText.rightAnchor.constraint(equalTo: sampleProgramBoxArrow.leftAnchor, constant: -4),
                sampleProgramBoxText.centerYAnchor.constraint(equalTo: sampleProgramBoxArrow.bottomAnchor)
            ])
        }
    }
    
    private func setupSampleDarkCornerBox() {
        let x = frame.width - Dimens.distanceDefault - itemSize.width-2
        let y = (Dimens.distanceSmall * 2) + sampleProgramButton.intrinsicContentSize.height + 70 + itemSize.height * 17
        
        CALayer.performWithoutAnimation {
            sampleDarkCornerBox.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
        }
        
        let halfHeight = itemSize.height / 2
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: y + Dimens.radiusSmall + halfHeight))
        path.addLine(to: CGPoint(x: x, y: y + Dimens.radiusSmall))
        path.addLine(to: CGPoint(x: x + Dimens.radiusSmall, y: y))
        path.addLine(to: CGPoint(x: x + Dimens.radiusSmall + halfHeight, y: y))
        path.close()
        sampleDarkCorner.path = path.cgPath
        
        if (itemSize != .zero) {
            dynamicConstraints.append(contentsOf: [
                sampleDarkCornerArrow.topAnchor.constraint(equalTo: topAnchor, constant: y + itemSize.height + 6),
                sampleDarkCornerArrow.rightAnchor.constraint(equalTo: rightAnchor, constant: -(itemSize.width / 2 + Dimens.distanceDefault)),
                
                sampleDarkCornerText.rightAnchor.constraint(equalTo: sampleDarkCornerArrow.leftAnchor, constant: -4),
                sampleDarkCornerText.centerYAnchor.constraint(equalTo: sampleDarkCornerArrow.bottomAnchor)
            ])
        }
    }
    
    private func makeArrowView() -> UIView {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(to: CGPoint(x: 50, y: 50), controlPoint1: CGPoint(x: 25, y: 0), controlPoint2: CGPoint(x: 50, y: 25))
        path.move(to: CGPoint(x: 5, y: -5))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 5, y: 5))
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.transparent.cgColor
        layer.lineWidth = 2
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.addSublayer(layer)
        return view
    }
    
    private func makeLabelView() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body1
        label.textColor = .onPrimary
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
