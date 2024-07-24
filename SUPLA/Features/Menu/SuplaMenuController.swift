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

class SuplaMenuController: UIViewController {
    @Singleton<SuplaAppCoordinator> private var coordinator
    
    private let _menuItems = SAMenuItems()
    private let _fakeConstraint = NSLayoutConstraint()
    private let _tapGR = UITapGestureRecognizer()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.addSubview(_menuItems)
                
        if SAApp.db().zwaveBridgeChannelAvailable() {
            _menuItems.buttonsAvailable = SAMenuItemIds.all
        } else {
            _menuItems.buttonsAvailable = SAMenuItemIds.all.subtracting(.zWave)
        }
        _menuItems.delegate = self
        
        _tapGR.addTarget(self, action: #selector(onMenuDismiss(_:)))
        _tapGR.delegate = self
        view.addGestureRecognizer(_tapGR)
    }
    
    override func viewDidLayoutSubviews() {
        if let navctrl = presentingViewController as? UINavigationController {
            let navbar = navctrl.navigationBar
            _fakeConstraint.constant = navbar.frame.origin.y + navbar.frame.size.height
            _menuItems.menuBarHeight = _fakeConstraint
        }
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let v = navBarSnapshotView()
        _menuItems.slideDown(true) {
            v.removeFromSuperview()
        }
    }
    
    @objc private func onMenuDismiss(_ gr: UIGestureRecognizer) {
        gr.isEnabled = false
        let v = navBarSnapshotView()
        _menuItems.slideDown(false) { [weak self] in
            v.removeFromSuperview()
            self?.coordinator.dismiss()
        }
    }
    
    // Insert a static snapshot for navbar/status bar area, as a
    // coverup for menu slide up/down animation.
    private func navBarSnapshotView() -> UIView {
        var navFrame = findNavigationControlelr()!.navigationBar.frame
        navFrame.size.height = navFrame.maxY
        navFrame.origin.y = 0
        UIGraphicsBeginImageContext(navFrame.size)
        let ctx = UIGraphicsGetCurrentContext()!
        currentWindow().layer.render(in: ctx)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let v = UIImageView(image: img)
        view.addSubview(v)
        return v
    }
    
    private func findNavigationControlelr() -> UINavigationController? {
        return (presentingViewController as? UINavigationController) ??
            presentingViewController?.navigationController
    }
    
    private func currentWindow() -> UIWindow {
        var cv = view
        repeat {
            if let wnd = cv as? UIWindow { return wnd }
            cv = cv?.superview
        } while (cv != nil)
        fatalError("currentWindow() called when not attached to window")
    }
}

extension SuplaMenuController: SAMenuItemsDelegate {
    func menuItemTouched(_ btnId: SAMenuItemIds) {
        coordinator.dismiss() { [weak self] in
            guard let self = self else { return }
            
            switch btnId {
            case .settings:
                self.coordinator.navigateToSettings()
            case .profile:
                self.coordinator.navigateToProfiles()
            case .addDevice:
                self.coordinator.navigateToAddWizard()
            case .about:
                self.coordinator.navigateToAbout()
            case .help:
                self.coordinator.openForum()
            case .homepage:
                self.coordinator.openUrl(url: self._menuItems.homepageUrl)
            case .cloud:
                self.coordinator.openCloud()
            case .zWave:
                SAZWaveConfigurationWizardVC.globalInstance().show()
            case .notifications:
                self.coordinator.navigateToNotificationsLog()
            case .deviceCatalog:
                self.coordinator.navigateToDeviceCatalog()
            default: break
            }
        }
    }
}

extension SuplaMenuController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gr: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == _menuItems {
            return false
        } else {
            return true
        }
    }
}
