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
import SharedCore

final class FacadeBlindsVM: BaseBlindsViewModel<FacadeBlindsViewState> {
    @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
    @Singleton<ChannelConfigEventsManager> private var channelConfigEventsManager
    @Singleton<ExecuteFacadeBlindActionUseCase> private var executeFacadeBlindActionUseCase
    
    override func defaultViewState() -> FacadeBlindsViewState { FacadeBlindsViewState() }
    
    override func handleChannel(_ channel: SAChannel) {
        guard let value = channel.value?.asFacadeBlindValue() else { return }
        
        updateView {
            if ($0.manualMoving) {
                return $0
            }
            
            let position = value.hasValidPosition() ? value.position : 0
            let tilt = value.hasValidTilt() && value.flags.contains(.tiltIsSet) ? CGFloat(value.tilt) : nil
            let windowState = $0.facadeBlindWindowState
                .changing(path: \.position, to: .similar(value.status.online ? CGFloat(position) : 25))
                .changing(path: \.slatTilt, to: tilt?.run { .similar(value.status.online ? $0 : 50) })
            
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
            let overallTilt = positions.map { CGFloat($0.tilt) }.max() ?? 0
            let markers = (overallPosition.isDifferent() ? positions : [])
                .map { ShadingBlindMarker(position: CGFloat($0.position), tilt: CGFloat($0.tilt)) }
            let windowState = $0.facadeBlindWindowState
                .changing(path: \.position, to: group.status().online ? overallPosition : .similar(25))
                .changing(path: \.slatTilt, to: group.status().online ? .similar(overallTilt) : .similar(50))
                .changing(path: \.markers, to: group.status().online ? markers : [])
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
}

struct FacadeBlindsViewState: BaseBlindsViewState {
    var tiltControlType: SuplaTiltControlType? = nil
    var tiltingTime: CGFloat? = nil
    var openingTime: CGFloat? = nil
    var closingTime: CGFloat? = nil
    var lastPosition: CGFloat? = nil
    
    var remoteId: Int32? = nil
    var facadeBlindWindowState: FacadeBlindWindowState = .init(position: .similar(0))
    var issues: [ChannelIssueItem] = []
    var offline: Bool = true
    var positionPresentation: ShadingSystemPositionPresentation = .asClosed
    var calibrating: Bool = false
    var calibrationPossible: Bool = false
    var positionUnknown: Bool = false
    var touchTime: CGFloat? = nil
    var isGroup: Bool = false
    var onlineStatusString: String? = nil
    var moveStartTime: TimeInterval? = nil
    var manualMoving: Bool = false
    
    var windowState: any WindowState { facadeBlindWindowState }
    
    var blindWindowState: any ShadingBlindWindowState { facadeBlindWindowState }
    
    func updateWindowState(position: WindowGroupedValue, tilt: WindowGroupedValue?, markers: [ShadingBlindMarker]) -> FacadeBlindsViewState {
        let windowState = facadeBlindWindowState
            .changing(path: \.position, to: position)
            .changing(path: \.slatTilt, to: tilt)
            .changing(path: \.markers, to: markers)
        
        return changing(path: \.facadeBlindWindowState, to: windowState)
    }
    
    func updateTiltAngles(tilt0: CGFloat, tilt100: CGFloat) -> FacadeBlindsViewState {
        let windowState = facadeBlindWindowState
            .changing(path: \.tilt0Angle, to: tilt0)
            .changing(path: \.tilt100Angle, to: tilt100)
        
        return changing(path: \.facadeBlindWindowState, to: windowState)
    }
}

private extension SAChannelGroup {
    func getFacadeBlindPositions() -> [ShadowingBlindGroupValue] {
        guard let totalValue = total_value as? GroupTotalValue else { return [] }
        return totalValue.values.compactMap { $0 as? ShadowingBlindGroupValue }
    }
}
