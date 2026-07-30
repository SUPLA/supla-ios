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
    class ViewModel<S: ObservableObject>: ObservableObject {
        @Published private(set) var state: S

        let disposeBag = DisposeBag()
        var visibilityScopedDisposeBag = DisposeBag()

        let eventSelector: Selector?

        init(state: S, eventSelector: Selector? = nil) {
            self.state = state
            self.eventSelector = eventSelector

            if let eventSelector {
                NotificationCenter.default.addObserver(
                    self,
                    selector: eventSelector,
                    name: NSNotification.Name.saEvent,
                    object: nil
                )
            }
        }

        func onViewAppear() {}

        func onViewDisappear() {
            // release all disposables when going to background
            visibilityScopedDisposeBag = DisposeBag()
        }

        deinit {
            if eventSelector != nil {
                NotificationCenter.default.removeObserver(self)
            }

#if DEBUG
            let className = NSStringFromClass(type(of: self))
            SALog.debug("[DEINIT] VM:\(className)")
#endif
        }
    }
}

extension Disposable {
    func disposedWhenDisappear<S>(by viewModel: SuplaCore.ViewModel<S>) {
        disposed(by: viewModel.visibilityScopedDisposeBag)
    }
}
