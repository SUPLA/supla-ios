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

class ScheduleDetailVC: BaseViewControllerVM<ScheduleDetailViewState, ScheduleDetailViewEvent, ScheduleDetailVM> {
    
    private let remoteId: Int32
    
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
    
    private var navigator: ThermostatDetailNavigationCoordinator? {
        get { navigationCoordinator as? ThermostatDetailNavigationCoordinator }
    }
    
    init(remoteId: Int32) {
        self.remoteId = remoteId
        super.init(nibName: nil, bundle: nil)
        viewModel = ScheduleDetailVM()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarBackgroundView.isHidden = true
        view.backgroundColor = .background
        
        viewModel.observeConfig(remoteId: remoteId)
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadConfig()
    }
    
    override func handle(event: ScheduleDetailViewEvent) {
        switch(event) {
        case .editProgram(let state):
            let dialog = EditProgramDialogVC(initialState: state)
            dialog.onFinishCallback = { self.viewModel.onProgramChanged($0) }
            present(dialog, animated: true)
        case .editScheduleBox(let state):
            let dialog = EditQuartersDialogVC(initialState: state)
            dialog.onFinishCallback = {
                self.viewModel.onQuartersChanged(key: state.key, value: $0, activeProgram: $1)
            }
            present(dialog, animated: true)
        }
    }
    
    override func handle(state: ScheduleDetailViewState) {
        buttonsRowView.activeProgram = state.activeProgram
        buttonsRowView.programs = state.programs
        scheduleDetailTableView.updateBoxes(schedule: state.schedule)
    }
    
    private func setupView() {
        view.addSubview(buttonsRowView)
        view.addSubview(scheduleDetailTableView)
        
        viewModel.bind(buttonsRowView.tapEvents) { self.viewModel.onProgramTap($0) }
        viewModel.bind(buttonsRowView.longPressEvents) { self.viewModel.onProgramLongPress($0) }
        viewModel.bind(scheduleDetailTableView.longPressEvents) { self.viewModel.onBoxLongPress($0) }
        viewModel.bind(scheduleDetailTableView.panningEvents) { self.viewModel.onBoxEvent($0) }
        
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
            scheduleDetailTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
            buttonView.textFont = .scheduleDetailButton
            buttonView.type = .neutral
            buttonView.tap
                .subscribe(onNext: { self.tapRelay.accept(program.scheduleProgram.program) })
                .disposed(by: disposeBag)
            if (program.scheduleProgram.program != .off) {
                buttonView.longPress
                    .subscribe(onNext: { self.longPressRelay.accept(program.scheduleProgram.program) })
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
    let longPressRelay: PublishRelay<ScheduleDetailBoxKey> = PublishRelay()
    let tapRelay: PublishRelay<PanningEvent> = PublishRelay()
    
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
        
        let date = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.weekday, from: date) - 1
        let currentHour = calendar.component(.hour, from: date)
        for day in DayOfWeek.allCases {
            if (day.rawValue == currentDay) {
                dayLabels.append(createBoldLabel(text: day.shortText()))
            } else {
                dayLabels.append(createRegularLabel(text: day.shortText()))
            }
            
            for _ in HoursRange {
                boxes.append(BoxShapeLayerWrapper())
            }
        }
        
        for hour in HoursRange {
            if (hour == currentHour) {
                hourLabels.append(createBoldLabel(text: hour.toHour()))
            } else {
                hourLabels.append(createRegularLabel(text: hour.toHour()))
            }
        }
        
        boxes.forEach { layer.addSublayer($0) }
        dayLabels.forEach { layer.addSublayer($0) }
        layer.addSublayer(currentDayIndicatorLayer)
        layer.addSublayer(currentHourIndicatorLayer)
        layer.addSublayer(currentItemIndicatorLayer)
    }
    
    override func layoutSubviews() {let date = Date()
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
        let itemWidth = gridWidth - (itemPadding * 2)
        let itemHeight = gridHeight - (itemPadding * 2)
        
        setupTable(itemWidth, itemHeight, gridWidth, gridHeight, currentDay, currentHour, firstColumnWidth)
        setupHourLabels(gridHeight, firstColumnWidth, currentHour, itemHeight)
        
        currentItemIndicatorLayer.frame = bounds
    }
    
    private func createRegularLabel(text: String) -> CATextLayer {
        return createLabel(text: text, fontName: "OpenSans-Regular")
    }
    
    private func createBoldLabel(text: String) -> CATextLayer {
        return createLabel(text: text, fontName: "OpenSans-Bold")
    }
    
    private func setupTable(_ itemWidth: CGFloat, _ itemHeight: CGFloat, _ gridWidth: CGFloat, _ gridHeight: CGFloat, _ currentDay: Int, _ currentHour: Int, _ firstColumnWidth: CGFloat) {
        var idx = 0
        var x = Dimens.distanceDefault + firstColumnWidth
        for day in DayOfWeek.allCases {
            if (day.rawValue == currentDay) {
                currentDayIndicatorLayer.frame = CGRect(
                    x: x + itemPadding,
                    y: itemPadding,
                    width: itemWidth,
                    height: itemHeight
                )
                currentDayIndicatorLayer.cornerRadius = itemHeight / 2
            }
            
            let dayLabel = dayLabels[idx / 24]
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
                    width: itemWidth,
                    height: itemHeight
                )
                
                let box = boxes[idx]
                box.frame = rect
                
                if (day.rawValue == currentDay && hour == currentHour) {
                    currentItemIndicatorLayer.path = setupCurrentBoxIndicatorPath(x, y, itemHeight)
                }
                
                y += gridHeight
                idx += 1
            }
            x += gridWidth
        }
    }
    
    private func setupHourLabels(_ gridHeight: CGFloat, _ firstColumnWidth: CGFloat, _ currentHour: Int, _ itemHeight: CGFloat) {
        var y = gridHeight
        var hour = 0
        hourLabels.forEach {
            if (hour == currentHour) {
                currentHourIndicatorLayer.frame = CGRect(
                    x: Dimens.distanceDefault + itemPadding,
                    y: y + itemPadding,
                    width: firstColumnWidth - (itemPadding * 2),
                    height: itemHeight
                )
                currentHourIndicatorLayer.cornerRadius = itemHeight / 2
            }
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
        label.font = CTFontCreateWithName(fontName as CFString, 12, nil)
        label.fontSize = 12
        label.string = text
        label.alignmentMode = .center
        label.foregroundColor = UIColor.black.cgColor
        label.contentsScale = UIScreen.main.scale
        
        return label
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

