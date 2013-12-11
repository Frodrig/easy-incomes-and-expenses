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
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAEHelpIndexViewControllerDelegate.h"

@interface IAEPasswordPanelViewController ()

@property (nonatomic) ModeType mode;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *keyboardView;
@property (nonatomic, strong) NSString *insertedPassword;
@property (nonatomic, copy) NSString *pendingConfirmationPassword;

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
        self.pendingConfirmationPassword = self.insertedPassword;
        self.insertedPassword = @"";
        [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.bounds.size.width * (subState + 1), 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) animated:YES];
    } else if (subState == confirmSubstate) {
        const BOOL passwordOk = [self.pendingConfirmationPassword isEqualToString:self.insertedPassword];
        if (passwordOk) {
            [[NSUserDefaults standardUserDefaults] setNewPassword:self.pendingConfirmationPassword];
            [self.delegate dismissAll];
        } else {
            IAEPasswordPanelScreenView *panel = [self findPasswordPanelOfScrollViewSubstate];
            [panel setMessage:NSLocalizedString(@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INVALIDPASSWORDINCONFIRM", @"")];
            self.insertedPassword = @"";
            [panel clearAllCodes];
        }
    }
}

// TODO: Refactorizar

- (void)performActionsAfterPasswordInsertedInChangeMode
{
    const NSUInteger insertOldSubstate = 0;
    const NSUInteger insertNewSubstate = 1;
    const NSUInteger confirmSubstate = 2;

    const NSUInteger subState = [self findScrollViewSubstate];
    if (subState == insertOldSubstate) {
        NSString *actualPassword = [[NSUserDefaults standardUserDefaults] findPassword];
        const BOOL passwordOk = [self.insertedPassword isEqualToString:actualPassword];
        if (passwordOk) {
            self.insertedPassword = @"";
            [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.bounds.size.width * (subState + 1), 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) animated:YES];
        } else {
            IAEPasswordPanelScreenView *panel = [self findPasswordPanelOfScrollViewSubstate];
            [panel setMessage:NSLocalizedString(@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INVALIDPASSWORDINCHANGE", @"")];
            self.insertedPassword = @"";
            [panel clearAllCodes];
        }
    } else if (subState == insertNewSubstate) {
        self.pendingConfirmationPassword = self.insertedPassword;
        self.insertedPassword = @"";
        [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.bounds.size.width * (subState + 1), 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) animated:YES];
    } else if (subState == confirmSubstate) {
        const BOOL passwordOk = [self.pendingConfirmationPassword isEqualToString:self.insertedPassword];
        if (passwordOk) {
            [[NSUserDefaults standardUserDefaults] setNewPassword:self.pendingConfirmationPassword];
            [self.delegate dismissAll];
        } else {
            IAEPasswordPanelScreenView *panel = [self findPasswordPanelOfScrollViewSubstate];
            [panel setMessage:NSLocalizedString(@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INVALIDPASSWORDINCONFIRM", @"")];
            self.insertedPassword = @"";
            [panel clearAllCodes];
        }
    }

}

// TODO: Refactorizar

- (void)performActionsAfterPasswordInsertedInDeactivateMode
{
    const NSUInteger insertSubstate = 0;
    
    const NSUInteger subState = [self findScrollViewSubstate];
    if (subState == insertSubstate) {
        NSString *actualPassword = [[NSUserDefaults standardUserDefaults] findPassword];
        const BOOL passwordOk = [self.insertedPassword isEqualToString:actualPassword];
        if (passwordOk) {
            [[NSUserDefaults standardUserDefaults] clearPassword];
            [self.delegate dismissAll];
        } else {
            IAEPasswordPanelScreenView *panel = [self findPasswordPanelOfScrollViewSubstate];
            [panel setMessage:NSLocalizedString(@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INVALIDPASSWORDINDEACTIVATE", @"")];
            self.insertedPassword = @"";
            [panel clearAllCodes];
        }
    }
}

// TODO: Refactorizar

- (void)performActionsAfterPasswordInsertedInValidateMode
{
    const NSUInteger insertSubstate = 0;
    
    const NSUInteger subState = [self findScrollViewSubstate];
    if (subState == insertSubstate) {
        NSString *actualPassword = [[NSUserDefaults standardUserDefaults] findPassword];
        const BOOL passwordOk = [self.insertedPassword isEqualToString:actualPassword];
        if (passwordOk) {
            [self.delegate dismissAll];
        } else {
            IAEPasswordPanelScreenView *panel = [self findPasswordPanelOfScrollViewSubstate];
            [panel setMessage:NSLocalizedString(@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INVALIDPASSWORDINVALIDATETOENTER", @"")];
            self.insertedPassword = @"";
            [panel clearAllCodes];
        }
    }
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

@end
