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
    
    var interactionController: UIViewControllerInteractiveTransitioning? {
        return _panController
    }
    
    private var _detailView: SADetailView!
    private let _panGR = UIPanGestureRecognizer()
    private var _panController: UIPercentDrivenInteractiveTransition?
    
    init(detailViewType: LegacyDetailType, channelBase: SAChannelBase) {
        super.init(nibName: nil, bundle: nil)
        _detailView = self.detailView(forDetailType: detailViewType)!
        _detailView.detailViewInit()
        _detailView.channelBase = channelBase
        
        _panGR.addTarget(self, action: #selector(onPan(_:)))
        _detailView.addGestureRecognizer(_panGR)
        _detailView.viewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView(_detailView)
        
        title = _detailView.channelBase.getNonEmptyCaption()
        
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
    
    @objc private func onPan(_ gr: UIPanGestureRecognizer) {
        switch gr.state {
        case .began:
            _panController = UIPercentDrivenInteractiveTransition()
            navigationController?.popViewController(animated: true)
        case .changed:
            let translation = gr.translation(in: _detailView)
            let d = translation.x / view.bounds.width
            _panController?.update(d)
        case .ended:
            if let _panController = _panController {
                if _panController.percentComplete > 0.28 {
                    _panController.finish()
                } else {
                    _panController.cancel()
                }
            }
            _panController = nil
        default: break
        }
    }
    
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
