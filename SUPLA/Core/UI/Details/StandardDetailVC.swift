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

class StandardDetailVC<S : ViewState, E : ViewEvent, VM : StandardDetailVM<S, E>> : SuplaTabBarController<S, E, VM> {
    
    @Singleton<RuntimeConfig> private var runtimeConfig
    
    private let remoteId: Int32
    private let pages: [DetailPage]
    
    init(navigator: NavigationCoordinator, viewModel: VM, remoteId: Int32, pages: [DetailPage]) {
        self.remoteId = remoteId
        self.pages = pages
        super.init(navigationCoordinator: navigator, viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.backgroundColor = .background
        
        viewModel.loadChannel(remoteId: remoteId)
        
        setupViewController()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        var openedPage = 0
        if let viewControllers = self.viewControllers {
            for controller in viewControllers {
                if (controller.tabBarItem == item) {
                    break
                }
                openedPage += 1
            }
            
        }
        
        runtimeConfig.setDetailOpenedPage(remoteId: remoteId, openedPage: openedPage)
    }
    
    private func setupViewController() {
        var viewControllers: [UIViewController] = []
        for page in pages {
            switch(page) {
            case .general:
                viewControllers.append(switchGeneral())
            case .timer:
                viewControllers.append(timerDetail())
            case .historyEm:
                viewControllers.append(legacyDetail(type: .em))
            case .historyIc:
                viewControllers.append(legacyDetail(type: .ic))
            case .thermostat:
                viewControllers.append(thermostatGeneral())
            case .schedule:
                viewControllers.append(scheduleDetail())
            }
        }
        
        self.viewControllers = viewControllers
        
        let pageToOpen = runtimeConfig.getDetailOpenedPage(remoteId: remoteId)
        if (pageToOpen < 0 || pageToOpen >= viewControllers.count) {
            self.selectedViewController = viewControllers[0]
        } else {
            self.selectedViewController = viewControllers[pageToOpen]
        }
    }
    
    private func switchGeneral() -> SwitchGeneralVC {
        let vc = SwitchGeneralVC(remoteId: remoteId)
        vc.navigationCoordinator = navigationCoordinator
        vc.tabBarItem = UITabBarItem(
            title: Strings.StandardDetail.tabGeneral,
            image: .iconGeneral,
            tag: DetailTabTag.Switch.rawValue
        )
        return vc
    }
    
    private func timerDetail() -> TimerDetailVC {
        let vc = TimerDetailVC(remoteId: remoteId)
        vc.navigationCoordinator = navigationCoordinator
        vc.tabBarItem = UITabBarItem(
            title: Strings.StandardDetail.tabTimer,
            image: .iconTimer,
            tag: DetailTabTag.Timer.rawValue
        )
        return vc
    }
    
    private func legacyDetail(type: LegacyDetailType) -> DetailViewController {
        let vc = DetailViewController(detailViewType: type, remoteId: remoteId)
        vc.navigationCoordinator = navigationCoordinator
        vc.tabBarItem = UITabBarItem(
            title: Strings.StandardDetail.tabMetrics,
            image: .iconMetrics,
            tag: DetailTabTag.History.rawValue
        )
        return vc
    }
    
    private func thermostatGeneral() -> ThermostatGeneralVC {
        let vc = ThermostatGeneralVC(remoteId: remoteId)
        vc.navigationCoordinator = navigationCoordinator
        vc.tabBarItem = UITabBarItem(
            title: Strings.StandardDetail.tabGeneral,
            image: .iconGeneral,
            tag: DetailTabTag.Thermostat.rawValue
        )
        return vc
    }
    
    private func scheduleDetail() -> ScheduleDetailVC {
        let vc = ScheduleDetailVC(remoteId: remoteId)
        vc.navigationCoordinator = navigationCoordinator
        vc.tabBarItem = UITabBarItem(
            title: Strings.StandardDetail.tabSchedule,
            image: .iconSchedule,
            tag: DetailTabTag.Schedule.rawValue
        )
        return vc
    }
}

fileprivate enum DetailTabTag: Int {
    case Switch = 1
    case Timer = 2
    case History = 3
    case Thermostat = 4
    case Schedule = 5
}
