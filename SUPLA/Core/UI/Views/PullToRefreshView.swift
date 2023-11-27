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
import RxSwift
import RxRelay

fileprivate let MAX_SWIPE_DOWN: CGFloat = 100
fileprivate let INITIAL_Y: CGFloat = -30

final class PullToRefreshView: UIActivityIndicatorView {
    
    var refreshObservable: Observable<Void> {
        get { refreshRelay.asObservable() }
    }
    
    var isRefreshing: Bool {
        get { refreshing }
        set {
            if (newValue == refreshing) {
                return // Skip when nothing changes
            }
            if (newValue) {
                startRefresh()
            } else {
                stopRefresh()
            }
        }
    }
    
    private var yStarting: CGFloat = 0
    private var yEnding: CGFloat = 0
    private var configured = false
    private var refreshing = false
    private let refreshRelay = PublishRelay<Void>()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let superview = superview else { return }
        
        frame = CGRect(x: superview.center.x - 12, y: INITIAL_Y, width: 24, height: 24)
        if (!configured) {
            superview.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan)))
            configured = true
        }
    }
    
    private func stopRefresh() {
        stopAnimating()
        refreshing = false
        UIView.animate(withDuration: 0.35) {
            self.center = CGPoint(x: self.center.x, y: INITIAL_Y)
        }
    }
    
    private func startRefresh() {
        startAnimating()
        refreshing = true
        UIView.animate(withDuration: 0.35) {
            self.center = CGPoint(x: self.center.x, y: MAX_SWIPE_DOWN)
        }
    }
    
    private func setupView() {
        transform = CGAffineTransformMakeScale(1.5, 1.5)
        hidesWhenStopped = false
    }
    
    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        if (refreshing) {
            return
        }
        
        switch sender.state {
        case .began:
            yStarting = center.y
        case .changed:
            let position = sender.translation(in: self)
            
            yEnding = yStarting + position.y
            if (yEnding > MAX_SWIPE_DOWN) {
                let add = 22 - 400 * (1 / (position.y - MAX_SWIPE_DOWN))
                yEnding = MAX_SWIPE_DOWN + add
            }
            
            center = CGPoint(x: center.x, y: yEnding)
        case .ended:
            let finalPosition = if (yEnding < MAX_SWIPE_DOWN) {
                INITIAL_Y
            } else {
                MAX_SWIPE_DOWN
            }
            UIView.animate(withDuration: 0.35) {
                self.center = CGPoint(x: self.center.x, y: finalPosition)
            }
            
            if (yEnding > MAX_SWIPE_DOWN) {
                refreshing = true
                startAnimating()
                refreshRelay.accept(())
            }
        default: break
        }
    }
}
