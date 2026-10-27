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

import Combine

extension CaptionChangeDialogFeature {
    class ViewState: ObservableObject {
        @Published var caption: String
        @Published var label: String?
        @Published var error: String?
        @Published var processing: Bool

        init(caption: String = "", label: String? = nil, error: String? = nil, processing: Bool = false) {
            self.caption = caption
            self.label = label
            self.error = error
            self.processing = processing
        }
    }
}
