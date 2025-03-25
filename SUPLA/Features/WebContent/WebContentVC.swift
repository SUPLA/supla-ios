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

@preconcurrency import WebKit

class WebContentVC<S: WebContentViewState, E: ViewEvent, VM: WebContentVM<S, E>>: BaseViewControllerVM<S, E, VM>, WKNavigationDelegate {
    lazy var webView: WKWebView! = {
        let view = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.navigationDelegate = self
        return view
    }()
    
    private lazy var loadingView: LoadingScrimView! = LoadingScrimView()
    
    override init(viewModel: VM) {
        super.init(viewModel: viewModel)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handle(state: S) {
        loadingView.isHidden = !state.loading
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let handle = viewModel.shouldHandle(url: navigationAction.request.url?.absoluteString)
        let handleMessage = handle ? "handle" : "not handle"
        let url = navigationAction.request.url?.absoluteString ?? "nil"
        SALog.debug("Will \(handleMessage) url \(url)")
        
        if (viewModel.shouldHandle(url: navigationAction.request.url?.absoluteString)) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.updateLoading(false)
    }
    
    private func setupView() {
        view.addSubview(webView)
        view.addSubview(loadingView)
        
        webView.load(URLRequest(url: viewModel.provideUrl()))
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
}
