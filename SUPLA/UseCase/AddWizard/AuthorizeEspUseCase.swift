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
    

private let TIMEOUT_SECS: UInt64 = 15

enum AuthorizeEsp {
    protocol UseCase {
        func invoke(password: String) async -> Result
    }
    
    class Implementation: UseCase {
        @Singleton<EspRepository> private var espRepository
        
        func invoke(password: String) async -> Result {
            SALog.info("ESP Authorization started")
            
            return await cancelableTaskWithTimeout(timeout: TIMEOUT_SECS) {
                await self.perform(password: password)
            } ?? .failureUnknown
        }
        
        private func perform(password: String) async -> Result {
            let result = await espRepository.login(password: password)
            
            return switch result {
            case .success: .success
            case .temporarilyLocked: .temporarilyLocked
            case .failure(let error): error is InvalidCredentialsError ? .failureWrongPassword : .failureUnknown
            default: .failureUnknown
            }
        }
    }
    
    enum Result {
        case success
        case failureWrongPassword
        case failureUnknown
        case temporarilyLocked
    }
}
