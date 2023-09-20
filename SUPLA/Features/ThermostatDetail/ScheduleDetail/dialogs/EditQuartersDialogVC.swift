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
import RxRelay
import RxSwift

final class EditQuartersDialogVC: SuplaCustomDialogVC<EditQuartersDialogViewState, EditQuartersDialogViewEvent, EditQuartersDialogVM> {
    
    var onFinishCallback: ((ScheduleDetailBoxValue, SuplaScheduleProgram?) -> Void)? = nil
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .h6
        return label
    }()
    
    private lazy var buttonsRowView: ButtonsRowView = {
        let view = ButtonsRowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dayLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        return label
    }()
    
    private lazy var firstQuarterRowView = {
        let row = QuarterRowView(quarterOfHour: .first)
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }()
    
    private lazy var secondQuarterRowView = {
        let row = QuarterRowView(quarterOfHour: .second)
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }()
    
    private lazy var thirdQuarterRowView = {
        let row = QuarterRowView(quarterOfHour: .third)
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }()
    
    private lazy var fourthQuarterRowView = {
        let row = QuarterRowView(quarterOfHour: .fourth)
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }()
    
    private lazy var bottonSeparatorView = {
        let view = SeparatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelButton = {
        let button = UIBorderedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Strings.General.cancel, for: .normal)
        return button
    }()
    
    private lazy var saveButton = {
        let button = UIFilledButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Strings.General.save, for: .normal)
        return button
    }()
    
    init(initialState: EditQuartersDialogViewState) {
        super.init()
        viewModel = EditQuartersDialogVM(initialState: initialState)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handle(event: EditQuartersDialogViewEvent) {
        switch(event) {
        case .dismiss(let programs, let activeProgram):
            if let callback = onFinishCallback {
                callback(programs, activeProgram)
            }
            dismiss(animated: true)
        }
    }
    
    override func handle(state: EditQuartersDialogViewState) {
        titleLabel.text = Strings.ThermostatDetail.editQuartersDialogHeader.arguments(state.key.hour)
        dayLabel.text = state.key.dayOfWeek.fullText().uppercased()
        
        firstQuarterRowView.label = state.key.hour.toHour(withMinutes: 0)
        firstQuarterRowView.program = state.quarterPrograms.firstQuarterProgram
        secondQuarterRowView.label = state.key.hour.toHour(withMinutes: 15)
        secondQuarterRowView.program = state.quarterPrograms.secondQuarterProgram
        thirdQuarterRowView.label = state.key.hour.toHour(withMinutes: 30)
        thirdQuarterRowView.program = state.quarterPrograms.thirdQuarterProgram
        fourthQuarterRowView.label = state.key.hour.toHour(withMinutes: 45)
        fourthQuarterRowView.program = state.quarterPrograms.fourthQuarterProgram
        
        buttonsRowView.activeProgram = state.activeProgram
        buttonsRowView.programs = state.availablePrograms
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        let tapObservables = Observable.merge([
            firstQuarterRowView.tapEvents,
            secondQuarterRowView.tapEvents,
            thirdQuarterRowView.tapEvents,
            fourthQuarterRowView.tapEvents
        ])
        viewModel.bind(tapObservables) { self.viewModel.onBoxTap($0) }
        cancelButton.rx.tap.subscribe(onNext: { self.dismiss(animated: true) }).disposed(by: self)
        viewModel.bind(saveButton.rx.tap.asObservable()) { self.viewModel.save() }
        viewModel.bind(buttonsRowView.tapEvents) { self.viewModel.onProgramTap($0) }
        
        container.addSubview(titleLabel)
        container.addSubview(buttonsRowView)
        container.addSubview(dayLabel)
        container.addSubview(firstQuarterRowView)
        container.addSubview(secondQuarterRowView)
        container.addSubview(thirdQuarterRowView)
        container.addSubview(fourthQuarterRowView)
        container.addSubview(bottonSeparatorView)
        container.addSubview(cancelButton)
        container.addSubview(saveButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        let buttonsRowHeightConstraint = buttonsRowView.heightAnchor.constraint(equalToConstant: 0)
        buttonsRowView.heightConstraint = buttonsRowHeightConstraint
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: Dimens.distanceDefault),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            buttonsRowView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Dimens.distanceDefault),
            buttonsRowView.leftAnchor.constraint(equalTo: container.leftAnchor),
            buttonsRowView.rightAnchor.constraint(equalTo: container.rightAnchor),
            buttonsRowHeightConstraint,
            
            dayLabel.topAnchor.constraint(equalTo: buttonsRowView.bottomAnchor, constant: Dimens.distanceDefault),
            dayLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            firstQuarterRowView.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: Dimens.distanceSmall),
            firstQuarterRowView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            firstQuarterRowView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            secondQuarterRowView.topAnchor.constraint(equalTo: firstQuarterRowView.bottomAnchor, constant: Dimens.distanceTiny),
            secondQuarterRowView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            secondQuarterRowView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            thirdQuarterRowView.topAnchor.constraint(equalTo: secondQuarterRowView.bottomAnchor, constant: Dimens.distanceTiny),
            thirdQuarterRowView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            thirdQuarterRowView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            fourthQuarterRowView.topAnchor.constraint(equalTo: thirdQuarterRowView.bottomAnchor, constant: Dimens.distanceTiny),
            fourthQuarterRowView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            fourthQuarterRowView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            bottonSeparatorView.topAnchor.constraint(equalTo: fourthQuarterRowView.bottomAnchor, constant: Dimens.distanceDefault),
            bottonSeparatorView.leftAnchor.constraint(equalTo: container.leftAnchor),
            bottonSeparatorView.rightAnchor.constraint(equalTo: container.rightAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: bottonSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
            cancelButton.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            cancelButton.rightAnchor.constraint(equalTo: container.centerXAnchor, constant: -Dimens.distanceDefault / 2),
            
            saveButton.topAnchor.constraint(equalTo: bottonSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
            saveButton.leftAnchor.constraint(equalTo: container.centerXAnchor, constant: Dimens.distanceDefault / 2),
            saveButton.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            saveButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Dimens.distanceDefault)
        ])
    }
}

// MARK: - Buttons row

fileprivate class ButtonsRowView: UIView {
    
    var tapEvents: Observable<SuplaScheduleProgram> {
        get { tapRelay.asObservable() }
    }
    var activeProgram: SuplaScheduleProgram? = nil {
        didSet {
            buttons.values.forEach { $0.active = false }
            if let activeProgram = activeProgram {
                buttons[activeProgram]?.active = true
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
    var heightConstraint: NSLayoutConstraint? = nil
    
    private let tapRelay: PublishRelay<SuplaScheduleProgram> = PublishRelay()
    private var buttons: [SuplaScheduleProgram : RoundedControlButtonView] = [:]
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .grayLight
    }
    
    override func layoutSubviews() {
        cleanUpView()
        super.layoutSubviews()
        
        for program in programs {
            let buttonView = RoundedControlButtonView(height: Dimens.buttonSmallHeight)
            buttonView.backgroundColor = program.program.color()
            buttonView.icon = program.icon != nil ? .suplaIcon(icon: program.icon) : nil
            buttonView.text = program.text
            buttonView.textFont = .scheduleDetailButton
            buttonView.type = .neutral
            buttonView.tap.subscribe(onNext: { self.tapRelay.accept(program.program) }).disposed(by: disposeBag)
            buttonView.frame.size.width = buttonView.intrinsicContentSize.width
            buttonView.frame.size.height = buttonView.intrinsicContentSize.height
            buttons[program.program] = buttonView
            
            addSubview(buttonView)
        }
        
        setupButtonsLayout()
    }
    
    func setupButtonsLayout() {
        
        let containerWidth = frame.size.width
        
        var currentX: CGFloat = Dimens.distanceDefault
        var currentY: CGFloat = Dimens.distanceSmall
        
        for program in programs {
            let button = buttons[program.program]!
            
            if (currentX + button.frame.width + Dimens.distanceDefault > containerWidth) {
                currentX = Dimens.distanceDefault
                currentY += Dimens.buttonSmallHeight + Dimens.distanceTiny
            }
            
            button.frame.origin.x = currentX
            button.frame.origin.y = currentY
            
            currentX += button.frame.width + Dimens.distanceTiny
        }
        
        guard let heightConstraint = heightConstraint else {
            fatalError("The variable heightConstraint needs to be set for proper working!")
        }
        heightConstraint.constant = currentY + Dimens.buttonSmallHeight + Dimens.distanceSmall
    }
    
    private func cleanUpView() {
        buttons.values.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
    }
}

// MARK: - Quarter view

fileprivate class QuarterRowView: UIView {
    
    var tapEvents: Observable<QuarterOfHour> {
        get { tapRelay.asObservable() }
    }
    
    var label: String? {
        get { labelView.text }
        set { labelView.text = newValue }
    }
    
    var program: SuplaScheduleProgram? = nil {
        didSet {
            if let color = program?.color() {
                boxView.backgroundColor = color
            } else {
                boxView.backgroundColor = SuplaScheduleProgram.off.color()
            }
        }
    }
    
    private lazy var labelView = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        return label
    }()
    
    private lazy var boxView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Dimens.radiusSmall
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBoxTapped)))
        return view
    }()
    
    private let tapRelay: PublishRelay<QuarterOfHour> = PublishRelay()
    private let quarterOfHour: QuarterOfHour
    
    init(quarterOfHour: QuarterOfHour) {
        self.quarterOfHour = quarterOfHour
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(labelView)
        addSubview(boxView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            labelView.centerYAnchor.constraint(equalTo: boxView.centerYAnchor),
            labelView.leftAnchor.constraint(equalTo: leftAnchor),
            
            boxView.topAnchor.constraint(equalTo: topAnchor),
            boxView.leftAnchor.constraint(equalTo: labelView.rightAnchor, constant: Dimens.distanceDefault),
            boxView.rightAnchor.constraint(equalTo: rightAnchor),
            boxView.bottomAnchor.constraint(equalTo: bottomAnchor),
            boxView.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    @objc private func onBoxTapped() {
        tapRelay.accept(quarterOfHour)
    }
}
