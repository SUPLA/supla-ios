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
    
final class EditTextCell: BaseSettingsCell<SATextField> {
    static let id = "EditTextCell"
    var callback: (Int32) -> Void = { _ in }
    
    private lazy var editTextView: SATextField = {
        let leftLabel = UILabel()
        leftLabel.text = "<"
        leftLabel.textColor = .gray
        leftLabel.font = .body2
        leftLabel.textAlignment = .right
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        let rightLabel = UILabel()
        rightLabel.text = "%"
        rightLabel.textColor = .gray
        rightLabel.font = .body2
        rightLabel.textAlignment = .left
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        let editText = SATextField()
        editText.leftView = leftLabel
        editText.rightView = rightLabel
        editText.keyboardType = .decimalPad
        editText.textAlignment = .center
        editText.delegate = self
        
        return editText
    }()
    
    override func provideActionView() -> SATextField {
        editTextView
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        NSLayoutConstraint.activate([
            editTextView.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    static func configure(_ label: String, _ level: Int32, _ callback: @escaping (Int32) -> Void, cellProvider: () -> EditTextCell) -> EditTextCell {
        let cell = cellProvider()
        cell.setLabel(label)
        cell.editTextView.text = String(format: "%d", level)
        cell.callback = callback
        return cell
    }
}

extension EditTextCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (!CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))) {
            return false
        }
            
        let currentText = textField.text ?? ""
        
        guard let stringRange = Swift.Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if let level = Int32(updatedText), updatedText.count <= 2 {
            callback(level)
        }
        
        return updatedText.count <= 2
    }
}
