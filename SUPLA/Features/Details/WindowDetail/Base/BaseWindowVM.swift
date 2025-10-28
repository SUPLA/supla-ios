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

class BaseWindowVM<S: BaseWindowViewState>: BaseViewModel<S, BaseWindowViewEvent> {
    @Singleton<ReadChannelByRemoteIdUseCase> var readChannelByRemoteIdUseCase
    @Singleton<GlobalSettings> var settings
    
    @Singleton<ReadGroupByRemoteIdUseCase> private var readGroupByRemoteIdUseCase
    @Singleton<ExecuteSimpleActionUseCase> private var executeSimpleActionUseCase
    @Singleton<CallSuplaClientOperationUseCase> private var callSuplaClientOperationUseCase
    @Singleton<ExecuteRollerShutterActionUseCase> private var executeRollerShutterActionUseCase
    @Singleton<GetGroupOnlineSummaryUseCase> private var getGroupOnlineSummaryUseCase
    @Singleton<DateProvider> private var dateProvider
    
    var positionTextFormat: WindowGroupedValueFormat {
        if (settings.showOpeningPercent) {
            .openingPercentage
        } else {
            .percentage
        }
    }
    
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
            updateView { updateMoveStartTime($0) }
            callSuplaClientOperationUseCase.invoke(remoteId: remoteId, type: type, operation: .moveUp).run(self)
        case .moveDown:
            updateView { updateMoveStartTime($0) }
            callSuplaClientOperationUseCase.invoke(remoteId: remoteId, type: type, operation: .moveDown).run(self)
        case .stop:
            updateView { calculateMoveTime($0).changing(path: \.manualMoving, to: false) }
            executeSimpleActionUseCase.invoke(action: .stop, type: type, remoteId: remoteId).run(self)
        case .openAt(let position):
            updateView {
                if ($0.calibrating) {
                    // During calibration the open/close time is not known so it's not possible to open window at expected position
                    return $0
                } else {
                    executeRollerShutterActionUseCase.invoke(action: .shutPartially, type: type, remoteId: remoteId, percentage: position.roundToInt()).run(self)
                    return $0.changing(path: \.moveStartTime, to: nil)
                        .changing(path: \.manualMoving, to: false)
                        .changing(path: \.touchTime, to: nil)
                }
            }
        case .calibrate:
            send(event: .showCalibrationDialog)
        default:
            break // should be handled in child classes
        }
    }
    
    func showAuthorizationDialog() {
        send(event: .showAuthorizationDialog)
    }
    
    func startCalibration(_ remoteId: Int32, _ type: SubjectType) {
        callSuplaClientOperationUseCase.invoke(remoteId: remoteId, type: type, operation: .recalibrate).run(self)
    }
    
    func positionToString(_ position: CGFloat) -> String {
        switch (getPositionPresentation()) {
        case .asOpened: String(format: "%.0f%%", 100 - position)
        default: String(format: "%.0f%%", position)
        }
    }
    
    private func loadChannel(_ remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(onNext: { [weak self] channel in self?.handleChannel(channel) })
            .disposed(by: self)
    }
    
    func updateChannel(_ state: S, _ channel: SAChannel, _ value: ShadingSystemValue, _ customHandler: (S) -> S) -> S {
        customHandler(
            state
                .changing(path: \.remoteId, to: channel.remote_id)
                .changing(path: \.issues, to: createIssues(value.flags))
                .changing(path: \.offline, to: !value.status.online)
                .changing(path: \.positionPresentation, to: getPositionPresentation())
                .changing(path: \.positionUnknown, to: !value.hasValidPosition())
                .changing(path: \.calibrating, to: value.flags.contains(.calibrationInProgress))
                .changing(path: \.calibrationPossible, to: (channel.flags & Int64(SUPLA_CHANNEL_FLAG_CALCFG_RECALIBRATE)) > 0)
        )
    }
    
    func handleChannel(_ channel: SAChannel) {
        fatalError("handleChannel(channel:) needs to be implemented!")
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
    
    func updateGroup(_ state: S, _ group: SAChannelGroup, _ onlineSummary: GroupOnlineSummary, _ customHandler: (S) -> S) -> S {
        customHandler(
            state.changing(path: \.remoteId, to: group.remote_id)
                .changing(path: \.offline, to: group.status().offline)
                .changing(path: \.positionPresentation, to: getPositionPresentation())
                .changing(path: \.calibrating, to: false)
                .changing(path: \.calibrationPossible, to: false)
                .changing(path: \.isGroup, to: true)
                .changing(path: \.onlineStatusString, to: "\(onlineSummary.onlineCount)/\(onlineSummary.count)")
        )
    }
    
    func handleGroup(_ group: SAChannelGroup, _ onlineSummary: GroupOnlineSummary) {
        fatalError("handleGroup(group:,onlineSUmmary:) needs to be implemented!")
    }
    
    func createIssues(_ flags: [SuplaShadingSystemFlag]) -> [ChannelIssueItem] {
        flags.filter { $0.isIssueFlag() }
            .map { $0.asChannelIssues() }
            .compactMap { $0 }
    }
    
    func canShowMoveTime(_ state: S) -> Bool {
        state.positionUnknown
    }
    
    func getPositionPresentation() -> ShadingSystemPositionPresentation {
        settings.showOpeningPercent ? .asOpened : .asClosed
    }
    
    private func updateMoveStartTime(_ state: S) -> S {
        if (canShowMoveTime(state)) {
            return state.changing(path: \.moveStartTime, to: dateProvider.currentTimestamp())
                .changing(path: \.touchTime, to: nil)
        }
        
        return state
    }
    
    private func calculateMoveTime(_ state: S) -> S {
        if canShowMoveTime(state),
           let startTime = state.moveStartTime
        {
            let timeDiffSecs = dateProvider.currentTimestamp() - startTime
            return state.changing(path: \.moveStartTime, to: nil)
                .changing(path: \.touchTime, to: CGFloat(timeDiffSecs))
        }

        return state
    }
    
    func getGroupPercentage<T>(_ values: [T], _ hadMarkers: Bool, _ extractor: ((T) -> CGFloat)? = nil) -> WindowGroupedValue {
        var lastValue: CGFloat? = nil
        var minValue: CGFloat? = nil
        var maxValue: CGFloat? = nil
        
        for value in values {
            let floatValue: CGFloat = value is CGFloat ? value as! CGFloat : extractor!(value)
            
            if (minValue == nil || minValue! > floatValue) {
                minValue = floatValue
            }
            if (maxValue == nil || maxValue! < floatValue) {
                maxValue = floatValue
            }

            if (lastValue == nil) {
                lastValue = floatValue
            }
        }
        
        if (lastValue == nil || lastValue == -1) {
            return .invalid
        } else {
            if let min = minValue, let max = maxValue {
                if ((hadMarkers && abs(min - max) > 3) || abs(min - max) > 5) {
                    return .different(min: min, max: max)
                }
            }
            
            return .similar(lastValue!)
        }
    }
}

private extension Observable {
    func run<T: BaseWindowViewState>(_ viewModel: BaseWindowVM<T>) {
        asDriverWithoutError()
            .drive()
            .disposed(by: viewModel)
    }
}

private extension Completable {
    func run<T: BaseWindowViewState>(_ viewModel: BaseWindowVM<T>) {
        asDriverWithoutError()
            .drive()
            .disposed(by: viewModel)
    }
}

enum ShadingSystemOrientation {
    case vertical, horizontal
}

enum BaseWindowViewEvent: ViewEvent {
    case showCalibrationDialog
    case showAuthorizationDialog
}

protocol BaseWindowViewState: ViewState {
    var remoteId: Int32? { get set }
    var windowState: WindowState { get }
    
    var issues: [ChannelIssueItem] { get set }
    var offline: Bool { get set }
    var positionPresentation: ShadingSystemPositionPresentation { get set }
    var calibrating: Bool { get set }
    var calibrationPossible: Bool { get set }
    var positionUnknown: Bool { get set }
    var touchTime: CGFloat? { get set }
    var isGroup: Bool { get set }
    var onlineStatusString: String? { get set }
    
    var moveStartTime: TimeInterval? { get set }
    var manualMoving: Bool { get set }
}
