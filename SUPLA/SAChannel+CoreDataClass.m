//
//  SAChannel+CoreDataClass.m
//  SUPLA
//
//  Created by Przemysław Zygmunt on 02.11.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "SAChannel+CoreDataClass.h"
#import "_SALocation+CoreDataClass.h"
#import "Database.h"

@implementation SAChannel

- (BOOL) setChannelLocation:(_SALocation*)location {
    
    if ( self.location != location ) {
        self.location = location;
        return YES;
    }
    
    return NO;
}


- (BOOL) setChannelFunction:(int)function {
    
    if ( [self.func isEqualToNumber:[NSNumber numberWithInt:function]] == NO ) {
        self.func = [NSNumber numberWithInt:function];
        return YES;
    }
    
    return NO;
}

- (BOOL) setChannelOnline:(char)online {
    
    if ( [self.online isEqualToNumber:[NSNumber numberWithBool:online != 0]] == NO ) {
        self.online = [NSNumber numberWithBool:online != 0];
        return YES;
    }
    
    return NO;
}

- (BOOL) number:(NSNumber*)n1 isEqualToNumber:(id)n2 {
    
    if ( n1 == nil && n2 != nil )
        return NO;
    
    if ( n2 == nil && n1 != nil )
        return NO;
    
    if ( [n1 isKindOfClass:[NSNumber class]] == NO || [n2 isKindOfClass:[NSNumber class]] == NO )
        return NO; // is unknown
    
    if ( n1 != nil && n2 != nil && [n1 isEqualToNumber:n2] == NO )
        return NO;
    
    return YES;
}

- (BOOL) setChannelValue:(TSuplaChannelValue*)value {
    
    id old_val = self.value;
    id old_sub_val = self.sub_value;
    
    switch([self.func intValue]) {
            
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
        case SUPLA_CHANNELFNC_POWERSWITCH:
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
            
            self.value = [NSNumber numberWithBool:value->value[0] == 1];
            self.sub_value = [NSNumber numberWithBool:value->sub_value[0] == 1];
            
            break;
            
        case SUPLA_CHANNELFNC_THERMOMETER:
        case SUPLA_CHANNELFNC_DEPTHSENSOR:
        case SUPLA_CHANNELFNC_DISTANCESENSOR:
        {
            double v;
            memcpy(&v, value->value, sizeof(double));
            self.value = [NSNumber numberWithDouble:v];
            self.sub_value = nil;
            break;
        }
            
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
        {
            double t,h;
            int v;
            
            memcpy(&v, value->value, 4);
            t = v/1000.00;
            
            memcpy(&v, &value->value[4], 4);
            h = v/1000.00;
            
            self.value = [NSArray arrayWithObjects:[NSNumber numberWithDouble:t], [NSNumber numberWithDouble:h], nil];
            self.sub_value = nil;
            break;
        }
            
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
        case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
            self.value = [NSNumber numberWithBool:value->value[0] == 1];
            self.sub_value = nil;
            break;
            
        case SUPLA_CHANNELFNC_DIMMER:
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
        {
            int brightness = value->value[0];
            
            if ( brightness > 100 || brightness < 0 )
                brightness = 0;
            
            int colorBrightness = value->value[1];
            
            if ( colorBrightness > 100 || colorBrightness < 0 )
                colorBrightness = 0;
            
            UIColor *color = [UIColor colorWithRed:(unsigned char)value->value[4]/255.00 green:(unsigned char)value->value[3]/255.00 blue:(unsigned char)value->value[2]/255.00 alpha:1];
            
            if ( (unsigned char) value->value[4] == 255
                 && (unsigned char) value->value[3] == 255
                 && (unsigned char) value->value[2] == 255 ) color = [UIColor whiteColor];
            
      
            self.value = [NSArray arrayWithObjects:[NSNumber numberWithInt:brightness], [NSNumber numberWithInt:colorBrightness], color, nil];
        }
            break;
    }
    
    if ( [self number:(NSNumber*)self.value isEqualToNumber:old_val] == NO
        || [self number:(NSNumber*)self.sub_value isEqualToNumber:old_sub_val] == NO ) {
        return YES;
    }
    
    return NO;
    
}

- (BOOL) setChannelCaption:(char*)caption {
    
    NSString *_caption = [NSString stringWithUTF8String:caption];
    
    if ( [self.caption isEqualToString:_caption] == NO  ) {
        self.caption = _caption;
        return YES;
    }
    
    return NO;
}

- (BOOL) setChannelVisible:(int)visible {
    
    if ( [self.visible isEqualToNumber:[NSNumber numberWithInt:visible]] == NO ) {
        self.visible = [NSNumber numberWithInt:visible];
        return YES;
    }
    
    return NO;
}

- (BOOL) isOnline {
    return [self.online isEqualToNumber:[NSNumber numberWithBool:YES]];
}

- (BOOL) isClosed {
    
    if ( [self isOnline] ) {
        switch([self.func intValue]) {
                
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
                if ( self.sub_value != nil
                    && [self.sub_value isKindOfClass:[NSNumber class]])
                    return [(NSNumber*)self.sub_value boolValue];
                break;
                
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
                return [self hiValue];
                break;
        }
    }
    
    return NO;
}

- (BOOL) hiValue {
    
    if ( [self isOnline]
        && self.value != nil
        && [self.value isKindOfClass:[NSNumber class]])
        return [(NSNumber*)self.value boolValue];
    
    
    return NO;
}

- (double) doubleValue {
    
    if ( self.value != nil
        && [self.value isKindOfClass:[NSNumber class]] )
        return [(NSNumber*)self.value doubleValue];
    
    return 0;
}

- (double) getDoubleValue:(int)idx size:(int)Size unknown_val:(double)unknown {
    
    if ( self.value != nil
        && [self.value isKindOfClass:[NSArray class]] ) {
        
        NSArray *arr = (NSArray*)self.value;
        if ( arr.count == Size ) {
            id obj = [arr objectAtIndex:idx];
            
            if ( [obj isKindOfClass:[NSNumber class]] )
                return [obj doubleValue];
        }
    }
    
    return unknown;
}


- (double) temperatureValue {
    
    switch([self.func intValue]) {
        case SUPLA_CHANNELFNC_THERMOMETER:
            return self.doubleValue;
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            return [self getDoubleValue:0 size:2 unknown_val:-275];
            
    }
    
    return -275;
}

- (double) humidityValue {
    
    if ( [self.func intValue] == SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE ) {
        return [self getDoubleValue:1 size:2 unknown_val:-1];
    }
    
    return -1;
}

- (BOOL) isOn {
    
    switch([self.func intValue]) {
            
        case SUPLA_CHANNELFNC_POWERSWITCH:
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
            
            return [self hiValue];
    }
    
    return NO;
}

- (int) getBrightness:(int)idx {
    
    switch([self.func intValue]) {
            
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMER:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            
            if ( self.value != nil
                && [self.value isKindOfClass:[NSArray class]] ) {
                
                NSArray *arr = (NSArray*)self.value;
                if ( arr.count >= idx
                    && arr.count >= 3
                    && [[arr objectAtIndex:idx] isKindOfClass:[NSNumber class]]
                    && [[arr objectAtIndex:2] isKindOfClass:[UIColor class]] ) {
                    
                    return [[arr objectAtIndex:idx] intValue];
                    
                }
            }
    }
    
    return 0;
    
    
}

-(UIColor *)getColor {
    
    
    switch([self.func intValue]) {
            
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            
            if ( self.value != nil
                && [self.value isKindOfClass:[NSArray class]] ) {
                
                NSArray *arr = (NSArray*)self.value;
                if ( arr.count >= 3
                    && [[arr objectAtIndex:2] isKindOfClass:[UIColor class]] ) {
                    
                    return [arr objectAtIndex:2];
                }
            }
    }
    
    
    return nil;
}

- (int) getBrightness {
    
    return [self getBrightness:0];
}

- (int) getColorBrightness {
    return [self getBrightness:1];
    
}

- (UIImage*) channelIcon {
    
    NSString *n1 = nil;
    NSString *n2 = nil;
    
    switch([self.func intValue]) {
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            n1 = @"gateway";
            break;
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
            n1 = @"gate";
            break;
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            n1 = @"garagedoor";
            break;
        case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
            n1 = @"door";
            break;
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
            n1 = @"rollershutter";
            break;
        case SUPLA_CHANNELFNC_POWERSWITCH:
            n2 = @"power";
            break;
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
            n2 = @"light";
            break;
        case SUPLA_CHANNELFNC_THERMOMETER:
            return [UIImage imageNamed:@"thermometer"];
        case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
            return [UIImage imageNamed:[self hiValue] ? @"liquid" : @"noliquid"];
        case SUPLA_CHANNELFNC_DIMMER:
            return [UIImage imageNamed:[NSString stringWithFormat:@"dimmer-%@", [self getBrightness] > 0 ? @"on" : @"off"]];
            
        case SUPLA_CHANNELFNC_RGBLIGHTING:
            return [UIImage imageNamed:[NSString stringWithFormat:@"rgb-%@", [self getColorBrightness] > 0 ? @"on" : @"off"]];
            
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return [UIImage imageNamed:[NSString stringWithFormat:@"dimmerrgb-%@%@", [self getBrightness] > 0 ? @"on" : @"off", [self getColorBrightness] > 0 ? @"on" : @"off"]];
            break;
            
    }
    
    if ( n1 ) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", n1, [self isClosed] ? @"closed" : @"open"]];
    }
    
    if ( n2 ) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", n2, [self isOn] ? @"on" : @"off"]];
    }
    
    
    return nil;
}

- (NSString *)getChannelCaption {
    
    if ( [self.caption isEqualToString:@""] ) {
        
        switch([self.func intValue]) {
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
                return NSLocalizedString(@"Gateway opening sensor", nil);
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
                return NSLocalizedString(@"Gateway", nil);
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
                return NSLocalizedString(@"Gate opening sensor", nil);
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
                return NSLocalizedString(@"Gate", nil);
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
                return NSLocalizedString(@"Garage door opening sensor", nil);
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
                return NSLocalizedString(@"Garage door", nil);
            case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
                return NSLocalizedString(@"Door opening sensor", nil);
            case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
                return NSLocalizedString(@"Door", nil);
            case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
                return NSLocalizedString(@"Roller shutter opening sensor", nil);
            case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
                return NSLocalizedString(@"Roller shutter", nil);
            case SUPLA_CHANNELFNC_POWERSWITCH:
                return NSLocalizedString(@"Power switch", nil);
            case SUPLA_CHANNELFNC_LIGHTSWITCH:
                return NSLocalizedString(@"Lighting switch", nil);
            case SUPLA_CHANNELFNC_THERMOMETER:
                return NSLocalizedString(@"Thermometer", nil);
            case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
                return NSLocalizedString(@"Temperature and humidity", nil);
            case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
                return NSLocalizedString(@"No liquid sensor", nil);
            case SUPLA_CHANNELFNC_RGBLIGHTING:
                return NSLocalizedString(@"RGB Lighting", nil);
            case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                return NSLocalizedString(@"Dimmer and RGB lighting", nil);
            case SUPLA_CHANNELFNC_DIMMER:
                return NSLocalizedString(@"Dimmer", nil);
            case SUPLA_CHANNELFNC_DISTANCESENSOR:
                return NSLocalizedString(@"Distance sensor", nil);
            case SUPLA_CHANNELFNC_DEPTHSENSOR:
                return NSLocalizedString(@"Depth sensor", nil);
                
        }
        
    }
    
    return self.caption;
    
}

@end
