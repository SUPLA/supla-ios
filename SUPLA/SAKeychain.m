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

#import "SAKeychain.h"

@implementation SAKeychain

+ (NSMutableDictionary *)attributesWithKey:(NSString *)key {
    return [@{(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
              (__bridge id)kSecAttrService : @"SAKeychain",
              (__bridge id)kSecAttrAccount : key,
              (__bridge id)kSecAttrAccessible : (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
              } mutableCopy];
}

+ (BOOL)deleteObjectWithKey:(NSString *)key {
    NSMutableDictionary *attrs = [self attributesWithKey:key];
    return noErr == SecItemDelete((__bridge CFDictionaryRef)attrs);
}

+ (BOOL)addObject:(id)object withKey:(NSString *)key {
    NSMutableDictionary *attrs = [self attributesWithKey:key];
    
    [attrs setObject:[NSKeyedArchiver archivedDataWithRootObject:object] forKey:(__bridge id)kSecValueData];
    return noErr == SecItemAdd((__bridge CFDictionaryRef)attrs, NULL);
}

+ (id)getObjectWithKey:(NSString *)key {
    id result = nil;
    
    NSMutableDictionary *attrs = [self attributesWithKey:key];
    
    [attrs setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [attrs setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    CFDataRef data = NULL;
    
    if (noErr == SecItemCopyMatching((__bridge CFDictionaryRef)attrs, (CFTypeRef *)&data)) {
        @try {
            result = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)data];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
            result = nil;
        }
        @finally {}
    }
    
    if (data) {
        CFRelease(data);
    }
    
    return result;
}
@end
