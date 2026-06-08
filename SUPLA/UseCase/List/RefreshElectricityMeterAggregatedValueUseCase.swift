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
    
enum RefreshElectricityMeterAggregatedValue {
    protocol UseCase {
        func invoke(profileId: Int32, remoteId: Int32) async
    }
    
    class Implementation: UseCase {
        @Singleton<DateProvider> private var dateProvider
        @Singleton<UserStateHolder> private var userStateHolder
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<ChannelValueRepository> private var channelValueRepository
        @Singleton<ElectricityMeasurementItemRepository> private var electricityMeasurementItemRepository
        @Singleton<LoadElectricityMeterMeasurementsUseCase> private var loadElectricityMeterMeasurementsUseCase
        
        private let formatter = ElectricityMeterValueFormatter()
        
        func invoke(profileId: Int32, remoteId: Int32) async {
            let settings = userStateHolder.getElectricityMeterSettings(profileId: profileId, remoteId: remoteId)
            if (!settings.usingAggregatedValue) {
                SALog.warning("Refresh electricity meter aggregated value started for no aggregation!")
                return
            }
            guard let profile = try? await profileRepository.getProfile(withId: profileId).awaitFirstElement(),
                  let profile
            else {
                SALog.warning("Could not find profile for given profile id: \(profileId)")
                return
            }
            
            let currentDate = dateProvider.currentDate()
            guard let entriesStartDate = settings.metricOnListAggregation.aggregationStartDate(currentDate: currentDate)
            else {
                SALog.error("Got nil as entries start date")
                await channelValueRepository.updateAggregatedValue(profileId, remoteId, NO_VALUE_TEXT)
                return
            }
            
            guard let aggregatedValue = try? await loadAggregatedValue(
                profile: profile,
                remoteId: remoteId,
                settings: settings,
                startDate: entriesStartDate,
                endDate: currentDate
            ) else {
                SALog.info("Aggregated value nil - setting no value text into DB.")
                await channelValueRepository.updateAggregatedValue(profileId, remoteId, NO_VALUE_TEXT)
                return
            }
            
            let unit = settings.metricOnList.suplaType.unit
            let formatted = formatter.format(value: aggregatedValue, format: withUnit(unit: unit, showNoValueText: false))
            SALog.debug("Aggregated value set to \(formatted)")
            await channelValueRepository.updateAggregatedValue(profileId, remoteId, formatted)
        }
        
        private func loadAggregatedValue(
            profile: AuthProfileItem,
            remoteId: Int32,
            settings: ElectricityMeterSettings,
            startDate: Date,
            endDate: Date
        ) async throws -> Double? {
            switch (settings.metricOnList) {
            case .forwardActiveEnergy:
                try await loadElectricityMeterMeasurementsUseCase.invoke(
                    profile: profile,
                    remoteId: remoteId,
                    startDate: startDate,
                    endDate: endDate
                )
                .awaitFirstElement()?
                .forwardActiveEnergy
            case .reverseActiveEnergy:
                try await loadElectricityMeterMeasurementsUseCase.invoke(
                    profile: profile,
                    remoteId: remoteId,
                    startDate: startDate,
                    endDate: endDate
                )
                .awaitFirstElement()?
                .reverseActiveEnergy
            case .forwardReactiveEnergy:
                try await loadEntries(
                    remoteId: remoteId,
                    serverId: profile.server?.id,
                    startDate: startDate,
                    endDate: endDate
                ).reduce(0.0) { acc, entry in acc + entry.phasesFre }
            case .reverseReactiveEnergy:
                try await loadEntries(
                    remoteId: remoteId,
                    serverId: profile.server?.id,
                    startDate: startDate,
                    endDate: endDate
                ).reduce(0.0) { acc, entry in acc + entry.phasesRre }
            case .activeEnergyBalance:
                try await loadElectricityMeterMeasurementsUseCase.invoke(
                    profile: profile,
                    remoteId: remoteId,
                    startDate: startDate,
                    endDate: endDate
                )
                .awaitFirstElement()?
                .summarized
            case .powerActive, .current, .voltage: nil
            }
        }
        
        private func loadEntries(
            remoteId: Int32,
            serverId: Int32?,
            startDate: Date,
            endDate: Date
        ) async throws -> [SAElectricityMeasurementItem] {
            try await electricityMeasurementItemRepository.findMeasurements(remoteId: remoteId, serverId: serverId, startDate: startDate, endDate: endDate)
                .awaitFirstElement() ?? []
        }
    }
}

private extension SAElectricityMeasurementItem {
    var phasesFre: Double { phase1_fre + phase2_fre + phase3_fre }
    var phasesRre: Double { phase1_rre + phase2_rre + phase3_rre }
}
