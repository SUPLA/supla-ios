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

class ImpulseCounterDetailVM: BaseDetailVM<ImpulseCounterDetailViewState> {
    @Singleton<CheckOcrPhotoExistsUseCase> var checkOcrPhotoExistsUseCase
    @Singleton<DownloadOcrPhotoUseCase> var downloadOcrPhotoUseCase
    @Singleton<SuplaSchedulers> var schedulers
    
    init(item: ItemBundle) {
        super.init(item: item, state: ImpulseCounterDetailViewState())
    }
    
    override func handleChannel(_ channel: SAChannel) {
        super.handleChannel(channel)
        
        if (channel.flags & Int64(SUPLA_CHANNEL_FLAG_OCR) == 0) {
            let hasPhoto = checkOcrPhotoExistsUseCase.invoke(profileId: Int64(channel.profile.id), remoteId: channel.remote_id)

            if (state.photoDownloaded) {
                state.hasPhoto = hasPhoto
            } else {
                triggerPhotoDownload(channel: channel)

                state.photoDownloaded = true
                state.hasPhoto = hasPhoto
                state.channelId = channel.remote_id
                state.profileId = channel.profile.id
            }
        }
    }

    private func triggerPhotoDownload(channel: SAChannel) {
        downloadOcrPhotoUseCase.invoke(remoteId: channel.remote_id)
            .subscribe(on: schedulers.background)
            .observe(on: schedulers.main)
            .subscribe(
                onCompleted: { [weak self] in
                    self?.handleChannel(channel)
                }
            )
            .disposed(by: disposeBag)
    }
}

final class ImpulseCounterDetailViewState: DetailViewState {
    @Published var title: String? = nil
    @Published var channelId: Int32? = nil
    @Published var profileId: Int32? = nil
    @Published var photoDownloaded: Bool = false
    @Published var hasPhoto: Bool = false
}
