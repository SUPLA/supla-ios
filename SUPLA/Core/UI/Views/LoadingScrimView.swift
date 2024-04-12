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

final class LoadingScrimView: UIView {
    
    override var isHidden: Bool {
        didSet {
            if (isHidden) {
                loaderView.stopAnimating()
            } else {
                loaderView.startAnimating()
            }
        }
    }
    
    private lazy var loaderView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.transform = CGAffineTransform(scaleX: 2, y: 2)
        view.color = .primary
        return view
    }()
    
    private lazy var loaderBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Dimens.radiusDefault
        view.backgroundColor = .surface
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .loadingScrim
        addSubview(loaderBackground)
        addSubview(loaderView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            loaderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loaderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            loaderBackground.centerXAnchor.constraint(equalTo: centerXAnchor),
            loaderBackground.centerYAnchor.constraint(equalTo: centerYAnchor),
            loaderBackground.widthAnchor.constraint(equalToConstant: 100),
            loaderBackground.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        true
    }
}
