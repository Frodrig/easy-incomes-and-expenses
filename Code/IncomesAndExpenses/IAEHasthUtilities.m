//
//  IAEHasthUtilities.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 19/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHasthUtilities.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation IAEHasthUtilities

+ (NSString *)hashedValueForStringIdentifier:(NSString*)identifier
{
    const int HASH_SIZE = 32;
    unsigned char hashedChars[HASH_SIZE];
    const char *accountName = [identifier UTF8String];
    size_t identifierLen = strlen(accountName);
    
    // Confirm that the length of the user name is small enough
    // to be recast when calling the hash function.
    if (identifierLen > UINT32_MAX) {
        NSLog(@"Account name too long to hash: %@", identifier);
        return nil;
    }
    
    CC_SHA256((__bridge const void *)(identifier), (CC_LONG)identifierLen, hashedChars);
    
    // Convert the array of bytes into a string showing its hex representation.
    NSMutableString *identifierHash = [[NSMutableString alloc] init];
    for (int i = 0; i < HASH_SIZE; i++) {
        // Add a dash every four bytes, for readability.
        if (i != 0 && i%4 == 0) {
            [identifierHash appendString:@"-"];
        }
        [identifierHash appendFormat:@"%02x", hashedChars[i]];
    }
    
    return identifierHash;
}
@end
