//
//  IAEPasswordPanelViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 10/12/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAEHelpIndexViewControllerDelegate;

typedef NS_ENUM(NSUInteger, ModeType)
{
    MT_Activate,
    MT_Deactivate,
    MT_Change,
    MT_Validate
};

@interface IAEPasswordPanelViewController : UIViewController

@property (nonatomic, weak)id<IAEHelpIndexViewControllerDelegate> delegate;

- (instancetype)initWithMode:(ModeType)mode;

@end
