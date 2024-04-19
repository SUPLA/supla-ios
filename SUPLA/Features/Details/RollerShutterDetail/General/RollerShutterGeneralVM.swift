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

class RollerShutterGeneralVM: BaseViewModel<RollerShutterGeneralViewState, RollerShutterGeneralViewEvent> {
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<ReadGroupByRemoteIdUseCase> private var readGroupByRemoteIdUseCase
    @Singleton<ExecuteSimpleActionUseCase> private var executeSimpleActionUseCase
    @Singleton<CallSuplaClientOperationUseCase> private var callSuplaClientOperationUseCase
    @Singleton<ExecuteRollerShutterActionUseCase> private var executeRollerShutterActionUseCase
    @Singleton<GetGroupOnlineSummaryUseCase> private var getGroupOnlineSummaryUseCase
    @Singleton<GlobalSettings> private var settings
    @Singleton<DateProvider> private var dateProvider
    
    override func defaultViewState() -> RollerShutterGeneralViewState { RollerShutterGeneralViewState() }
    
    func loadData(remoteId: Int32, type: SubjectType) {
        switch (type) {
        case .channel: loadChannel(remoteId)
        case .group: loadGroup(remoteId)
        default: break
        }
    }
    
    func handleAction(_ action: RollerShutterAction, remoteId: Int32, type: SubjectType) {
        switch (action) {
        case .open:
            updateView {
                $0.changing(path: \.moveStartTime, to: nil)
                    .changing(path: \.touchTime, to: nil)
                    .changing(path: \.manualMoving, to: false)
            }
            executeSimpleActionUseCase.invoke(action: .reveal, type: type, remoteId: remoteId).run(self)
        case .close:
            updateView {
                $0.changing(path: \.moveStartTime, to: nil)
                    .changing(path: \.touchTime, to: nil)
                    .changing(path: \.manualMoving, to: false)
            }
            executeSimpleActionUseCase.invoke(action: .shut, type: type, remoteId: remoteId).run(self)
        case .moveUp:
            updateView { $0.updateMoveStartTime(dateProvider) }
            callSuplaClientOperationUseCase.invoke(remoteId: remoteId, type: type, operation: .moveUp).run(self)
        case .moveDown:
            updateView { $0.updateMoveStartTime(dateProvider) }
            callSuplaClientOperationUseCase.invoke(remoteId: remoteId, type: type, operation: .moveDown).run(self)
        case .stop:
            updateView { $0.calculateMoveTime(dateProvider).changing(path: \.manualMoving, to: false) }
            executeSimpleActionUseCase.invoke(action: .stop, type: type, remoteId: remoteId).run(self)
        case .openAt(let position):
            updateView {
                if ($0.calibrating) {
                    // During calibration the open/close time is not known so it's not possible to open window at expected position
                    return $0
                } else {
                    executeRollerShutterActionUseCase.invoke(action: .shutPartially, type: type, remoteId: remoteId, percentage: position).run(self)
                    return $0.changing(path: \.moveStartTime, to: nil)
                        .changing(path: \.manualMoving, to: false)
                        .changing(path: \.touchTime, to: nil)
                }
            }
        case .calibrate:
            send(event: .showCalibrationDialog)
        }
    }
    
    func showCalibrationDialog() {
        send(event: .showAuthorizationDialog)
    }
    
    func startCalibration(_ remoteId: Int32, _ type: SubjectType) {
        callSuplaClientOperationUseCase.invoke(remoteId: remoteId, type: type, operation: .recalibrate).run(self)
    }
    
    func positionToString(_ position: CGFloat) -> String {
        let showOpening = settings.showOpeningPercent
        return String(format: "%.0f%%", showOpening ? (100 - position) : position)
    }
    
    private func loadChannel(_ remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(onNext: { [weak self] channel in self?.handleChannel(channel) })
            .disposed(by: self)
    }
    
    private func handleChannel(_ channel: SAChannel) {
        guard let value = channel.value?.asRollerShutterValue() else { return }
        
        updateView {
            if ($0.manualMoving) {
                return $0
            }
            
            let position = value.hasValidPosition ? value.position : 0
            let showOpening = settings.showOpeningPercent
            let windowState = WindowState(
                position: value.online ? CGFloat(position) : 25,
                bottomPosition: CGFloat(value.bottomPosition)
            )
            
            return $0
                .changing(path: \.remoteId, to: channel.remote_id)
                .changing(path: \.windowState, to: windowState)
                .changing(path: \.issues, to: createIssues(value.flags))
                .changing(path: \.offline, to: !value.online)
                .changing(path: \.showClosingPercentage, to: !showOpening)
                .changing(path: \.positionUnknown, to: !value.hasValidPosition)
                .changing(path: \.calibrating, to: value.flags.contains(.calibrationInProgress))
                .changing(path: \.calibrationPossible, to: (channel.flags & Int64(SUPLA_CHANNEL_FLAG_CALCFG_RECALIBRATE)) > 0)
                .changing(path: \.positionText, to: positionToString(CGFloat(position)))
                .changing(path: \.isGroup, to: false)
        }
    }
    
    private func loadGroup(_ remoteId: Int32) {
        Observable.zip(
            readGroupByRemoteIdUseCase.invoke(remoteId: remoteId),
            getGroupOnlineSummaryUseCase.invoke(remoteId: remoteId)
        ) { group, summary in (group, summary) }
            .asDriverWithoutError()
            .drive(onNext: { [weak self] (group, summary) in self?.handleGroup(group, summary) })
            .disposed(by: self)
    }
    
    private func handleGroup(_ group: SAChannelGroup, _ onlineSummary: GroupOnlineSummary) {
        updateView {
            if ($0.manualMoving) {
                return $0
            }
            
            let positions = group.getRollerShutterPositions()
            let overallPosition = getGroupPercentage(positions, !$0.windowState.markers.isEmpty)
            let showOpening = self.settings.showOpeningPercent
            let markers: [CGFloat] = switch (overallPosition) {
            case .different(_, _): positions
            default: []
            }
            let windowState = WindowState(
                position: group.isOnline() ? CGFloat(overallPosition.position) : 25,
                markers: markers
            )
            
            return $0
                .changing(path: \.remoteId, to: group.remote_id)
                .changing(path: \.windowState, to: windowState)
                .changing(path: \.offline, to: !group.isOnline())
                .changing(path: \.showClosingPercentage, to: !showOpening)
                .changing(path: \.positionUnknown, to: overallPosition == .invalid)
                .changing(path: \.calibrating, to: false)
                .changing(path: \.calibrationPossible, to: false)
                .changing(path: \.positionText, to: overallPosition.toString(showOpening))
                .changing(path: \.isGroup, to: true)
                .changing(path: \.onlineStatusString, to: "\(onlineSummary.onlineCount)/\(onlineSummary.count)")
        }
    }
    
    private func createIssues(_ flags: [SuplaRollerShutterFlag]) -> [ChannelIssueItem] {
        flags.filter { $0.issueFlag }
            .map { ChannelIssueItem(issueIconType: $0.issueIconType!, description: $0.issueDescription!) }
    }
    
    private func getGroupPercentage(_ positions: [CGFloat], _ hadMarkers: Bool) -> GroupPercentage {
        var percentage: CGFloat? = nil
        var minPercentage: CGFloat? = nil
        var maxPercentage: CGFloat? = nil
        
        for position in positions {
            if (minPercentage == nil || minPercentage! > position) {
                minPercentage = position
            }
            if (maxPercentage == nil || maxPercentage! < position) {
                maxPercentage = position
            }

            if (percentage == nil) {
                percentage = position
            }
        }
        
        if (percentage == nil || percentage == -1) {
            return .invalid
        } else {
            if let min = minPercentage,
               let max = maxPercentage
            {
                if ((hadMarkers && abs(min - max) > 3) || abs(min - max) > 5) {
                    return .different(min: min, max: max)
                }
            }
            return .similar(position: percentage!)
        }
    }
    
    private enum GroupPercentage: Equatable {
        case invalid
        case similar(position: CGFloat)
        case different(min: CGFloat, max: CGFloat)
        
        var position: CGFloat {
            switch (self) {
            case .similar(let position): position
            default: 0
            }
        }
        
        func toString(_ showOpening: Bool) -> String {
            switch (self) {
            case .invalid:
                return "---"
            case .similar(let position):
                return String(format: "%.0f%%", showOpening ? 100 - position : position)
            case .different(let min, let max):
                return String(
                    format: "%.0f%% - %.0f%%",
                    showOpening ? 100 - min : min,
                    showOpening ? 100 - max : max
                )
            }
        }
    }
}

private extension Observable {
    func run(_ viewModel: RollerShutterGeneralVM) {
        asDriverWithoutError()
            .drive()
            .disposed(by: viewModel)
    }
}

private extension Completable {
    func run(_ viewModel: RollerShutterGeneralVM) {
        asDriverWithoutError()
            .drive()
            .disposed(by: viewModel)
    }
}

enum RollerShutterGeneralViewEvent: ViewEvent {
    case showCalibrationDialog
    case showAuthorizationDialog
}

struct RollerShutterGeneralViewState: ViewState {
    var remoteId: Int32? = nil
    var windowState: WindowState = .init(position: 0)
    var issues: [ChannelIssueItem] = []
    var offline: Bool = true
    var showClosingPercentage: Bool = false
    var calibrating: Bool = false
    var calibrationPossible: Bool = false
    var positionUnknown: Bool = false
    var touchTime: CGFloat? = nil
    var isGroup: Bool = false
    var onlineStatusString: String? = nil
    var positionText: String = ""
    
    var moveStartTime: TimeInterval? = nil
    var manualMoving: Bool = false
    
    func updateMoveStartTime(_ dateProvider: DateProvider) -> RollerShutterGeneralViewState {
        if (positionUnknown) {
            return changing(path: \.moveStartTime, to: dateProvider.currentTimestamp())
                .changing(path: \.touchTime, to: nil)
        }
        
        return self
    }
    
    func calculateMoveTime(_ dateProvider: DateProvider) -> RollerShutterGeneralViewState {
        if (positionUnknown) {
            if let startTime = moveStartTime {
                let timeDiffSecs = dateProvider.currentTimestamp() - startTime
                return changing(path: \.moveStartTime, to: nil)
                    .changing(path: \.touchTime, to: CGFloat(timeDiffSecs))
            }
        }
        
        return self
    }
}

private extension SAChannelGroup {
    func getRollerShutterPositions() -> [CGFloat] {
        guard let positions = total_value as? [NSObject] else { return [] }
        
        var result: [CGFloat] = []
        for object in positions {
            guard let itemData = object as? [NSObject] else { continue }
            
            if (itemData.count == 2),
               let position = itemData[0] as? Int,
               let sensor = itemData[1] as? Int
            {
                if (position < 100 && sensor == 1) {
                    result.append(100)
                } else {
                    result.append(CGFloat(position))
                }
            }
        }
        
        return result
    }
}
