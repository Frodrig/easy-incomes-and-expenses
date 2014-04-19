//
//  IAEPasswordRecoveryEmailPanelViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 19/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordRecoveryEmailPanelViewController.h"
#import "NSUserDefaults+EasyIncAndExp.h"

@interface IAEPasswordRecoveryEmailPanelViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *customNavigationItem;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFieldView;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
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
    
    [self configureNavigationView];
    [self configurePasswordTextFieldView];
    [self configureInformationLabel];
}

- (void)configureNavigationView
{
    self.customNavigationItem.title = NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_TITLE", @"");
}

- (void)configurePasswordTextFieldView
{
    self.passwordTextFieldView.placeholder = NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_TEXTFIELD_PLACEHOLDER", @"");

    if ([[NSUserDefaults standardUserDefaults] isPasswordRecoveryEmailSet]) {
        self.passwordTextFieldView.text = [[NSUserDefaults standardUserDefaults] findPasswordRecoveryEmail];
    }
}

- (void)configureInformationLabel
{
    [self setDefaultMessageForInformationLabel];
}

- (void)setDefaultMessageForInformationLabel
{
    self.informationLabel.text = NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_INFOMSG_DEFAULT", @"");
}

- (void)setIncorrectEmailMessageForInformationLabel
{
    self.informationLabel.text = NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_INFOMSG_INVALIDEMAIL", @"");
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
