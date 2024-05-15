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

extension UIView {
    
    public func removeAllConstraints() {
        var _superview = self.superview
        
        while let superview = _superview {
            for constraint in superview.constraints {
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }
            
            _superview = superview.superview
        }
        
        NSLayoutConstraint.deactivate(self.constraints)
        self.removeConstraints(self.constraints)
    }
    
    func drawPath(_ context: CGContext, fillColor: UIColor? = nil, strokeColor: UIColor? = nil, withShadow: Bool = false, _ pathProducer: () -> CGPath) {
        context.beginPath()
        context.addPath(pathProducer())
        if (withShadow) {
            context.setShadow(offset: ShadowValues.offset, blur: ShadowValues.blur)
        } else {
            context.setShadow(offset: .zero, blur: 0)
        }
        if let color = fillColor {
            context.setFillColor(color.cgColor)
            context.drawPath(using: .fill)
        }
        if let color = strokeColor {
            context.setStrokeColor(color.cgColor)
            context.drawPath(using: .stroke)
        }
    }
}
