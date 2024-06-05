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

class BaseBlindsViewModel<S: BaseBlindsViewState>: BaseWindowVM<S> {
    @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
    @Singleton<ChannelConfigEventsManager> private var channelConfigEventsManager
    @Singleton<ExecuteFacadeBlindActionUseCase> private var executeFacadeBlindActionUseCase
    @Singleton<ReadGroupTiltingDetailsUseCase> private var readGroupTiltingDetailsUseCase
    @Singleton<SuplaSchedulers> private var schedulers
    
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
        switch (type) {
        case .channel:
            getChannelConfigUseCase.invoke(remoteId: remoteId, type: .defaultConfig).subscribe().disposed(by: self)
        case .group:
            readGroupTiltingDetailsUseCase.invoke(remoteId: remoteId)
                .subscribe(on: schedulers.background)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.handleTiltingDetails($0) })
                .disposed(by: self)
        default: break
        }
    }
    
    override func handleAction(_ action: RollerShutterAction, remoteId: Int32, type: SubjectType) {
        switch (action) {
        case .tiltTo(let tilt):
            updateView {
                if ($0.calibrating || $0.remoteId == nil) {
                    // Check for remote id is add to prevent calling the logic at the initialization time
                    // When setting value observer to the slider initial 0 is emitted
                    return $0
                }
                
                let markers: [ShadingBlindMarker] = if ($0.tiltControlType == .tiltsOnlyWhenFullyClosed) {
                    []
                } else if ($0.windowState.position.isDifferent()) {
                    $0.blindWindowState.markers.map { marker in ShadingBlindMarker(position: marker.position, tilt: tilt) }
                } else {
                    []
                }
                let position: WindowGroupedValue = $0.tiltControlType == .tiltsOnlyWhenFullyClosed ? .similar(100) : $0.windowState.position

                return $0.updateWindowState(position: position, tilt: .similar(tilt), markers: markers)
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
                let tilt: CGFloat? = if ($0.blindWindowState.slatTilt == nil) {
                    nil
                } else if ($0.tiltControlType == .changesPositionWhileTilting) {
                    limitTilt(tilt: tilt, position: position, state: $0)
                } else if ($0.tiltControlType != .tiltsOnlyWhenFullyClosed || position == 100) {
                    tilt
                } else {
                    0
                }
                
                return $0.updateWindowState(position: .similar(position), tilt: tilt?.run { .similar($0) }, markers: [])
                    .changing(path: \.manualMoving, to: true)
                    .changing(path: \.positionUnknown, to: false)
            }
        case .moveAndTiltSetTo(let position, let tilt):
            updateView {
                if ($0.calibrating) {
                    return $0
                }
                let tilt: CGFloat = if ($0.blindWindowState.slatTilt == nil) {
                    CGFloat(VALUE_IGNORE)
                } else if ($0.tiltControlType == .changesPositionWhileTilting) {
                    limitTilt(tilt: tilt, position: position, state: $0)
                } else if ($0.tiltControlType != .tiltsOnlyWhenFullyClosed || position == 100) {
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
    
    private func limitTilt(tilt: CGFloat, position: CGFloat, state: any BaseBlindsViewState) -> CGFloat {
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
    
    private func handleConfig(_ config: ChannelConfigEvent) {
        guard let facadeConfig = config.config as? SuplaChannelFacadeBlindConfig else { return }
        
        let (tilt0, tilt100) = if (facadeConfig.tilt0Angle == facadeConfig.tilt100Angle) {
            (DEFAULT_TILT_0_ANGLE, DEFAULT_TILT_100_ANGLE)
        } else {
            (CGFloat(facadeConfig.tilt0Angle), CGFloat(facadeConfig.tilt100Angle))
        }
        
        updateView {
            return $0.updateTiltAngles(tilt0: tilt0, tilt100: tilt100)
                .changing(path: \.tiltingTime, to: CGFloat(facadeConfig.tiltingTimeMs))
                .changing(path: \.openingTime, to: CGFloat(facadeConfig.openingTimeMs))
                .changing(path: \.closingTime, to: CGFloat(facadeConfig.closingTimeMs))
                .changing(path: \.tiltControlType, to: facadeConfig.type)
        }
    }
    
    private func handleTiltingDetails(_ details: TiltingDetails) {
        switch (details) {
        case .similar(let tilt0Angle, let tilt100Angle, let tiltControlType):
            updateView {
                $0.updateTiltAngles(tilt0: CGFloat(tilt0Angle), tilt100: CGFloat(tilt100Angle))
                    .changing(path: \.tiltControlType, to: tiltControlType)
            }
        default:
            SALog.info("Tilting details differs from Similar: \(details)")
        }
    }
}

private extension Completable {
    func run<T: BaseBlindsViewState>(_ viewModel: BaseBlindsViewModel<T>) {
        asDriverWithoutError()
            .drive()
            .disposed(by: viewModel)
    }
}

protocol BaseBlindsViewState: BaseWindowViewState {
    var tiltControlType: SuplaTiltControlType? { get set }
    var tiltingTime: CGFloat? { get set }
    var openingTime: CGFloat? { get set }
    var closingTime: CGFloat? { get set }
    var lastPosition: CGFloat? { get set }
    
    func updateWindowState(position: WindowGroupedValue, tilt: WindowGroupedValue?, markers: [ShadingBlindMarker]) -> Self
    func updateTiltAngles(tilt0: CGFloat, tilt100: CGFloat) -> Self
    
    var blindWindowState: any ShadingBlindWindowState { get }
}
