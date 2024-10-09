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

extension ElectricityDataSelectionFeature {
    class ViewController: SuplaCore.Dialog.BaseViewController<ViewState, View, ViewModel> {
        var onFinishCallback: ((ElectricityMeterChartType, [Phase]) -> Void)? = nil

        override init(viewModel: ViewModel) {
            super.init(viewModel: viewModel)

            contentView = View(
                viewState: viewModel.state,
                onTypeChange: { [weak self] in
                    self?.viewModel.onTypeChange($0)
                    self?.setNeedsUpdateConstraints()
                },
                onOk: { [weak self] in
                    if let callback = self?.onFinishCallback {
                        let phases = viewModel.state.selectablePhases
                            .filter { $0.selected }
                            .map { $0.item }

                        callback(viewModel.state.selectedType, phases)
                    }
                    self?.dismiss(animated: true)
                },
                onCancel: { [weak self] in self?.dismiss(animated: true) }
            )
        }

        static func create(name: String, filters: ElectricityChartFilters) -> ViewController {
            ViewController(viewModel: ViewModel(name: name, filters: filters))
        }
    }
}
