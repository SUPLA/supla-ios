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
import CoreData
import RxSwift
import RxRelay

class LocationOrderingVM {
    
    let locations = BehaviorRelay<[_SALocation]>(value: [_SALocation]())
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<GroupRepository> private var groupRepository
    @Singleton<SceneRepository> private var sceneRepository
    @Singleton<LocationRepository> private var locationRepository
    
    func onViewDidLoad() {
        locations.accept(try! fetchLocations())
    }
    
    private func fetchLocations() throws -> [_SALocation] {
        var locationsSet = Set<NSNumber>()
        for channel in try getChannelsLocations() {
            if let locationId = channel.location?.location_id {
                locationsSet.insert(locationId)
            }
        }
        for scene in try getScenesLocations() {
            if let locationId = scene.location?.location_id {
                locationsSet.insert(locationId)
            }
        }
        for group in try getGroupsLocations() {
            if let locationId = group.location?.location_id {
                locationsSet.insert(locationId)
            }
        }

        var result = [_SALocation]()
        for location in try getLocations() {
            if let locationId = location.location_id {
                if (locationsSet.contains(locationId)) {
                    result.append(location)
                }
            }
        }
        
        return result
    }
    
    private func getChannelsLocations() throws -> [SAChannelBase] {
        try profileRepository.getActiveProfile()
            .flatMapFirst { self.channelRepository.getAllVisibleChannels(forProfile: $0) }
            .subscribeSynchronous()!
    }

    private func getGroupsLocations() throws -> [SAChannelBase] {
        try profileRepository.getActiveProfile()
            .flatMapFirst { self.groupRepository.getAllVisibleGroups(forProfile: $0) }
            .subscribeSynchronous()!
    }
    
    private func getScenesLocations() throws -> [SAScene] {
        try profileRepository.getActiveProfile()
            .flatMapFirst { self.sceneRepository.getAllVisibleScenes(forProfile: $0) }
            .subscribeSynchronous()!
    }
    
    private func getLocations() throws -> [_SALocation] {
        try profileRepository.getActiveProfile()
            .flatMapFirst { self.locationRepository.getAllLocations(forProfile: $0) }
            .subscribeSynchronous()!
    }

    func saveNewOrder() {
        var map: [NSNumber: Int] = [:]
        locations.value.enumerated().forEach { (i, location) in
            map[location.location_id!] = i
        }
        
        try! profileRepository.getActiveProfile()
            .flatMapFirst { self.locationRepository.getAllLocations(forProfile: $0) }
            .map { locations in
                locations.forEach { location in
                    if
                        let locationId = location.location_id,
                        let order = map[locationId] {
                        location.sortOrder = NSNumber(value: order)
                    }
                }
            }
            .flatMapFirst { self.locationRepository.save() }
            .subscribeSynchronous()
    }
}
