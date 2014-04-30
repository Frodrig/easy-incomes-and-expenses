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
#import <AWSRuntime/AWSRuntime.h>
#import <AWSSES/AWSSES.h>


@interface IAEPasswordRecoveryEmailPanelViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *customNavigationItem;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFieldView;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic) BOOL editing;
@property (nonatomic, strong) UIColor *defaultMsgColor;
@property (nonatomic, strong) UIColor *invalidEmailMsgColor;
@property (nonatomic, strong) UIColor *validEmailMsgColor;
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
    [self enableSaveButtonIfApplicable];
}

- (void)configureNavigationView
{
    self.customNavigationItem.title = NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_TITLE", @"");
}

- (void)configurePasswordTextFieldView
{
    self.passwordTextFieldView.delegate = self;
    self.passwordTextFieldView.placeholder = NSLocalizedString(@"LTEXT_PASSWORDPANELEMAILEDITOR_TEXTFIELD_PLACEHOLDER", @"");

    if ([[NSUserDefaults standardUserDefaults] isPasswordRecoveryEmailSet]) {
        self.passwordTextFieldView.text = [[NSUserDefaults standardUserDefaults] findPasswordRecoveryEmail];
    }
}

- (void)configureInformationLabel
{
    [self setDefaultMessageForInformationLabelWithAnimation:NO];
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
        const CGFloat animationTime = animation ? 0.5 : 0;
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
    [self saveActualEmailRecoveryAddressAndDissmis];
}

static NSString * const kAWSAccessKeyId = @"AKIAJ7V3LH7KQC3WBXOQ";
static NSString * const kAWSSecretKey = @"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";

- (void)saveActualEmailRecoveryAddressAndDissmis
{
    [[NSUserDefaults standardUserDefaults] vinculePasswordRecoveryEmail:[self actualPasswordRecoveryEmailWithValidFormat]];
    
     
    
     AmazonSESClient *sesClient = [[AmazonSESClient alloc] initWithAccessKey:kAWSAccessKeyId withSecretKey:kAWSSecretKey];
     
     SESContent *messageBody = [[SESContent alloc] init];
     messageBody.data = @"Test enviado correo con Amazon SES";
     
     SESContent *subject = [[SESContent alloc] init];
     subject.data = @"Title";
    
     SESBody *body = [[SESBody alloc] init];
     body.text = messageBody;
     
     SESMessage *message = [[SESMessage alloc] init];
     message.subject = subject;
     message.body    = body;
     
     SESDestination *destination = [[SESDestination alloc] init];
     [destination.toAddresses addObject:[self actualPasswordRecoveryEmailWithValidFormat]];
     
     SESSendEmailRequest *ser = [[SESSendEmailRequest alloc] init];
     ser.source      = @"hola@frodrig.com";
     ser.destination = destination;
     ser.message     = message;
     
    SESSendEmailResponse *response = [sesClient sendEmail:ser];
    
    
    NSLog(@"a");
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)actualPasswordRecoveryEmailWithValidFormat
{
    return [self.passwordTextFieldView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark - UITextFieldDelegate

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


@end
