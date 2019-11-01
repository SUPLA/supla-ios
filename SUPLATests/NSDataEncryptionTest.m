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
#import "NSData+AES.h"

@interface NSDataEncryptionTest : XCTestCase

@end

@implementation NSDataEncryptionTest

- (void)testEncryption {
   
    NSString *sourceText = @"ABCD";
    NSData *sourceData = [sourceText dataUsingEncoding:NSUTF8StringEncoding];
    
    // Key is aligned to 32 characters
    NSData *encrypted = [sourceData aes128EncryptWithPassword:@"X"];
    XCTAssertNotNil(encrypted);
    XCTAssertFalse([encrypted isEqualToData:sourceData]);
    
    NSData *decrypted = [encrypted aes128DecryptWithPassword:@"X"];
    XCTAssertNotNil(decrypted);
    XCTAssertFalse([encrypted isEqualToData:decrypted]);
    XCTAssertTrue([decrypted isEqualToData:sourceData]);
    
    NSString *decryptedText = [[NSString alloc]
                               initWithData:decrypted encoding:NSUTF8StringEncoding];
    XCTAssertTrue([decryptedText isEqualToString:sourceText]);
    
    decrypted = [encrypted aes128DecryptWithPassword:@"Y"];
    XCTAssertFalse([sourceData isEqualToData:decrypted]);
    
    decrypted = [encrypted aes128DecryptWithPassword:@"X000000000000000000000000000000Y"];
    XCTAssertFalse([sourceData isEqualToData:decrypted]);
    
    decrypted = [encrypted aes128DecryptWithPassword:@"X0000000000000000000000000000000Y"];
    XCTAssertTrue([sourceData isEqualToData:decrypted]);
}

@end
