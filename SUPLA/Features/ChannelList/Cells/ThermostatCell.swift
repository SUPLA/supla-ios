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

import RxSwift

final class ThermostatCell: BaseCell<ChannelWithChildren> {
    
    @Singleton<ValuesFormatter> private var formatter
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    
    private lazy var thermostatIconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var currentTemperatureView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .cellValueFont
        view.textColor = .onBackground
        return view
    }()
    
    private lazy var indicatorView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var setpointTemperatureView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .formLabelFont
        view.textColor = .onBackground
        return view
    }()
    
    override func provideRefreshData(_ updateEventsManager: UpdateEventsManager, forData: ChannelWithChildren) -> Observable<ChannelWithChildren> {
        updateEventsManager.observeChannelWithChildren(remoteId: Int(forData.channel.remote_id))
    }
    
    override func leftButtonSettings() -> CellButtonSettings {
        CellButtonSettings(
            visible: data?.channel.isOnline() ?? false,
            title: NSLocalizedString("Off", comment: "")
        )
    }
    
    override func rightButtonSettings() -> CellButtonSettings {
        CellButtonSettings(
            visible: data?.channel.isOnline() ?? false,
            title: NSLocalizedString("On", comment: "")
        )
    }
    
    override func getLocationCaption() -> String? { data?.channel.location?.caption }
    
    override func remoteId() -> Int32? { data?.channel.remote_id }
    
    override func online() -> Bool { data?.channel.isOnline() ?? false }
    
    override func issueMessage() -> String? {
        if (data?.channel.value?.asThermostatValue().flags.contains(.thermometerError) == true) {
            return Strings.ThermostatDetail.thermometerError
        } else if (data?.channel.value?.asThermostatValue().flags.contains(.clockError) == true) {
            return Strings.ThermostatDetail.clockError
        } else {
            return nil
        }
    }
    
    override func derivedClassControls() -> [UIView] {
        return [
            thermostatIconView,
            currentTemperatureView,
            indicatorView,
            setpointTemperatureView
        ]
    }
    
    override func onInfoPress(_ gr: UITapGestureRecognizer) {
        if let delegate = delegate as? ThermostatCellDelgate,
           let channel = data?.channel {
            delegate.onInfoIconTapped(channel)
        }
    }
    
    override func setupView() {
        currentTemperatureView.font = .cellValueFont.withSize(scale(Dimens.Fonts.value, limit: .lower(1)))
        setpointTemperatureView.font = .formLabelFont.withSize(scale(Dimens.Fonts.label, limit: .lower(1)))
        
        container.addSubview(thermostatIconView)
        container.addSubview(currentTemperatureView)
        container.addSubview(indicatorView)
        container.addSubview(setpointTemperatureView)
        
        super.setupView()
    }
    
    override func derivedClassConstraints() -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = [
            thermostatIconView.widthAnchor.constraint(equalToConstant: scale(60.0)),
            thermostatIconView.heightAnchor.constraint(equalToConstant: scale(Dimens.ListItem.iconHeight)),
            thermostatIconView.leftAnchor.constraint(equalTo: container.leftAnchor),
            thermostatIconView.topAnchor.constraint(equalTo: container.topAnchor),
            
            currentTemperatureView.leftAnchor.constraint(equalTo: thermostatIconView.rightAnchor, constant: Dimens.distanceTiny),
            
            indicatorView.widthAnchor.constraint(equalToConstant: scale(12.0, limit: .lower(1))),
            indicatorView.heightAnchor.constraint(equalToConstant: scale(12.0, limit: .lower(1))),
            
            setpointTemperatureView.leftAnchor.constraint(equalTo: indicatorView.rightAnchor, constant: 4)
        ]
        
        if (scaleFactor > 1) {
            constraints.append(contentsOf: [
                currentTemperatureView.bottomAnchor.constraint(equalTo: thermostatIconView.centerYAnchor),

                indicatorView.centerYAnchor.constraint(equalTo: setpointTemperatureView.centerYAnchor),
                indicatorView.leftAnchor.constraint(equalTo: thermostatIconView.rightAnchor, constant: Dimens.distanceTiny),
                
                setpointTemperatureView.topAnchor.constraint(equalTo: thermostatIconView.centerYAnchor),
                setpointTemperatureView.rightAnchor.constraint(equalTo: container.rightAnchor)
            ])
        } else {
            constraints.append(contentsOf: [
                currentTemperatureView.centerYAnchor.constraint(equalTo: thermostatIconView.centerYAnchor),
                
                indicatorView.leftAnchor.constraint(equalTo: currentTemperatureView.rightAnchor, constant: Dimens.distanceTiny),
                indicatorView.centerYAnchor.constraint(equalTo: currentTemperatureView.centerYAnchor),
                
                setpointTemperatureView.centerYAnchor.constraint(equalTo: currentTemperatureView.centerYAnchor),
                setpointTemperatureView.rightAnchor.constraint(equalTo: container.rightAnchor)
            ])
        }
        
        return constraints
    }
    
    override func updateContent(data: ChannelWithChildren) {
        super.updateContent(data: data)
        
        let channel = data.channel
        let thermostatValue = channel.value?.asThermostatValue()
        
        caption = channel.getNonEmptyCaption()
        
        leftStatusIndicatorView.configure(filled: true, online: channel.isOnline())
        rightStatusIndicatorView.configure(filled: true, online: channel.isOnline())
        
        thermostatIconView.image = getChannelBaseIconUseCase.invoke(
            channel: channel,
            subfunction: thermostatValue?.subfunction
        )
        
        indicatorView.image = .iconStandby
        issueIcon = nil
        
        if let thermostatValue = thermostatValue {
            setpointTemperatureView.text = getSetpointTemperatureString(channel, thermostatValue)
            indicatorView.image = getIndicatorIcon(channel, thermostatValue)
            
            if (channel.isOnline() && thermostatValue.flags.contains(.thermometerError)) {
                issueIcon = .error
            } else if (channel.isOnline() && thermostatValue.flags.contains(.clockError)) {
                issueIcon = .warning
            }
        }
        
        if let mainThermometer = data.children.first(where: { $0.relationType == .mainThermometer })?.channel {
            currentTemperatureView.text = mainThermometer.attrStringValue().string
        } else {
            currentTemperatureView.text = NO_VALUE_TEXT
        }
    }
    
    private func getSetpointTemperatureString(_ channel: SAChannel, _ thermostatValue: ThermostatValue) -> String {
        if (!channel.isOnline()) {
            return ""
        }
        switch (thermostatValue.mode) {
        case .cool: return formatter.temperatureToString(thermostatValue.setpointTemperatureCool)
        case .heat: return formatter.temperatureToString(thermostatValue.setpointTemperatureHeat)
        case .off: return "Off"
        case .auto:
            let min = formatter.temperatureToString(thermostatValue.setpointTemperatureHeat)
            let max = formatter.temperatureToString(thermostatValue.setpointTemperatureCool)
            return "\(min) - \(max)"
        default: return ""
        }
    }
    
    private func getIndicatorIcon(_ channel: SAChannel, _ thermostatValue: ThermostatValue) -> UIImage? {
        if (channel.isOnline() && thermostatValue.flags.contains(.cooling)) {
            return .iconCooling
        } else if (channel.isOnline() && thermostatValue.flags.contains(.heating)) {
            return .iconHeating
        } else if (channel.isOnline() && thermostatValue.mode != .off) {
            return .iconStandby
        } else {
            return nil
        }
    }
}

protocol ThermostatCellDelgate: BaseCellDelegate {
    func onInfoIconTapped(_ channel: SAChannel)
}
