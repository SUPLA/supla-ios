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

import RxCocoa
import RxRelay
import RxSwift

final class SADateTimePicker: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: datePicker.intrinsicContentSize.height)
    }
    
    var saveTap: Observable<Date?> { saveButton.rx.tap.map { _ in self.selectedDate } }
    
    var cancelTap: Observable<Void> { cancelButton.rx.tap.asObservable() }
    
    var date: Date? {
        get { selectedDate }
        set {
            selectedDate = newValue
            if let newDate = newValue {
                datePicker.date = newDate
            }
        }
    }
    
    var minDate: Date? {
        get { datePicker.minimumDate }
        set { datePicker.minimumDate = newValue }
    }
    
    var maxDate: Date? {
        get { datePicker.maximumDate }
        set { datePicker.maximumDate = newValue }
    }
    
    private lazy var datePicker: UIDatePicker = {
        let view = UIDatePicker()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.datePickerMode = .dateAndTime
        view.tintColor = .primary
        view.preferredDatePickerStyle = .inline
        view.addTarget(self, action: #selector(onDateChanged), for: .valueChanged)
        return view
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .surface
        view.layer.cornerRadius = Dimens.radiusDefault
        return view
    }()
    
    private lazy var separatorView = SeparatorView()
    
    private lazy var saveButton: UIFilledButton = {
        let button = UIFilledButton()
        button.setTitle(Strings.General.save, for: .normal)
        return button
    }()
    
    private lazy var cancelButton: UIPlainButton = {
        let button = UIPlainButton()
        button.setTitle(Strings.General.cancel, for: .normal)
        return button
    }()
    
    private var selectedDate: Date? = nil
    
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
        backgroundColor = .dialogScrim
        
        addSubview(backgroundView)
        addSubview(datePicker)
        addSubview(separatorView)
        addSubview(saveButton)
        addSubview(cancelButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: Dimens.distanceSmall),
            datePicker.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: Dimens.distanceSmall),
            datePicker.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -Dimens.distanceSmall),
            
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            separatorView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: Dimens.distanceSmall),
            separatorView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor),
            
            saveButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: Dimens.distanceSmall),
            saveButton.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: Dimens.distanceSmall),
            saveButton.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -Dimens.distanceSmall),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: Dimens.distanceTiny),
            cancelButton.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: Dimens.distanceSmall),
            cancelButton.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -Dimens.distanceSmall),
            cancelButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -Dimens.distanceSmall)
        ])
    }
    
    @objc
    private func onDateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
