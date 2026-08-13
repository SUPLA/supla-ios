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
import UIKit

@objc
class LegacyDimmerSettingsVC: SuplaCore.NavigableBaseViewController {
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<GetCaptionUseCase> private var getCaptionUseCase
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private lazy var detailView = {
        let view = Bundle.main.loadNibNamed("RGBWDetail", owner: self, options: nil)!.first as? SADetailView
        view?.detailViewInit()
        view?.viewController = self
        view?.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let remoteId: Int32
    private let disposeBag = DisposeBag()
    
    init(remoteId: Int32) {
        self.remoteId = remoteId
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .background
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let detailView else { return }
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem.back(target: self, action: #selector(onBack))
        view.addSubview(detailView)
        
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            detailView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
            detailView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0),
            detailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onAppDidEnterBackground(_:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                
                self.title = self.getCaptionUseCase.invoke(data: $0.shareable).string
                self.detailView?.channelBase = $0
                self.detailView?.detailWillShow()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detailView?.detailWillHide()
    }

    func handleBack() {
        onBack()
    }
    
    @objc private func onAppDidEnterBackground(_ notification: Notification) {
        // Hide detail view, when application loses foreground context
        AppRouterLegacyWrapper.finish()
    }
    
    @objc private func onBack() {
        detailView?.onMenubarBackButtonPressed()
    }
}
