//
//  IAEOrientationHelper.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEOrientationHelper.h"

@implementation IAEOrientationHelper

+ (UIInterfaceOrientation)getInterfaceOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    return orientation;
}

+ (BOOL)isActualOrientationPortraitOrientation
{
    UIInterfaceOrientation orientation = [self getInterfaceOrientation];
    return [self isPortraitOrientationForInterfaceOrientation:orientation];
}

+ (BOOL)isActualOrientationLandscapeOrientation
{
    UIInterfaceOrientation orientation = [self getInterfaceOrientation];
    return [self isLandscapeOrientationForInterfaceOrientation:orientation];
}

+ (BOOL)isPortraitOrientationForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}

+ (BOOL)isLandscapeOrientationForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}

@end
