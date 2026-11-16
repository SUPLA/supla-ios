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

final class TopBarActionCoordinator: ObservableObject {
    @Published private(set) var actions: [TopBarAction] = []
    private let eventSubject = PassthroughSubject<TopBarEvent, Never>()
    private var registrations: [Registration] = []

    private struct Registration {
        let token: UUID
        let actions: [TopBarAction]
    }

    var events: AnyPublisher<TopBarEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    func emit(_ event: TopBarEvent) {
        eventSubject.send(event)
    }

    @discardableResult
    func setActions(_ actions: [TopBarAction]) -> UUID {
        let token = UUID()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.registrations.append(Registration(token: token, actions: actions))
            self.publishActions()
        }
        return token
    }

    func clearAction(registration token: UUID) {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let index = self.registrations.firstIndex(where: { $0.token == token }) else { return }
            self.registrations.remove(at: index)
            self.publishActions()
        }
    }

    private func publishActions() {
        actions = registrations.flatMap(\.actions).enumerated()
            .sorted { lhs, rhs in
                if (lhs.element.lifetime != rhs.element.lifetime) {
                    return lhs.element.lifetime == .detail
                }
                return lhs.offset < rhs.offset
            }
            .map(\.element)
    }
}
