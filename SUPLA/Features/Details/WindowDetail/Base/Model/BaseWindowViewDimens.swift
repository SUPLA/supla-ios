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

class BaseWindowViewDimens {
    var parentFrame = CGRect()
    var scale: CGFloat = 0
    
    var frame: CGRect = .zero
    var canvasRect: CGRect = .zero
    
    final func update(_ frame: CGRect) {
        if (self.parentFrame == frame) {
            return // Frame is not changed - no calculations needed
        }
        self.parentFrame = frame
        self.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size)
        
        calculateDimens(frame)
    }
    
    func calculateDimens(_ frame: CGRect) {
        fatalError("calculateDimens(frame:) needs to be implemented!")
    }
}
