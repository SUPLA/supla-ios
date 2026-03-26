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
    
extension NfcTagDetailFeature {
    class ViewController: SuplaCore.BaseViewController<ViewState, View, ViewModel> {
        
        override init(viewModel: NfcTagDetailFeature.ViewModel) {
            super.init(viewModel: viewModel)
            
            contentView = View(
                viewState: viewModel.state,
                delegate: viewModel
            )
            
            title = Strings.Nfc.List.title
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .trash,
                target: self,
                action: #selector(onDelete)
            )
            
            viewModel.setTitleSetter { [weak self] title in self?.title = title }
        }
        
        @objc
        func onDelete() {
            viewModel.onDelete()
        }
        
        static func create(uuid: String) -> UIViewController {
            let viewModel = ViewModel(uuid: uuid)
            return ViewController(viewModel: viewModel)
        }
    }
}
