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
import SharedCore

final class EditProgramDialogVC : SACustomDialogVC<EditProgramDialogViewState, EditProgramDialogViewEvent, EditProgramDialogVM> {
    
    @Singleton<GroupShared.Settings> private var settings
    
    var onFinishCallback: ((SuplaWeeklyScheduleProgram) -> Void)? = nil
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .h6
        return label
    }()
    
    private lazy var titleIconView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var topSeparatorView: SeparatorView = { SeparatorView() }()
    
    private lazy var editHeatTemperatureView: EditTemperatureView = {
        let view = EditTemperatureView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel.text = Strings.ThermostatDetail.heatingTemperature
        view.unit = settings.temperatureUnit
        return view
    }()
    
    private lazy var editCoolTemperatureView: EditTemperatureView = {
        let view = EditTemperatureView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel.text = Strings.ThermostatDetail.coolingTemperature
        view.unit = settings.temperatureUnit
        return view
    }()
    
    private lazy var configurationFailureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.text = Strings.ThermostatDetail.configurationFailure
        return label
    }()
    
    private lazy var bottonSeparatorView: SeparatorView = { SeparatorView() }()
    
    private lazy var cancelButton: UIBorderedButton = {
        let button = UIBorderedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Strings.General.cancel, for: .normal)
        return button
    }()
    
    private lazy var saveButton: UIFilledButton = {
        let button = UIFilledButton()
        button.setTitle(Strings.General.save, for: .normal)
        return button
    }()
    
    init(initialState: EditProgramDialogViewState) {
        super.init(viewModel: EditProgramDialogVM(initialState: initialState))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handle(event: EditProgramDialogViewEvent) {
        switch (event) {
        case .dismiss(let program):
            if let callback = onFinishCallback {
                callback(program)
            }
            dismiss(animated: true)
        }
    }
    
    override func handle(state: EditProgramDialogViewState) {
        titleLabel.text = Strings.ThermostatDetail.editProgramDialogHeader.arguments(state.program.rawValue)
        titleIconView.backgroundColor = state.program.color()
        editHeatTemperatureView.isHidden = !state.showHeatEdit
        editHeatTemperatureView.minusIconButton.isEnabled = state.heatMinusActive
        editHeatTemperatureView.plusIconButton.isEnabled = state.heatPlusActive
        editHeatTemperatureView.setValueCorrect(state.heatCorrect)
        editCoolTemperatureView.isHidden = !state.showCoolEdit
        editCoolTemperatureView.minusIconButton.isEnabled = state.coolMinusActive
        editCoolTemperatureView.plusIconButton.isEnabled = state.coolPlusActive
        editCoolTemperatureView.setValueCorrect(state.coolCorrect)
        saveButton.isEnabled = state.saveAllowed
        
        editHeatTemperatureView.temperatureTextField.text = state.heatTemperatureText
        editCoolTemperatureView.temperatureTextField.text = state.coolTemperatureText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        viewModel.bind(editHeatTemperatureView.plusTapObservable) { self.viewModel.heatTemperatureChange(.smallUp) }
        viewModel.bind(editHeatTemperatureView.minusTapObservable) { self.viewModel.heatTemperatureChange(.smallDown) }
        viewModel.bind(editHeatTemperatureView.temperatureObservable) { self.viewModel.heatTemperatureChange($0) }
        viewModel.bind(editCoolTemperatureView.plusTapObservable) { self.viewModel.coolTemperatureChange(.smallUp) }
        viewModel.bind(editCoolTemperatureView.minusTapObservable) { self.viewModel.coolTemperatureChange(.smallDown) }
        viewModel.bind(editCoolTemperatureView.temperatureObservable) { self.viewModel.coolTemperatureChange($0) }
        cancelButton.rx.tap.subscribe(onNext: { self.dismiss(animated: true) }).disposed(by: self)
        viewModel.bind(saveButton.rx.tap.asObservable()) { self.viewModel.save() }
        
        container.addSubview(titleLabel)
        container.addSubview(titleIconView)
        container.addSubview(topSeparatorView)
        container.addSubview(editHeatTemperatureView)
        container.addSubview(editCoolTemperatureView)
        container.addSubview(bottonSeparatorView)
        container.addSubview(cancelButton)
        container.addSubview(saveButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        var constraints = [
            titleIconView.widthAnchor.constraint(equalToConstant: 16),
            titleIconView.heightAnchor.constraint(equalToConstant: 16),
            titleIconView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            titleIconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: Dimens.distanceDefault),
            titleLabel.leftAnchor.constraint(equalTo: titleIconView.rightAnchor, constant: Dimens.distanceTiny),
            titleLabel.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            topSeparatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Dimens.distanceDefault),
            topSeparatorView.leftAnchor.constraint(equalTo: container.leftAnchor),
            topSeparatorView.rightAnchor.constraint(equalTo: container.rightAnchor),
            
            bottonSeparatorView.leftAnchor.constraint(equalTo: container.leftAnchor),
            bottonSeparatorView.rightAnchor.constraint(equalTo: container.rightAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: bottonSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
            cancelButton.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            cancelButton.rightAnchor.constraint(equalTo: container.centerXAnchor, constant: -Dimens.distanceDefault / 2),
            
            saveButton.topAnchor.constraint(equalTo: bottonSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
            saveButton.leftAnchor.constraint(equalTo: container.centerXAnchor, constant: Dimens.distanceDefault / 2),
            saveButton.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            saveButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Dimens.distanceDefault)
        ]
        
        let showHeat = viewModel.shouldShowHeatTemperature()
        let showCool = viewModel.shouldShowCoolTemperature()
        if (showHeat && showCool) {
            constraints.append(contentsOf: [
                editHeatTemperatureView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
                editHeatTemperatureView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
                editHeatTemperatureView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
                
                editCoolTemperatureView.topAnchor.constraint(equalTo: editHeatTemperatureView.bottomAnchor, constant: Dimens.distanceDefault),
                editCoolTemperatureView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
                editCoolTemperatureView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
                
                bottonSeparatorView.topAnchor.constraint(equalTo: editCoolTemperatureView.bottomAnchor, constant: Dimens.distanceDefault)
            ])
        } else if (showHeat) {
            constraints.append(contentsOf: [
                editHeatTemperatureView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
                editHeatTemperatureView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
                editHeatTemperatureView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
                
                bottonSeparatorView.topAnchor.constraint(equalTo: editHeatTemperatureView.bottomAnchor, constant: Dimens.distanceDefault)
            ])
        } else if (showCool) {
            constraints.append(contentsOf: [
                editCoolTemperatureView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
                editCoolTemperatureView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
                editCoolTemperatureView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
                
                bottonSeparatorView.topAnchor.constraint(equalTo: editCoolTemperatureView.bottomAnchor, constant: Dimens.distanceDefault)
            ])
        } else {
            container.addSubview(configurationFailureLabel)
            constraints.append(contentsOf: [
                configurationFailureLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                configurationFailureLabel.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
                configurationFailureLabel.bottomAnchor.constraint(equalTo: bottonSeparatorView.topAnchor, constant: -Dimens.distanceDefault)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - EditTemperatureView

fileprivate class EditTemperatureView: UIView, UITextFieldDelegate {
    
    var temperatureObservable: Observable<String> {
        get {
            temperatureTextField.rx.text
            .asObservable()
            .skip(1) // always emits empty value when subscribing - is not needed so skip it
            .compactMap { $0 }
            .distinctUntilChanged()
        }
    }
    
    var plusTapObservable: Observable<Void> {
        get { plusIconButton.rx.tap.asObservable() }
    }
    
    var minusTapObservable: Observable<Void> {
        get { minusIconButton.rx.tap.asObservable() }
    }
    
    var unit: TemperatureUnit? = nil {
        didSet {
            (temperatureTextField.rightView as? UILabel)?.text = unit?.valueUnit.text
        }
    }
    
    lazy var titleLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .h6
        return label
    }()
    
    lazy var minusIconButton = {
        let button = UIIconButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .iconMinus
        button.isUserInteractionEnabled = true
        return button
    }()
    
    lazy var plusIconButton = {
        let button = UIIconButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .iconPlus
        return button
    }()
    
    lazy var temperatureTextField = {
        let unitLabel = UILabel()
        unitLabel.text = unit?.valueUnit.text
        unitLabel.textColor = .gray
        unitLabel.font = .body2
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        let leftPadding = UIView()
        leftPadding.translatesAutoresizingMaskIntoConstraints = false
        leftPadding.widthAnchor.constraint(equalToConstant: 12).isActive = true
        
        let editText = SATextField()
        editText.rightView = unitLabel
        editText.leftView = leftPadding
        editText.delegate = self
        editText.keyboardType = .decimalPad
        
        return editText
    }()
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValueCorrect(_ correct: Bool) {
        if (correct) {
            temperatureTextField.layer.borderColor = UIColor.grayLighter.cgColor
            (temperatureTextField.rightView as? UILabel)?.textColor = .gray
        } else {
            temperatureTextField.layer.borderColor = UIColor.error.cgColor
            (temperatureTextField.rightView as? UILabel)?.textColor = .error
        }
    }
    
    private func setupView() {
        
        addSubview(titleLabel)
        addSubview(minusIconButton)
        addSubview(temperatureTextField)
        addSubview(plusIconButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            
            minusIconButton.centerYAnchor.constraint(equalTo: temperatureTextField.centerYAnchor),
            minusIconButton.leftAnchor.constraint(equalTo: leftAnchor),
            
            temperatureTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Dimens.distanceTiny),
            temperatureTextField.leftAnchor.constraint(equalTo: minusIconButton.rightAnchor, constant: Dimens.distanceTiny),
            temperatureTextField.widthAnchor.constraint(equalToConstant: 120),
            
            plusIconButton.leftAnchor.constraint(equalTo: temperatureTextField.rightAnchor, constant: Dimens.distanceTiny),
            plusIconButton.centerYAnchor.constraint(equalTo: temperatureTextField.centerYAnchor),
            
            temperatureTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if var currentText = textField.text?.replacingOccurrences(of: ",", with: ".") {
            let string = string.replacingOccurrences(of: ",", with: ".")

            // first minus sign
            if (string == "-" && currentText.count == 0 && range.location == 0) {
                return true
            }
            // Adding new characters
            if (range.location == currentText.count) {
                return Float("\(currentText)\(string)")?.isNaN == false
            }
            // removing last character
            if (string.count == 0 && currentText.count == 1 && range.location == 0) {
                return true
            }

            if let stringRange = Swift.Range(range, in: currentText) {
                currentText.replaceSubrange(stringRange, with: string)
                return currentText.isEmpty || Float(currentText)?.isNaN == false
            }
        }
        
        return false
    }
}
