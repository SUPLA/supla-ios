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

class FadeTransition: NSObject {
    
    private let isPresenting: Bool
    private let duration = TimeInterval(0.25)
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }
}

extension FadeTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let vfrom = transitionContext.view(forKey: .from),
              let vto = transitionContext.view(forKey: .to) else {
                  return
        }
        let container = transitionContext.containerView

        vto.alpha = 0;
        if isPresenting {
            container.addSubview(vto)
        } else {
            container.insertSubview(vto, belowSubview: vfrom)
        }
        
        UIView.animate(withDuration: duration, animations: {
            vto.alpha = 1.0
            vfrom.alpha = 0
        }) { completed in
            transitionContext.completeTransition(completed)
        }
        
    }
    
    
}
