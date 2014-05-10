//
//  IAEPasswordPanelViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 10/12/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordPanelViewController.h"
#import "IAEPasswordPanelScreenView.h"
#import "UIView+LoadFromXib.m"
#import "IAESettingsViewControllerDefs.h"
#import "IAEHelpIndexViewControllerDelegate.h"
#import "KeychainItemWrapper.h"
#import "IAEEmailSender.h"
#import "NSUserDefaults+EasyIncAndExp.h"

@interface IAEPasswordPanelViewController ()

@property (nonatomic) ModeType mode;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *keyboardView;
@property (nonatomic, strong) NSString *insertedPassword;
@property (nonatomic, copy) NSString *pendingConfirmationPassword;
@property (weak, nonatomic) IBOutlet UIButton *recoveryButton;

@end

@implementation IAEPasswordPanelViewController

#pragma mark - constants

static const NSInteger kBasePanelPasswordTag = 100;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return nil;
}

- (id)init
{
    return nil;
}

- (instancetype)initWithMode:(ModeType)mode
{
    self = [super initWithNibName:@"IAEPasswordPanelViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        _mode = mode;
        _insertedPassword = @"";
        _pendingConfirmationPassword = @"";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureNavigationController];
    [self configureRecoveryButtonBasedInMode];
}

- (void)configureNavigationController
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = [self findTitleForNavigationControllerWithModeType:self.mode];
}

-(NSString *)findTitleForNavigationControllerWithModeType:(ModeType)mode
{
    NSString *retTitle;
    
    if (mode == MT_Activate) {
        retTitle = @"LTEXT_PASSWORDPANEL_ACTIVATEMODETITLE";
    } else if (mode == MT_Deactivate) {
        retTitle = @"LTEXT_PASSWORDPANEL_DEACTIVATEMODETITLE";
    } else if (mode == MT_Change) {
        retTitle = @"LTEXT_PASSWORDPANEL_CHANGEMODETITLE";
    } else if (mode == MT_Validate) {
        retTitle = @"";
    }
    
    retTitle = NSLocalizedString(retTitle, @"");
    
    return retTitle;
}

- (void)configureRecoveryButtonBasedInMode
{
    if (self.mode == MT_Validate && [[NSUserDefaults standardUserDefaults] isPasswordRecoveryEmailSet]) {
        self.recoveryButton.hidden = NO;
        [self.recoveryButton setTitle:NSLocalizedString(@"LTEXT_PASSWORDPANEL_RECOVERYBUTTON_TITLE", @"") forState:UIControlStateNormal];
    } else {
        self.recoveryButton.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureScrollViewBasedInMode];
}

- (void)configureScrollViewBasedInMode
{
    if (self.mode == MT_Activate) {
        [self addCreatePasswordPanelScreen];
    } else if (self.mode == MT_Deactivate) {
        [self addInsertToValidatePasswordPanelScreen];
    } else if (self.mode == MT_Change) {
        [self addInsertToChangePasswordPanelScreen];
    } else if (self.mode == MT_Validate) {
        [self addInsertToValidatePasswordPanelScreenToEnter];
    }
}

- (void)addCreatePasswordPanelScreen
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 2, self.scrollView.bounds.size.height);
    
    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOCREATE" atScrollViewPosition:0];
    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOCONFIRM" atScrollViewPosition:1];
}

- (void)addInsertToValidatePasswordPanelScreen
{
    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOVALIDATE" atScrollViewPosition:0];
}

- (void)addInsertToValidatePasswordPanelScreenToEnter
{
    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTTOVALIDATETOENTER" atScrollViewPosition:0];
}

- (void)addInsertToChangePasswordPanelScreen
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 3, self.scrollView.bounds.size.height);

    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOCHANGE" atScrollViewPosition:0];
    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOCREATE" atScrollViewPosition:1];
    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOCONFIRM" atScrollViewPosition:2];
}

- (void)createAndInsertPasswordPanelScreenViewWithMessage:(NSString *)message atScrollViewPosition:(NSInteger)position
{
    IAEPasswordPanelScreenView *panel = (IAEPasswordPanelScreenView *)[UIView viewFromXib:@"IAEPasswordPanelScreenView" withOwner:self];
    panel.frame = CGRectMake(self.scrollView.bounds.size.width * position, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    panel.tag = [self createTagForPasswordPanelAtPosition:position];
    [panel setMessage:NSLocalizedString(message, @"")];
    
    [self.scrollView addSubview:panel];
}

- (IAEPasswordPanelScreenView *)findPasswordPanelScreenAtPosition:(NSInteger)position
{
    const NSInteger tag = [self createTagForPasswordPanelAtPosition:position];
    IAEPasswordPanelScreenView *panel = (IAEPasswordPanelScreenView *)[self.scrollView viewWithTag:tag];
    
    return panel;
}

- (NSInteger)createTagForPasswordPanelAtPosition:(NSInteger)position
{
    const NSInteger tag = kBasePanelPasswordTag + position;
    
    return tag;
}

- (NSUInteger)findScrollViewSubstate
{
    const NSUInteger substate = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    
    return substate;
}

- (IAEPasswordPanelScreenView *)findPasswordPanelOfScrollViewSubstate
{
    const NSUInteger subState = [self findScrollViewSubstate];
    const NSUInteger panelTag = [self createTagForPasswordPanelAtPosition:subState];
    IAEPasswordPanelScreenView *panel = (IAEPasswordPanelScreenView *)[self.scrollView viewWithTag:panelTag];
    
    return panel;
}

#pragma mark - Keyboard Events

- (IBAction)keyboardCodePressed:(UIButton *)sender
{
    if (self.insertedPassword.length < 4) {
        [self addToInsertedPasswordTheCode:[sender titleForState:UIControlStateNormal]];
        [self updatePanelScreenWithInsertedPassword];
        if (self.insertedPassword.length == 4) {
            [self checkStateAfterPasswordInsertedAndPerformActions];
        }
    }
}

- (void)addToInsertedPasswordTheCode:(NSString *)code
{
    self.insertedPassword = [self.insertedPassword stringByAppendingString:code];
}

- (void)checkStateAfterPasswordInsertedAndPerformActions
{
    if (self.mode == MT_Activate) {
        [self performActionsAfterPasswordInsertedInActivateMode];
    } else if (self.mode == MT_Change) {
        [self performActionsAfterPasswordInsertedInChangeMode];
    } else if (self.mode == MT_Deactivate) {
        [self performActionsAfterPasswordInsertedInDeactivateMode];
    } else if (self.mode == MT_Validate) {
        [self performActionsAfterPasswordInsertedInValidateMode];
    }
}

// TODO: Refactorizar

- (void)performActionsAfterPasswordInsertedInActivateMode
{
    const NSUInteger insertSubstate = 0;
    const NSUInteger confirmSubstate = 1;
    
    const NSUInteger subState = [self findScrollViewSubstate];
    if (subState == insertSubstate) {
        [self advanceScrollViewSavingInsertedPassword:YES andCleaningInsertedPassword:YES];
    } else if (subState == confirmSubstate) {
        [self checkInsertedPasswordWithPendingConfirmationPasswordAndPerformActions];
    }
}

- (void)advanceScrollViewSavingInsertedPassword:(BOOL)saveInsertedPassword andCleaningInsertedPassword:(BOOL)cleanInsertedPassword
{
    [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.bounds.size.width + self.scrollView.contentOffset.x, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) animated:YES];
    
    if (saveInsertedPassword) {
        self.pendingConfirmationPassword = self.insertedPassword;
    }
    
    if (cleanInsertedPassword) {
        self.insertedPassword = @"";
    }
}

- (void)checkInsertedPasswordWithPendingConfirmationPasswordAndPerformActions
{
    const BOOL passwordOk = [self.pendingConfirmationPassword isEqualToString:self.insertedPassword];
    if (passwordOk) {
        [self changeUserPasswordWithNotificationEmailIfApplicableAndDismiss:self.pendingConfirmationPassword];
    } else {
        [self performActionsAfterInvalidPasswordInsertedWithIncorrectPasswordMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INVALIDPASSWORDINCONFIRM"];
    }
}

- (void)changeUserPasswordWithNotificationEmailIfApplicableAndDismiss:(NSString *)newPasswordCode
{
    const BOOL passwordRecoveryEmailSet = [[NSUserDefaults standardUserDefaults] isPasswordRecoveryEmailSet];
    const BOOL canSendPasswordChangedEmail = passwordRecoveryEmailSet && [[KeychainItemWrapper defaultKeychain] isPasswordActivated];
    const BOOL canSendPasswordEnabledEmail = passwordRecoveryEmailSet && ![[KeychainItemWrapper defaultKeychain] isPasswordActivated];
    
    [[KeychainItemWrapper defaultKeychain] setNewPassword:self.pendingConfirmationPassword];
    
    if (canSendPasswordChangedEmail) {
        [[IAEEmailSender sharedInstance] sendPasswordChangedEmail];
    } else if (canSendPasswordEnabledEmail){
        [[IAEEmailSender sharedInstance] sendPasswordEnabledEmail];
    }
    
    [self.delegate dismissAll];
}

- (void)performActionsAfterPasswordInsertedInChangeMode
{
    const NSUInteger insertOldSubstate = 0;
    const NSUInteger insertNewSubstate = 1;
    const NSUInteger confirmSubstate = 2;

    const NSUInteger subState = [self findScrollViewSubstate];
    if (subState == insertOldSubstate) {
       if ([self isInsertedPasswordEqualToUserPassword]) {
           [self advanceScrollViewSavingInsertedPassword:NO andCleaningInsertedPassword:YES];
        } else {
            [self performActionsAfterInvalidPasswordInsertedWithIncorrectPasswordMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INVALIDPASSWORDINCHANGE"];
        }
    } else if (subState == insertNewSubstate) {
        [self advanceScrollViewSavingInsertedPassword:YES andCleaningInsertedPassword:YES];
    } else if (subState == confirmSubstate) {
        [self checkInsertedPasswordWithPendingConfirmationPasswordAndPerformActions];
    }
}

- (void)performActionsAfterInvalidPasswordInsertedWithIncorrectPasswordMessage:(NSString *)incorrectPasswordMessage
{
    IAEPasswordPanelScreenView *panel = [self findPasswordPanelOfScrollViewSubstate];
    [panel setMessage:NSLocalizedString(incorrectPasswordMessage, @"")];
    self.insertedPassword = @"";
    [panel clearAllCodes];
    
    [panel executeFXInvalidPassword];
}
- (void)performActionsAfterPasswordInsertedInDeactivateMode
{
    [self performActionsAfterPasswordInsertedCleaningUserPassword:YES
                               andShowingIncorrectPasswordMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INVALIDPASSWORDINDEACTIVATE"];

}

- (void)performActionsAfterPasswordInsertedInValidateMode
{
    [self performActionsAfterPasswordInsertedCleaningUserPassword:NO
                               andShowingIncorrectPasswordMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INVALIDPASSWORDINVALIDATETOENTER"];
}

- (void)performActionsAfterPasswordInsertedCleaningUserPassword:(BOOL)clearUserPassword andShowingIncorrectPasswordMessage:(NSString *)incorrectPasswordMessage
{
    const NSUInteger insertSubstate = 0;
    
    const NSUInteger subState = [self findScrollViewSubstate];
    if (subState == insertSubstate) {
        if ([self isInsertedPasswordEqualToUserPassword]) {
            if (clearUserPassword) {
                [self clearUserPasswordAndNotifyWithRecoveryEmailIfApplicable];
            }
            [self.delegate dismissAll];
        } else {
            [self performActionsAfterInvalidPasswordInsertedWithIncorrectPasswordMessage:incorrectPasswordMessage];
        }
    }
}

- (void)clearUserPasswordAndNotifyWithRecoveryEmailIfApplicable
{
    [[KeychainItemWrapper defaultKeychain] clearPassword];
    if ([[NSUserDefaults standardUserDefaults] isPasswordRecoveryEmailSet]) {
        [[IAEEmailSender sharedInstance] sendPasswordDisabledEmail];
    }
}

- (BOOL)isInsertedPasswordEqualToUserPassword
{
    NSString *actualPassword = [[KeychainItemWrapper defaultKeychain] findPassword];
    const BOOL passwordEqual = [self.insertedPassword isEqualToString:actualPassword];

    return passwordEqual;
}

- (IBAction)keyboardDeletePressed:(id)sender
{
    [self deleteLastCodeInInsertedPassword];
    [self updatePanelScreenWithInsertedPassword];
}

- (void)deleteLastCodeInInsertedPassword
{
    if (self.insertedPassword.length > 0) {
        self.insertedPassword = [self.insertedPassword substringToIndex:self.insertedPassword.length - 1];
    }
}

- (void)updatePanelScreenWithInsertedPassword
{
    IAEPasswordPanelScreenView *panel = [self findPasswordPanelOfScrollViewSubstate];
    for (NSUInteger index = 0; index < 4; ++index) {
        if (self.insertedPassword.length > index) {
            [panel addCodeAtPosition:index];
        } else {
            [panel clearCodeAtPosition:index];
        }
    }
}

#pragma mark - RecoveryPasswordButton

- (IBAction)recoveryButtonPressed:(id)sender
{
    [[IAEEmailSender sharedInstance] sendRecoveryPasswordEmail];
    [self launchAlertViewToInformAboutRecoveryPasswordEmailWasSend];
}

- (void)launchAlertViewToInformAboutRecoveryPasswordEmailWasSend
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_PASSWORDPANEL_VALIDATE_ALERTVIEWRECOVERYEMAILPASSWORDSEND_TITLE", @"")
                                                        message:NSLocalizedString(@"LTEXT_PASSWORDPANEL_VALIDATE_ALERTVIEWRECOVERYEMAILPASSWORDSEND_MESSAGE", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"LTEXT_PASSWORDPANEL_VALIDATE_ALERTVIEWRECOVERYEMAILPASSWORDSEND_OK", @"")
                                              otherButtonTitles:nil];
    [alertView show];
}


@end
