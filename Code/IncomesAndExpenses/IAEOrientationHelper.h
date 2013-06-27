//
//  IAEOrientationHelper.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEOrientationHelper : NSObject

+ (BOOL)isActualOrientationPortraitOrientation;
+ (BOOL)isActualOrientationLandscapeOrientation;

+ (BOOL)isPortraitOrientationForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
+ (BOOL)isLandscapeOrientationForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
