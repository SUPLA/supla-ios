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

-(NSData *)aes128Operation:(CCOperation)operation withPassword:(NSString *)password {
    
    // *Password
    // This is not a good implementation but sufficient for current use
    while(password.length < 32) {
        password = [NSString stringWithFormat:@"%@0", password];
    }
    
    password = [password substringToIndex:32];
    
    size_t bufferSize = [self length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    NSData *_key = [password dataUsingEncoding:NSUTF8StringEncoding];
    
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

- (NSData *)aes128EncryptWithPassword:(NSString *)password {
    return [self aes128Operation:kCCEncrypt withPassword:password];
}

- (NSData *)aes128DecryptWithPassword:(NSString *)password {
    return [self aes128Operation:kCCDecrypt withPassword:password];
}

- (NSData *)aes128EncryptWithDeviceUniqueId {
    // Unfortunately, identifierForVendor is different for AppStore and TestFlight
    NSString *pwd = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return [self aes128EncryptWithPassword:pwd];
}

- (NSData *)aes128DecryptWithDeviceUniqueId {
    NSString *pwd = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return [self aes128DecryptWithPassword:pwd];
    
}
@end
