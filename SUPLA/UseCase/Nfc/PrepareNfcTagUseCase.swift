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

struct PrepareNfcTag {
    private static let retryInterval = DispatchTimeInterval.milliseconds(500)
    private static let androidMimeType = Data("application/vnd.org.supla.tag".utf8)
    
    protocol UseCase {
        func invoke() async throws -> NfcResult
    }
    
    // There is some duplication issue when compiling with name Implementation
    // Temporary changed to _Implementation
    final class _Implementation: NSObject, UseCase {
        @Singleton private var settings: GlobalSettings
        
        private var continuation: CheckedContinuation<NfcResult, Error>? = nil
        
        func invoke() async throws -> NfcResult {
            guard continuation == nil else {
                return .busy
            }
            
            return try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
                let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
                session.alertMessage = Strings.Nfc.Add.scanHint
                session.begin()
            }
        }
        
        private func finish(_ session: NFCNDEFReaderSession, with result: Result<NfcResult, Error>) {
            switch (result) {
            case .success(_):
                session.alertMessage = Strings.Nfc.Add.success
                session.invalidate()
            case .failure(let error):
                if let nfcError = error as? NfcError {
                    if (nfcError == .cancelled || nfcError == .timeout) {
                        session.invalidate()
                    } else {
                        session.invalidate(errorMessage: nfcError.message)
                    }
                } else {
                    session.invalidate(errorMessage: Strings.Nfc.Add.errorWriteFailed)
                }
            }
            
            continuation?.resume(with: result)
            continuation = nil
        }
    }
    
    enum NfcResult {
        case uuid(uuid: String, readOnly: Bool)
        case busy
    }
}

extension PrepareNfcTag._Implementation: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // not used because of readerSession(_, didDetect:)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        SALog.debug("Detection of NFC tag (tags: \(tags.count))")
        
        guard tags.count == 1 else {
            session.alertMessage = Strings.Nfc.Add.tooManyTags
            DispatchQueue.global().asyncAfter(deadline: .now() + PrepareNfcTag.retryInterval) {
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
                    self?.handleWritableTag(session, tag: tag, capacity: capacity)
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

extension PrepareNfcTag._Implementation {
    private func handleReadOnlyTag(_ session: NFCNDEFReaderSession, tag: NFCNDEFTag) {
        tag.readNDEF { [weak self] message, error in
            if let error {
                SALog.error("[NFC] Tag could not be read: \(error)")
                self?.finish(session, with: .failure(error))
                return
            }
            
            if let uuid = message.findUuid() {
                SALog.info("[NFC] Found SUPLA UUID: \(uuid)")
                self?.finish(session, with: .success(.uuid(uuid: uuid, readOnly: true)))
            } else {
                SALog.info("[NFC] No UUID found, quiting with notUsable error")
                self?.finish(session, with: .failure(NfcError.writeProtected))
            }
        }
    }
    
    private func handleWritableTag(_ session: NFCNDEFReaderSession, tag: NFCNDEFTag, capacity: Int) {
        tag.readNDEF { [weak self] message, error in
            if let error {
                SALog.error("[NFC] Tag could not be read: \(error)")
                self?.finish(session, with: .failure(error))
                return
            }
            
            if let uuid = message.findUuid() {
                SALog.info("[NFC] Found SUPLA UUID: \(uuid)")
                self?.finish(session, with: .success(.uuid(uuid: uuid, readOnly: false)))
                return
            }
            
            let uuid = UUID().uuidString.lowercased()
            guard let message = self?.prepareMessage(uuid) else {
                SALog.error("[NFC] Could not prepare message")
                self?.finish(session, with: .failure(NfcError.writeFailed))
                return
            }
            
            if (message.length > capacity) {
                SALog.error("[NFC] Tag has not enough capacity")
                self?.finish(session, with: .failure(NfcError.notEnoughSpace))
                return
            }
            
            tag.writeNDEF(message) { error in
                if let error {
                    SALog.error("[NFC] Tag could not be written: \(error)")
                    self?.finish(session, with: .failure(error))
                    return
                }
                
                SALog.info("[NFC] Wrote SUPLA UUID: \(uuid)")
                self?.finish(session, with: .success(.uuid(uuid: uuid, readOnly: false)))
            }
        }
    }
    
    private func prepareMessage(_ uuid: String) -> NFCNDEFMessage? {
        guard let urlRecord = NFCNDEFPayload.wellKnownTypeURIPayload(string: "https://supla.org/tag/\(uuid)") else { return nil }
        let androidMimeRecord = prepareAndroidMimeRecord(uuid)
        
        return NFCNDEFMessage(records: [androidMimeRecord, urlRecord])
    }
    
    private func prepareAndroidMimeRecord(_ uuid: String) -> NFCNDEFPayload {
        NFCNDEFPayload(
            format: .media,
            type: PrepareNfcTag.androidMimeType,
            identifier: Data(),
            payload: Data(uuid.utf8)
        )
    }
}

private func decodeTextPayload(_ record: NFCNDEFPayload) -> String? {
    guard record.typeNameFormat == .nfcWellKnown,
          let type = String(data: record.type, encoding: .utf8),
          type == "T" else { return nil }

    let payload = record.payload
    guard payload.count > 1 else { return nil }

    let languageCodeLength = Int(payload[0] & 0x3F)
    let textStartIndex = 1 + languageCodeLength
    let textData = payload.subdata(in: textStartIndex ..< payload.count)

    return String(data: textData, encoding: .utf8)
}
