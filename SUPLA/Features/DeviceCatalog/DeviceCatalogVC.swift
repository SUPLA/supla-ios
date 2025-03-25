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
import WebKit

class DeviceCatalogVC: WebContentVC<DeviceCatalogViewState, DeviceCatalogViewEvent, DeviceCatalogVM> {
    @Singleton<SuplaAppCoordinator> private var coordinator
    
    private var userInterfaceStyle: UIUserInterfaceStyle? = nil

    init() {
        super.init(viewModel: DeviceCatalogVM())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Strings.DeviceCatalog.menu
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)
        webView.evaluateJavaScript("document.body.classList.add('mobile');")
        
        userInterfaceStyle = traitCollection.userInterfaceStyle
        if (userInterfaceStyle == .dark) {
            webView.evaluateJavaScript("document.body.classList.add('darkTheme');")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if (userInterfaceStyle != traitCollection.userInterfaceStyle) {
            self.userInterfaceStyle = traitCollection.userInterfaceStyle
            
            switch (self.userInterfaceStyle) {
            case .dark: webView.evaluateJavaScript("document.body.classList.add('darkTheme');")
            case .light: webView.evaluateJavaScript("document.body.classList.remove('darkTheme');")
            default: break
            }
        }
    }
    
    override func handle(event: DeviceCatalogViewEvent) {
        switch (event) {
        case .openUrl(let url):
            coordinator.openUrl(url: url)
        }
    }
}

extension DeviceCatalogVC: NavigationSubcontroller {
    func screenTakeoverAllowed() -> Bool { false }
}
