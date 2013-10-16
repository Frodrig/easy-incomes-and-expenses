//
//  IAEAboutAndOptions2ViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 15/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEAboutAndOptionsViewController.h"
#import "IAEHelpIndexViewController.h"

@interface IAEAboutAndOptionsViewController ()

@end

@implementation IAEAboutAndOptionsViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
