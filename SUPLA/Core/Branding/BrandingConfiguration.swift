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

@objc public final class BrandingConfiguration: NSObject {
    @objc(BrandingConfigurationMenu) public final class Menu: NSObject {
        @objc static let DEVICES_OPTION_VISIBLE = true
        @objc static let Z_WAVE_OPTION_VISIBLE = true
        @objc static let ABOUT_OPTION_VISIBLE = true
        @objc static let HELP_OPTION_VISIBLE = true
    }

    static let SHOW_LICENCE = true
    static let ASK_FOR_RATE = true

    public enum About {
        static let LOGO: ImageResource = .logoLight
        static let COLOR_FILLER: Color = .Supla.onBackground
    }

    public enum Status {
        static let LOGO: ImageResource = .logoLight
        static let COLOR_FILLER: Color = .Supla.primary
    }
    
    public enum LockScreen {
        static let LOGO: ImageResource = .logoWithName
    }
    
    public enum ProjectorScreen {
        static let LOGO: UIImage = .logo!.withTintColor(.primary)
        static let ALPHA: CGFloat = 0.2
        static let LOGO_WIDTH: CGFloat = 120
        static let LOGO_HEIGHT: CGFloat = 137
    }
}
