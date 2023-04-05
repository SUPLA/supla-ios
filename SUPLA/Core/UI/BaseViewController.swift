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

class BaseViewControllerVM<S : ViewState, E : ViewEvent, VM : BaseViewModel<S, E>> : BaseViewController {
    
    private let disposeBag = DisposeBag()
    var viewModel: VM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.eventsObervable()
            .subscribe(onNext: { event in self.handle(event: event) })
            .disposed(by: disposeBag)
        viewModel.stateObservable()
            .subscribe(onNext: { state in self.handle(state: state) })
            .disposed(by: disposeBag)
    }
 
    func handle(event: E) { fatalError("handle(event:) has not been implemented!") }
    func handle(state: S) { fatalError("handle(state:) has not been implemented!") }
}
