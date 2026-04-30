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
    
import CoreNFC

struct LockNfcTag {
    private static let retryInterval = DispatchTimeInterval.milliseconds(500)
    
    protocol UseCase {
        func invoke(_ uuid: String, name: String) async throws -> NfcResult
    }
    
    final class Implementation: NSObject, UseCase {
        @Singleton private var settings: GlobalSettings
        
        private var continuation: CheckedContinuation<NfcResult, Error>? = nil
        private var uuid: String? = nil
        private var name: String? = nil
        
        func invoke(_ uuid: String, name: String) async throws -> NfcResult {
            guard continuation == nil else {
                return .busy
            }
            
            self.uuid = uuid
            self.name = name
            return try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
                let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
                session.alertMessage = Strings.Nfc.Detail.lockTitle.arguments(name)
                session.begin()
            }
        }
        
        private func finish(_ session: NFCNDEFReaderSession, with result: Result<NfcResult, Error>) {
            switch (result) {
            case .success(_):
                session.alertMessage = Strings.Nfc.Detail.lockSuccess
                session.invalidate()
            case .failure(let error):
                if let nfcError = error as? NfcError {
                    switch (nfcError) {
                    case .cancelled, .timeout: session.invalidate()
                    case .wrong: session.invalidate(errorMessage: nfcError.message.arguments(name ?? ""))
                    default: session.invalidate(errorMessage: nfcError.message)
                    }
                } else {
                    session.invalidate(errorMessage: Strings.Nfc.Add.errorWriteFailed)
                }
            }
            
            continuation?.resume(with: result)
            continuation = nil
            uuid = nil
            name = nil
        }
    }
    
    enum NfcResult {
        case success
        case busy
    }
}

extension LockNfcTag.Implementation: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // not used because of readerSession(_, didDetect:)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        SALog.debug("Detection of NFC tag (tags: \(tags.count))")
        
        guard tags.count == 1 else {
            session.alertMessage = Strings.Nfc.Add.tooManyTags
            DispatchQueue.global().asyncAfter(deadline: .now() + LockNfcTag.retryInterval) {
                session.restartPolling()
            }
            return
        }
        
        let tag = tags.first!
        session.connect(to: tag) { [weak self] (error: Error?) in
            if let error {
                self?.finish(session, with: .failure(error))
                return
            }
            
            tag.queryNDEFStatus { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                if let error {
                    self?.finish(session, with: .failure(error))
                    return
                }
                
                switch (ndefStatus) {
                case .notSupported:
                    self?.finish(session, with: .failure(NfcError.unsupported))
                case .readOnly:
                    self?.handleReadOnlyTag(session, tag: tag)
                case .readWrite:
                    self?.handleWritableTag(session, tag: tag)
                default:
                    self?.finish(session, with: .failure(NfcError.unsupported))
                }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: any Error) {
        if let nfcError = error as? NFCReaderError {
            switch (nfcError.code) {
            case .readerSessionInvalidationErrorUserCanceled:
                finish(session, with: .failure(NfcError.cancelled))
                return
            case .readerSessionInvalidationErrorSessionTimeout:
                finish(session, with: .failure(NfcError.timeout))
                return
            default: break
            }
        }
        
        finish(session, with: .failure(error))
    }
}

extension LockNfcTag.Implementation {
    private func handleReadOnlyTag(_ session: NFCNDEFReaderSession, tag: NFCNDEFTag) {
        tag.readNDEF { [weak self] message, error in
            if let error {
                SALog.error("[NFC] Tag could not be read: \(error)")
                self?.finish(session, with: .failure(error))
                return
            }
            
            if let uuid = message.findUuid() {
                SALog.info("[NFC] Found SUPLA UUID: \(uuid)")
                if (uuid == self?.uuid) {
                    self?.finish(session, with: .success(.success))
                } else {
                    self?.finish(session, with: .failure(NfcError.wrong))
                }
            } else {
                SALog.info("[NFC] No UUID found, quiting with notUsable error")
                self?.finish(session, with: .failure(NfcError.writeProtected))
            }
        }
    }
    
    private func handleWritableTag(_ session: NFCNDEFReaderSession, tag: NFCNDEFTag) {
        tag.readNDEF { [weak self] message, error in
            if let error {
                SALog.error("[NFC] Tag could not be read: \(error)")
                self?.finish(session, with: .failure(error))
                return
            }
            
            if let uuid = message.findUuid() {
                SALog.error("[NFC] Found writable tag with UUID: \(uuid)")
                if (uuid == self?.uuid) {
                    tag.writeLock { [weak self] error in
                        if let error {
                            SALog.error("[NFC] Tag could not be locked: \(error)")
                            self?.finish(session, with: .failure(NfcError.protectionFailed))
                            return
                        }
                        
                        SALog.error("[NFC] Tag with UUID: \(uuid) locked successfully")
                        self?.finish(session, with: .success(.success))
                    }
                } else {
                    SALog.error("[NFC] Wrong tag scanned (uuid: \(uuid))")
                    self?.finish(session, with: .failure(NfcError.wrong))
                }
            } else {
                SALog.error("[NFC] Unsupported tag scanned")
                self?.finish(session, with: .failure(NfcError.unsupported))
            }
        }
    }
}
