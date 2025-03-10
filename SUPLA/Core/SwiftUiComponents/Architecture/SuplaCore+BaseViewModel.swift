//
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

extension SuplaCore {
    class BaseViewModel<S: ObservableObject>: BaseViewModelBinder {
        let disposeBag = DisposeBag()
        var visibilityScopedDisposeBag = DisposeBag()
        
        var state: S
        
        init(state: S) {
            self.state = state
        }
        
        func onViewDidLoad() {}
        
        func onViewWillAppear() {}
        
        func onViewWillDisappear() {
            // release all disposables when going to background
            visibilityScopedDisposeBag = DisposeBag()
        }
        
        func onViewAppeared() {}
        
        func onViewDisappeared() {}
        
        func handle(_ disposable: Disposable) {
            disposeBag.insert(disposable)
        }
    }
}

extension Disposable {
    func disposedWhenDisappear<S>(by viewModel: SuplaCore.BaseViewModel<S>) {
        disposed(by: viewModel.visibilityScopedDisposeBag)
    }
}
