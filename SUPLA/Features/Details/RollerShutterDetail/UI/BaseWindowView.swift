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

import RxRelay
import RxSwift

class BaseWindowView: UIView {
    var isEnabled: Bool = false
    
    var touchRect: CGRect {
        get { fatalError("Not implemented!") }
    }
    
    var position: CGFloat = 0
    
    var bottomPosition: CGFloat = 100
    
    var markers: [CGFloat] = []
    
    var isMoving: Bool { startPosition != nil }
    
    fileprivate let positionRelay: PublishRelay<CGFloat> = PublishRelay()
    fileprivate let positionChangeRelay: PublishRelay<CGFloat> = PublishRelay()
    
    // Touch handling
    private var startPosition: CGPoint? = nil
    private var startPercentage: CGFloat? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = event?.allTouches?.first?.location(in: self) else { return }
        if (isEnabled && touchRect.contains(point)) {
            startPosition = point
            startPercentage = position
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let startPosition = startPosition,
              let startPercentage = startPercentage,
              let currentPosition = event?.allTouches?.first?.location(in: self) else { return }
        
        let positionDiffAsPercentage = (currentPosition.y - startPosition.y)
            .divideToPercentage(value: touchRect.height)
        position = (startPercentage + positionDiffAsPercentage).toPercentage(max: 100)
        positionRelay.accept(position)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (startPosition != nil && startPercentage != nil) {
            positionChangeRelay.accept(position)
            startPosition = nil
            startPercentage = nil
        }
    }
}

extension Reactive where Base: BaseWindowView {
    var position: Observable<CGFloat> {
        base.positionRelay.asObservable()
    }
    
    var positionChange: Observable<CGFloat> {
        base.positionChangeRelay.asObservable()
    }
}
