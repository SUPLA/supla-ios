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

import Foundation
import RxSwift

class HorizontalyScrollableView<T: UIView>: UIScrollView {
    
    var items: [T] = []
    var disposeBag = DisposeBag()
    private var changableConstraints: [NSLayoutConstraint] = []
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
    
    override func layoutSubviews() {
        cleanUpView()
        items = createItems()
        if (!items.isEmpty) {
            items.forEach { contentView.addSubview($0) }
        }
        setupItemsLayout()
    }
    
    func createItems() -> [T] {
        fatalError("createItems() has not been implemented")
    }
    
    func horizontalConstraint(item: T) -> NSLayoutConstraint {
        fatalError("horizontalConstraint(item:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        delaysContentTouches = false
        showsHorizontalScrollIndicator = false
        
        addSubview(contentView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    private func setupItemsLayout() {
        var width: CGFloat = Dimens.distanceDefault
        var previousItem: T? = nil
        for itemView in items {
            width += itemView.intrinsicContentSize.width + Dimens.distanceTiny

            changableConstraints.append(horizontalConstraint(item: itemView))
            changableConstraints.append(itemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Dimens.distanceSmall))

            if let previousItem = previousItem {
                changableConstraints.append(itemView.leftAnchor.constraint(equalTo: previousItem.rightAnchor, constant: Dimens.distanceTiny))
            } else {
                changableConstraints.append(itemView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Dimens.distanceDefault))
            }
            previousItem = itemView
        }
        if let lastItem = previousItem {
            changableConstraints.append(lastItem.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Dimens.distanceDefault))
        }
        contentSize = CGSize(width: width + 16, height: 64)

        NSLayoutConstraint.activate(changableConstraints)
    }
    
    private func cleanUpView() {
        if (!changableConstraints.isEmpty) {
            NSLayoutConstraint.deactivate(changableConstraints)
            changableConstraints.removeAll()
        }
        items.forEach { $0.removeFromSuperview() }
        items.removeAll()
        disposeBag = DisposeBag()
    }
}
