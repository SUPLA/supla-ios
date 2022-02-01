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

class SwipeTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Direction {
        case slideIn
        case slideOut
    }
    
    private let _direction: Direction
    var interactionController: UIViewControllerInteractiveTransitioning?
    
    init(direction: Direction) {
        _direction = direction
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = self.transitionDuration(using: transitionContext)
        if _direction == .slideOut, let fromVC = transitionContext.viewController(forKey: .from),
           let toVC = transitionContext.viewController(forKey: .to),
           let newView = toVC.view, let oldView = fromVC.view {
            let ff = transitionContext.finalFrame(for: toVC)
            newView.frame = ff.offsetBy(dx: -ff.width, dy: 0)
            transitionContext.containerView.addSubview(newView)
            UIView.animate(withDuration: duration, animations: {
                newView.frame = ff
                oldView.frame = oldView.frame.offsetBy(dx: ff.width, dy: 0)
            }, completion: { completed in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        } else if _direction == .slideIn,
                    let newVC = transitionContext.viewController(forKey: .to),
                  let oldVC = transitionContext.viewController(forKey: .from),
                  let newView = newVC.view, let oldView = oldVC.view {
            let ff = transitionContext.finalFrame(for: newVC)
            transitionContext.containerView.addSubview(newView)
            newView.frame = ff.offsetBy(dx: ff.width, dy: 0)
            UIView.animate(withDuration: duration) {
                newView.frame = ff
                oldView.frame = ff.offsetBy(dx: -ff.width, dy: 0)
            } completion: { completed in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
