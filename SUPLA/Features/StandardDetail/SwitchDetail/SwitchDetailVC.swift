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

class SwitchDetailVC : BaseViewControllerVM<SwitchDetailViewState, SwitchDetailViewEvent, SwitchDetailVM> {
    
    private let remoteId: Int32
    
    private lazy var stateLabelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        return label
    }()
    
    private lazy var stateIcon: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    private lazy var stateValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .openSansBold(style: .body, size: 14)
        return label
    }()
    
    init(remoteId: Int32) {
        self.remoteId = remoteId
        super.init(nibName: nil, bundle: nil)
        viewModel = SwitchDetailVM()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarBackgroundView.isHidden = true
        
        view.backgroundColor = .background
        
        setupView()
    }
    
    override func handle(event: SwitchDetailViewEvent) {
    }
    
    override func handle(state: SwitchDetailViewState) {
    }
    
    private func setupView() {
//        view.addSubview(stateLabelView)
//        view.addSubview(stateIcon)
//        view.addSubview(stateValue)
        
        setupLayout()
    }
    
    private func setupLayout() {
//        NSLayoutConstraint.activate([
//            stateLabelView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
//            stateLabelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
//            stateLabelView.trailingAnchor.constraint(equalTo: stateIcon.leadingAnchor, constant: 8),
//            
//            stateIcon.centerYAnchor.constraint(equalTo: stateLabelView.centerYAnchor),
//            stateIcon.trailingAnchor.constraint(equalTo: stateValue.leadingAnchor, constant: 8),
//            
//            stateValue.centerYAnchor.constraint(equalTo: stateIcon.centerYAnchor),
//            stateIcon.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 24)
//        ])
    }
    
}

