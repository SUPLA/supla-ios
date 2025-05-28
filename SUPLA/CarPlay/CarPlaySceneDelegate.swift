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

import AVFoundation
import CarPlay
import RxSwift

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    @Singleton<ReadCarPlayItems.UseCase> private var readCarPlayItemsUseCase
    @Singleton<CarPlayRefresh.UseCase> private var carPlayRefreshUseCase
    @Singleton<GlobalSettings> private var settings

    var interfaceController: CPInterfaceController?
    let synthesizer = AVSpeechSynthesizer()
    var disposeBag = DisposeBag()

    var processingItems: [NSManagedObjectID] = []
    var errorItems: [NSManagedObjectID: String] = [:]

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController

        let list = CPListTemplate(title: Strings.appName, sections: [])
        interfaceController.setRootTemplate(list, animated: false, completion: { [weak self] success, _ in
            if (success) {
                self?.reloadItems()
                self?.observeReload()
            }
        })
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
        disposeBag = DisposeBag()
    }
    
    private func observeReload() {
        carPlayRefreshUseCase.observable()
            .asDriverWithoutError()
            .drive(onNext: { [weak self] _ in
                self?.reloadItems()
            })
            .disposed(by: disposeBag)
    }

    private func reloadItems() {
        readCarPlayItemsUseCase.invoke()
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] items in
                    let list = self?.interfaceController?.rootTemplate as? CPListTemplate
                    let sectionItems = items.map { carPlayItem in
                        carPlayItem.listItem(
                            error: self?.errorItems[carPlayItem.id],
                            processing: self?.processingItems.contains(carPlayItem.id) ?? false,
                            handler: { [weak self] _, callback in
                                self?.listItemClick(item: carPlayItem)
                                callback()
                            }
                        )
                    }
                    list?.updateSections([CPListSection(items: sectionItems)])
                }
            )
            .disposed(by: disposeBag)
    }

    private func listItemClick(item: ReadCarPlayItems.Item) {
        processingItems.append(item.id)
        reloadItems()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            @Singleton<SingleCall> var singleCall

            if let action = item.action?.action,
               let profile = item.profile
            {
                do {
                    try singleCall.executeAction(action, subjectType: item.subjectType, subjectId: item.subjectId, authorizationEntity: profile.authorizationEntity)
                } catch {
                    let errorMessage = error.getErrorMessage(subjectType: item.subjectType)
                    self?.errorItems[item.id] = errorMessage
                    self?.sayErrorMessage(errorMessage)
                    DispatchQueue.main.async { [weak self] in
                        self?.reloadItems()
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                    self?.processingItems.removeAll(where: { $0 == item.id })
                    self?.errorItems.removeValue(forKey: item.id)
                    self?.reloadItems()
                }
            }
        }
    }

    private func sayErrorMessage(_ message: String?) {
        guard let message else { return }
        if (settings.carPlayVoiceMessages) {
            let utterance = AVSpeechUtterance(string: message)
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, options: [.interruptSpokenAudioAndMixWithOthers, .duckOthers])
                try session.setMode(.voicePrompt)
                try session.setActive(true)
                synthesizer.speak(utterance)
                try session.setActive(false)
            } catch {
                SALog.error("Failed to get audio session")
                synthesizer.speak(utterance)
            }
        } else {
            SALog.info("Car play messages are deactivated")
        }
    }
}

private extension ReadCarPlayItems.Item {
    func listItem(error: String?, processing: Bool, handler: @escaping (any CPSelectableListItem, @escaping () -> Void) -> Void) -> CPListItem {
        let detailText = if let error { error } else { processing ? Strings.CarPlay.executing : subjectType.name }
        let item = CPListItem(text: caption, detailText: detailText, image: icon.uiImage)
        item.handler = handler
        return item
    }
}
