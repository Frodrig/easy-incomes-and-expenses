//
//  IAEPasswordPanelViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 10/12/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordPanelViewController.h"

@interface IAEPasswordPanelViewController ()

@property (nonatomic) ModeType mode;

@end

@implementation IAEPasswordPanelViewController


#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return nil;
}

- (id)init
{
    return nil;
}

- (instancetype)initWithMode:(ModeType)mode
{
    self = [super initWithNibName:@"IAEPasswordPanelViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        _mode = mode;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationController];
}

- (void)configureNavigationController
{
    NSString *title = [self findTitleForNavigationControllerWithModeType:self.mode];
    self.navigationItem.title = title;
}

-(NSString *)findTitleForNavigationControllerWithModeType:(ModeType)mode
{
    NSString *retTitle;
    
    if (mode == MT_Activate) {
        retTitle = @"LTEXT_PASSWORDPANEL_ACTIVATEMODETITLE";
    } else if (mode == MT_Deactivate) {
        retTitle = @"LTEXT_PASSWORDPANEL_DEACTIVATEMODETITLE";
    } else if (mode == MT_Change) {
        retTitle = @"LTEXT_PASSWORDPANEL_CHANGEMODETITLE";
    }
    
    retTitle = NSLocalizedString(retTitle, @"");
    
    return retTitle;
}

@end
