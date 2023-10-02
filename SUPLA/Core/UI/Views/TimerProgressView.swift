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

class TimerProgressView: UIView {
    
    private var progress: CGFloat = 0
    var progressPercentage: CGFloat {
        get { progress }
        set {
            if (newValue > 1) {
                progress = 1
            } else if (newValue < 0) {
                progress = 0
            } else {
                progress = newValue
            }
            setNeedsDisplay()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 220, height: 220)
    }
    
    private lazy var circleShape: CAShapeLayer = {
        let layer = CAShapeLayer()
        let path = UIBezierPath(
            arcCenter: CGPoint(x: 110, y: 110),
            radius: 106,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        path.append(
            UIBezierPath(
                arcCenter: CGPoint(x: 110, y: 110),
                radius: 94,
                startAngle: 0,
                endAngle: 2 * .pi,
                clockwise: true
            ).reversing()
        )
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.cgColor
        return layer
    }()
    
    private lazy var progressShape: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineCap = .round
        layer.strokeColor = UIColor.primaryVariant.cgColor
        layer.lineWidth = 6
        layer.shadowRadius = 9
        layer.shadowOpacity = 0.8
        layer.shadowColor = UIColor.primaryVariant.cgColor
        return layer
    }()
    
    private var endPoint = GreenPointLayers()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        circleShape.frame = bounds
        progressShape.frame = bounds
        endPoint.frame = bounds
    }
    
    override func draw(_ rect: CGRect) {
        let alpha = 2 * progress * .pi
        let x = 100 * cos(alpha) + 110
        let y = 100 * sin(alpha) + 110
        
        endPoint.move(to: CGPoint(x: x, y: y))
        
        progressShape.path = UIBezierPath(ovalIn: rect.insetBy(dx: 10, dy: 10)).cgPath
        progressShape.strokeStart = 0
        progressShape.strokeEnd = progress
    }
    
    private func setupView() {
        layer.transform = CATransform3DMakeRotation(CGFloat(90 * Double.pi / 180), 0, 0, -1)
        
        layer.addSublayer(circleShape)
        layer.addSublayer(progressShape)
        layer.addSublayer(endPoint)
    }
}
