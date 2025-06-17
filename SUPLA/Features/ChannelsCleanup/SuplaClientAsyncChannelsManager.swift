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

protocol SuplaClientAsyncChannelsManager {
    func start()
    func kill()
}
    
class SuplaClientAsyncChannelsManagerImpl: SuplaClientAsyncChannelsManager {
    
    @Singleton<RemoveHiddenChannelsUseCase> private var removeHiddenChannelsUseCase
    
    private var task: Task<Void, Never>?
    
    func start() {
        task = Task(priority: .low) {
            SALog.info("Starting hidden channels removal manager")
            removeHiddenChannelsUseCase.invoke()
            SALog.info("Finishing hidden channels removal manager")
            if #available(iOS 17.0, *) {
                exportCarPlayItems()
            }
        }
    }
    
    func kill() {
        SALog.info("Killing hidden channels removal manager")
        task?.cancel()
    }
    
    @available(iOS 17.0, *)
    private func exportCarPlayItems() {
        SALog.info("Starting car play items export")
        @Singleton<ExportCarPlayItems.UseCase> var exportCarPlayItemsUseCase
        do {
            try exportCarPlayItemsUseCase.invoke().subscribeSynchronous()
            SALog.info("Finishing car play items export")
        } catch {
            SALog.error("Could not export carplay items \(String(describing: error))")
        }
    }
}
