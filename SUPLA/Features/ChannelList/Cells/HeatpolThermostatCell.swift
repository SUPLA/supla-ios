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
import SharedCore

final class HeatpolThermostatCell: BaseCell<ChannelWithChildren> {
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    @Singleton<GetCaptionUseCase> private var getCaptionUseCase
    @Singleton<GetChannelValueUseCase> private var getChannelValueUseCase
    @Singleton<GetChannelIssuesForListUseCase> private var getChannelIssuesForListUseCase
    @Singleton<SharedCore.ThermometerValueFormatter> private var thermometerValueFormatter
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var firstValueView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .onBackground
        return view
    }()
    
    private lazy var secondValueView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .onBackground
        return view
    }()
    
    override func provideRefreshData(_ updateEventsManager: UpdateEventsManager, forData: ChannelWithChildren) -> Observable<ChannelWithChildren> {
        updateEventsManager.observeChannelWithChildren(remoteId: Int(forData.channel.remote_id))
    }
    
    override func getLocationCaption() -> String? { data?.channel.location?.caption }
    
    override func getRemoteId() -> Int32? { data?.channel.remote_id ?? 0 }
    
    override func online() -> Bool { data?.onlineState.online ?? false }
    
    override func derivedClassControls() -> [UIView] {
        return [
            iconView,
            firstValueView,
            secondValueView
        ]
    }
    
    override func onInfoPress(_ gr: UITapGestureRecognizer) {
        if let delegate = delegate as? BaseCellDelegate,
           let channel = data?.channel
        {
            delegate.onInfoIconTapped(channel)
        }
    }
    
    override func setupView() {
        firstValueView.font = .cellValueFont.withSize(scale(Dimens.Fonts.value, limit: .lower(1)))
        secondValueView.font = .formLabelFont.withSize(scale(Dimens.Fonts.label, limit: .lower(1)))
        
        container.addSubview(iconView)
        container.addSubview(firstValueView)
        container.addSubview(secondValueView)
        
        super.setupView()
    }
    
    override func derivedClassConstraints() -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = [
            iconView.heightAnchor.constraint(equalToConstant: scale(Dimens.ListItem.iconHeight)),
            iconView.widthAnchor.constraint(equalToConstant: scale(Dimens.ListItem.iconHeight)),
            iconView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: inverseScale(6)),
            iconView.topAnchor.constraint(equalTo: container.topAnchor),
            
            firstValueView.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: Distance.tiny),
        ]
        
        if (scaleFactor > 1) {
            constraints.append(contentsOf: [
                firstValueView.topAnchor.constraint(equalTo: iconView.topAnchor),
                firstValueView.rightAnchor.constraint(equalTo: container.rightAnchor),
                
                secondValueView.leftAnchor.constraint(equalTo: firstValueView.leftAnchor),
                secondValueView.topAnchor.constraint(equalTo: firstValueView.bottomAnchor)
            ])
        } else {
            constraints.append(contentsOf: [
                firstValueView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
                secondValueView.leftAnchor.constraint(equalTo: firstValueView.rightAnchor),
                secondValueView.bottomAnchor.constraint(equalTo: firstValueView.bottomAnchor),
                secondValueView.rightAnchor.constraint(equalTo: container.rightAnchor)
            ])
        }
        
        return constraints
    }
    
    override func updateContent(data: ChannelWithChildren) {
        super.updateContent(data: data)
        
        let channel = data.channel
        
        caption = getCaptionUseCase.invoke(data: channel.shareable).string
        
        let onlineState = data.onlineState
        leftStatusIndicatorView.configure(filled: getLeftButtonText(data.channel.func) != nil, onlineState: onlineState)
        rightStatusIndicatorView.configure(filled: getRightButtonText(data.channel.func) != nil, onlineState: onlineState)
        
        iconView.image = getChannelBaseIconUseCase.invoke(channel: channel).uiImage
        
        let anyValue: Any = getChannelValueUseCase.invoke(channel)
        if let value = anyValue as? HomePlusThermostatValue {
            firstValueView.text = thermometerValueFormatter.format(
                value: value.measuredTemperature,
                format: ValueFormat.companion.WithUnit
            )
            let presetTemperature = thermometerValueFormatter.format(
                value: value.presetTemperature,
                format: ValueFormat.companion.WithUnit
            )
            if (scaleFactor > 1) {
                secondValueView.text = presetTemperature
            } else {
                secondValueView.text = "/\(presetTemperature)"
            }
        }
        
        issues = getChannelIssuesForListUseCase.invoke(channelWithChildren: data.shareable)
        
        setNeedsUpdateConstraints()
    }
    
    override func leftButtonSettings() -> CellButtonSettings {
        if let title = getLeftButtonText(data?.channel.func) {
            return CellButtonSettings(visible: online(), title: title)
        } else {
            return super.leftButtonSettings()
        }
    }
    
    override func rightButtonSettings() -> CellButtonSettings {
        if let title = getRightButtonText(data?.channel.func) {
            return CellButtonSettings(visible: online(), title: title)
        } else {
            return super.rightButtonSettings()
        }
    }
}
