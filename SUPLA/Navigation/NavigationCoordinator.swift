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
protocol NavigationCoordinator {
    @objc var parentCoordinator: NavigationCoordinator? { get }
    
    /// Return a root view controller of this flow
    @objc var viewController: UIViewController { get }
    
    /// Set to true if view controller should be displayed with animations
    @objc var wantsAnimatedTransitions: Bool { get }
    
    /// Return current active coordinator (i.e. the topmost subflow in the stack)
    @objc var currentCoordinator: NavigationCoordinator { get }

    /// Attach this flow to given window
    @objc optional func attach(to window: UIWindow)

    /// Start child navigation flow rooted at this coordinator
    func startFlow(coordinator: NavigationCoordinator)

    /// Start this flow
    @objc func start(from parent: NavigationCoordinator?)

    /// Handle notification that child flow has finished
    func didFinish(coordinator child: NavigationCoordinator)
    
    ///  Called on child after it's finished (so we have new current coordinator)
    func parentDidTakeFlowOver(_ parent: NavigationCoordinator)

    /// Notify a coordinator that controller spawned by it has been dismissed
    func viewControllerDidDismiss(_ viewController: UIViewController)

    /// Finish child flow
    func finish()
    
    /// Indicates that the coordinator is finishing
    var isFinishing: Bool { get }
}

@objc
protocol NavigationCoordinatorAware {
    weak var navigationCoordinator: NavigationCoordinator? { set get }
}


class BaseNavigationCoordinator: NSObject {
    private(set) weak var parentCoordinator: NavigationCoordinator?
    private var children = [NavigationCoordinator]()
    
    private(set) var isFinishing: Bool = false
}

extension BaseNavigationCoordinator: NavigationCoordinator {
    var wantsAnimatedTransitions: Bool {
        return true
    }
    
    var viewController: UIViewController {
        fatalError("needs to be overriden")
    }
    
    var currentCoordinator: NavigationCoordinator {
        return children.last ?? self
    }
    
    func startFlow(coordinator child: NavigationCoordinator) {
        children.append(child)
        child.start(from: self)
    }

    func didFinish(coordinator child: NavigationCoordinator) {
        assert(children.last === child)
        children.removeLast()
        child.parentDidTakeFlowOver(self)
    }
    
    func parentDidTakeFlowOver(_ parent: NavigationCoordinator) {
        // intentionally left empty
    }

    func viewControllerDidDismiss(_ viewController: UIViewController) {
        // intentionally left empty
    }

    func finish() {
        isFinishing = true
        parentCoordinator?.didFinish(coordinator: self)
    }

    func start(from parent: NavigationCoordinator?) {
        assert(parentCoordinator == nil)
        parentCoordinator = parent
    }
}
