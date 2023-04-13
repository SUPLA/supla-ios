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

class AccountRemovalVM : BaseViewModel<AccountRemovalViewState, AccountRemovalViewEvent> {
    
    private static let REMOVAL_FINISHED_SUFIX = "/db99845855b2ecbfecca9a095062b96c3e27703f?ack=true"
    
    private let needsRestart: Bool
    private let serverAddress: String?
    
    init(needsRestart: Bool, serverAddress: String? = nil) {
        self.needsRestart = needsRestart
        self.serverAddress = serverAddress
    }
    
    func handleUrl(url: String?) {
        guard let url = url else { return }
        
        if (url.hasSuffix(AccountRemovalVM.REMOVAL_FINISHED_SUFIX)) {
            if (needsRestart) {
                send(event: .finishAndRestart)
            } else {
                send(event: .finish)
            }
        }
    }
    
    func provideUrl() -> String {
        if let server = serverAddress {
            return "https://\(server)/db99845855b2ecbfecca9a095062b96c3e27703f"
        } else {
            return "https://cloud.supla.org/db99845855b2ecbfecca9a095062b96c3e27703f"
        }
    }
    
    override func defaultViewState() -> AccountRemovalViewState { AccountRemovalViewState() }
}

enum AccountRemovalViewEvent: ViewEvent {
    case finish
    case finishAndRestart
}

struct AccountRemovalViewState: ViewState {}
