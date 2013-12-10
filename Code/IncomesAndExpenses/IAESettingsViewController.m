//
//  IAEAboutAndOptions2ViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 15/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAESettingsViewController.h"
#import "IAEHelpIndexViewController.h"
#import "IAESettingsViewControllerDefs.h"

@interface IAESettingsViewController ()

@end

@implementation IAESettingsViewController

#pragma mark - Constants


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
   
    [self configureController];
    [self configureView];
    [self launchIndexViewController];
}

- (void)configureController
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)configureView
{
    self.view.tintColor = [UIColor colorWithWhite:kTintValueForNavigation alpha:1.0];
}

-(void)launchIndexViewController
{
    IAEHelpIndexViewController *helpIndexViewController = [[IAEHelpIndexViewController alloc] init];
    [self pushViewController:helpIndexViewController animated:NO];
}

@end
