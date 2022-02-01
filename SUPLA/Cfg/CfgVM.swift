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
import RxSwift
import RxCocoa

class CfgVM {
    struct Inputs {
        var channelHeight: Observable<ChannelHeight>
        var temperatureUnit: Observable<TemperatureUnit>
        var autoHideButtons: Observable<Bool>
        var showChannelInfo: Observable<Bool>
        var showOpeningPercent: Observable<Bool>
        var onDismiss: Observable<Void>
    }
    
    var channelHeight: Observable<ChannelHeight> { return _channelHeight.asObservable() }
    var temperatureUnit: Observable<TemperatureUnit> { return _temperatureUnit.asObservable() }
    var autoHideButtons: Observable<Bool> { return _autoHideButtons.asObservable() }
    var showChannelInfo: Observable<Bool> { return _showChannelInfo.asObservable() }
    var showOpeningPercent: Observable<Bool> { return _showOpeningPercent.asObservable() }
    
    private let _channelHeight = BehaviorRelay<ChannelHeight>(value: .height100)
    private let _temperatureUnit = BehaviorRelay<TemperatureUnit>(value: .celsius)
    private let _autoHideButtons = BehaviorRelay<Bool>(value: true)
    private let _showChannelInfo = BehaviorRelay<Bool>(value: true)
    private let _showOpeningPercent = BehaviorRelay<Bool>(value: false)
    
    private let disposeBag = DisposeBag()
    private let model: Config
    
    init(inputs: Inputs, configModel: Config) {
        model = configModel
        
        inputs.onDismiss.subscribe(onNext: { [weak self] in
            self?.commitSettings()
        }).disposed(by: disposeBag)
        
        inputs.channelHeight.bind(to: _channelHeight).disposed(by: disposeBag)
        inputs.autoHideButtons.bind(to: _autoHideButtons).disposed(by: disposeBag)
        inputs.temperatureUnit.bind(to: _temperatureUnit).disposed(by: disposeBag)
        inputs.showChannelInfo.bind(to: _showChannelInfo).disposed(by: disposeBag)
        inputs.showOpeningPercent.bind(to: _showOpeningPercent).disposed(by: disposeBag)
        
        _channelHeight.accept(model.channelHeight)
        _temperatureUnit.accept(model.temperatureUnit)
        _autoHideButtons.accept(model.autohideButtons)
        _showChannelInfo.accept(model.showChannelInfo)
        _showOpeningPercent.accept(model.showOpeningPercent)
    }
    
    private func commitSettings() {
        model.channelHeight = _channelHeight.value
        model.temperatureUnit = _temperatureUnit.value
        model.autohideButtons = _autoHideButtons.value
        model.showChannelInfo = _showChannelInfo.value
        model.showOpeningPercent = _showOpeningPercent.value
    }
}
