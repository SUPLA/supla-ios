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

extension UIFont {
    static let h1 = openSansLight(style: .largeTitle, size: 96)
    static let h2 = openSansLight(style: .title1, size: 60)
    static let h3 = openSansRegular(style: .title2, size: 48)
    static let h4 = openSansRegular(style: .title3, size: 34)
    static let h5 = openSansRegular(style: .title3, size: 24)
    static let h6 = openSansRegular(style: .title3, size: 20)
    static let subtitle1 = openSansRegular(style: .subheadline, size: 16)
    static let subtitle2 = openSansMedium(style: .subheadline, size: 14)
    static let body1 = openSansRegular(style: .body, size: 16)
    @objc static let body2 = openSansRegular(style: .body, size: 14)
    static let button = openSansMedium(style: .caption1, size: 17)
    static let caption = openSansMedium(style: .caption2, size: 10)
    
    static func openSansLight(style: UIFont.TextStyle, size: CGFloat) -> UIFont {
        guard let openSansFont = UIFont(name: "OpenSans-Light", size: size)
        else {
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            return UIFont(descriptor: descriptor, size: size)
        }
        
        return openSansFont.dynamicallyTyped(withStyle: .title1)
    }
    
    static func openSansRegular(style: UIFont.TextStyle, size: CGFloat) -> UIFont {
        guard let openSansFont = UIFont(name: "OpenSans", size: size)
        else {
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            return UIFont(descriptor: descriptor, size: size)
        }
        
        return openSansFont.dynamicallyTyped(withStyle: .title1)
    }
    
    static func openSansMedium(style: UIFont.TextStyle, size: CGFloat) -> UIFont {
        guard let openSansFont = UIFont(name: "OpenSans-Medium", size: size)
        else {
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            return UIFont(descriptor: descriptor, size: size)
        }
        
        return openSansFont.dynamicallyTyped(withStyle: .title1)
    }
    
    static func openSansBold(style: UIFont.TextStyle, size: CGFloat) -> UIFont {
        guard let openSansFont = UIFont(name: "OpenSans-Bold", size: size)
        else {
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            return UIFont(descriptor: descriptor, size: size)
        }
        
        return openSansFont.dynamicallyTyped(withStyle: .title1)
    }
    
    private func dynamicallyTyped(withStyle style: UIFont.TextStyle) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        return metrics.scaledFont(for: self)
    }
    
    // TODO: Replace with system fonts
    
    @objc static let suplaTitleBarFont = UIFont(name: "Quicksand-Regular", size: 27)!
    @objc static let suplaSubtitleFont = UIFont(name: "Quicksand-Regular", size: 16)!

    static let formLabelFont = UIFont(name: "OpenSans", size: 14)!
    static let cellCaptionFont = UIFont(name: "OpenSans-Bold", size: 14)!
}
