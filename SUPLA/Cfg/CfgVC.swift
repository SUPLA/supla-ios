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
import RxSwift
import RxSwiftExt

class CfgVC: BaseViewController {
    
    private(set) var vM: CfgVM!
    
    private enum Settings: Int, CaseIterable {
        case channelHeight
        case temperatureUnit
        case buttonAutoHide
        case showChannelInfo
        case locationOrdering
        
        static var allCases: [Settings] {
            var rv: [Settings] = [.channelHeight, .temperatureUnit,
                                  .buttonAutoHide, .showChannelInfo]
            if #available(iOS 11.0, *) {
                rv.append(.locationOrdering)
            }
            return rv
        }
    }
    
    private var channelHeightControl: UISegmentedControl!
    private var temperatureUnitControl: UISegmentedControl!

    private let buttonAutoHideControl = UISwitch()
    private let showChannelInfoControl = UISwitch()
    private let chevronRightControl = UIImageView(image: UIImage(named: "ChevronRight"))
    
    private let disposeBag = DisposeBag()
    private let dismissCmd = PublishSubject<Void>()
    let openLocalizationOrderingCmd = PublishSubject<Void>()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        self.title = Strings.Cfg.appConfigTitle
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tv = UITableView(frame: .zero, style: .grouped)
        
        view.addSubview(tv)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tv.dataSource = self
        tv.delegate = self
        
        let segmentWidth = CGFloat(60) // source: figma design
        let channels = [ "channel_height_small", "channel_height_normal",
                         "channel_height_big" ]
        let ch = UISegmentedControl(items: channels.map { UIImage(named: $0)! })
        channels.enumerated().forEach { (i, _) in
            ch.setWidth(segmentWidth, forSegmentAt: i)
        }
        channelHeightControl = ch
        
        let units = TemperatureUnit.allCases
        temperatureUnitControl = UISegmentedControl(items: units.map { $0.symbol })
        units.enumerated().forEach { (i,_) in
            temperatureUnitControl.setWidth(segmentWidth, forSegmentAt: i)
        }
        
        chevronRightControl.tintColor = .suplaGreen
        

        let inputs = CfgVM.Inputs(channelHeight: channelHeightControl.rx.selectedSegmentIndex.map({ ChannelHeight.allCases[max(0,$0)] }).asObservable(),
                                  temperatureUnit: temperatureUnitControl.rx.selectedSegmentIndex.map({ TemperatureUnit.allCases[max(0,$0)]}).asObservable(),
                                  autoHideButtons: buttonAutoHideControl.rx.isOn.asObservable(),
                                  showChannelInfo: showChannelInfoControl.rx.isOn.asObservable(),
                                  onDismiss: dismissCmd.asObservable())

        vM = CfgVM(inputs: inputs, configModel: Config())
        vM.channelHeight.map({ ch in ChannelHeight.allCases.enumerated().first(where: { $0.element == ch })!.offset}).bind(to: channelHeightControl.rx.selectedSegmentIndex).disposed(by: disposeBag)
        vM.temperatureUnit.map({ tu in TemperatureUnit.allCases.enumerated().first(where: { $0.element == tu})!.offset})
            .bind(to: temperatureUnitControl.rx.selectedSegmentIndex).disposed(by: disposeBag)
        vM.autoHideButtons.bind(to: buttonAutoHideControl.rx.isOn).disposed(by: disposeBag)
        vM.showChannelInfo.bind(to: showChannelInfoControl.rx.isOn).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onBackButtonPressed(_:)),
                                               name: Notification.Name(kSAMenubarBackButtonPressed),
                                               object: nil)
    }
    
    @objc private func onBackButtonPressed(_ n: Notification) {
        dismissCmd.on(.next(()))
        // FIXME: needs new solution
//        SAApp.ui().invalidateMainVC()
//        SAApp.ui().showMainVC()
    }
    
    private func cellForSetting(_ setting: Settings) -> UITableViewCell {
        let cell = CfgCell()

        let actionView: UIView
        let label: String

        switch setting {
        case .buttonAutoHide:
            label = Strings.Cfg.buttonAutoHide
            actionView = buttonAutoHideControl
        case .channelHeight:
            label = Strings.Cfg.channelHeight
            actionView = channelHeightControl
        case .temperatureUnit:
            label = Strings.Cfg.temperatureUnit
            actionView = temperatureUnitControl
        case .showChannelInfo:
            label = Strings.Cfg.showChannelInfo
            actionView = showChannelInfoControl
        case .locationOrdering:
            label = Strings.Cfg.locationOrdering
            actionView = chevronRightControl
        }
        
        cell.titleLabel.text = label
        cell.actionView = actionView

        return cell
    }
}

extension CfgVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Strings.Cfg.appConfigTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Settings.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingType = Settings(rawValue: indexPath.row)!
        return cellForSetting(settingType)
    }

}

extension CfgVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let row = Settings(rawValue: indexPath.row), row == .locationOrdering {
            openLocalizationOrderingCmd.on(.next(()))
        }
    }
}
