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
#import "SAThermostatCalendar.h"

@interface ThermostatCalendarTests : XCTestCase

@end

@implementation ThermostatCalendarTests {
    SAThermostatCalendar *_calendar;
}

- (void)setUp {
    _calendar = [[SAThermostatCalendar alloc] init];
}

- (void)tearDown {
    _calendar = nil;
}

- (void)testSettingFirtsDay {
    for(short a=1;a<=7;a++) {
        _calendar.firstDay = a;
        XCTAssertEqual(a, _calendar.firstDay);
    }

    _calendar.firstDay = 0;
    XCTAssertEqual(7, _calendar.firstDay);
    _calendar.firstDay = 8;
    XCTAssertEqual(7, _calendar.firstDay);
}

- (void)testGettingDayOffset {

    {
        int d[] = { 1, 2, 3, 4, 5, 6, 7 };

        for(short a=1;a<=7;a++) {
            XCTAssertEqual(d[a-1], [_calendar addOffsetToDay:a]);
        }
    }


    _calendar.firstDay = 2;

    {
        int d[] = { 2, 3, 4, 5, 6, 7, 1 };

        for(short a=1;a<=7;a++) {
            XCTAssertEqual(d[a-1], [_calendar addOffsetToDay:a]);
        }
    }

    _calendar.firstDay = 7;

    {
        int d[] = { 7, 1, 2, 3, 4, 5, 6 };

        for(short a=1;a<=7;a++) {
            XCTAssertEqual(d[a-1], [_calendar addOffsetToDay:a]);
        }
    }

}


- (void)testSettingHourProgramTo1 {
    short d,h;

    for(d=1;d<=7;d++) {
        for(h=0;h<24;h++) {
            XCTAssertFalse([_calendar programIsSetToOneWithDay:d andHour:h]);
            [_calendar setProgramForDay:d andHour:h toOne:true];
            XCTAssertTrue([_calendar programIsSetToOneWithDay:d andHour:h]);
        }
    }
}

@end
