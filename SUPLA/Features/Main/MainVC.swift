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

class MainVC : SuplaTabBarController<MainViewState, MainViewEvent, MainViewModel> {
    
    @Singleton<GlobalSettings> private var settings
    @Singleton<SuplaAppCoordinator> private var coordinator
    
    private let notificationView: NotificationView = NotificationView()
    private let newGestureInfoView: NewGestureInfoView = NewGestureInfoView()
    private var notificationViewHeightConstraint: NSLayoutConstraint? = nil
    
    private var notificationTimer: Timer? = nil
    private var profileChooser: ProfileChooser? = nil
    
    private var iconsDownloadTask: SADownloadUserIcons? = nil
    
    init() {
        super.init(viewModel: MainViewModel())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Strings.NavBar.titleSupla
        
        setupTabBarController()
        setupToolbar()
        setupNotificationView()
        setupNewGestureInfoView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewAppear()
        showNewGestureInfoView()
        SARateApp().showDialog(withDelay: 1)
        updateBottomBarLabels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.onViewDisappear()
    }
    
    override func handle(state: MainViewState) {
        if (state.showProfilesIcon) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "profile-navbar"),
                style: .plain,
                target: self,
                action: #selector(onProfileButton)
            )
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func handle(event: MainViewEvent) {
        switch(event) {
        case let .showNotification(message: message, icon: icon):
            showNotification(message: message, image: icon)
            break
        case .loadIcons:
            runIconsDownloadTask()
            break;
        }
    }
    
    // MARK: View controller setup
    
    private func setupToolbar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "menu"),
            style: .plain, target: self,
            action: #selector(onMenuToggle)
        )
    }
    
    private func setupTabBarController() {
        let channelListVC = ChannelListVC()
        channelListVC.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.Main.channels : nil,
            image: UIImage(named: "list"),
            tag: HomeTabTag.Channels.rawValue
        )
        channelListVC.navigationBarMaintainedByParent = true
        let groupListVC = GroupListVC()
        groupListVC.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.Main.groups : nil,
            image: UIImage(named: "bottom_bar_groups"),
            tag: HomeTabTag.Groups.rawValue
        )
        groupListVC.navigationBarMaintainedByParent = true
        let sceneListVC = SceneListVC()
        sceneListVC.tabBarItem = UITabBarItem(
            title: settings.showBottomLabels ? Strings.Main.scenes : nil,
            image: UIImage(named: "coffee"),
            tag: HomeTabTag.Scenes.rawValue
        )
        sceneListVC.navigationBarMaintainedByParent = true
        
        self.viewControllers = [channelListVC, groupListVC, sceneListVC]
    }
    
    // MARK: Notifications setup
    
    private func setupNotificationView() {
        view.addSubview(notificationView)
        
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        notificationView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        notificationView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        notificationView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        notificationViewHeightConstraint = notificationView.heightAnchor.constraint(equalToConstant: 0)
        notificationViewHeightConstraint?.isActive = true
        notificationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onNotificationiTapped)))
        
    }
    
    private func showNewGestureInfoView() {
        if (!settings.newGestureInfoShown && settings.shouldShowNewGestureInfo) {
            newGestureInfoView.isHidden = false
        }
    }
    
    private func updateBottomBarLabels() {
        viewControllers?.forEach {
            if let channels = $0 as? ChannelListVC {
                channels.tabBarItem.title = settings.showBottomLabels ? Strings.Main.channels : nil
            }
            if let groups = $0 as? GroupListVC {
                groups.tabBarItem.title = settings.showBottomLabels ? Strings.Main.groups : nil
            }
            if let scenes = $0 as? SceneListVC {
                scenes.tabBarItem.title = settings.showBottomLabels ? Strings.Main.scenes : nil
            }
        }
    }
    
    private func setupNewGestureInfoView() {
        view.addSubview(newGestureInfoView)
        
        newGestureInfoView.translatesAutoresizingMaskIntoConstraints = false
        newGestureInfoView.delegate = self
        NSLayoutConstraint.activate([
            newGestureInfoView.topAnchor.constraint(equalTo: view.topAnchor),
            newGestureInfoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            newGestureInfoView.leftAnchor.constraint(equalTo: view.leftAnchor),
            newGestureInfoView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func showNotification(message: String, image: UIImage) {
        notificationTimer?.invalidate()
        notificationTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hideNotification), userInfo: nil, repeats: false)
        
        notificationView.icon = image
        notificationView.text = message
        
        view.layoutIfNeeded()
        notificationViewHeightConstraint?.constant = getNotificationHeight()
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func getNotificationHeight() -> CGFloat {
        if #available(iOS 11, *),
            let keyWindow = UIApplication.shared.keyWindow,
            keyWindow.safeAreaInsets.bottom > 0 {
            return 140
        } else {
            return 110
        }
    }
    
    // MARK: Action handlers
    
    @objc
    private func onMenuToggle() {
        coordinator.showMenu()
    }
    
    @objc
    private func onProfileButton() {
        if (profileChooser != nil) {
            return // Chooser already opened
        }
        
        profileChooser = ProfileChooser(profileManager: SAApp.profileManager())
        profileChooser?.delegate = self
        profileChooser?.show(from: navigationController!)
    }
    
    @objc
    private func hideNotification() {
        notificationTimer?.invalidate()
        
        view.layoutIfNeeded()
        notificationViewHeightConstraint?.constant = 0
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc
    private func onNotificationiTapped(recognizer: UITapGestureRecognizer? = nil) {
        hideNotification()
    }
    
    // MARK: Downloading user icons
    
    private func runIconsDownloadTask() {
        if (iconsDownloadTask != nil && !iconsDownloadTask!.isTaskIsAlive(withTimeout: 90)) {
            iconsDownloadTask?.cancel()
            iconsDownloadTask?.delegate = nil
            iconsDownloadTask = nil
        }
        
        if (iconsDownloadTask == nil) {
            iconsDownloadTask = SADownloadUserIcons()
            iconsDownloadTask?.delegate = self
            iconsDownloadTask?.start()
        }
    }
}

extension MainVC: ProfileChooserDelegate {
    func profileChooserDidDismiss(profileChanged: Bool) {
        profileChooser = nil
    }
}

extension MainVC: SARestApiClientTaskDelegate {
    func onRestApiTaskFinished(_ task: SARestApiClientTask) {
        if (iconsDownloadTask == task) {
            iconsDownloadTask?.delegate = nil
            iconsDownloadTask = nil
        }
    }
}

extension MainVC: NewGestureInfoDelegate {
    func onCloseTapped() {
        var settings = settings
        settings.newGestureInfoShown = true
        newGestureInfoView.isHidden = true
    }
}

enum HomeTabTag: Int {
    case Channels = 1
    case Groups = 2
    case Scenes = 3
}
