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
    
protocol ToolbarSearchHandlerDelegate: AnyObject {
    var navigationItem: UINavigationItem { get }
    func onSearchedTextChanged(_ text: String)
}

class ToolbarSearchHandler: NSObject {
    lazy var searchBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem.create(
            image: .iconSearch,
            barButtonSystemItem: .search,
            target: self,
            action: #selector(onSearchIconPressed)
        )
    }()
    
    weak var delegate: ToolbarSearchHandlerDelegate?
    
    init(delegate: ToolbarSearchHandlerDelegate?) {
        self.delegate = delegate
    }
    
    @objc func onSearchIconPressed() {
        if (delegate?.navigationItem.titleView is UITextField) {
            delegate?.onSearchedTextChanged("")
            delegate?.navigationItem.titleView = nil
            searchBarButtonItem.image = .iconSearch
        } else {
            let searchField = UITextField()
            searchField.placeholder = Strings.Notifications.searchPrompt
            searchField.backgroundColor = .surface
            searchField.borderStyle = .roundedRect
            searchField.addTarget(self, action: #selector(onTextChanged), for: .editingChanged)
            delegate?.navigationItem.titleView = searchField
            searchBarButtonItem.image = .iconClose
            searchField.becomeFirstResponder()
        }
    }
    
    @objc func onTextChanged(_ textField: UITextField) {
        delegate?.onSearchedTextChanged(textField.text ?? "")
    }
}
