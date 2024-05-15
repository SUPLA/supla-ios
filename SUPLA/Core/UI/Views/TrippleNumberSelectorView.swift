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

import RxSwift
import RxRelay

fileprivate let columnWidth = 110
fileprivate let columnHeight = 160

final class TrippleNumberSelectorView: UIView {
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 3 * columnWidth + 2 * Int(Dimens.distanceTiny), height: columnHeight)
    }
    
    var firstColumnCount: Int = 0
    var secondColumnCount: Int = 0
    var thirdColumnCount: Int = 0
    
    var firstColumnValueFormatter: ((Int) -> String)? = nil
    var secondColumnValueFormatter: ((Int) -> String)? = nil
    var thirdColumnValueFormatter: ((Int) -> String)? = nil
    
    var value: Value {
        get { currentValue() }
        set {
            firstPickerView.selectRow(newValue.firstValue, inComponent: 0, animated: true)
            secondPickerView.selectRow(newValue.secondValue, inComponent: 0, animated: true)
            thirdPickerView.selectRow(newValue.thirdValue, inComponent: 0, animated: true)
        }
    }
    var valueObservable: Observable<Value> {
        get { valueRelay.asObservable() }
    }
    
    private lazy var selectedPickerRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .grayLighter
        view.layer.cornerRadius = Dimens.buttonRadius
        return view
    }()
    
    private lazy var firstPickerView: UIPickerView = {
        let view = UIPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private lazy var secondPickerView: UIPickerView = {
        let view = UIPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private lazy var thirdPickerView: UIPickerView = {
        let view = UIPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private lazy var valueRelay: PublishRelay<Value> = PublishRelay()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(selectedPickerRowView)
        addSubview(firstPickerView)
        addSubview(secondPickerView)
        addSubview(thirdPickerView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            firstPickerView.leftAnchor.constraint(equalTo: leftAnchor),
            firstPickerView.widthAnchor.constraint(equalToConstant: CGFloat(columnWidth)),
            firstPickerView.heightAnchor.constraint(equalToConstant: CGFloat(columnHeight)),
            
            secondPickerView.leftAnchor.constraint(equalTo: firstPickerView.rightAnchor, constant: Dimens.distanceTiny),
            secondPickerView.widthAnchor.constraint(equalToConstant: CGFloat(columnWidth)),
            secondPickerView.heightAnchor.constraint(equalToConstant: CGFloat(columnHeight)),
            
            thirdPickerView.leftAnchor.constraint(equalTo: secondPickerView.rightAnchor, constant: Dimens.distanceTiny),
            thirdPickerView.widthAnchor.constraint(equalToConstant: CGFloat(columnWidth)),
            thirdPickerView.heightAnchor.constraint(equalToConstant: CGFloat(columnHeight)),
            
            selectedPickerRowView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedPickerRowView.heightAnchor.constraint(equalToConstant: 40),
            selectedPickerRowView.leftAnchor.constraint(equalTo: leftAnchor),
            selectedPickerRowView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
    }
    
    private func currentValue() -> Value {
        Value(
            firstValue: firstPickerView.selectedRow(inComponent: 0),
            secondValue: secondPickerView.selectedRow(inComponent: 0),
            thirdValue: thirdPickerView.selectedRow(inComponent: 0)
        )
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    struct Value: Equatable {
        let firstValue: Int
        let secondValue: Int
        let thirdValue: Int
        
        init(firstValue: Int, secondValue: Int, thirdValue: Int) {
            self.firstValue = firstValue
            self.secondValue = secondValue
            self.thirdValue = thirdValue
        }
        
        init(valueForHours: Int) {
            self.firstValue = valueForHours / HOUR_IN_SEC
            self.secondValue = (valueForHours % HOUR_IN_SEC) / MINUTE_IN_SEC
            self.thirdValue = valueForHours % MINUTE_IN_SEC
        }
        
        init(valueForDays: Int) {
            self.firstValue = valueForDays / DAY_IN_SEC
            self.secondValue = (valueForDays % DAY_IN_SEC) / HOUR_IN_SEC
            self.thirdValue = (valueForDays % HOUR_IN_SEC) / MINUTE_IN_SEC
        }
        
        func toHoursInSec() -> Int {
            firstValue * HOUR_IN_SEC + secondValue * MINUTE_IN_SEC + thirdValue
        }
        
        func toDaysInSec() -> Int {
            firstValue * DAY_IN_SEC + secondValue * HOUR_IN_SEC + thirdValue * MINUTE_IN_SEC
        }
    }
}

extension TrippleNumberSelectorView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        pickerView.subviews[1].backgroundColor = .clear
        
        let label: UILabel
        if (view == nil) {
            label = UILabel()
            label.font = .button
            label.textAlignment = .center
        } else {
            label = view as! UILabel
        }
        
        if (pickerView == firstPickerView) {
            if let formatter = firstColumnValueFormatter {
                label.text = formatter(row)
            } else {
                label.text = "\(row)"
            }
        } else if (pickerView == secondPickerView) {
            if let formatter = secondColumnValueFormatter {
                label.text = formatter(row)
            } else {
                label.text = "\(row)"
            }
        } else if (pickerView == thirdPickerView) {
            if let formatter = thirdColumnValueFormatter {
                label.text = formatter(row)
            } else {
                label.text = "\(row)"
            }
        } else {
            label.text = "\(row)"
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        40
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        valueRelay.accept(currentValue())
    }
}

extension TrippleNumberSelectorView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == firstPickerView) {
            return firstColumnCount
        } else if (pickerView == secondPickerView) {
            return secondColumnCount
        } else if (pickerView == thirdPickerView) {
            return thirdColumnCount
        } else {
            return 0
        }
    }
    
    
}
