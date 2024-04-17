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

import RxSwift

final class FacadeBlindsVM: BaseWindowVM<FacadeBlindsViewState> {
    @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
    @Singleton<ChannelConfigEventsManager> private var channelConfigEventsManager
    @Singleton<ExecuteFacadeBlindActionUseCase> private var executeFacadeBlindActionUseCase
    
    override func defaultViewState() -> FacadeBlindsViewState { FacadeBlindsViewState() }
    
    override func handleAction(_ action: RollerShutterAction, remoteId: Int32, type: SubjectType) {
        switch (action) {
        case .tiltTo(let tilt):
            updateView {
                if ($0.calibrating || $0.remoteId == nil) {
                    // Check for remote id is add to prevent calling the logic at the initialization time
                    // When setting value observer to the slider initial 0 is emitted
                    return $0
                }
                
                let markers: [FacadeBlindMarker] = if ($0.facadeBlindType == .tiltsOnlyWhenFullyClosed) {
                    []
                } else if ($0.windowState.position.isDifferent()) {
                    $0.facadeBlindWindowState.markers.map { marker in FacadeBlindMarker(position: marker.position, tilt: tilt) }
                } else {
                    []
                }
                let position: WindowGroupedValue = $0.facadeBlindType == .tiltsOnlyWhenFullyClosed ? .similar(100) : $0.windowState.position
                
                let windowState = $0.facadeBlindWindowState
                    .changing(path: \.position, to: position)
                    .changing(path: \.slatTilt, to: .similar(tilt))
                    .changing(path: \.markers, to: markers)
                return $0.changing(path: \.facadeBlindWindowState, to: windowState)
                    .changing(path: \.manualMoving, to: true)
                    .changing(path: \.positionUnknown, to: false)
            }
        case .tiltSetTo(let tilt):
            updateView {
                if ($0.calibrating) {
                    return $0
                }
                executeFacadeBlindActionUseCase
                    .invoke(action: .shutPartially, type: type, remoteId: remoteId, position: CGFloat(VALUE_IGNORE), tilt: tilt)
                    .run(self)
                
                return $0.changing(path: \.moveStartTime, to: nil)
                    .changing(path: \.manualMoving, to: false)
                    .changing(path: \.touchTime, to: nil)
            }
        case .moveAndTiltTo(let position, let tilt):
            updateView {
                if ($0.calibrating) {
                    return $0
                }
                let tilt: CGFloat? = if ($0.facadeBlindWindowState.slatTilt == nil) {
                    nil
                } else if ($0.facadeBlindType == .changesPositionWhileTilting) {
                    limitTilt(tilt: tilt, position: position, state: $0)
                } else if ($0.facadeBlindType != .tiltsOnlyWhenFullyClosed || position == 100) {
                    tilt
                } else {
                    0
                }
                let windowState = $0.facadeBlindWindowState
                    .changing(path: \.position, to: .similar(position))
                    .changing(path: \.slatTilt, to: tilt?.run { .similar($0) })
                    .changing(path: \.markers, to: [])
                return $0.changing(path: \.facadeBlindWindowState, to: windowState)
                    .changing(path: \.manualMoving, to: true)
                    .changing(path: \.positionUnknown, to: false)
            }
        case .moveAndTiltSetTo(let position, let tilt):
            updateView {
                if ($0.calibrating) {
                    return $0
                }
                let tilt: CGFloat = if ($0.facadeBlindWindowState.slatTilt == nil) {
                    CGFloat(VALUE_IGNORE)
                } else if ($0.facadeBlindType == .changesPositionWhileTilting) {
                    limitTilt(tilt: tilt, position: position, state: $0)
                } else if ($0.facadeBlindType != .tiltsOnlyWhenFullyClosed || position == 100) {
                    tilt
                } else {
                    0
                }
                
                executeFacadeBlindActionUseCase
                    .invoke(action: .shutPartially, type: type, remoteId: remoteId, position: position, tilt: tilt)
                    .run(self)
                
                return $0.changing(path: \.moveStartTime, to: nil)
                    .changing(path: \.manualMoving, to: false)
                    .changing(path: \.touchTime, to: nil)
            }
        default: super.handleAction(action, remoteId: remoteId, type: type)
        }
    }
    
    func observeConfig(_ remoteId: Int32, _ type: SubjectType) {
        if (type == .channel) {
            channelConfigEventsManager.observeConfig(id: remoteId)
                .filter { $0.config is SuplaChannelFacadeBlindConfig }
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.handleConfig($0) })
                .disposed(by: self)
        }
    }
    
    func loadConfig(_ remoteId: Int32, _ type: SubjectType) {
        if (type == .channel) {
            getChannelConfigUseCase.invoke(remoteId: remoteId, type: .defaultConfig).subscribe().disposed(by: self)
        }
    }
    
    override func handleChannel(_ channel: SAChannel) {
        guard let value = channel.value?.asFacadeBlindValue() else { return }
        
        updateView {
            if ($0.manualMoving) {
                return $0
            }
            
            let position = value.hasValidPosition ? value.position : 0
            let tilt = value.hasValidTilt && value.flags.contains(.tiltIsSet) ? CGFloat(value.tilt) : nil
            let windowState = $0.facadeBlindWindowState
                .changing(path: \.position, to: .similar(value.online ? CGFloat(position) : 25))
                .changing(path: \.slatTilt, to: tilt?.run { .similar(value.online ? $0 : 50) })
            
            return updateChannel($0, channel, value) {
                $0.changing(path: \.facadeBlindWindowState, to: windowState)
                    .changing(path: \.lastPosition, to: CGFloat(position))
            }
        }
    }
    
    override func handleGroup(_ group: SAChannelGroup, _ onlineSummary: GroupOnlineSummary) {
        updateView {
            if ($0.manualMoving) {
                return $0
            }
            
            let positions = group.getFacadeBlindPositions()
            let overallPosition = getGroupPercentage(positions, !$0.facadeBlindWindowState.markers.isEmpty) { CGFloat($0.position) }
            let overallTilt = getGroupPercentage(positions, !$0.facadeBlindWindowState.markers.isEmpty) { CGFloat($0.tilt) }
            let markers = (overallPosition.isDifferent() ? positions : [])
                .map { FacadeBlindMarker(position: CGFloat($0.position), tilt: CGFloat($0.tilt)) }
            let windowState = $0.facadeBlindWindowState
                .changing(path: \.position, to: group.isOnline() ? overallPosition : .similar(25))
                .changing(path: \.slatTilt, to: group.isOnline() ? overallTilt : .similar(50))
                .changing(path: \.markers, to: group.isOnline() ? markers : [])
                .changing(path: \.positionTextFormat, to: positionTextFormat)
            
            return updateGroup($0, group, onlineSummary) {
                $0.changing(path: \.facadeBlindWindowState, to: windowState)
                    .changing(path: \.positionUnknown, to: overallPosition == .invalid)
                    .changing(path: \.lastPosition, to: overallPosition.value)
            }
        }
    }
    
    override func canShowMoveTime(_ state: FacadeBlindsViewState) -> Bool {
        state.positionUnknown || state.facadeBlindWindowState.slatTilt == nil
    }
    
    private func handleConfig(_ config: ChannelConfigEvent) {
        guard let facadeConfig = config.config as? SuplaChannelFacadeBlindConfig else { return }
        
        let (tilt0, tilt100) = if (facadeConfig.tilt0Angle == facadeConfig.tilt100Angle) {
            (DEFAULT_TILT_0_ANGLE, DEFAULT_TILT_100_ANGLE)
        } else {
            (CGFloat(facadeConfig.tilt0Angle), CGFloat(facadeConfig.tilt100Angle))
        }
        
        updateView {
            let windowState = $0.facadeBlindWindowState
                .changing(path: \.tilt0Angle, to: tilt0)
                .changing(path: \.tilt100Angle, to: tilt100)
            return $0.changing(path: \.facadeBlindWindowState, to: windowState)
                .changing(path: \.tiltingTime, to: CGFloat(facadeConfig.tiltingTimeMs))
                .changing(path: \.openingTime, to: CGFloat(facadeConfig.openingTimeMs))
                .changing(path: \.closingTime, to: CGFloat(facadeConfig.closingTimeMs))
                .changing(path: \.facadeBlindType, to: facadeConfig.type)
        }
    }
    
    private func limitTilt(tilt: CGFloat, position: CGFloat, state: FacadeBlindsViewState) -> CGFloat {
        guard let tiltingTime = state.tiltingTime,
              let openingTime = state.openingTime,
              let closingTime = state.closingTime,
              let lastPosition = state.lastPosition
        else {
            return tilt
        }
        
        let time = position > lastPosition ? closingTime : openingTime
        let positionTime = time * position / 100

        if (positionTime < tiltingTime) {
            return min(tilt, 100 * positionTime / tiltingTime)
        }
        if (positionTime > time - tiltingTime) {
            return max(tilt, 100 - (100 * (time - positionTime) / tiltingTime))
        }

        return tilt
    }
}

private extension Completable {
    func run(_ viewModel: FacadeBlindsVM) {
        asDriverWithoutError()
            .drive()
            .disposed(by: viewModel)
    }
}

struct FacadeBlindsViewState: BaseWindowViewState {
    var facadeBlindType: SuplaTiltControlType? = nil
    var tiltingTime: CGFloat? = nil
    var openingTime: CGFloat? = nil
    var closingTime: CGFloat? = nil
    var lastPosition: CGFloat? = nil
    
    var remoteId: Int32? = nil
    var facadeBlindWindowState: FacadeBlindWindowState = .init(position: .similar(0))
    var issues: [ChannelIssueItem] = []
    var offline: Bool = true
    var showClosingPercentage: Bool = false
    var calibrating: Bool = false
    var calibrationPossible: Bool = false
    var positionUnknown: Bool = false
    var touchTime: CGFloat? = nil
    var isGroup: Bool = false
    var onlineStatusString: String? = nil
    var moveStartTime: TimeInterval? = nil
    var manualMoving: Bool = false
    
    var windowState: any WindowState {
        facadeBlindWindowState
    }
}

private extension SAChannelGroup {
    func getFacadeBlindPositions() -> [FacadeBlindGroupValue] {
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        return totalValue.values.compactMap { $0 as? FacadeBlindGroupValue }
    }
}
