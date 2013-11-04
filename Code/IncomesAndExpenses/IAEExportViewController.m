//
//  IAEExportViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExportViewController.h"
#import "IAEExportChooseWhereViewController.h"

@interface IAEExportViewController ()

@property (nonatomic, strong) NSMutableDictionary *userConfiguration;

@end

@implementation IAEExportViewController

#pragma mark - Constants

static const CGFloat kTintValueForNavigation = 0.6;

#pragma mark - Properties
- (NSMutableDictionary *)userConfiguration
{
    if (!_userConfiguration) {
        _userConfiguration = [NSMutableDictionary dictionary];
    }
    
    return _userConfiguration;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
    [self launchExportStepOneViewController];
}

- (void)configureView
{
    self.view.tintColor = [UIColor colorWithWhite:kTintValueForNavigation alpha:1.0];
}

- (void)launchExportStepOneViewController
{
    IAEExportChooseWhereViewController *chooseWhereViewController = [[IAEExportChooseWhereViewController alloc] initWithNibName:nil bundle:nil];
    chooseWhereViewController.userConfiguration = self.userConfiguration;
    [self pushViewController:chooseWhereViewController animated:NO];
}

@end
