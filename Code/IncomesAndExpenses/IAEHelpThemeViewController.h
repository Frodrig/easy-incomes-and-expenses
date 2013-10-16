//
//  IAEHelpThemeViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAEHelpTheme;

@interface IAEHelpThemeViewController : UIViewController

@property (nonatomic, weak, readonly) IAEHelpTheme *helpTheme;

- (instancetype)initWithHelpTheme:(IAEHelpTheme *)helpTheme;

@end
