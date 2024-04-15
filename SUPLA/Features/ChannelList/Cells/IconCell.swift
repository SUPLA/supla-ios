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

final class IconCell: BaseCell<ChannelWithChildren> {
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    @Singleton<GetChannelBaseCaptionUseCase> private var getChannelBaseCaptionUseCase
    @Singleton<GetChannelValueStringUseCase> private var getChannelValueStringUseCase
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override func provideRefreshData(_ updateEventsManager: UpdateEventsManager, forData: ChannelWithChildren) -> Observable<ChannelWithChildren> {
        updateEventsManager.observeChannelWithChildren(remoteId: Int(forData.channel.remote_id))
    }
    
    override func getLocationCaption() -> String? { data?.channel.location?.caption }
    
    override func getRemoteId() -> Int32? { data?.channel.remote_id ?? 0 }
    
    override func online() -> Bool { data?.channel.isOnline() ?? false }
    
    override func derivedClassControls() -> [UIView] {
        return [iconView]
    }
    
    override func onInfoPress(_ gr: UITapGestureRecognizer) {
        if let delegate = delegate as? BaseCellDelegate,
           let channel = data?.channel
        {
            delegate.onInfoIconTapped(channel)
        }
    }
    
    override func setupView() {
        container.addSubview(iconView)
        
        super.setupView()
    }
    
    override func derivedClassConstraints() -> [NSLayoutConstraint] {
        return [
            iconView.widthAnchor.constraint(equalToConstant: scale(60.0)),
            iconView.heightAnchor.constraint(equalToConstant: scale(Dimens.ListItem.iconHeight)),
            iconView.leftAnchor.constraint(equalTo: container.leftAnchor),
            iconView.topAnchor.constraint(equalTo: container.topAnchor),
            iconView.rightAnchor.constraint(equalTo: container.rightAnchor)
        ]
    }
    
    override func updateContent(data: ChannelWithChildren) {
        super.updateContent(data: data)
        
        let channel = data.channel
        
        caption = getChannelBaseCaptionUseCase.invoke(channelBase: channel)
        
        leftStatusIndicatorView.configure(filled: hasLeftButton(), online: channel.isOnline())
        rightStatusIndicatorView.configure(filled: hasRightButton(), online: channel.isOnline())
        
        iconView.image = getChannelBaseIconUseCase.invoke(channel: channel)
        
        issueIcon = nil
    }
    
    override func leftButtonSettings() -> CellButtonSettings {
        if (hasLeftButton()) {
            return CellButtonSettings(visible: online(), title: Strings.General.close)
        } else {
            return super.leftButtonSettings()
        }
    }
    
    override func rightButtonSettings() -> CellButtonSettings {
        if (hasLeftButton()) {
            return CellButtonSettings(visible: online(), title: Strings.General.close)
        } else {
            return super.rightButtonSettings()
        }
    }
    
    private func hasLeftButton() -> Bool {
        switch (data?.channel.func) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW,
             SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND,
             SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER: true
        default: false
        }
    }
    
    private func hasRightButton() -> Bool {
        switch (data?.channel.func) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW,
             SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND,
             SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER: true
        default: false
        }
    }
}
