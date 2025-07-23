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
    
import SharedCore

struct SuplaClientMessage {
    protocol Proxy: SharedCore.SuplaClientMessageHandler {}
    
    class Implementation: Proxy {
        private var listeners: [SuplaClientMessageHandlerListener] = []
        
        init() {
            NotificationCenter.default.addObserver(self, selector: #selector(onRegistrationEnabledNotification), name: NSNotification.Name.saRegistrationEnabled, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(onSetRegistrationEnabledNotification), name: NSNotification.Name("KSA-N18"), object: nil)
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        func register(listener: any SuplaClientMessageHandlerListener) {
            listeners.append(listener)
        }
        
        func unregister(listener: any SuplaClientMessageHandlerListener) {
            guard let index = listeners.firstIndex(where: { $0 === listener }) else { return }
            listeners.remove(at: index)
        }
        
        @objc private func onRegistrationEnabledNotification(notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let data = userInfo[UserInfoKeys.registrationEnabled.rawValue] as? SARegistrationEnabled else { return }
            
            for listener in listeners {
                listener.onReceived(message: SuplaClientMessageRegistrationEnabled.from(data))
            }
        }
        
        @objc private func onSetRegistrationEnabledNotification(notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let code = userInfo[UserInfoKeys.setRegistrationEnabledCode.rawValue] as? NSNumber else { return }
            
            let resultCode = SharedCore.SuplaResultCode.companion.from(value: code.int32Value)
            for listener in listeners {
                listener.onReceived(message: SuplaClientMessageSetRegistrationEnabledResult(resultCode: resultCode))
            }
        }
    }
    
    enum UserInfoKeys: String {
        case registrationEnabled = "reg_enabled"
        case setRegistrationEnabledCode = "code"
    }
}
