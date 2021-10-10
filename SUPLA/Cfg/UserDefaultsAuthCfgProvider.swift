//
	

import Foundation

/*
 TODO: Move responsibility for managing authentication out of SAApp into
 some form of profile manager, when ready.
 */


class UserDefaultsAuthCfgProvider {
    private let kAdvancedAuthConfig = "supla_auth_cfg_advanced_mode"
    
    private func detectAdvancedConfig() -> Bool {
        if UserDefaults.standard.bool(forKey: kAdvancedAuthConfig) {
            return true
        } else {
            return SAApp.isAdvancedConfig()
        }
    }
}

extension UserDefaultsAuthCfgProvider: AuthCfgProvider {
    func loadCurrentAuthCfg() -> AuthCfg? {
        return AuthCfg(usesEmailAuth: !SAApp.isAdvancedConfig(),
                       isAdvancedConfig: detectAdvancedConfig(),
                       emailAddress: SAApp.getEmailAddress(),
                       serverHostName: SAApp.getServerHostName(),
                       accessID: Int(SAApp.getAccessID()),
                       accessPassword: SAApp.getAccessIDpwd())
    }
    
    func storeCurrentAuthCfg(_ ac: AuthCfg) {
        UserDefaults.standard.set(ac.isAdvancedConfig,
                                  forKey: kAdvancedAuthConfig)
        SAApp.setAdvancedConfig(!ac.usesEmailAuth)
        SAApp.setEmailAddress(ac.emailAddress)
        SAApp.setServerHostName(ac.serverHostName)
        SAApp.setAccessID(Int32(ac.accessID ?? 0))
        SAApp.setAccessIDpwd(ac.accessPassword)
    }
}
