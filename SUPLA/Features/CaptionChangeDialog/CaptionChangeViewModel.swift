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
    
extension CaptionChangeDialogFeature {
    class ViewModel: SuplaCore.Dialog.ViewModel {
        
        @Singleton<VibrationService> private var vibrationService
        @Singleton<CaptionChangeUseCase> private var captionChangeUseCase
        @Singleton<ReadGroupByRemoteIdUseCase> private var readGroupByRemoteIdUseCase
        @Singleton<ReadSceneByRemoteIdUseCase> private var readSceneByRemoteIdUseCase
        @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
        @Singleton<ReadLocationByRemoteIdUseCase> private var readLocationByRemoteIdUseCase
        
        @Published var caption: String = ""
        @Published private(set) var label: String? = nil
        @Published private(set) var error: String? = nil
        
        private var remoteId: Int32 = 0
        private var captionType: CaptionChangeUseCaseImpl.CaptionType = .channel
        private var finishedCallback: ((CaptionChangeUseCaseImpl.CaptionType) -> Void)?
        
        init(finishedCallback: ((CaptionChangeUseCaseImpl.CaptionType) -> Void)? = nil) {
            self.finishedCallback = finishedCallback
            super.init()
        }
        
        init(caption: String = "", label: String? = nil, error: String? = nil) {
            self.finishedCallback = { _ in }
            self.caption = caption
            self.label = label
            self.error = error
        }

        func show(_ viewController: UIViewController?, channelRemoteId: Int32) {
            readChannelByRemoteIdUseCase.invoke(remoteId: channelRemoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in
                    self?.show(viewController, remoteId: $0.remote_id, caption: $0.caption ?? "", captionType: .channel)
                })
                .disposed(by: self)
        }
        
        func show(_ viewController: UIViewController?, groupRemoteId: Int32) {
            readGroupByRemoteIdUseCase.invoke(remoteId: groupRemoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in
                    self?.show(viewController, remoteId: $0.remote_id, caption: $0.caption ?? "", captionType: .group)
                })
                .disposed(by: self)
        }
        
        func show(_ viewController: UIViewController?, sceneRemoteId: Int32) {
            readSceneByRemoteIdUseCase.invoke(remoteId: sceneRemoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in
                    self?.show(viewController, remoteId: $0.sceneId, caption: $0.caption ?? "", captionType: .scene)
                })
                .disposed(by: self)
        }
        
        func show(_ viewController: UIViewController?, locationRemoteId: Int32) {
            readLocationByRemoteIdUseCase.invoke(remoteId: locationRemoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in
                    if let locationId = $0.location_id?.int32Value {
                        self?.show(viewController, remoteId: locationId, caption: $0.caption ?? "", captionType: .location)
                    }
                })
                .disposed(by: self)
        }
        
        func show(_ viewController: UIViewController?, sensorData: RelatedChannelData) {
            show(viewController, remoteId: sensorData.channelId, caption: sensorData.userCaption, captionType: .channel)
        }
        
        func show(_ viewController: UIViewController?, remoteId: Int32, caption: String, captionType: CaptionChangeUseCaseImpl.CaptionType) {
            if let viewController {
                self.remoteId = remoteId
                self.caption = caption
                self.label = captionType.label
                self.captionType = captionType
                
                vibrationService.vibrate()
                
                SAAuthorizationDialogVC { [weak self] in self?.present = true }.showAuthorization(viewController)
            }
        }
        
        func hide() {
            present = false
        }
        
        func onApply() {
            captionChangeUseCase.invoke(caption: caption, type: captionType, remoteId: remoteId)
                .asDriverWithoutError()
                .drive(onCompleted: { [weak self] in
                    if let self {
                        self.hide()
                        self.finishedCallback?(self.captionType)
                    }
                })
                .disposed(by: self)
        }
        
    }
}

fileprivate extension CaptionChangeUseCaseImpl.CaptionType {
    var label: String {
        switch (self) {
        case .channel: Strings.ChangeCaption.channelName
        case .group: Strings.ChangeCaption.groupName
        case .scene: Strings.ChangeCaption.sceneName
        case .location: Strings.ChangeCaption.locationName
        }
    }
}
