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
    
    func drawGlass(_ context: CGContext, _ glassRect: CGRect, _ colors: [CGColor]) {
        context.saveGState()
        
        context.beginPath()
        context.addRect(glassRect)
        context.closePath()
        context.clip()
    
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let startPoint = CGPoint(x: 0, y: glassRect.minY)
        let endPoint = CGPoint(x: 0, y: glassRect.maxY)
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        context.fillPath()
        
        context.restoreGState()
    }
}
