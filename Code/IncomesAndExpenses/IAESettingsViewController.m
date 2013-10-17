//
//  IAEAboutAndOptions2ViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 15/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAESettingsViewController.h"
#import "IAEHelpIndexViewController.h"

@interface IAESettingsViewController ()

@end

@implementation IAESettingsViewController

#pragma mark - Constants

static const NSUInteger kTintValueForNavigation = 0.74;

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
    
    // Do any additional setup after loading the view from its nib.
    IAEHelpIndexViewController *helpIndexViewController = [[IAEHelpIndexViewController alloc] init];
    [self pushViewController:helpIndexViewController animated:NO];
    self.view.tintColor = [UIColor colorWithWhite:kTintValueForNavigation alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
