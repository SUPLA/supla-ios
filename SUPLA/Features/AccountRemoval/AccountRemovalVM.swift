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

class AccountRemovalVM: WebContentVM<AccountRemovalViewState, AccountRemovalViewEvent> {
    private static let REMOVAL_FINISHED_SUFIX = "ack=true"
    
    private let needsRestart: Bool
    private let serverAddress: String?
    
    init(needsRestart: Bool, serverAddress: String? = nil) {
        self.needsRestart = needsRestart
        self.serverAddress = serverAddress
    }
    
    override func shouldHandle(url: String?) -> Bool {
        guard let url = url else { return true }
        
        if (url.hasSuffix(AccountRemovalVM.REMOVAL_FINISHED_SUFIX)) {
            if (needsRestart) {
                send(event: .finishAndRestart)
            } else {
                send(event: .finish)
            }
        }
        
        return true
    }
    
    override func provideUrl() -> URL {
        if let server = serverAddress {
            return URL(string: Strings.AccountRemoval.url.replacingOccurrences(of: "{SERVER_ADDRESS}", with: server))!
        } else {
            return URL(string: Strings.AccountRemoval.url.replacingOccurrences(of: "{SERVER_ADDRESS}", with: "cloud.supla.org"))!
        }
    }
    
    override func defaultViewState() -> AccountRemovalViewState { AccountRemovalViewState() }
    
    override func updateLoading(_ loading: Bool) {
        updateView { $0.changing(path: \.loading, to: loading) }
    }
}

enum AccountRemovalViewEvent: ViewEvent {
    case finish
    case finishAndRestart
}

struct AccountRemovalViewState: WebContentViewState {
    var loading: Bool = true
}
