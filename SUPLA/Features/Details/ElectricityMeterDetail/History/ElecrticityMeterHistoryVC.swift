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

import SwiftUI
    
extension ElectricityMeterHistoryFeature {
    class ViewController: BaseHistoryDetailVC {
        
        private lazy var introductionViewController: UIHostingController = {
            let viewModel = (viewModel as! ViewModel)
            let view = UIHostingController(rootView: IntroductionView(
                viewState: viewModel.introductionState,
                onClose: viewModel.closeIntroductionView
            ))
            view.view.translatesAutoresizingMaskIntoConstraints = false
            view.view.backgroundColor = .clear
            view.view.isHidden = true
            return view
        }()
        
        init(viewModel: ViewModel, item: ItemBundle, navigationItemProvider: NavigationItemProvider) {
            super.init(remoteId: item.remoteId, navigationItemProvider: navigationItemProvider)
            self.viewModel = viewModel
            
            setupView()
        }
        
        override func showDataSelectionDialog(_ channelSets: ChannelChartSets, _ filters: CustomChartFiltersContainer?) {
            guard let filters = filters?.filters as? ElectricityChartFilters else { return }
            if (filters.availableTypes.count == 1 && filters.availablePhases.count == 1) {
                return
            }
            
            let dialog = ElectricityDataSelectionFeature.ViewController.create(name: channelSets.name, filters: filters)
            dialog.onFinishCallback = { [weak self] type, phases in
                if let viewModel = self?.viewModel as? ElectricityMeterHistoryFeature.ViewModel {
                    viewModel.onDataSelectionChange(type: type, phases: phases)
                }
            }
            present(dialog, animated: true)
        }
        
        override func handle(state: BaseHistoryDetailViewState) {
            super.handle(state: state)
            introductionViewController.view.isHidden = !state.showIntroduction
        }
        
        private func setupView() {
            addChild(introductionViewController)
            view.addSubview(introductionViewController.view)
            introductionViewController.didMove(toParent: self)
            
            NSLayoutConstraint.activate([
                introductionViewController.view!.topAnchor.constraint(equalTo: view.topAnchor),
                introductionViewController.view!.leftAnchor.constraint(equalTo: view.leftAnchor),
                introductionViewController.view!.rightAnchor.constraint(equalTo: view.rightAnchor),
                introductionViewController.view!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        static func create(item: ItemBundle, navigationItemProvider: NavigationItemProvider) -> UIViewController {
            ViewController(viewModel: ViewModel(), item: item, navigationItemProvider: navigationItemProvider)
        }
    }
}
