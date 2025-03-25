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

final class DoubleIconValueCell: BaseCell<ChannelWithChildren> {
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    @Singleton<GetCaptionUseCase> private var getCaptionUseCase
    @Singleton<GetChannelValueStringUseCase> private var getChannelValueStringUseCase
    @Singleton<GetChannelIssuesForListUseCase> private var getChannelIssuesForListUseCase
    
    private lazy var firstIconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var firstValueView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .cellValueFont
        view.textColor = .onBackground
        return view
    }()
    
    private lazy var secondIconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var secondValueView: UILabel = {
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
            firstIconView,
            firstValueView,
            secondIconView,
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
        secondValueView.font = .cellValueFont.withSize(scale(Dimens.Fonts.value, limit: .lower(1)))
        
        container.addSubview(firstIconView)
        container.addSubview(firstValueView)
        container.addSubview(secondIconView)
        container.addSubview(secondValueView)
        
        super.setupView()
    }
    
    override func derivedClassConstraints() -> [NSLayoutConstraint] {
        return [
            firstIconView.heightAnchor.constraint(equalToConstant: scale(Dimens.ListItem.iconHeight)),
            firstIconView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: inverseScale(6)),
            firstIconView.topAnchor.constraint(equalTo: container.topAnchor),
            
            firstValueView.leftAnchor.constraint(equalTo: firstIconView.rightAnchor, constant: 4),
            firstValueView.centerYAnchor.constraint(equalTo: firstIconView.centerYAnchor),
            firstValueView.widthAnchor.constraint(equalToConstant: firstValueView.intrinsicContentSize.width),
            firstValueView.rightAnchor.constraint(equalTo: container.centerXAnchor, constant: -6),
            
            secondIconView.heightAnchor.constraint(equalToConstant: scale(Dimens.ListItem.iconHeight)),
            secondIconView.leftAnchor.constraint(equalTo: container.centerXAnchor, constant: 6),
            secondIconView.topAnchor.constraint(equalTo: container.topAnchor),
            
            secondValueView.leftAnchor.constraint(equalTo: secondIconView.rightAnchor, constant: 4),
            secondValueView.centerYAnchor.constraint(equalTo: secondIconView.centerYAnchor),
            secondValueView.widthAnchor.constraint(equalToConstant: secondValueView.intrinsicContentSize.width),
            secondValueView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -inverseScale(6))
        ]
    }
    
    override func updateContent(data: ChannelWithChildren) {
        super.updateContent(data: data)
        
        let channel = data.channel
        
        caption = getCaptionUseCase.invoke(data: channel.shareable).string
        
        let onlineState = data.onlineState
        leftStatusIndicatorView.configure(filled: getLeftButtonText(data.channel.func) != nil, onlineState: onlineState)
        rightStatusIndicatorView.configure(filled: getRightButtonText(data.channel.func) != nil, onlineState: onlineState)
        
        firstIconView.image = getChannelBaseIconUseCase.invoke(channel: channel).uiImage
        firstValueView.text = getChannelValueStringUseCase.valueOrNil(channel)
        secondIconView.image = getChannelBaseIconUseCase.invoke(channel: channel, type: .second).uiImage
        secondValueView.text = getChannelValueStringUseCase.valueOrNil(channel, valueType: .second, withUnit: false)
        
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
