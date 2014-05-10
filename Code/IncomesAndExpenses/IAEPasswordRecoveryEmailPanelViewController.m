//
//  IAEPasswordRecoveryEmailPanelViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 19/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordRecoveryEmailPanelViewController.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAEEmailChecker.h"
#import "IAEEmailSender.h"

typedef NS_ENUM(NSUInteger, AlertViewType) {
    AlertViewRecoveryEmailLinked,
    AlertViewRecoveryEmailUnlinked,
    AlertViewDefault,
    AlertViewNone
};

static const CGFloat kDissolveMessagesTime = 0.5;

@interface IAEPasswordRecoveryEmailPanelViewController ()<UITextFieldDelegate,
                                                          UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *customNavigationItem;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFieldView;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *unlinkButton;
@property (weak, nonatomic) IBOutlet UILabel *noComercialUseLabel;
@property (nonatomic) BOOL editing;
@property (nonatomic, strong) UIColor *defaultMsgColor;
@property (nonatomic, strong) UIColor *invalidEmailMsgColor;
@property (nonatomic, strong) UIColor *validEmailMsgColor;
@property (nonatomic, strong) NSString *unlinkRecoveryEmail;
@property (nonatomic) AlertViewType actualAlertView;

@end

@implementation IAEPasswordRecoveryEmailPanelViewController

#pragma mark - Properties

- (UIColor *)defaultMsgColor
{
    if (!_defaultMsgColor) {
        _defaultMsgColor = [UIColor blackColor];
    }
    
    return _defaultMsgColor;
}

- (UIColor *)invalidEmailMsgColor
{
    if (!_invalidEmailMsgColor) {
        _invalidEmailMsgColor = [UIColor blackColor];
    }
    
    return _invalidEmailMsgColor;
}

- (UIColor *)validEmailMsgColor
{
    if (!_validEmailMsgColor) {
        _validEmailMsgColor = [UIColor blackColor];
    }
    
    return _validEmailMsgColor;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initVars];
        [self configureModalPresentationAndTransition];
    }
    return self;
}

- (void)initVars
{
    _actualAlertView = AlertViewNone;
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
    [self configureBarButtons];
    [self configureUnlinkButton];
    [self configurePasswordTextFieldView];
    [self configureInformationLabel];
    [self configureNoComercialUseLabel];
    [self enableSaveButtonIfApplicable];
}

- (void)configureNavigationView
{
    self.customNavigationItem.title = NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_TITLE", @"");
}

- (void)configureBarButtons
{
    if ([[NSUserDefaults standardUserDefaults] isPasswordRecoveryEmailSet]) {
        self.customNavigationItem.rightBarButtonItem = nil;
    }
}

- (void)configureUnlinkButton
{
    [self.unlinkButton setTitle:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_UNLINKBUTTON_TITLE", @"") forState:UIControlStateNormal];
}

- (void)configurePasswordTextFieldView
{
    self.passwordTextFieldView.delegate = self;
    self.passwordTextFieldView.placeholder = [[NSUserDefaults standardUserDefaults] isPasswordRecoveryEmailSet] ? [[NSUserDefaults standardUserDefaults] findPasswordRecoveryEmail
    ] : NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_TEXTFIELD_PLACEHOLDER", @"");
}

- (void)configureInformationLabel
{
    if ([[NSUserDefaults standardUserDefaults] isPasswordRecoveryEmailSet]) {
        self.unlinkButton.hidden = NO;
    } else {
        [self setDefaultMessageForInformationLabelWithAnimation:NO];
        self.unlinkButton.hidden = YES;
    }
}

- (void)setDefaultMessageForInformationLabelWithAnimation:(BOOL)animation
{
    [self setMessage:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_INFOMSG_DEFAULT", @"") forInformationLabelWithAnimation:animation withColor:self.defaultMsgColor];
}

- (void)setIncorrectEmailMessageForInformationLabelWithAnimation:(BOOL)animation
{
    [self setMessage:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_INFOMSG_INVALIDEMAIL", @"") forInformationLabelWithAnimation:animation withColor:self.invalidEmailMsgColor];
}

- (void)setNewEmailMessageForInformationLabelWithAnimation:(BOOL)animation
{
    [self setMessage:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_INFOMSG_NEWVALIDEMAIL", @"") forInformationLabelWithAnimation:animation withColor:self.validEmailMsgColor];
}

- (void)setMessage:(NSString *)message forInformationLabelWithAnimation:(BOOL)animation withColor:(UIColor *)color
{
    if ([message compare:self.informationLabel.text] != NSOrderedSame) {
        const CGFloat animationTime = animation ? kDissolveMessagesTime : 0;
        [UIView animateWithDuration:animationTime animations:^{
            self.informationLabel.alpha = 0;
        } completion:^(BOOL finished) {
            self.informationLabel.text = message;
            self.informationLabel.textColor = color;
            [UIView animateWithDuration:animationTime animations:^{
                self.informationLabel.alpha = 1.0;
            }];
        }];
    }
}

- (void)configureNoComercialUseLabel
{
    self.noComercialUseLabel.text = NSLocalizedString(@"LTEXT_PASSWORDPANEL_INFONOCOMERCIALUSE", @"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BarButtonsEvents

- (IBAction)cancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButton:(id)sender
{
    [self saveActualEmailRecoveryAddress];
    [self sendConfirmationLinkedEmailRecoveryAddress];
    [self launchPreDismissAlertViewWithInformationAboutVinculeEmailRecoveryAddress];
}

- (void)saveActualEmailRecoveryAddress
{
    [[NSUserDefaults standardUserDefaults] vinculePasswordRecoveryEmail:[self actualPasswordRecoveryEmailWithValidFormat]];
}

- (void)sendConfirmationLinkedEmailRecoveryAddress
{
    [[IAEEmailSender sharedInstance] sendConfirmationLinkedMailForRecoveryPasswordEmail];
}

- (void)launchPreDismissAlertViewWithInformationAboutVinculeEmailRecoveryAddress
{
    self.actualAlertView = AlertViewRecoveryEmailLinked;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_ALERTVIEW_TITLE", @"")
                                                        message:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_ALERTVIEW_MESSAGE", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_ALERTVIEW_OK", @"")
                                              otherButtonTitles:nil];
    [alertView show];
}

- (NSString *)actualPasswordRecoveryEmailWithValidFormat
{
    return [self.passwordTextFieldView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.actualAlertView == AlertViewRecoveryEmailLinked) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (self.actualAlertView == AlertViewRecoveryEmailUnlinked) {
        if (buttonIndex == 1) {
            [[NSUserDefaults standardUserDefaults] desvinculePasswordRecoveryEmail];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    const BOOL should = ![[NSUserDefaults standardUserDefaults] isPasswordRecoveryEmailSet];
    if (!should) {
        [self launchAlertViewWithWarningAboutBeginEditingWithPasswordRecoveryEmailSet];
    }
    
    return should;
}

- (void)launchAlertViewWithWarningAboutBeginEditingWithPasswordRecoveryEmailSet
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_ALERTVIEW_WARNINGCANTEDITEMAILWITHLINKEDEMAIL_TITLE", @"")
                                                        message:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_ALERTVIEW_WARNINGCANTEDITEMAILWITHLINKEDEMAIL_MESSAGE", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_ALERTVIEW_WARNINGCANTEDITEMAILWITHLINKEDEMAIL_OK", @"")
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.editing = YES;
    [self disableSaveButton];
}

- (void)enableSaveButtonIfApplicable
{
    self.saveButton.enabled = !self.editing && [self isActualEmailRecoveryAddressNewAndValid];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.editing = NO;
    [self enableSaveButtonIfApplicable];
    if ([self isSaveButtonAvailable]) {
        if ([self isNewEmailRecoveryDifferentFromPreviousEmailRecovery]) {
            [self setNewEmailMessageForInformationLabelWithAnimation:YES];
        } else {
            [self setDefaultMessageForInformationLabelWithAnimation:YES];
        }
    } else {
        if ([self actualPasswordRecoveryEmailWithValidFormat].length > 0) {
            [self setIncorrectEmailMessageForInformationLabelWithAnimation:YES];
        } else {
            [self setDefaultMessageForInformationLabelWithAnimation:YES];
        }
    }
}

- (BOOL)isNewEmailRecoveryDifferentFromPreviousEmailRecovery
{
    BOOL retIsNewEmailRecoveryDifferent = YES;
    if ([[NSUserDefaults standardUserDefaults] isPasswordRecoveryEmailSet]) {
        retIsNewEmailRecoveryDifferent = [[[[NSUserDefaults standardUserDefaults] findPasswordRecoveryEmail] uppercaseString] compare:[[self actualPasswordRecoveryEmailWithValidFormat] uppercaseString]] != NSOrderedSame;
    }
    
    return retIsNewEmailRecoveryDifferent;
}

- (BOOL)isSaveButtonAvailable
{
    return self.saveButton.enabled;
}

- (void)disableSaveButton
{
    self.saveButton.enabled = NO;
}

- (BOOL)isActualEmailRecoveryAddressNewAndValid
{
    return [IAEEmailChecker isValidEmail:[self actualPasswordRecoveryEmailWithValidFormat]];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    // IMPORTANTE: Por algun motivo para que el teclado desaparezca tras return EN UN MODAL, hay que sobrecargar esta funcion
    return NO;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UnlinkButton

- (IBAction)unlinkButtonPressed:(id)sender
{
    [self launchAlertViewToConfirmDesvinculeRecoveryEmail];
}

- (void)launchAlertViewToConfirmDesvinculeRecoveryEmail
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_ALERTVIEW_CONFIRMUNLINKRECOVERYEMAIL_TITLE", @"")
                                                        message:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_ALERTVIEW_CONFIRMUNLINKRECOVERYEMAIL_MESSAGE", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_ALERTVIEW_CONFIRMUNLINKRECOVERYEMAIL_NO", @"")
                                              otherButtonTitles:NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_ALERTVIEW_CONFIRMUNLINKRECOVERYEMAIL_YES", @""), nil];
    [alertView show];
    
    self.actualAlertView = AlertViewRecoveryEmailUnlinked;
}

@end
