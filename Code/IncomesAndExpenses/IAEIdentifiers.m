//
//  IAEIdentifiers.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 19/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEIdentifiers.h"

@implementation IAEIdentifiers

+ (NSString *)generateUniqueIdentifier
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef stringUUID = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    NSString *retString = (__bridge NSString *)stringUUID;
    
    return retString;
}

@end
