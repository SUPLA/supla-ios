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
    static let displayLarge = openSansLight(style: .title1, size: FontSize.displayLarge)
    static let displayMedium = openSansRegular(style: .title2, size: FontSize.displayMedium)
    static let displaySmall = openSansRegular(style: .title3, size: FontSize.displaySmall)

    static let headlineLarge = openSansRegular(style: .title1, size: FontSize.headlineLarge)
    static let headlineMedium = openSansRegular(style: .title2, size: FontSize.headlineMedium)
    static let headlineSmall = openSansRegular(style: .title3, size: FontSize.headlineSmall)

    static let titleLarge = openSansSemiBold(style: .title1, size: FontSize.titleLarge)
    static let titleMedium = openSansSemiBold(style: .title2, size: FontSize.titleMedium)
    static let titleSmall = openSansSemiBold(style: .title3, size: FontSize.titleSmall)

    static let bodyLarge = openSansRegular(style: .body, size: FontSize.bodyLarge)
    @objc static let bodyMedium = openSansRegular(style: .body, size: FontSize.bodyMedium)
    static let bodyMediumBold = openSansBold(style: .body, size: FontSize.bodyMedium)
    static let bodySmall = openSansRegular(style: .body, size: FontSize.bodySmall)

    static let labelLarge = openSansMedium(style: .caption1, size: FontSize.labelLarge)
    static let labelMedium = openSansSemiBold(style: .caption1, size: FontSize.labelMedium)
    static let labelSmall = openSansSemiBold(style: .caption2, size: FontSize.labelSmall)
    
    @objc
    class StaticSize: NSObject {
        static let labelSmall = UIFont(name: FontName.OpenSans.SemiBold, size: FontSize.labelSmall)
        
        static let marker = UIFont(name: FontName.OpenSans.Regular, size: 11)!
        static let markerBold = UIFont(name: FontName.OpenSans.Bold, size: 11)!
    }
    
    static func openSansLight(style: UIFont.TextStyle, size: CGFloat) -> UIFont {
        guard let openSansFont = UIFont(name: "OpenSans-Light", size: size)
        else {
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            return UIFont(descriptor: descriptor, size: size)
        }
        
        return openSansFont.dynamicallyTyped(withStyle: style)
    }
    
    static func openSansRegular(style: UIFont.TextStyle, size: CGFloat) -> UIFont {
        guard let openSansFont = UIFont(name: "OpenSans", size: size)
        else {
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            return UIFont(descriptor: descriptor, size: size)
        }
        
        return openSansFont.dynamicallyTyped(withStyle: style)
    }
    
    static func openSansMedium(style: UIFont.TextStyle, size: CGFloat) -> UIFont {
        guard let openSansFont = UIFont(name: "OpenSans-Medium", size: size)
        else {
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            return UIFont(descriptor: descriptor, size: size)
        }
        
        return openSansFont.dynamicallyTyped(withStyle: style)
    }
    
    static func openSansSemiBold(style: UIFont.TextStyle, size: CGFloat) -> UIFont {
        guard let openSansFont = UIFont(name: "OpenSans-SemiBold", size: size)
        else {
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            return UIFont(descriptor: descriptor, size: size)
        }
        
        return openSansFont.dynamicallyTyped(withStyle: style)
    }
    
    static func openSansBold(style: UIFont.TextStyle, size: CGFloat) -> UIFont {
        guard let openSansFont = UIFont(name: "OpenSans-Bold", size: size)
        else {
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            return UIFont(descriptor: descriptor, size: size)
        }
        
        return openSansFont.dynamicallyTyped(withStyle: style)
    }
    
    private func dynamicallyTyped(withStyle style: UIFont.TextStyle) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        return metrics.scaledFont(for: self)
    }
    
    // TODO: Replace with system fonts
    
    static let formLabelFont = UIFont(name: "OpenSans", size: 14)!
    
    @objc static let cellCaptionFont = UIFont(name: "OpenSans-Bold", size: Dimens.Fonts.caption)!
    @objc static let cellValueFont = UIFont(name: "OpenSans", size: Dimens.Fonts.value)!
}
