//
//  IAEExportViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExportViewController.h"
#import "IAEExportStepOneViewController.h"

@interface IAEExportViewController ()

@end

@implementation IAEExportViewController

#pragma mark - Constants

static const CGFloat kTintValueForNavigation = 0.6;

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
    IAEExportStepOneViewController *exportStepOneViewController = [[IAEExportStepOneViewController alloc] initWithNibName:nil bundle:nil];
    [self pushViewController:exportStepOneViewController animated:NO];
}

@end
