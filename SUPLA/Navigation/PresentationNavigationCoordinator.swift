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

/**
 Navigation coordinator to implement presentable flows (i.e. view
 controllers that are presented from other view controllers.
 */
@objc
class PresentationNavigationCoordinator: BaseNavigationCoordinator {
    
    var shouldAnimatePresentation = true
    var isAnimating = false {
        didSet {
            if !isAnimating && shouldFinish {
                finish()
            }
        }
    }
    private var shouldFinish = false
    
    override var wantsAnimatedTransitions: Bool {
        return shouldAnimatePresentation
    }
    
    override var viewController: UIViewController { return _viewController }
    
    private let _viewController: UIViewController
    
    @objc init(viewController: UIViewController) {
        _viewController = viewController
        super.init()
        if let vc = _viewController as? NavigationCoordinatorAware {
            vc.navigationCoordinator = self
        }
    }
    
    override func finish() {
        if isAnimating {
            shouldFinish = true
            return
        }
        if let vc = viewController as? PresentationCoordinatorPeer {
            vc.willFinish() {
                self.parentCoordinator?.didFinish(coordinator: self)
            }
        } else {
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
    
    override func parentDidTakeFlowOver(_ parent: NavigationCoordinator) {
        super.parentDidTakeFlowOver(parent)
        if let vc = viewController as? PresentationCoordinatorPeer {
            vc.didFinish()
        }
    }
}

protocol PresentationCoordinatorPeer {
    func willFinish(_ continuation: @escaping ()->Void)
    func didFinish()
}
