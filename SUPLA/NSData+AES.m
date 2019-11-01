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

#import "NSData+AES.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (AES)

-(NSData *)aes128Operation:(CCOperation)operation withKey:(NSString *)key {
    
    while(key.length < 32) {
        key = [NSString stringWithFormat:@"%@0", key];
    }
    
    key = [key substringToIndex:32];
    
    size_t bufferSize = [self length] + kCCBlockSizeAES128 * 2;
    void *buffer = malloc(bufferSize);
    
    NSData *_key = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [_key bytes],
                                          [_key length],
                                          nil,
                                          [self bytes],
                                          [self length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);

    if (cryptStatus == kCCSuccess && encryptedSize > 0) {
        return [NSData dataWithBytesNoCopy:buffer length:encryptedSize];
    }
    
    free(buffer);
    return nil;
}

- (NSData *)aes128EncryptWithKey:(NSString *)key {
    return [self aes128Operation:kCCEncrypt withKey:key];
}

- (NSData *)aes128DecryptWithKey:(NSString *)key {
    return [self aes128Operation:kCCDecrypt withKey:key];
}

- (NSData *)aes128EncryptWithDeviceUniqueId {
    NSString *key = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return [self aes128EncryptWithKey:key];
}

- (NSData *)aes128DecryptWithDeviceUniqueId {
    NSString *key = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return [self aes128DecryptWithKey:key];
    
}
@end
