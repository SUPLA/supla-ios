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

class GreenPointLayers: LayerGroup {
    
    var frame: CGRect {
        get { fatalError("Not implemented") }
        set {
            pointShadowShape.frame = newValue
            pointShape.frame = newValue
        }
    }
    
    var isHidden: Bool {
        get { pointShape.isHidden && pointShadowShape.isHidden }
        set {
            pointShape.isHidden = newValue
            pointShadowShape.isHidden = newValue
        }
    }
    
    private lazy var pointShadowShape: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.progressPointShadow.cgColor
        return layer
    }()
    
    private lazy var pointShape: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.primary.cgColor
        return layer
    }()
    
    func move(to position: CGPoint) {
        pointShadowShape.path = UIBezierPath(
            arcCenter: position,
            radius: Dimens.Point.shadowRadius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        ).cgPath
        pointShape.path = UIBezierPath(
            arcCenter: position,
            radius: Dimens.Point.radius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        ).cgPath
    }
    
    func sublayers() -> [CALayer] {
         [pointShadowShape, pointShape]
    }
}
