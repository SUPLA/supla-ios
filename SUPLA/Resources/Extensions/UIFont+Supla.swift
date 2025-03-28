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
    static let h6 = openSansSemiBold(style: .title3, size: 17)
    static let subtitle1 = openSansRegular(style: .subheadline, size: 16)
    static let subtitle2 = openSansMedium(style: .subheadline, size: 14)
    static let body1 = openSansRegular(style: .body, size: 16)
    @objc static let body2 = openSansRegular(style: .body, size: 14)
    static let button = openSansMedium(style: .caption1, size: 17)
    static let caption = openSansRegular(style: .caption2, size: 12)
    static let captionSemiBold = openSansSemiBold(style: .caption2, size: 12)
    
    // custom variation
    static let body2Bold = openSansBold(style: .body, size: 14)
    
    @objc
    class StaticSize: NSObject {
        static let h1 = UIFont(name: "OpenSans-Light", size: 96)!
        static let h2 = UIFont(name: "OpenSans-Light", size: 60)!
        static let h3 = UIFont(name: "OpenSans", size: 48)!
        static let h4 = UIFont(name: "OpenSans", size: 34)!
        static let h5 = UIFont(name: "OpenSans", size: 24)!
        static let h6 = UIFont(name: "OpenSans-SemiBold", size: 17)!
        static let subtitle1 = UIFont(name: "OpenSans", size: 16)!
        static let subtitle2 = UIFont(name: "OpenSans-Medium", size: 14)!
        static let body1 = UIFont(name: "OpenSans", size: 16)!
        @objc static let body2 = UIFont(name: "OpenSans", size: 14)!
        static let button = UIFont(name: "OpenSans-Medium", size: 17)!
        static let caption = UIFont(name: "OpenSans-Medium", size: 10)!
        
        static let marker = UIFont(name: "OpenSans", size: 11)!
        static let markerBold = UIFont(name: "OpenSans-Bold", size: 11)!
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
    
    static let thermostatControlBigTemperature = UIFont(name: "OpenSans-Medium", size: 48)
    static let thermostatControlSmallTemperature = UIFont(name: "OpenSans-Medium", size: 32)
    static let thermostatTimerTime = UIFont(name: "OpenSans-Bold", size: 24)
    
    static let scheduleDetailButton = UIFont(name: "OpenSans-Bold", size: 14)
    
    // TODO: Replace with system fonts
    
    @objc static let suplaTitleBarFont = UIFont(name: "Quicksand-Regular", size: 27)!
    @objc static let suplaSubtitleFont = UIFont(name: "Quicksand-Regular", size: 16)!

    static let formLabelFont = UIFont(name: "OpenSans", size: Dimens.Fonts.label)!
    
    @objc static let cellCaptionFont = UIFont(name: "OpenSans-Bold", size: Dimens.Fonts.caption)!
    @objc static let cellValueFont = UIFont(name: "OpenSans", size: Dimens.Fonts.value)!
}
