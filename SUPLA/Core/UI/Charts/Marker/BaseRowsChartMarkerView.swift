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
    
import Charts

@objc class BaseRowsChartMarkerView: BaseChartMarkerView {
    var rows: [MarkerRowView] {
        fatalError("Rows needs to be implemented")
    }
    
    private var dynamicConstraints: [NSLayoutConstraint] = []
    
    override func setupView() {
        super.setupView()
        rows.forEach { addSubview($0) }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        NSLayoutConstraint.deactivate(dynamicConstraints)
        dynamicConstraints.removeAll()
        
        dynamicConstraints.append(contentsOf: rows.getConstraints(leftAnchor: leftAnchor, topAnchor: title.bottomAnchor))
        NSLayoutConstraint.activate(dynamicConstraints)
    }
    
    func updateContainerSize() {
        let tableSize = rows.intrinsicContentSize
        let tableWidth = Distance.tiny + tableSize.width + Distance.tiny
        let titleWidth = Distance.tiny + title.intrinsicContentSize.width + Distance.tiny
        
        frame.size.width = max(titleWidth, tableWidth)
        frame.size.height = Distance.tiny + title.intrinsicContentSize.height + Distance.tiny + tableSize.height + Distance.tiny
    }
}
