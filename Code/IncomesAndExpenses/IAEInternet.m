//
//  IAEInternet.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 21/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEInternet.h"
#import "Reachability.h"

@implementation IAEInternet

+ (BOOL)isConnected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    const BOOL isConnected = [reachability currentReachabilityStatus] != NotReachable;
    
    return isConnected;
}

@end
