//
//  IAEHelpThemeViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpThemeViewController.h"
#import "IAEHelpTheme.h"

@interface IAEHelpThemeViewController ()

@end

@implementation IAEHelpThemeViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithHelpTheme:nil];
}

- (instancetype)initWithHelpTheme:(IAEHelpTheme *)helpTheme
{
    NSAssert(helpTheme, @"");
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _helpTheme = helpTheme;
    }
    
    return self;
}

#pragma mark - ViewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNavigationController];
}

- (void)configureNavigationController
{
    self.title = _helpTheme.title;
}

@end
