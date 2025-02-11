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
    
extension CounterPhotoFeature {
    class ViewState: ObservableObject {
        @Published var latestPhoto: OcrPhoto? = nil
        @Published var photos: [OcrPhoto]? = nil
        @Published var configurationAddress: String? = nil
        
        @Published var loadingError: Bool = false
        @Published var loading: Bool = false
    }
    
    struct OcrPhoto: Identifiable {
        let id: String
        
        let date: String?
        let original: Data?
        let cropped: Data?
        let value: OcrValue
    }
    
    enum OcrValue {
        case waiting
        case error
        case warning(value: String)
        case success(value: String)
        
        var backgroundColor: Color {
            switch self {
            case .waiting: .Supla.ocrProcessing
            case .error: .Supla.error
            case .success: .Supla.primary
            case .warning: .Supla.ocrWarning
            }
        }
        
        var text: String {
            switch self {
            case .waiting: "..."
            case .error: Strings.CounterPhoto.error
            case .success(let value): value
            case .warning(let value): value
            }
        }
    }
}
