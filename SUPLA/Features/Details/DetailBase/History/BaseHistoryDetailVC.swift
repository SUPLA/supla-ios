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

import RxCocoa
import RxRelay
import RxSwift
import SwiftUI

class BaseHistoryDetailVC: BaseViewControllerVM<BaseHistoryDetailViewState, BaseHistoryDetailViewEvent, BaseHistoryDetailVM> {
    let remoteId: Int32
    
    private var dataSetsRowState = DataSetsViewState()
    private lazy var dataSetsRow: DataSetsRow = DataSetsRow(viewState: dataSetsRowState)
    private lazy var dataSetsRowController: UIHostingController = {
        let view = UIHostingController(rootView: dataSetsRow)
        view.view.translatesAutoresizingMaskIntoConstraints = false
        ShadowValues.apply(toLayer: view.view.layer)
        view.view.layer.masksToBounds = false
        return view
    }()
    
    private lazy var filtersRow: FiltersRowView = {
        let rowView = FiltersRowView()
        return rowView
    }()
    
    private lazy var historyDisabledLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.textColor = .onBackground
        label.text = Strings.Charts.historyDisabled
        label.textAlignment = .center
        return label
    }()
    
    private lazy var combinedChartView: SuplaCombinedChartView = {
        let view = SuplaCombinedChartView()
        view.chartStyle = viewModel.chartStyle
        return view
    }()
    
    private lazy var pieChartView: SuplaPieChartView = {
        let view = SuplaPieChartView()
        view.chartStyle = viewModel.chartStyle
        return view
    }()
    
    private lazy var paginationView: BottomPaginationView = {
        let view = BottomPaginationView()
        return view
    }()
    
    private lazy var rangeSelectionView: RangeSelectionView = {
        let view = RangeSelectionView()
        return view
    }()
    
    private lazy var pullToRefresh: PullToRefreshView = {
        let view = PullToRefreshView(self)
        return view
    }()
    
    private lazy var datePicker: SADateTimePicker = {
        let view = SADateTimePicker()
        return view
    }()
    
    private unowned var navigationItemProvider: NavigationItemProvider
    
    init(remoteId: Int32, navigationItemProvider: NavigationItemProvider) {
        self.remoteId = remoteId
        self.navigationItemProvider = navigationItemProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.loadData(remoteId: remoteId)
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 14.0, *) {
            let barButton = UIBarButtonItem(image: .iconMore, style: .plain, target: nil, action: nil)
            let deleteAction = UIAction(title: Strings.Charts.historyDeleteData, handler: { [weak self] (_) in
                if let self = self {
                    self.viewModel.deleteAndDownloadData(remoteId: self.remoteId)
                }
            })
            barButton.menu = UIMenu(children: [deleteAction])
            navigationItemProvider.navigationItem.rightBarButtonItem = barButton
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItemProvider.navigationItem.rightBarButtonItem = nil
    }
    
    override func handle(event: BaseHistoryDetailViewEvent) {
        switch (event) {
        case .clearHighlight:
            combinedChartView.clearHighlight()
            pieChartView.clearHighlight()
        case .showDownloadInProgress:
            showToast(Strings.Charts.historyWaitForDownload)
        case .showDataSelectionDialog(let channelSets, let filters):
            showDataSelectionDialog(channelSets, filters)
        }
    }
    
    override func handle(state: BaseHistoryDetailViewState) {
        filtersRow.ranges = state.ranges?.items ?? []
        filtersRow.aggregations = state.aggregations?.items ?? []
        filtersRow.selectedRange = state.ranges?.selected
        filtersRow.selectedAggregation = state.aggregations?.selected
        filtersRow.isHidden = !state.showHistory
        
        dataSetsRowState.channelsSets = state.chartData.sets
        dataSetsRowState.historyEnabled = state.showHistory
        
        let data = state.chartData
        if let combinedData = data as? CombinedChartData {
            combinedChartView.isHidden = !state.showHistory
            pieChartView.isHidden = true
            
            combinedChartView.channelFunction = state.channelFunction
            combinedChartView.data = combinedData
            combinedChartView.maxLeftAxis = state.maxLeftAxis
            combinedChartView.minLeftAxis = state.minLeftAxis
            combinedChartView.maxRightAxis = state.maxRightAxis
            combinedChartView.rangeStart = state.range?.start.timeIntervalSince1970
            combinedChartView.rangeEnd = state.range?.end.timeIntervalSince1970
            combinedChartView.emptyChartMessage = state.emptyChartMessage
            combinedChartView.rangeStart = state.chartData.xMin
            combinedChartView.rangeEnd = state.chartData.xMax
            combinedChartView.withLeftAxis = state.withLeftAxis
            combinedChartView.withRightAxis = state.withRightAxis
            if (combinedChartView.combinedData != nil) {
                if let chartParameters = state.chartParameters?.getOptional() {
                    if (chartParameters.hasDefaultValues()) {
                        combinedChartView.fitScreen()
                    } else {
                        combinedChartView.zoom(parameters: chartParameters)
                    }
                }
            }
        }
        if let pieData = data as? PieChartData {
            pieChartView.isHidden = !state.showHistory
            combinedChartView.isHidden = true
            
            pieChartView.data = pieData
            pieChartView.emptyChartMessage = state.emptyChartMessage
        }
        
        let customRangeSelected = state.ranges?.selected == .custom
        paginationView.isHidden = !state.showHistory || customRangeSelected
        paginationView.paginationAllowed = state.paginationAllowed
        paginationView.leftEnabled = state.shiftLeftEnabled
        paginationView.rightEnabled = state.shiftRightEnabled
        paginationView.text = state.rangeText
        
        rangeSelectionView.isHidden = !state.showHistory || !customRangeSelected
        rangeSelectionView.startDate = state.range?.start
        rangeSelectionView.endDate = state.range?.end
        
        datePicker.isHidden = !state.showHistory || state.editDate == nil
        if (!datePicker.isHidden) {
            datePicker.date = state.dateForEdit
            datePicker.minDate = state.minDate
            datePicker.maxDate = state.maxDate
        }
        
        pullToRefresh.isRefreshing = state.loading
        
        historyDisabledLabel.isHidden = state.showHistory
    }
    
    func showDataSelectionDialog(_ channelSets: ChannelChartSets, _ filters: CustomChartFiltersContainer?) {
        fatalError("showDataSelectionDialog(_:_:) needs to be implemented!")
    }
    
    private func setupView() {
        addChild(dataSetsRowController)
        
        view.addSubview(dataSetsRowController.view)
        view.addSubview(filtersRow)
        view.addSubview(combinedChartView)
        view.addSubview(pieChartView)
        view.addSubview(paginationView)
        view.addSubview(rangeSelectionView)
        view.addSubview(pullToRefresh)
        view.addSubview(datePicker)
        view.addSubview(historyDisabledLabel)
        
        dataSetsRowController.didMove(toParent: self)
        
        viewModel.bind(dataSetsRow.tap) { [weak self] event in
            self?.viewModel.changeSetActive(remoteId: event.remoteId, type: event.type)
        }
        
        viewModel.bind(filtersRow.rangesObservable) { [weak self] in
            self?.viewModel.changeRange(range: $0)
        }
        viewModel.bind(filtersRow.aggregationsObservable) { [weak self] in
            self?.viewModel.changeAggregation(aggregation: $0)
        }
        
        viewModel.bind(combinedChartView.parametersObservable) { [weak self] in
            self?.viewModel.updateChartPosition(parameters: $0)
        }
        
        viewModel.bind(paginationView.tap.filter { $0 == .end }) { [weak self] _ in
            self?.viewModel.moveToDataEnd()
        }
        viewModel.bind(paginationView.tap.filter { $0 == .left }) { [weak self] _ in
            self?.viewModel.moveRangeLeft()
        }
        viewModel.bind(paginationView.tap.filter { $0 == .right }) { [weak self] _ in
            self?.viewModel.moveRangeRight()
        }
        viewModel.bind(paginationView.tap.filter { $0 == .start }) { [weak self] _ in
            self?.viewModel.moveToDataBegin()
        }
        
        viewModel.bind(pullToRefresh.refreshObservable) { [weak self] _ in self?.viewModel.refresh() }
        
        viewModel.bind(rangeSelectionView.tap) { [weak self] in
            self?.viewModel.customRangeEditDate($0)
        }
        viewModel.bind(datePicker.cancelTap) { [weak self] _ in
            self?.viewModel.customRangeEditCancel()
        }
        viewModel.bind(datePicker.saveTap) { [weak self] in self?.viewModel.customRangeEditSave($0) }
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(([
            dataSetsRowController.view!.topAnchor.constraint(equalTo: view.topAnchor),
            dataSetsRowController.view!.leftAnchor.constraint(equalTo: view.leftAnchor),
            dataSetsRowController.view!.rightAnchor.constraint(equalTo: view.rightAnchor),
            dataSetsRowController.view!.heightAnchor.constraint(equalToConstant: 80),
            
            filtersRow.topAnchor.constraint(equalTo: dataSetsRowController.view!.bottomAnchor, constant: Dimens.distanceTiny),
            filtersRow.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            filtersRow.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            
            combinedChartView.topAnchor.constraint(equalTo: filtersRow.bottomAnchor, constant: Dimens.distanceSmall),
            combinedChartView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceTiny),
            combinedChartView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceTiny),
            combinedChartView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -96),
            
            pieChartView.topAnchor.constraint(equalTo: filtersRow.bottomAnchor, constant: Dimens.distanceSmall),
            pieChartView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceTiny),
            pieChartView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceTiny),
            pieChartView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -96),
            
            paginationView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceSmall),
            paginationView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceSmall),
            paginationView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Dimens.distanceDefault),
            
            rangeSelectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            rangeSelectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault),
            rangeSelectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            datePicker.leftAnchor.constraint(equalTo: view.leftAnchor),
            datePicker.topAnchor.constraint(equalTo: view.topAnchor),
            datePicker.rightAnchor.constraint(equalTo: view.rightAnchor),
            datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            historyDisabledLabel.topAnchor.constraint(equalTo: dataSetsRowController.view!.bottomAnchor, constant: Dimens.distanceDefault),
            historyDisabledLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.distanceDefault),
            historyDisabledLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Dimens.distanceDefault)
        ]))
    }
}

extension BaseHistoryDetailVC: PullToRefreshHolder {
    func shouldReceive(touch: UITouch) -> Bool {
        if (!pieChartView.isHidden) {
            let touchPoint = touch.location(in: view)
            return !pieChartView.frame.contains(touchPoint)
        }
        return true
    }
}

private class FiltersRowView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    var rangesObservable: Observable<ChartRange> { rangesRelay.asObservable() }

    var aggregationsObservable: Observable<ChartDataAggregation> { aggregationsRelay.asObservable() }
    
    var ranges: [ChartRange] = []
    var aggregations: [ChartDataAggregation] = []
    var selectedRange: ChartRange? {
        get { rangesRelay.value }
        set {
            if let range = newValue {
                rangeField.text = range.label
                
                if let index = ranges.indexOf(element: range) {
                    rangePicker.selectRow(index, inComponent: 0, animated: false)
                }
            }
        }
    }

    var selectedAggregation: ChartDataAggregation? {
        get { aggregationsRelay.value }
        set {
            if let aggregation = newValue {
                aggregationField.text = aggregation.label
                
                if let index = aggregations.indexOf(element: aggregation) {
                    aggregationPicker.selectRow(index, inComponent: 0, animated: false)
                }
            }
        }
    }
    
    private var rangesRelay: BehaviorRelay<ChartRange> = BehaviorRelay(value: .lastDay)
    private var aggregationsRelay: BehaviorRelay<ChartDataAggregation> = BehaviorRelay(value: .minutes)
    
    private lazy var rangeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption
        label.textColor = .gray
        label.text = Strings.Charts.rangeLabel.uppercased()
        return label
    }()
    
    private lazy var rangeField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.inputView = rangePicker
        textField.font = .body2
        textField.layer.borderColor = UIColor.onBackground.cgColor
        textField.backgroundColor = UIColor.background
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.text = "Last 24 hours"
        return textField
    }()
    
    private lazy var rangePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        return picker
    }()
    
    private lazy var aggregationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption
        label.textColor = .gray
        label.text = Strings.Charts.dataTypeLabel.uppercased()
        return label
    }()
    
    private lazy var aggregationField: UITextField! = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.inputView = aggregationPicker
        textField.font = .body2
        textField.layer.borderColor = UIColor.onBackground.cgColor
        textField.backgroundColor = UIColor.background
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.text = "Minutes"
        return textField
    }()
    
    private lazy var aggregationPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        return picker
    }()
    
    override var intrinsicContentSize: CGSize {
        let leftHeight = rangeLabel.intrinsicContentSize.height + 4 + rangeField.intrinsicContentSize.height
        let rightHeight = aggregationLabel.intrinsicContentSize.height + 4 + aggregationField.intrinsicContentSize.height
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: leftHeight > rightHeight ? leftHeight : rightHeight
        )
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(rangeLabel)
        addSubview(rangeField)
        addSubview(aggregationLabel)
        addSubview(aggregationField)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            rangeLabel.topAnchor.constraint(equalTo: topAnchor),
            rangeLabel.leftAnchor.constraint(equalTo: leftAnchor),
            
            rangeField.topAnchor.constraint(equalTo: rangeLabel.bottomAnchor, constant: 4),
            rangeField.leftAnchor.constraint(equalTo: leftAnchor),
            rangeField.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            aggregationLabel.topAnchor.constraint(equalTo: topAnchor),
            aggregationLabel.leftAnchor.constraint(equalTo: aggregationField.leftAnchor),
            
            aggregationField.topAnchor.constraint(equalTo: aggregationLabel.bottomAnchor, constant: 4),
            aggregationField.rightAnchor.constraint(equalTo: rightAnchor),
            aggregationField.bottomAnchor.constraint(equalTo: bottomAnchor),
            aggregationField.widthAnchor.constraint(greaterThanOrEqualToConstant: 90)
        ])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == rangePicker) {
            ranges.count
        } else if (pickerView == aggregationPicker) {
            aggregations.count
        } else {
            0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return if (pickerView == rangePicker && row < ranges.count) {
            ranges[row].label
        } else if (pickerView == aggregationPicker && row < aggregations.count) {
            aggregations[row].label
        } else {
            nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == rangePicker) {
            rangesRelay.accept(ranges[row])
        } else if (pickerView == aggregationPicker) {
            aggregationsRelay.accept(aggregations[row])
        }
        endEditing(true)
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension FiltersRowView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        false
    }
}

private class BottomPaginationView: UIView {
    var tap: Observable<ButtonType> { tapRelay.asObservable() }
    
    var leftEnabled: Bool {
        get { doubleLeftButton.isEnabled && leftButton.isEnabled }
        set {
            doubleLeftButton.isEnabled = newValue
            leftButton.isEnabled = newValue
        }
    }
    
    var rightEnabled: Bool {
        get { doubleRightButton.isEnabled && rightButton.isEnabled }
        set {
            doubleRightButton.isEnabled = newValue
            rightButton.isEnabled = newValue
        }
    }
    
    var text: String? {
        get { rangeTextLabel.text }
        set { rangeTextLabel.text = newValue }
    }
    
    var paginationAllowed: Bool {
        get { fatalError("Getter not supported") }
        set {
            doubleLeftButton.isHidden = !newValue
            leftButton.isHidden = !newValue
            rightButton.isHidden = !newValue
            doubleRightButton.isHidden = !newValue
        }
    }
    
    private lazy var doubleLeftButton: UIIconButton = {
        let button = UIIconButton(config: .transparent())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .iconArrowDoubleRight
        let buttonMiddlePoint = Dimens.buttonSmallHeight / 2
        button.layer.transform = CATransform3DMakeRotation(.pi, 0, 0, 1)
        return button
    }()
    
    private lazy var leftButton: UIIconButton = {
        let button = UIIconButton(config: .transparent())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .iconArrowRight
        let buttonMiddlePoint = Dimens.buttonSmallHeight / 2
        button.layer.transform = CATransform3DMakeRotation(.pi, 0, 0, 1)
        return button
    }()
    
    private lazy var rangeTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption
        label.textAlignment = .center
        return label
    }()
    
    private lazy var rightButton: UIIconButton = {
        let button = UIIconButton(config: .transparent())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .iconArrowRight
        return button
    }()
    
    private lazy var doubleRightButton: UIIconButton = {
        let button = UIIconButton(config: .transparent())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.icon = .iconArrowDoubleRight
        return button
    }()
    
    private let tapRelay = PublishRelay<ButtonType>()
    private let disposeBag = DisposeBag()
    
    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: doubleLeftButton.intrinsicContentSize.height
        )
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(doubleLeftButton)
        addSubview(leftButton)
        addSubview(rangeTextLabel)
        addSubview(rightButton)
        addSubview(doubleRightButton)
        
        doubleLeftButton.rx.tap.subscribe(onNext: { self.tapRelay.accept(.start) }).disposed(by: disposeBag)
        leftButton.rx.tap.subscribe(onNext: { self.tapRelay.accept(.left) }).disposed(by: disposeBag)
        rightButton.rx.tap.subscribe(onNext: { self.tapRelay.accept(.right) }).disposed(by: disposeBag)
        doubleRightButton.rx.tap.subscribe(onNext: { self.tapRelay.accept(.end) }).disposed(by: disposeBag)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            doubleLeftButton.leftAnchor.constraint(equalTo: leftAnchor),
            doubleLeftButton.topAnchor.constraint(equalTo: topAnchor),
            
            leftButton.leftAnchor.constraint(equalTo: doubleLeftButton.rightAnchor, constant: Distance.small),
            leftButton.topAnchor.constraint(equalTo: topAnchor),
            
            rangeTextLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            rangeTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            rightButton.rightAnchor.constraint(equalTo: doubleRightButton.leftAnchor, constant: -Distance.small),
            rightButton.topAnchor.constraint(equalTo: topAnchor),
            
            doubleRightButton.rightAnchor.constraint(equalTo: rightAnchor),
            doubleLeftButton.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    enum ButtonType {
        case start, left, right, end
    }
}

private class RangeSelectionView: UIView {
    @Singleton<ValuesFormatter> private var valuesFormatter
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 96)
    }
    
    var tap: Observable<RangeValueType> {
        Observable.merge(
            startDateField.rx.controlEvent(.touchDown).map { _ in RangeValueType.start },
            endDateField.rx.controlEvent(.touchDown).map { _ in RangeValueType.end }
        )
    }
    
    var startDate: Date? {
        get { fatalError("Getter not supported") }
        set { startDateField.text = valuesFormatter.getFullDateString(date: newValue) }
    }
    
    var endDate: Date? {
        get { fatalError("Getter not supported") }
        set { endDateField.text = valuesFormatter.getFullDateString(date: newValue) }
    }
    
    private lazy var startDateField: SATextField = {
        let field = textField()
        return field
    }()
    
    private lazy var separatorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-"
        return label
    }()
    
    private lazy var endDateField: SATextField = {
        let field = textField()
        return field
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(startDateField)
        addSubview(separatorLabel)
        addSubview(endDateField)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            startDateField.leftAnchor.constraint(equalTo: leftAnchor),
            startDateField.rightAnchor.constraint(equalTo: separatorLabel.leftAnchor, constant: -8),
            startDateField.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            separatorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            separatorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        
            endDateField.leftAnchor.constraint(equalTo: separatorLabel.rightAnchor, constant: 8),
            endDateField.centerYAnchor.constraint(equalTo: centerYAnchor),
            endDateField.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    private func textField() -> SATextField {
        let field = SATextField(height: 32)
        field.font = .body2
        field.textAlignment = .center
        field.backgroundColor = .surface
        field.isUserInteractionEnabled = true
        field.delegate = self
        return field
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension RangeSelectionView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        false
    }
}
