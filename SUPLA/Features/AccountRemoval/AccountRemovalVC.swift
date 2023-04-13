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
import UIKit
import WebKit

class AccountRemovalVC : BaseViewControllerVM<AccountRemovalViewState, AccountRemovalViewEvent, AccountRemovalVM>, WKUIDelegate {
    
    private var navigator: AccountRemovalNavigationCoordinator? {
        get {
            navigationCoordinator as? AccountRemovalNavigationCoordinator
        }
    }
    
    private var webView: WKWebView!
    
    convenience init(navigationCoordinator: NavigationCoordinator, needsRestart: Bool, serverAddress: String?) {
        self.init(nibName: nil, bundle: nil)
        self.navigationCoordinator = navigationCoordinator
        
        viewModel = AccountRemovalVM(needsRestart: needsRestart, serverAddress: serverAddress)
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: viewModel.provideUrl())!
        let urlRequet = URLRequest(url: url)
        webView.load(urlRequet)
    }
    
    override func handle(event: AccountRemovalViewEvent) {
        switch(event) {
        case .finishAndRestart:
            navigator?.finishWithRestart()
        case .finish:
            navigator?.finish()
            break
        }
    }
}

extension AccountRemovalVC : WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        viewModel.handleUrl(url: navigationAction.request.url?.absoluteString)
        decisionHandler(.allow)
    }
}
