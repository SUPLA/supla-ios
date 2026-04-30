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

extension CallNfcActionFeature {
    class ViewState: ObservableObject {
        @Published var step: TagProcessingStep = .processing
        @Published var tagData: TagData? = nil
        
        init(step: TagProcessingStep = .processing, tagData: TagData? = nil) {
            self.step = step
            self.tagData = tagData
        }
    }
    
    struct TagData {
        let name: String
        let action: ActionId?
        let subjectName: String
    }
    
    enum TagProcessingStep {
        case processing
        case success
        case failure(type: FailureType)
        
        var failureType: FailureType? {
            switch (self) {
            case .processing, .success: nil
            case .failure(let type): type
            }
        }
    }
    
    enum FailureType {
        case unknownUrl
        case tagNotFound(uuid: String)
        case tagNotConfigured(uuid: String)
        case actionFailed
        case channelNotFound(uuid: String)
        case channelOffline
    }
}

extension CallNfcActionFeature.FailureType {
    var title: String {
        switch (self) {
        case .unknownUrl: Strings.Nfc.Call.unknownUrlTitle
        case .tagNotFound(_): Strings.Nfc.Call.tagNotFoundTitle
        case .tagNotConfigured(_): Strings.Nfc.Call.tagNotConfiguredTitle
        case .actionFailed: Strings.Nfc.Call.actionCallFailedTitle
        case .channelNotFound(_): Strings.Nfc.Call.channelNotFoundTitle
        case .channelOffline: Strings.Nfc.Call.channelOfflineTitle
        }
    }
    
    var message: String {
        switch (self) {
        case .unknownUrl: Strings.Nfc.Call.unknownUrlMessage
        case .tagNotFound(_): Strings.Nfc.Call.tagNotFoundMessage
        case .tagNotConfigured(_): Strings.Nfc.Call.tagNotConfiguredMessage
        case .actionFailed: Strings.Nfc.Call.actionCallFailedMessage
        case .channelNotFound(_): Strings.Nfc.Call.channelNotFoundMessage
        case .channelOffline: Strings.Nfc.Call.channelOfflineMessage
        }
    }
    
    var primaryActionText: String? {
        switch (self) {
        case .unknownUrl,
             .actionFailed,
             .channelOffline: nil
            
        case .tagNotFound(_): Strings.Nfc.Call.addTag
        case .tagNotConfigured(_): Strings.Nfc.Call.assignAction
        case .channelNotFound(_): Strings.Nfc.Call.updateAction
        }
    }
    
    var secondaryActionText: String {
        switch (self) {
        case .tagNotFound(_): Strings.General.cancel
        default: Strings.General.exit
        }
    }
}
