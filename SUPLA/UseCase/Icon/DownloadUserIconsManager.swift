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
    
protocol DownloadUserIconsManager {
    func download()
}

final class DownloadUserIconsManagerImpl: DownloadUserIconsManager {
    
    @Singleton<DownloadUserIcons.UseCase> private var downloadUserIconsUseCase
    @Singleton<UpdateEventsManager> private var updateEventsManager
    @Singleton<SuplaSchedulers> private var schedulers
    
    private var downloading = false
    
    func download() {
        SALog.debug("Starting icons download")
        synced(self) {
            if (downloading) {
                SALog.debug("Downloading in progress - skiping.")
                return
            }
            downloading = true
        }
        
        _ = downloadUserIconsUseCase.invoke()
            .subscribe(on: schedulers.background)
            .observe(on: schedulers.main)
            .subscribe(
                onNext: { self.finishDownloading($0) },
                onError: { self.handleError($0) }
            )
    }
    
    private func finishDownloading(_ result: DownloadUserIcons.Result) {
        synced(self) {
            downloading = false
        }
        
        if (result == .repeat) {
            SALog.debug("Icons download not ready - repeating.")
            download()
        }
    }
    
    private func handleError(_ error: Error) {
        synced(self) {
            downloading = false
        }
        SALog.error("Icons download failed with error: \(error)")
    }
}
