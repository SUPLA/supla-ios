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
import SwiftUI
import UIKit

struct MainListTable: UIViewRepresentable {
    @Environment(\.listSearchText) private var listSearchText

    let items: [MainListItem]
    let callbacks: MainListTableView.Callbacks
    let onScroll: (CGFloat) -> Void
    let onScrollEnded: (Bool) -> Void

    func makeUIView(context: Context) -> MainListTableView {
        let view = MainListTableView()
        view.callbacks = callbacks
        view.searchText = listSearchText
        view.onScroll = onScroll
        view.onScrollEnded = onScrollEnded
        view.update(items: items)
        return view
    }

    func updateUIView(_ uiView: MainListTableView, context: Context) {
        uiView.callbacks = callbacks
        uiView.searchText = listSearchText
        uiView.onScroll = onScroll
        uiView.onScrollEnded = onScrollEnded
        uiView.update(items: items)
    }
}

final class MainListTableView: UIView {
    struct Callbacks {
        var onItemClick: (MainListItem) -> Void = { _ in }
        var onInfoClick: (MainListItem) -> Void = { _ in }
        var onIssueClick: (MainListItem, ListItemIssues) -> Void = { _, _ in }
        var onTitleLongClick: (MainListItem) -> Void = { _ in }
        var onLocationClick: (LocationListItem) -> Void = { _ in }
        var onLocationLongClick: (LocationListItem) -> Void = { _ in }
        var onLeftButtonClick: (MainListItem) -> Void = { _ in }
        var onRightButtonClick: (MainListItem) -> Void = { _ in }
        var onMove: (MainListItem, MainListItem) -> Void = { _, _ in }
    }

    @Singleton<RuntimeConfig> private var runtimeConfig
    @Singleton<GlobalSettings> private var settings
    @Singleton<VibrationService> private var vibrationService

    var callbacks = Callbacks()
    var searchText: String?
    var onScroll: (CGFloat) -> Void = { _ in }
    var onScrollEnded: (Bool) -> Void = { _ in }

    private let cellIdentifier = "MainListCell"
    private var items: [MainListItem] = []
    private var renderedSearchText: String?
    private var scaleFactor: CGFloat = 1
    private var showChannelInfo = false
    private var lastEffectiveContentOffsetY: CGFloat?
    private var disposeBag = DisposeBag()

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .background
        view.separatorStyle = .none
        view.dataSource = self
        view.delegate = self
        view.dragDelegate = self
        view.dropDelegate = self
        view.dragInteractionEnabled = true
        view.register(MainListCell.self, forCellReuseIdentifier: cellIdentifier)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConfigObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConfigObserver()
    }

    func update(items: [MainListItem]) {
        let showChannelInfoChanged = showChannelInfo != settings.showChannelInfo
        let searchTextChanged = renderedSearchText != searchText
        showChannelInfo = settings.showChannelInfo
        renderedSearchText = searchText

        guard self.items.map(\.key) != items.map(\.key) else {
            let changedRows = self.items
                .enumerated()
                .compactMap { index, item in item != items[index] ? index : nil }
            self.items = items
            if (showChannelInfoChanged || searchTextChanged) {
                tableView.reloadData()
            } else {
                refreshVisibleCells(atRows: changedRows)
            }
            return
        }

        self.items = items
        tableView.reloadData()
    }

    private func setupView() {
        backgroundColor = .background
        addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupConfigObserver() {
        runtimeConfig
            .preferencesObservable()
            .asDriverWithoutError()
            .drive(onNext: { [weak self] preferences in
                self?.scaleFactor = CGFloat(preferences.scaleFactor)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    private func refreshVisibleCells(atRows rows: [Int]) {
        rows
            .map { IndexPath(row: $0, section: 0) }
            .compactMap { indexPath -> (MainListCell, IndexPath)? in
                guard let cell = tableView.cellForRow(at: indexPath) as? MainListCell else { return nil }
                return (cell, indexPath)
            }
            .forEach { cell, indexPath in configure(cell, at: indexPath) }
    }

    private func configure(_ cell: MainListCell, at indexPath: IndexPath) {
        let item = items[indexPath.row]
        cell.configure(
            item: item,
            scaleFactor: scaleFactor,
            showChannelInfo: showChannelInfo,
            searchText: searchText,
            callbacks: .init(
                onItemClick: { [weak self] in self?.callbacks.onItemClick(item) },
                onInfoClick: { [weak self] in self?.callbacks.onInfoClick(item) },
                onIssueClick: { [weak self] issues in self?.callbacks.onIssueClick(item, issues) },
                onTitleLongClick: { [weak self] in self?.callbacks.onTitleLongClick(item) },
                onLocationClick: { [weak self] location in self?.callbacks.onLocationClick(location) },
                onLocationLongClick: { [weak self] location in self?.callbacks.onLocationLongClick(location) },
                onLeftButtonClick: { [weak self] in self?.callbacks.onLeftButtonClick(item) },
                onRightButtonClick: { [weak self] in self?.callbacks.onRightButtonClick(item) }
            )
        )
    }

    private func isMoveAllowed(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Bool {
        guard
            items.indices.contains(sourceIndexPath.row),
            items.indices.contains(destinationIndexPath.row)
        else {
            return false
        }

        let source = items[sourceIndexPath.row]
        let destination = items[destinationIndexPath.row]

        return source.draggable
            && destination.draggable
            && source.locationId == destination.locationId
    }

    private func moveItem(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard isMoveAllowed(from: sourceIndexPath, to: destinationIndexPath) else { return }

        let source = items[sourceIndexPath.row]
        let destination = items[destinationIndexPath.row]
        items.remove(at: sourceIndexPath.row)
        items.insert(source, at: destinationIndexPath.row)
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        callbacks.onMove(source, destination)
    }

    private func dispatchScroll(_ delta: CGFloat) {
        DispatchQueue.main.async { [onScroll] in
            onScroll(delta)
        }
    }

    private func dispatchScrollEnded(atTop: Bool) {
        DispatchQueue.main.async { [onScrollEnded] in
            onScrollEnded(atTop)
        }
    }
}

extension MainListTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MainListCell
        configure(cell, at: indexPath)
        return cell
    }
}

extension MainListTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard items.indices.contains(indexPath.row) else { return Dimens.ListItem.itemHeight }

        switch (items[indexPath.row]) {
        case .location:
            return Dimens.ListItem.sectionHeight + Dimens.ListItem.separatorHeight
        default:
            return Dimens.ListItem.itemHeight * scaleFactor
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.effectiveContentOffsetY

        guard scrollView.isUserScrolling, scrollView.canScrollVertically else {
            lastEffectiveContentOffsetY = contentOffsetY
            return
        }

        guard let lastEffectiveContentOffsetY else {
            self.lastEffectiveContentOffsetY = contentOffsetY
            return
        }

        let delta = contentOffsetY - lastEffectiveContentOffsetY
        self.lastEffectiveContentOffsetY = contentOffsetY

        if (abs(delta) > 0.1) {
            dispatchScroll(delta)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            dispatchScrollEnded(atTop: scrollView.isAtTop)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dispatchScrollEnded(atTop: scrollView.isAtTop)
    }
}

extension MainListTableView: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard
            items.indices.contains(indexPath.row),
            items[indexPath.row].draggable,
            let cell = tableView.cellForRow(at: indexPath) as? MainListCell,
            !cell.isTitleFrameHit(at: session.location(in: cell.contentView))
        else {
            return []
        }

        vibrationService.vibrate()

        let itemProvider = NSItemProvider(object: items[indexPath.row].key as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = indexPath
        return [dragItem]
    }
}

extension MainListTableView: UITableViewDropDelegate {
    func tableView(
        _ tableView: UITableView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UITableViewDropProposal {
        let forbidden = UITableViewDropProposal(operation: .forbidden)

        guard
            session.items.count == 1,
            let sourceIndexPath = session.items.first?.localObject as? IndexPath,
            let destinationIndexPath,
            isMoveAllowed(from: sourceIndexPath, to: destinationIndexPath)
        else {
            return forbidden
        }

        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard
            let item = coordinator.items.first,
            let sourceIndexPath = item.dragItem.localObject as? IndexPath,
            let destinationIndexPath = coordinator.destinationIndexPath,
            isMoveAllowed(from: sourceIndexPath, to: destinationIndexPath)
        else {
            return
        }

        moveItem(from: sourceIndexPath, to: destinationIndexPath)
        coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
    }
}

final class MainListCell: MGSwipeTableCell, MoveableCell {
    struct Callbacks {
        var onItemClick: () -> Void
        var onInfoClick: () -> Void
        var onIssueClick: (ListItemIssues) -> Void
        var onTitleLongClick: () -> Void
        var onLocationClick: (LocationListItem) -> Void
        var onLocationLongClick: (LocationListItem) -> Void
        var onLeftButtonClick: () -> Void
        var onRightButtonClick: () -> Void
    }

    @Singleton<GlobalSettings> private var settings

    private var item: MainListItem?
    private var callbacks: Callbacks?
    private var hostingController: UIHostingController<AnyView>?
    private var titleFrame: CGRect = .null
    private var shouldHandleTitleInteractions: Bool {
        item?.draggable == true
    }

    private lazy var titleInteractionView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.addGestureRecognizer(titleTapRecognizer)
        view.addGestureRecognizer(titleLongPressRecognizer)
        return view
    }()

    private lazy var titleTapRecognizer: UITapGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(onTitleTap))
    }()

    private lazy var titleLongPressRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(onTitleLongPress(_:)))
        recognizer.minimumPressDuration = 0.3
        recognizer.cancelsTouchesInView = true
        return recognizer
    }()

    private lazy var leftButton: CellButton = {
        let button = CellButton(title: "", backgroundColor: .primary)!
        button.addTarget(self, action: #selector(onLeftButtonTap(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var rightButton: CellButton = {
        let button = CellButton(title: "", backgroundColor: .primary)!
        button.addTarget(self, action: #selector(onRightButtonTap(_:)), for: .touchUpInside)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFallbackTitleInteractionViewFrameIfNeeded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
        callbacks = nil
        titleFrame = .null
        updateTitleInteractionViewFrame(titleFrame)
        leftButtons = []
        rightButtons = []
        hideSwipe(animated: false)
    }

    func configure(
        item: MainListItem,
        scaleFactor: CGFloat,
        showChannelInfo: Bool,
        searchText: String?,
        callbacks: Callbacks
    ) {
        self.item = item
        self.callbacks = callbacks

        setupButtons(for: item)
        setupContent(
            for: item,
            scaleFactor: scaleFactor,
            showChannelInfo: showChannelInfo,
            searchText: searchText,
            callbacks: callbacks
        )
        updateFallbackTitleInteractionViewFrameIfNeeded()
    }

    func movementEnabled() -> Bool {
        item?.draggable == true
    }

    func getRemoteId() -> Int32? {
        item?.remoteId
    }

    func getLocationCaption() -> String? {
        item?.locationCaption
    }

    func dropAllowed(to destination: MoveableCell) -> Bool {
        getLocationCaption() == destination.getLocationCaption()
    }

    private func setupView() {
        selectionStyle = .none
        backgroundColor = .surface
        contentView.backgroundColor = .surface
        leftSwipeSettings.transition = MGSwipeTransition.rotate3D
        rightSwipeSettings.transition = MGSwipeTransition.rotate3D
        contentView.addSubview(titleInteractionView)
    }

    private func setupButtons(for item: MainListItem) {
        if let leftButtonTitle = item.leftButtonTitle {
            leftButton.setTitle(leftButtonTitle, for: .normal)
            leftButton.buttonWidth = Dimens.ListItem.buttonWidth
            leftButtons = [leftButton as Any]
        } else {
            leftButtons = []
        }

        if let rightButtonTitle = item.rightButtonTitle {
            rightButton.setTitle(rightButtonTitle, for: .normal)
            rightButton.buttonWidth = Dimens.ListItem.buttonWidth
            rightButtons = [rightButton as Any]
        } else {
            rightButtons = []
        }
    }

    private func setupContent(
        for item: MainListItem,
        scaleFactor: CGFloat,
        showChannelInfo: Bool,
        searchText: String?,
        callbacks: Callbacks
    ) {
        let rootView = MainListItemView(
            item: item,
            onInfoClick: callbacks.onInfoClick,
            onIssueClick: callbacks.onIssueClick,
            onTitleLongClick: {},
            onItemClick: callbacks.onItemClick,
            onLocationClick: {
                if case .location(let locationItem) = item {
                    callbacks.onLocationClick(locationItem)
                }
            },
            onLocationLongClick: {
                if case .location(let locationItem) = item {
                    callbacks.onLocationLongClick(locationItem)
                }
            }
        )
        .environment(\.scaleFactor, scaleFactor)
        .environment(\.showChannelInfo, showChannelInfo)
        .environment(\.listSearchText, searchText)
        .coordinateSpace(name: ListItemTitleFramePreferenceKey.coordinateSpaceName)
        .onPreferenceChange(ListItemTitleFramePreferenceKey.self) { [weak self] titleFrame in
            self?.titleFrame = titleFrame
            self?.updateTitleInteractionViewFrame(titleFrame)
        }

        if let hostingController {
            hostingController.rootView = AnyView(rootView)
        } else {
            let hostingController = UIHostingController(rootView: AnyView(rootView))
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.backgroundColor = .clear
            contentView.addSubview(hostingController.view)

            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])

            self.hostingController = hostingController
        }

        contentView.bringSubviewToFront(titleInteractionView)
    }

    func isTitleFrameHit(at point: CGPoint) -> Bool {
        shouldHandleTitleInteractions && !titleInteractionView.isHidden && titleInteractionView.frame.contains(point)
    }

    private func updateTitleInteractionViewFrame(_ frame: CGRect) {
        titleInteractionView.isHidden = !shouldHandleTitleInteractions || frame.isNull
        titleInteractionView.frame = frame.insetBy(dx: -Distance.tiny, dy: -Distance.tiny)
    }

    private func updateFallbackTitleInteractionViewFrameIfNeeded() {
        if titleFrame.isNull {
            updateTitleInteractionViewFrame(
                CGRect(
                    x: Distance.default,
                    y: contentView.bounds.height - Dimens.ListItem.verticalPadding - Dimens.iconSize,
                    width: max(0, contentView.bounds.width - 2 * Distance.default),
                    height: Dimens.iconSize
                )
            )
        } else {
            updateTitleInteractionViewFrame(titleFrame)
        }
    }

    @objc private func onTitleTap() {
        callbacks?.onItemClick()
    }

    @objc private func onTitleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            callbacks?.onTitleLongClick()
        }
    }

    @objc private func onLeftButtonTap(_ button: MGSwipeButton) {
        onButtonTap(button) { [weak self] in
            self?.callbacks?.onLeftButtonClick()
        }
    }

    @objc private func onRightButtonTap(_ button: MGSwipeButton) {
        onButtonTap(button) { [weak self] in
            self?.callbacks?.onRightButtonClick()
        }
    }

    private func onButtonTap(_ button: MGSwipeButton, callback: @escaping () -> Void) {
        button.backgroundColor = .buttonPressed
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { [weak self, weak button] in
            button?.backgroundColor = .primary

            if (self?.settings.autohideButtons == true) {
                self?.hideSwipe(animated: true)
            }

            callback()
        }
    }
}

private extension UIScrollView {
    var isUserScrolling: Bool {
        isTracking || isDragging || isDecelerating
    }

    var canScrollVertically: Bool {
        let contentHeight = contentSize.height + adjustedContentInset.top + adjustedContentInset.bottom
        return contentHeight > bounds.height + 1
    }

    var effectiveContentOffsetY: CGFloat {
        min(max(contentOffset.y, minContentOffsetY), maxContentOffsetY)
    }

    var isAtTop: Bool {
        effectiveContentOffsetY <= minContentOffsetY + 1
    }

    private var minContentOffsetY: CGFloat {
        -adjustedContentInset.top
    }

    private var maxContentOffsetY: CGFloat {
        max(minContentOffsetY, contentSize.height - bounds.height + adjustedContentInset.bottom)
    }
}
