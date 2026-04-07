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

extension View {
    @ViewBuilder
    func hideScrollIndicators() -> some View {
        if #available(iOS 16, *) {
            self.scrollIndicators(.hidden)
        } else {
            self.background(
                ScrollViewIntrospector { scrollView in
                    scrollView.showsVerticalScrollIndicator = false
                    scrollView.showsHorizontalScrollIndicator = false
                }
            )
        }
    }
}

private struct ScrollViewIntrospector: UIViewRepresentable {
    var onResolve: (UIScrollView) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        DispatchQueue.main.async {
            if let scrollView = findScrollView(from: view) {
                onResolve(scrollView)
            }
        }
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private func findScrollView(from view: UIView) -> UIScrollView? {
        var superview = view.superview
        while superview != nil {
            if let scroll = superview as? UIScrollView {
                return scroll
            }
            superview = superview?.superview
        }
        return nil
    }
}
