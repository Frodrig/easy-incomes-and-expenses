//
//  IAEHelpThemeViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAEHelpIndexViewControllerDelegate;
@class IAEHelpTheme;

@interface IAEHelpThemeViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, weak) id<IAEHelpIndexViewControllerDelegate> delegate;
@property (nonatomic, weak, readonly) IAEHelpTheme *helpTheme;

- (instancetype)initWithHelpTheme:(IAEHelpTheme *)helpTheme;

@end
