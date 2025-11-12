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

import SharedCore
import SwiftUI

class ChannelListVC: ChannelBaseTableViewController<ChannelListState, ChannelListViewEvent, ChannelListViewModel> {
    @Singleton<SuplaAppCoordinator> private var coordinator
    
    private lazy var stateViewModel: StateDialogFeature.ViewModel = {
        let viewModel = StateDialogFeature.ViewModel { [weak self] in
            self?.showAuthorizationLightSourceLifespanSettings($0, $1, $2)
        }
        viewModel.presentationCallback = { [weak self] shown in
            self?.overlay.view.isHidden = !shown
        }
        return viewModel
    }()
    
    private lazy var overlay: UIHostingController = {
        let view = UIHostingController(rootView: ChannelListView(
            stateDialogViewModel: stateViewModel,
            captionChangeDialogViewModel: captionChangeViewModel,
            channelListViewState: viewModel.channelListViewState,
            onAlertConfirmed: { [weak self] in self?.viewModel.forceAction($1, remoteId: $0) },
            onAlertDismissed: { [weak self] in self?.viewModel.dismissAlertDialog() }
        ))
        view.view.translatesAutoresizingMaskIntoConstraints = false
        view.view.backgroundColor = .clear
        view.view.isHidden = true
        return view
    }()
    
    init() {
        super.init(viewModel: ChannelListViewModel())
        viewModel.presentationCallback = { [weak self] in self?.overlay.view.isHidden = !$0 }
        setupView()
    }
    
    @available(*, unavailable)
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getCollapsedFlag() -> CollapsedFlag { .channel }
    
    override func setOverlayHidden(_ hidden: Bool) {
        overlay.view.isHidden = hidden
    }
    
    override func handle(event: ChannelListViewEvent) {
        switch (event) {
        case .navigateToDetail(let legacyDetailType, let channelBase):
            coordinator.navigateToLegacyDetail(legacyDetailType, channelBase: channelBase)
        case .navigateToSwitchDetail(let item, let pages):
            coordinator.navigateToSwitchDetail(item: item, pages: pages)
        case .navigateToThermostatDetail(let item, let pages):
            coordinator.navigateToThermostatDetail(item: item, pages: pages)
        case .navigateToThermometerDetail(let item, let pages):
            coordinator.navigateToThermometerDetail(item: item, pages: pages)
        case .navigateToGpmDetail(let item, let pages):
            coordinator.navigateToGpmDetail(item: item, pages: pages)
        case .navigateToRollerShutterDetail(let item, let pages):
            coordinator.navigateToWindowDetail(item: item, pages: pages)
        case .navigateToElectricityMeterDetail(let item, let pages):
            coordinator.navigateToElectricityMeterDetail(item: item, pages: pages)
        case .navigateToImpulseCounterDetail(let item, let pages):
            coordinator.navigateToImpulseCounterDetail(item: item, pages: pages)
        case .navigateToHumidityDetail(let item, let pages):
            coordinator.navigateToHumidityDetail(item: item, pages: pages)
        case .navigateToValveDetail(let item, let pages):
            coordinator.navigateToValveDetail(item: item, pages: pages)
        case .navigateToContainerDetail(let item, let pages):
            coordinator.navigateToContainerDetail(item: item, pages: pages)
        case .navigateToGateDetail(let item, let pages):
            coordinator.navigateToGateDetail(item: item, pages: pages)
        case .showAddWizard:
            coordinator.navigateToAddWizard()
        }
    }
    
    override func handle(state: ChannelListState) {
        overlay.view.isHidden = state.overlayHidden
    }
    
    override func configureCell(channelBase: SAChannelBase, children: [ChannelChild], indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(channelBase: channelBase, children: children, indexPath: indexPath)
        
        if let channelCell = cell as? SAChannelCell {
            channelCell.delegate = self
        }
        if let baseCell = cell as? MGSwipeTableCell {
            baseCell.delegate = self
        }
        
        return cell
    }
    
    override func showEmptyMessage(_ tableView: UITableView?) {
        guard let tableView = tableView else { return }
        tableView.backgroundView = createNoContentView(Strings.Menu.addDevice, withDeviceCatalog: BrandingConfiguration.Menu.DEVICES_OPTION_VISIBLE)
    }
    
    private func setupView() {
        viewModel.bind(noContentButton.rx.tap) { [weak self] in self?.viewModel.onNoContentButtonClicked() }
        noContentDevicesButton.rx.tap
            .asDriverWithoutError()
            .drive(onNext: { [weak self] in self?.coordinator.navigateToDeviceCatalog() })
            .disposed(by: self)
        setupOverlay(overlay)
    }
}

extension ChannelListVC: SAChannelCellDelegate {
    func channelButtonClicked(_ cell: SAChannelCell!) {}
    
    func channelCaptionLongPressed(_ remoteId: Int32) {
        vibrationService.vibrate()
        captionChangeViewModel.show(self, channelRemoteId: remoteId)
    }
    
    func infoIconPressed(_ remoteId: Int32) {
        stateViewModel.show(remoteId: remoteId)
    }
}

extension ChannelListVC: BaseCellDelegate {
    func onButtonTapped(buttonType: CellButtonType, remoteId: Int32, data: Any?) {
        viewModel.onButtonClicked(buttonType: buttonType, data: data)
    }
    
    func onIssuesIconTapped(issues: ListItemIssues) {
        viewModel.showAlert(issues.message)
    }
    
    func onCaptionLongPress(_ remoteId: Int32) {
        vibrationService.vibrate()
        captionChangeViewModel.show(self, channelRemoteId: remoteId)
    }
    
    func onInfoIconTapped(_ channel: SAChannel) {
        stateViewModel.show(remoteId: channel.remote_id)
    }
}
