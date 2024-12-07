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

class ImpulseCounterDetailVM: StandardDetailVM<ImpulseCounterDetailViewState, ImpulseCounterDetailViewEvent> {
    @Singleton<CheckOcrPhotoExistsUseCase> var checkOcrPhotoExistsUseCase
    @Singleton<DownloadOcrPhotoUseCase> var downloadOcrPhotoUseCase
    @Singleton<SuplaSchedulers> var schedulers
    
    var hasPhoto: Bool { currentState()?.hasPhoto ?? false }
    
    override func defaultViewState() -> ImpulseCounterDetailViewState { ImpulseCounterDetailViewState() }
    
    override func setTitle(_ title: String) {
        updateView { $0.changing(path: \.title, to: title) }
    }
    
    override func handleChannel(_ channel: SAChannel) {
        super.handleChannel(channel)
        updateView {
            let hasPhoto = checkOcrPhotoExistsUseCase.invoke(profileId: Int64(channel.profile.id), remoteId: channel.remote_id)
            
            if ($0.photoDownloaded) {
                return $0.changing(path: \.hasPhoto, to: hasPhoto)
            } else {
                triggerPhotoDownload(channel: channel)
                
                return $0.changing(path: \.photoDownloaded, to: true)
                    .changing(path: \.hasPhoto, to: hasPhoto)
                    .changing(path: \.channelId, to: channel.remote_id)
                    .changing(path: \.profileId, to: channel.profile.id)
            }
        }
    }
    
    @objc
    func onPhotoButtonClick() {
        if let profileId = currentState()?.profileId,
           let remoteId = currentState()?.channelId {
            send(event: .openOcrPhoto(profileId: profileId, remoteId: remoteId))
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
            .disposed(by: self)
    }
}
    
enum ImpulseCounterDetailViewEvent: ViewEvent {
    case openOcrPhoto(profileId: Int32, remoteId: Int32)
}

struct ImpulseCounterDetailViewState: ViewState {
    var title: String? = nil
    var channelId: Int32? = nil
    var profileId: Int32? = nil
    var photoDownloaded: Bool = false
    var hasPhoto: Bool = false
}
