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

import SwiftUI

private let VERTICAL_PADDING: CGFloat = 8
private let HORIZONTAL_PADDING: CGFloat = 16
private let DEFAULT_FONT_SIZE_PX: CGFloat = 35

private func defaultFont(_ scale: CGFloat) -> UIFont {
    let fontSizePx: CGFloat = DEFAULT_FONT_SIZE_PX * scale
    let fontSizePt = fontSizePx / UIScreen.main.scale
    
    return UIFont(name: "OpenSans-SemiBold", size: fontSizePt)!
}

extension String {
    func boxMetrics(scale: CGFloat) -> CGSize {
        let font = defaultFont(scale)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let textSize = (self as NSString).size(withAttributes: attributes)
        return CGSize(
            width: textSize.width + HORIZONTAL_PADDING * scale,
            height: textSize.height + VERTICAL_PADDING * scale
        )
    }
}

extension GraphicsContext {
    func drawTextInRoundRect(
        text: String,
        x: CGFloat,
        y: CGFloat,
        textSize: CGSize,
        scale: CGFloat
    ) {
        let rect = CGRect(
            x: x - textSize.width / 2,
            y: y - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        let path = Path(roundedRect: rect, cornerRadius: textSize.height / 2)
        fill(path, with: .color(Color.Supla.background))
        stroke(path, with: .color(Color.Supla.outline), style: StrokeStyle(lineWidth: 1))

        draw(
            Text(text).font(Font(defaultFont(scale))),
            at: CGPoint(x: x, y: y),
            anchor: .center
        )
    }
}
