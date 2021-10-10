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
        var onDismiss: Observable<Void>
    }
    
    var channelHeight: Observable<ChannelHeight> { return _channelHeight.asObservable() }
    var temperatureUnit: Observable<TemperatureUnit> { return _temperatureUnit.asObservable() }
    var autoHideButtons: Observable<Bool> { return _autoHideButtons.asObservable() }
    
    private let _channelHeight = BehaviorRelay<ChannelHeight>(value: .height100)
    private let _temperatureUnit = BehaviorRelay<TemperatureUnit>(value: .celsius)
    private let _autoHideButtons = BehaviorRelay<Bool>(value: true)
    
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
        
        _channelHeight.accept(model.channelHeight)
        _temperatureUnit.accept(model.temperatureUnit)
        _autoHideButtons.accept(model.autohideButtons)
    }
    
    private func commitSettings() {
        model.channelHeight = _channelHeight.value
        model.temperatureUnit = _temperatureUnit.value
        model.autohideButtons = _autoHideButtons.value
    }
}
