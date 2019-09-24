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

#import <XCTest/XCTest.h>
#import "SAThermostatScheduleCfg.h"

@interface ThermostatScheduleCfgTests : XCTestCase

@end

@implementation ThermostatScheduleCfgTests {
    SAThermostatScheduleCfg *_cfg;
}

- (void)setUp {
    _cfg = [[SAThermostatScheduleCfg alloc] init];
}

- (void)tearDown {
    _cfg = nil;
}

- (void) testTemperatureSettingForOneDa {
    for(short a=0;a<23;a++) {
        [_cfg setTemperature:a forHour:a weekday:kMONDAY];
    }

    XCTAssertEqual(1, _cfg.groupCount);
    [_cfg clear];
    XCTAssertEqual(0, _cfg.groupCount);
}

- (void) testTemperatureSettingForAllDaysWithIdenticalTemperatures {

    for(short a=0;a<23;a++) {
        [_cfg setTemperature:a forHour:a weekday:kMONDAY];
        [_cfg setTemperature:a forHour:a weekday:kTUESDAY];
        [_cfg setTemperature:a forHour:a weekday:kWEDNESDAY];
        [_cfg setTemperature:a forHour:a weekday:kTHURSDAY];
        [_cfg setTemperature:a forHour:a weekday:kFRIDAY];
        [_cfg setTemperature:a forHour:a weekday:kSATURDAY];
        [_cfg setTemperature:a forHour:a weekday:kSUNDAY];
    }

    XCTAssertEqual(1, _cfg.groupCount);
    [_cfg clear];
    XCTAssertEqual(0, _cfg.groupCount);
}

- (void) testSettingTemperatureAndProgram {

    [_cfg setTemperature:0 forHour:0 weekday:kMONDAY];
    [_cfg setProgram:0 forHour:0 weekday:kMONDAY];

    XCTAssertEqual(1, _cfg.groupCount);

    [_cfg clear];
    XCTAssertEqual(0, _cfg.groupCount);

    [_cfg setTemperature:0 forHour:0 weekday:kMONDAY];
    [_cfg setTemperature:0 forHour:0 weekday:kTUESDAY];
 
    XCTAssertEqual(1, _cfg.groupCount);

    [_cfg setTemperature:0 forHour:0 weekday:kMONDAY];
    [_cfg setProgram:0 forHour:0 weekday:kTUESDAY];
    
    XCTAssertEqual(2, _cfg.groupCount);
}

- (void) testTemperatureSettingForAllDaysWithDifferentTemperatures {

    for(short a=0;a<23;a++) {
        [_cfg setTemperature:1 forHour:a weekday:kMONDAY];
        [_cfg setTemperature:2 forHour:a weekday:kTUESDAY];
        [_cfg setTemperature:3 forHour:a weekday:kWEDNESDAY];
        [_cfg setTemperature:4 forHour:a weekday:kTHURSDAY];
        [_cfg setTemperature:5 forHour:a weekday:kFRIDAY];
        [_cfg setTemperature:6 forHour:a weekday:kSATURDAY];
        [_cfg setTemperature:7 forHour:a weekday:kSUNDAY];
    }

    XCTAssertEqual(7, _cfg.groupCount);
    [_cfg clear];
    XCTAssertEqual(0, _cfg.groupCount);
}

- (void) testGettingGroupWeekDay {

    [_cfg setTemperature:3 forHour:1 weekday:kWEDNESDAY];
    [_cfg setTemperature:4 forHour:2 weekday:kTHURSDAY];
    
    XCTAssertEqual(2, _cfg.groupCount);
    XCTAssertEqual(0, [_cfg weekDaysForGroupIndex:-1]);
 
    XCTAssertEqual(kWEDNESDAY, [_cfg weekDaysForGroupIndex:0]);
    XCTAssertEqual(kTHURSDAY, [_cfg weekDaysForGroupIndex:1]);

    [_cfg setTemperature:3 forHour:1 weekday:kTHURSDAY];

    XCTAssertEqual(2, _cfg.groupCount);
    XCTAssertEqual(kTHURSDAY, [_cfg weekDaysForGroupIndex:1]);
    XCTAssertEqual(kWEDNESDAY, [_cfg weekDaysForGroupIndex:0]);
}

- (void) testGettingGroupHourValueType {
    
    XCTAssertEqual(kTEMPERATURE, [_cfg valueTypeForGroupIndex:0]);

    [_cfg setTemperature:3 forHour:1 weekday:kWEDNESDAY];

    XCTAssertEqual(kTEMPERATURE, [_cfg valueTypeForGroupIndex:0]);

    [_cfg setProgram:3 forHour:1 weekday:kWEDNESDAY];

    XCTAssertEqual(kPROGRAM, [_cfg valueTypeForGroupIndex:0]);
}

- (void) testGettingGroupHourValue {
    char hourValue[24];
    memset(hourValue, 0, sizeof(hourValue));
    
    XCTAssertFalse([_cfg hourValueEqualTo:hourValue forGroupIndex:0]);
    
    [_cfg setTemperature:0 forHour:1 weekday:kWEDNESDAY];
    
    XCTAssertTrue([_cfg hourValueEqualTo:hourValue forGroupIndex:0]);

    [_cfg setTemperature:30 forHour:17 weekday:kWEDNESDAY];

    hourValue[17] = 30;
    XCTAssertTrue([_cfg hourValueEqualTo:hourValue forGroupIndex:0]);
}

- (void) testGroupCount {
    XCTAssertEqual(0, _cfg.groupCount);
    [_cfg setTemperature:30 forHour:17 weekday:kMONDAY];
    XCTAssertEqual(1, _cfg.groupCount);
    [_cfg setTemperature:30 forHour:18 weekday:kMONDAY];
    XCTAssertEqual(1, _cfg.groupCount);
    [_cfg setTemperature:30 forHour:18 weekday:kWEDNESDAY];
    XCTAssertEqual(2, _cfg.groupCount);
    [_cfg setTemperature:40 forHour:18 weekday:kMONDAY];
    XCTAssertEqual(2, _cfg.groupCount);
    [_cfg setTemperature:0 forHour:17 weekday:kMONDAY];
    XCTAssertEqual(2, _cfg.groupCount);
    [_cfg setTemperature:30 forHour:18 weekday:kMONDAY];
    XCTAssertEqual(1, _cfg.groupCount);
}

- (void) testGetingHourValue {
    XCTAssertEqual(0, _cfg.groupCount);
    char value1[24];
    char value2[24];
    memset(value1, 0, sizeof(value1));
    memset(value2, 0, sizeof(value2));
    
    [_cfg setTemperature:30 forHour:18 weekday:kWEDNESDAY];
    XCTAssertEqual(1, _cfg.groupCount);
    
    value2[18] = 30;
    [_cfg getHourValue:value1 forGroupIndex:0];
    
    XCTAssertTrue(memcmp(value1, value2, sizeof(value1)) == 0);
}
@end
