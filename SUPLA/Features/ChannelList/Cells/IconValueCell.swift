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

final class IconValueCell: BaseCell<ChannelWithChildren> {
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    @Singleton<GetCaptionUseCase> private var getCaptionUseCase
    @Singleton<GetChannelValueStringUseCase> private var getChannelValueStringUseCase
    @Singleton<GetChannelIssuesForListUseCase> private var getChannelIssuesForListUseCase
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var valueView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .cellValueFont
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
            valueView
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
        valueView.font = .cellValueFont.withSize(scale(Dimens.Fonts.value, limit: .lower(1)))
        
        container.addSubview(iconView)
        container.addSubview(valueView)
        
        super.setupView()
    }
    
    override func derivedClassConstraints() -> [NSLayoutConstraint] {
        return [
            iconView.widthAnchor.constraint(equalToConstant: scale(60.0)),
            iconView.heightAnchor.constraint(equalToConstant: scale(Dimens.ListItem.iconHeight)),
            iconView.leftAnchor.constraint(equalTo: container.leftAnchor),
            iconView.topAnchor.constraint(equalTo: container.topAnchor),
            
            valueView.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 4),
            valueView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            valueView.rightAnchor.constraint(equalTo: container.rightAnchor)
        ]
    }
    
    override func updateContent(data: ChannelWithChildren) {
        super.updateContent(data: data)
        
        let channel = data.channel
        
        caption = getCaptionUseCase.invoke(data: channel.shareable).string
        
        let onlineState = data.onlineState
        leftStatusIndicatorView.configure(filled: getLeftButtonText(data.channel.func) != nil, onlineState: onlineState)
        rightStatusIndicatorView.configure(filled: getRightButtonText(data.channel.func) != nil, onlineState: onlineState)
        
        iconView.image = getChannelBaseIconUseCase.invoke(channel: channel).uiImage
        valueView.text = getChannelValueStringUseCase.valueOrNil(channel)
        
        issues = getChannelIssuesForListUseCase.invoke(channelWithChildren: data.shareable)
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
    
    override func timerEndDate() -> Date? {
        data?.channel.getTimerEndDate()
    }
}
