//
//  IAEInfoProVersionLicenceViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 16/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEInfoProVersionLicenceViewController.h"

@interface IAEInfoProVersionLicenceViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UILabel *easyIncomesAndExpensesLabel;
@property (weak, nonatomic) IBOutlet UILabel *proVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *thankYouLabel;

@end

@implementation IAEInfoProVersionLicenceViewController

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
    [self localizeStrings];
}

- (void)localizeStrings
{
    self.navItem.title = NSLocalizedString(@"LTEXT_INFOPROVERSIONMODAL_TITLE", @"");
    self.easyIncomesAndExpensesLabel.text = NSLocalizedString(@"LTEXT_INFOPROVERSIONMODAL_APPNAME", @"");
    self.proVersionLabel.text = NSLocalizedString(@"LTEXT_INFOPROVERSIONMODAL_PROVERSION", @"");
    self.thankYouLabel.text = NSLocalizedString(@"LTEXT_INFOPROVERSIONMODAL_THANKYOU", @"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Events

- (IBAction)doneButtonPressed:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
