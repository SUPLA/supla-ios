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


import UIKit

@objc
class DetailViewController: BaseViewController {
    
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    
    var interactionController: UIViewControllerInteractiveTransitioning? {
        return _panController
    }
    
    private var _detailView: SADetailView!
    private var _panController: UIPercentDrivenInteractiveTransition?
    private var inNewDetail = false
    
    init(detailViewType: LegacyDetailType, channelBase: SAChannelBase) {
        super.init(nibName: nil, bundle: nil)
        _detailView = self.detailView(forDetailType: detailViewType)!
        _detailView.detailViewInit()
        _detailView.channelBase = channelBase
        
        _detailView.viewController = self
    }
    
    init(detailViewType: LegacyDetailType, remoteId: Int32) {
        super.init(nibName: nil, bundle: nil)
        _detailView = self.detailView(forDetailType: detailViewType)!
        _detailView.detailViewInit()
        _detailView.channelBase = try! readChannelByRemoteIdUseCase.invoke(remoteId: remoteId).subscribeSynchronous()
        
        _detailView.viewController = self
        
        inNewDetail = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if (inNewDetail) {
            statusBarBackgroundView.isHidden = true
            view.addSubview(_detailView)
            _detailView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        } else {
            addChildView(_detailView)
            title = _detailView.channelBase?.getNonEmptyCaption() ?? ""
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onAppDidEnterBackground(_:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _detailView.detailWillShow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _detailView.detailDidShow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _detailView.detailWillHide()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _detailView.detailDidHide()
    }
    
    override func shouldUpdateTitleFont() -> Bool { true }
    
    @objc private func onAppDidEnterBackground(_ notification: Notification) {
        // Hide detail view, when application loses foreground context
        navigationController?.popViewController(animated: false)
    }
    
    private func detailView(forDetailType detailType: LegacyDetailType) -> SADetailView? {
        switch(detailType) {
        case .em:
            return Bundle.main.loadNibNamed("ElectricityMeterDetailView", owner: self, options: nil)?[0] as? SADetailView
        case .ic:
            return Bundle.main.loadNibNamed("ImpulseCounterDetailView", owner: self, options: nil)?[0] as? SADetailView
        case .rgbw:
            return Bundle.main.loadNibNamed("RGBWDetail", owner: self, options: nil)?[0] as? SADetailView
        case .rs:
            return Bundle.main.loadNibNamed("RSDetail", owner: self, options: nil)?[0] as? SADetailView
        case .thermostat_hp:
            return Bundle.main.loadNibNamed("HomePlusDetailView", owner: self, options: nil)?[0] as? SADetailView
        case .temperature:
            return Bundle.main.loadNibNamed("TemperatureDetailView", owner: self, options: nil)?[0] as? SADetailView
        case .temperature_humidity:
            return Bundle.main.loadNibNamed("TempHumidityDetailView", owner: self, options: nil)?[0] as? SADetailView
        case .digiglass:
            return Bundle.main.loadNibNamed("DigiglassDetailView", owner: self, options: nil)?[0] as? SADetailView
        }
    }
}
