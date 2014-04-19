//
//  IAEPasswordRecoveryEmailPanelViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 19/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordRecoveryEmailPanelViewController.h"

@interface IAEPasswordRecoveryEmailPanelViewController ()

@end

@implementation IAEPasswordRecoveryEmailPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self configureModalPresentationAndTransition];
    }
    return self;
}

- (void)configureModalPresentationAndTransition
{
    self.modalPresentationStyle = UIModalPresentationFormSheet;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
