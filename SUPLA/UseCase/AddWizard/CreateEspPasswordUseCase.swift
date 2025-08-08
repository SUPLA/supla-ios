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

struct CreateEspPassword {
    protocol UseCase {
        func invoke(password: String) async -> Result
    }
    
    final class Implementation: UseCase {
        @Singleton<EspRepository> private var espRepository
        
        func invoke(password: String) async -> Result {
            SALog.info("ESP Password setup started")
            
            return await cancelableTaskWithTimeout(timeout: TIMEOUT_SECS) {
                await self.perform(password: password)
            } ?? .failure
        }
        
        private func perform(password: String) async -> Result {
            let result = await espRepository.setup(password: password)
            
            return switch result {
            case .success: .success
            case .temporarilyLocked: .temporarilyLocked
            default: .failure
            }
        }
    }
    
    enum Result {
        case success
        case failure
        case temporarilyLocked
    }
}
