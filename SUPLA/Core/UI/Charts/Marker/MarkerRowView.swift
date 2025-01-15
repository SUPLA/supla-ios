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
    

class MarkerRowView {
    static let CELL_DISTANCE: CGFloat = Distance.tiny / 2
    static let DOT_SIZE: CGFloat = 8
    static let ICON_SIZE: CGFloat = 18
    
    var isHidden: Bool {
        imageView.isHidden && labelView.isHidden && valueView.isHidden && priceView.isHidden
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = MarkerRowView.DOT_SIZE / 2
        return view
    }()
    
    lazy var labelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .StaticSize.marker
        label.textColor = .onBackground
        return label
    }()
    
    lazy var valueView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .StaticSize.marker
        label.textColor = .onBackground
        label.textAlignment = .right
        return label
    }()
    
    lazy var priceView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .StaticSize.marker
        label.textColor = .onBackground
        label.textAlignment = .right
        return label
    }()
    
    func setData(value: String, color: UIColor? = nil, icon: UIImage? = nil, label: String? = nil, price: String? = nil) {
        setHidden(false)
        
        valueView.text = value
        
        imageView.isHidden = color == nil && icon == nil
        if let dotColor = color {
            imageView.layer.backgroundColor = dotColor.cgColor
            imageView.image = nil
        }
        if let icon {
            imageView.layer.backgroundColor = UIColor.clear.cgColor
            imageView.image = icon
        }
        labelView.isHidden = label == nil
        if let label = label {
            labelView.text = label
        }
        priceView.isHidden = price == nil
        if let price = price {
            priceView.text = price
        }
    }
    
    func setHidden(_ isHidden: Bool) {
        imageView.isHidden = isHidden
        labelView.isHidden = isHidden
        valueView.isHidden = isHidden
        priceView.isHidden = isHidden
    }
    
    func bold() {
        labelView.font = .StaticSize.markerBold
        valueView.font = .StaticSize.markerBold
        priceView.font = .StaticSize.markerBold
    }
    
    func regular() {
        labelView.font = .StaticSize.marker
        valueView.font = .StaticSize.marker
        priceView.font = .StaticSize.marker
    }
    
    func getConstraints(
        _ leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>,
        _ topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>,
        _ plannedImageWidth: CGFloat,
        _ labelWidth: CGFloat,
        _ valueWidth: CGFloat,
        _ priceWidth: CGFloat
    ) -> [NSLayoutConstraint] {
        let padding: CGFloat = plannedImageWidth > MarkerRowView.DOT_SIZE && imageView.image == nil ? 5 : 0
        let imageWidth = imageView.image == nil ? MarkerRowView.DOT_SIZE : MarkerRowView.ICON_SIZE
        return [
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: Distance.tiny + padding),
            imageView.centerYAnchor.constraint(equalTo: valueView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: imageWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageWidth),
            
            labelView.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: MarkerRowView.CELL_DISTANCE + padding),
            labelView.centerYAnchor.constraint(equalTo: valueView.centerYAnchor),
            labelView.widthAnchor.constraint(equalToConstant: labelWidth),
            
            valueView.leftAnchor.constraint(equalTo: labelView.rightAnchor, constant: MarkerRowView.CELL_DISTANCE),
            valueView.topAnchor.constraint(equalTo: topAnchor, constant: MarkerRowView.CELL_DISTANCE),
            valueView.widthAnchor.constraint(equalToConstant: valueWidth),
            
            priceView.leftAnchor.constraint(equalTo: valueView.rightAnchor, constant: MarkerRowView.CELL_DISTANCE),
            priceView.centerYAnchor.constraint(equalTo: valueView.centerYAnchor),
            priceView.widthAnchor.constraint(equalToConstant: priceWidth)
        ]
    }
}

extension UIView {
    func addSubview(_ subview: MarkerRowView) {
        addSubview(subview.imageView)
        addSubview(subview.labelView)
        addSubview(subview.valueView)
        addSubview(subview.priceView)
    }
}

extension Array where Element == MarkerRowView {
    var intrinsicContentSize: CGSize {
        var imageWidth: CGFloat = 0
        var labelWidth: CGFloat = 0
        var valueWidth: CGFloat = 0
        var priceWidth: CGFloat = 0
        var height: CGFloat = 0
        
        for row in self {
            if (row.isHidden == false) {
                imageWidth = Swift.max(imageWidth, row.imageView.image == nil ? MarkerRowView.DOT_SIZE : MarkerRowView.ICON_SIZE)
                labelWidth = Swift.max(labelWidth, row.labelView.intrinsicContentSize.width)
                valueWidth = Swift.max(valueWidth, row.valueView.intrinsicContentSize.width)
                priceWidth = Swift.max(priceWidth, row.priceView.intrinsicContentSize.width)
                height += row.valueView.intrinsicContentSize.height + MarkerRowView.CELL_DISTANCE
            }
        }
        
        return CGSize(
            width: imageWidth + labelWidth + valueWidth + priceWidth + MarkerRowView.CELL_DISTANCE * 3,
            height: height > 0 ? height - MarkerRowView.CELL_DISTANCE : 0
        )
    }
    
    func getConstraints(
        leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>,
        topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>
    ) -> [NSLayoutConstraint] {
        var imageWidth: CGFloat = 0
        var labelWidth: CGFloat = 0
        var valueWidth: CGFloat = 0
        var priceWidth: CGFloat = 0
        
        for row in self {
            if (row.isHidden == false) {
                imageWidth = Swift.max(imageWidth, row.imageView.image == nil ? MarkerRowView.DOT_SIZE : MarkerRowView.ICON_SIZE)
                labelWidth = Swift.max(labelWidth, row.labelView.intrinsicContentSize.width)
                valueWidth = Swift.max(valueWidth, row.valueView.intrinsicContentSize.width)
                priceWidth = Swift.max(priceWidth, row.priceView.intrinsicContentSize.width)
            }
        }
        
        var result: [NSLayoutConstraint] = []
        var topAnchor = topAnchor
        for row in self {
            if (row.isHidden == false) {
                let constraints = row.getConstraints(leftAnchor, topAnchor, imageWidth, labelWidth, valueWidth, priceWidth)
                result.append(contentsOf: constraints)
                topAnchor = row.valueView.bottomAnchor
            }
        }
        
        return result
    }
}
