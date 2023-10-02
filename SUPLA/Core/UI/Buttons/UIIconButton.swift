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

class UIIconButton: UIButton {
    
    override var intrinsicContentSize: CGSize {
        get { CGSize(width: size, height: size) }
    }
    
    override var isEnabled: Bool {
        didSet {
            color = isEnabled ? .primary : .disabled
            backgroundColor = color
        }
    }
    
    var icon: UIImage? {
        get { fatalError("Not implemented") }
        set {
            setImage(newValue?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    private var color: UIColor = .primary
    private var size: CGFloat
    
    init(size: CGFloat = Dimens.buttonSmallHeight) {
        self.size = size
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundColor = .primaryVariant
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        backgroundColor = color
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        backgroundColor = color
    }
    
    private func setupView() {
        backgroundColor = color
        layer.cornerRadius = size / 2
        tintColor = .white
        
        imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        imageView?.contentMode = .scaleAspectFit
    }
}
