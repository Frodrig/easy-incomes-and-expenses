//
//  IAEFixRemoveCategoryActionLostInUnloadedYears.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 17/03/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEFixRemoveCategoryActionLostInUnloadedYears : NSObject

@property(nonatomic, strong) NSString *resultReport;

+ (IAEFixRemoveCategoryActionLostInUnloadedYears *)defaultFix;

- (void)checkAndExecuteIfApplicable;

@end
