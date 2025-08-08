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

extension AddWizardFeature {
    struct ProgressInformationView: SwiftUI.View {
        let progress: Float
        let label: String?
        
        var body: some SwiftUI.View {
            VStack {
                ZStack {
                    ProgressView(value: progress)
                        .frame(width: 250)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.Supla.primary))
                        .padding(4)
                }
                .background(Color.Supla.onPrimaryContainer)
                .cornerRadius(6)
                
                if let label {
                    Text(label)
                        .fontBodySmall()
                        .textColor(Color.Supla.onPrimaryContainer)
                }
            }
        }
    }
}
