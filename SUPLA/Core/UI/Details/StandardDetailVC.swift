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

class StandardDetailVC<S: ViewState, E: ViewEvent, VM: StandardDetailVM<S, E>>: SuplaTabBarController<S, E, VM>, NavigationItemProvider {
    @Singleton<RuntimeConfig> private var runtimeConfig
    @Singleton<GlobalSettings> private var settings
    
    private let item: ItemBundle
    private let pages: [DetailPage]
    
    init(viewModel: VM, item: ItemBundle, pages: [DetailPage]) {
        self.item = item
        self.pages = pages
        super.init(viewModel: viewModel)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadData(remoteId: item.remoteId, type: item.subjectType)
        
        setupViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupToolbar()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        var openedPage = 0
        if let viewControllers = viewControllers {
            for controller in viewControllers {
                if (controller.tabBarItem == item) {
                    break
                }
                openedPage += 1
            }
        }
        
        runtimeConfig.setDetailOpenedPage(remoteId: self.item.remoteId, openedPage: openedPage)
    }
    
    private func setupViewController() {
        var viewControllers: [UIViewController] = []
        for page in pages {
            switch (page) {
            case .switchGeneral:
                viewControllers.append(switchGeneral())
            case .switchTimer:
                viewControllers.append(switchTimerDetail())
            case .impulseCounterGeneral:
                viewControllers.append(impulseCounterGeneralDetail())
            case .impulseCounterHistory:
                viewControllers.append(impulseCounterHistoryDetail())
            case .impulseCounterOcr:
                viewControllers.append(impulseCounterOcrDetail())
            case .thermostatGeneral:
                viewControllers.append(thermostatGeneral())
            case .thermostatList:
                viewControllers.append(thermostatList())
            case .schedule:
                viewControllers.append(scheduleDetail())
            case .thermostatHistory:
                viewControllers.append(thermostatHistoryDetail())
            case .thermometerHistory:
                viewControllers.append(thermometerHistoryDetail())
            case .thermostatTimer:
                viewControllers.append(thermostatTimerDetail())
            case .gpmHistory:
                viewControllers.append(gpmHistoryDetail())
            case .rollerShutter:
                viewControllers.append(rollerShutterDetail())
            case .roofWindow:
                viewControllers.append(roofWindowDetail())
            case .facadeBlind:
                viewControllers.append(facadeBlindDetail())
            case .terraceAwning:
                viewControllers.append(terraceAwningDetail())
            case .projectorScreen:
                viewControllers.append(projectorScreenDetail())
            case .curtain:
                viewControllers.append(curtainDetail())
            case .verticalBlind:
                viewControllers.append(verticalBlindDetail())
            case .garageDoor:
                viewControllers.append(garageDoorDetail())
            case .electricityMeterGeneral:
                viewControllers.append(electricityMeterGeneralDetail())
            case .electricityMeterHistory:
                viewControllers.append(electricityMeterHistoryDetail())
            case .electricityMeterSettings:
                viewControllers.append(electricityMeterSettingsDetail())
            case .humidityHistory:
                viewControllers.append(humidityHistoryDetail())
            }
        }
        
        self.viewControllers = viewControllers
        
        let pageToOpen = runtimeConfig.getDetailOpenedPage(remoteId: item.remoteId)
        if (pageToOpen < 0 || pageToOpen >= viewControllers.count) {
            selectedViewController = viewControllers[0]
        } else {
            selectedViewController = viewControllers[pageToOpen]
        }
        
        tabBar.isHidden = pages.count == 1
    }
    
    private func switchGeneral() -> SwitchGeneralVC {
        let vc = SwitchGeneralVC(remoteId: item.remoteId)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.Switch.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func switchTimerDetail() -> SwitchTimerDetailVC {
        let vc = SwitchTimerDetailVC(remoteId: item.remoteId)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabTimer : nil,
            image: .iconTimer,
            tag: DetailTabTag.Timer.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func legacyDetail(type: LegacyDetailType) -> DetailViewController {
        let vc = DetailViewController(detailViewType: type, remoteId: item.remoteId)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabMetrics : nil,
            image: .iconMetrics,
            tag: DetailTabTag.History.rawValue
        )
        return vc
    }
    
    private func thermostatGeneral() -> ThermostatGeneralVC {
        let vc = ThermostatGeneralVC(item: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.Thermostat.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func thermostatList() -> UIViewController {
        let vc = ThermostatSlavesFeature.ViewController.create(item: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabList : nil,
            image: .iconList,
            tag: DetailTabTag.List.rawValue
        )
        return vc
    }
    
    private func scheduleDetail() -> ScheduleDetailVC {
        let vc = ScheduleDetailVC(item: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabSchedule : nil,
            image: .iconSchedule,
            tag: DetailTabTag.Schedule.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func thermostatHistoryDetail() -> ThermostatHistoryDetailVC {
        let vc = ThermostatHistoryDetailVC(remoteId: item.remoteId, navigationItemProvider: self)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabHistory : nil,
            image: .iconHistory,
            tag: DetailTabTag.ThermostatHistory.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func thermometerHistoryDetail() -> ThermometerHistoryDetailVC {
        let vc = ThermometerHistoryDetailVC(remoteId: item.remoteId, navigationItemProvider: self)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabHistory : nil,
            image: .iconHistory,
            tag: DetailTabTag.ThermostatHistory.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func thermostatTimerDetail() -> ThermostatTimerDetailVC {
        let vc = ThermostatTimerDetailVC(remoteId: item.remoteId)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabTimer : nil,
            image: .iconTimer,
            tag: DetailTabTag.Timer.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func gpmHistoryDetail() -> GpmHistoryDetailVC {
        let vc = GpmHistoryDetailVC(remoteId: item.remoteId, navigationItemProvider: self)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabHistory : nil,
            image: .iconHistory,
            tag: DetailTabTag.History.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func rollerShutterDetail() -> RollerShutterVC {
        let vc = RollerShutterVC(itemBundle: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.Window.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func roofWindowDetail() -> RoofWindowVC {
        let vc = RoofWindowVC(itemBundle: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.Window.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func facadeBlindDetail() -> FacadeBlindsVC {
        let vc = FacadeBlindsVC(itemBundle: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.Window.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func terraceAwningDetail() -> TerraceAwningVC {
        let vc = TerraceAwningVC(itemBundle: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.Window.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func projectorScreenDetail() -> ProjectorScreenVC {
        let vc = ProjectorScreenVC(itemBundle: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.Window.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func curtainDetail() -> CurtainVC {
        let vc = CurtainVC(itemBundle: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.Window.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func verticalBlindDetail() -> VerticalBlindsVC {
        let vc = VerticalBlindsVC(itemBundle: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.Window.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func garageDoorDetail() -> GarageDoorVC {
        let vc = GarageDoorVC(itemBundle: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.Window.rawValue
        )
        vc.navigationBarMaintainedByParent = true
        return vc
    }
    
    private func electricityMeterGeneralDetail() -> UIViewController {
        let vc = ElectricityMeterGeneralFeature.ViewController.create(item: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.General.rawValue
        )
        return vc
    }
    
    private func electricityMeterHistoryDetail() -> UIViewController {
        let vc = ElectricityMeterHistoryFeature.ViewController.create(item: item, navigationItemProvider: self)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabHistory : nil,
            image: .iconHistory,
            tag: DetailTabTag.History.rawValue
        )
        return vc
    }
    
    private func electricityMeterSettingsDetail() -> UIViewController {
        let vc = ElectricityMeterSettingsFeature.ViewController.create(item: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabSettings : nil,
            image: .iconSettings,
            tag: DetailTabTag.History.rawValue
        )
        return vc
    }
    
    private func humidityHistoryDetail() -> UIViewController {
        let vc = HumidityHistoryDetailVC(remoteId: item.remoteId, navigationItemProvider: self)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabSettings : nil,
            image: .iconSettings,
            tag: DetailTabTag.History.rawValue
        )
        return vc
    }
    
    private func impulseCounterHistoryDetail() -> UIViewController {
        let vc = ImpulseCounterHistoryDetailVC(remoteId: item.remoteId, navigationItemProvider: self)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabHistory : nil,
            image: .iconHistory,
            tag: DetailTabTag.History.rawValue
        )
        return vc
    }
    
    private func impulseCounterGeneralDetail() -> UIViewController {
        let vc = ImpulseCounterGeneralFeature.ViewController.create(item: item)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabGeneral : nil,
            image: .iconGeneral,
            tag: DetailTabTag.General.rawValue
        )
        return vc
    }
    
    private func impulseCounterOcrDetail() -> UIViewController {
        let vc = CounterPhotoFeature.ViewController.create(channelId: item.remoteId)
        vc.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.StandardDetail.tabOcr : nil,
            image: .iconOcrPhoto,
            tag: DetailTabTag.Ocr.rawValue
        )
        return vc
    }
}

protocol NavigationItemProvider: AnyObject {
    var navigationItem: UINavigationItem { get }
}

private enum DetailTabTag: Int {
    case General = 0
    case Switch = 1
    case Timer = 2
    case History = 3
    case Thermostat = 4
    case Schedule = 5
    case ThermostatHistory = 6
    case Window = 7
    case List = 8
    case Ocr = 9
}
