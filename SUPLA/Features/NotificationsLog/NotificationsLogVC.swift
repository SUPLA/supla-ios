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

import RxDataSources

private let CELL_ID = "NotificationCell"

class NotificationsLogVC: BaseViewControllerVM<NotificationsLogViewState, NotificationsLogViewEvent, NotificationsLogVM> {
    private var navigator: NotificationsLogNavigationCoordinator? { navigationCoordinator as? NotificationsLogNavigationCoordinator }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(NotificationViewCell.self, forCellReuseIdentifier: CELL_ID)
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<NotificationList> = RxTableViewSectionedReloadDataSource(
        configureCell: { dataSource, tableView, indexPath, _ in
            let notification = dataSource[indexPath]
            return configureCell(notification, tableView, indexPath)
        },
        canEditRowAtIndexPath: { _, _ in true }
    )
    
    init(navigator: NotificationsLogNavigationCoordinator) {
        super.init(nibName: nil, bundle: nil)
        self.navigationCoordinator = navigator
        self.viewModel = NotificationsLogVM()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        title = Strings.Notifications.menu
        view.backgroundColor = .background
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(onDeleteItems)
        )
        
        viewModel.state.map { [NotificationList.list(items: $0.items)] }
            .asDriverWithoutError()
            .drive() { [weak self] list in
                self!.tableView.rx.items(dataSource: self!.dataSource)(list)
            }
            .disposed(by: self)
    }
    
    @objc
    private func onDeleteItems() {
        let alert = UIAlertController(
            title: Strings.Notifications.deleteAllTitile,
            message: Strings.Notifications.deleteAllMessage,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(
                title: Strings.Notifications.buttonDeleteAll,
                style: .destructive,
                handler: { [weak self] _ in self?.viewModel.deleteAll() }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: Strings.Notifications.buttonDeleteOlderThanMonth,
                style: .destructive,
                handler: { [weak self] _ in self?.viewModel.deleteOlderThanMonth() }
            )
        )
        alert.addAction(UIAlertAction(title: Strings.General.cancel, style: .cancel))
        present(alert, animated: true)
    }
    
    enum NotificationList {
        case list(items: [SANotification])
    }
}

private func configureCell(
    _ notification: SANotification,
    _ tableView: UITableView,
    _ indexPath: IndexPath
) -> UITableViewCell {
    @Singleton<ValuesFormatter> var valuesFormatter
    
    let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath)
    
    if let notificationCell = cell as? NotificationViewCell {
        notificationCell.title = notification.title
        notificationCell.message = notification.message
        notificationCell.date = valuesFormatter.getFullDateString(date: notification.date)
        notificationCell.profileName = notification.profileName
    }
    
    return cell
}

extension NotificationsLogVC.NotificationList: SectionModelType {
    typealias Item = SANotification
    
    var items: [SANotification] {
        switch self {
        case .list(let items):
            return items
        }
    }
    
    init(original: NotificationsLogVC.NotificationList, items: [SANotification]) {
        switch original {
        case .list:
            self = .list(items: items)
        }
    }
}

extension NotificationsLogVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            if let item = self?.dataSource[indexPath] as? SANotification {
                self?.viewModel.delete(item)
                tableView.reloadData()
                completion(true)
            } else {
                completion(false)
            }
        }
        
        action.image = .iconDelete
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}
