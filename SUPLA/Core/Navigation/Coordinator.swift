//
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

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }

    func start(animated: Bool)
}

extension Coordinator {
    func navigateTo(_ view: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(view, animated: animated)
    }

    func popViewController(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }

    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        navigationController.popToViewController(ofClass: ofClass, animated: animated)
    }
    
    func present(_ view: UIViewController, animated: Bool = false) {
        navigationController.present(view, animated: animated)
    }

    func dismiss(animated: Bool = false, completion: (() -> Void)? = nil) {
        navigationController.dismiss(animated: animated, completion: completion)
    }
}
