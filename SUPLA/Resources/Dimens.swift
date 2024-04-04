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

struct Dimens {
    static let distanceTiny = CGFloat(8)
    static let distanceSmall = CGFloat(16)
    static let distanceDefault = CGFloat(24)
    
    static let radiusDefault = CGFloat(9)
    static let radiusSmall = CGFloat(4)
    
    static let buttonRadius = radiusDefault
    static let buttonHeight = CGFloat(48)
    static let buttonSmallHeight = CGFloat(32)
    
    static let iconSize = CGFloat(24)
    static let iconSizeSmall = CGFloat(19)
    static let iconSizeList = CGFloat(30)
    static let iconInfoSize = CGFloat(24)
    static let iconSizeBig = CGFloat(32)
    
    static let elementOffset = CGFloat(8)
    
    struct Form {
        static let elementSpacing = CGFloat(16)
        static let verticalMargin = CGFloat(11)
    }
    
    struct Fonts {
        static let caption = CGFloat(12)
        static let label = CGFloat(14)
        
        static let value = CGFloat(21)
    }
    
    struct ListItem {
        static let verticalPadding = CGFloat(11)
        static let horizontalPadding = CGFloat(11)
        static let separatorHeight = CGFloat(1)
        static let separatorInset = CGFloat(8)
        
        static let statusIndicatorSize = CGFloat(10)
        
        static let buttonWidth = CGFloat(105)
        
        static let iconWidth = CGFloat(100)
        static let iconHeight = CGFloat(50)
    }
    
    struct Shadow {
        static let radius = CGFloat(2)
        static let opacity: Float = 0.3
        static let offset = CGSizeMake(0, 0)
    }
    
    struct Point {
        static let radius = CGFloat(8)
        static let shadowRadius = CGFloat(12)
    }
}
