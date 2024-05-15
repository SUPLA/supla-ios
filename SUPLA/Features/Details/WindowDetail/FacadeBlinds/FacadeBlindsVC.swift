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

final class FacadeBlindsVC: BaseWindowVC<FacadeBlindWindowState, FacadeBlindsView, FacadeBlindsViewState, FacadeBlindsVM> {
    init(itemBundle: ItemBundle) {
        super.init(itemBundle: itemBundle, viewModel: FacadeBlindsVM())
    }
    
    override func getWindowView() -> FacadeBlindsView { FacadeBlindsView() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.observeConfig(itemBundle.remoteId, itemBundle.subjectType)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadConfig(itemBundle.remoteId, itemBundle.subjectType)
    }
    
    override func handle(state: FacadeBlindsViewState) {
        windowView.windowState = state.facadeBlindWindowState
        
        topView.valueBottom = state.facadeBlindWindowState.slatTiltText
        
        slatTiltSlider.isHidden = false
        slatTiltSlider.isEnabled = !state.offline && state.facadeBlindWindowState.slatTilt != nil
        slatTiltSlider.value = Float(state.facadeBlindWindowState.slatTilt?.value ?? 0)
        slatTiltSlider.minDegree = state.facadeBlindWindowState.tilt0Angle?.float ?? SlatTiltSlider.defaultMinDegrees
        slatTiltSlider.maxDegree = state.facadeBlindWindowState.tilt100Angle?.float ?? SlatTiltSlider.defaultMaxDegrees
        
        super.handle(state: state)
    }
    
    override func setupWindowGesturesObservers() {
        viewModel.bind(windowView.rx.positionAndTilt) { [weak self] point in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(
                .moveAndTiltTo(position: point.y, tilt: point.x),
                remoteId: bundle.remoteId,
                type: bundle.subjectType
            )
        }
        
        viewModel.bind(windowView.rx.positionAndTiltSet) { [weak self] point in
            guard let bundle = self?.itemBundle else { return }
            self?.viewModel.handleAction(
                .moveAndTiltSetTo(position: point.y, tilt: point.x),
                remoteId: bundle.remoteId,
                type: bundle.subjectType
            )
        }
    }
}
