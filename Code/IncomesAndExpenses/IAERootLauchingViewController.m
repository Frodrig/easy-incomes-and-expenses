//
//  IAERootLauchingViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 12/09/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAERootLauchingViewController.h"
#import "IAEEasyIncomesAndExpensesViewController.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAEPasswordPanelViewController.h"

@interface IAERootLauchingViewController ()

@property (nonatomic, strong) IAEPasswordPanelViewController *passwordViewController;
@property (nonatomic, strong) UINavigationController *mainViewController;
@property (nonatomic, strong) UIImageView *launchImage;
@end

@implementation IAERootLauchingViewController

#pragma mark - constants

static NSString * const kMainStoryBoardName = @"Main";
static NSString * const kLaunchImageName = @"ipadlandscape_launchimage";
static NSString * const kEasyIncomesAndExpensesViewControllerID = @"EasyIncomesAndExpensesViewControllerID";

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initSuscriptionToGlobalNotifications];
        if ([[NSUserDefaults standardUserDefaults] isPasswordActivated]) {
            [self initPasswordController];
        } else {
            [self initNavigationControllerWithRootController];
        }
        [self initLaunchImage];
    }
    return self;
}

- (void)initSuscriptionToGlobalNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notificationApplicationDidEnterBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notificationApplicationWillEnterForeground:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
}

- (void)initPasswordController
{
    _passwordViewController = [[IAEPasswordPanelViewController alloc] initWithMode:MT_Validate];
    _passwordViewController.delegate = self;
    _passwordViewController.modalPresentationStyle = UIModalPresentationFormSheet;
}

- (void)initLaunchImage
{
    _launchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kLaunchImageName]];
    _launchImage.backgroundColor = [UIColor clearColor];
}

- (void)initNavigationControllerWithRootController
{
    IAEEasyIncomesAndExpensesViewController *rootViewController = [self instantiateFromStoryBoardEasyIncomesViewController];
    rootViewController.delegate = self;
    
    _mainViewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    _mainViewController.navigationBar.tintColor = [UIColor colorWithWhite:kGlobalTintColorForWhiteComponent alpha:1.0];
}

- (IAEEasyIncomesAndExpensesViewController *)instantiateFromStoryBoardEasyIncomesViewController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kMainStoryBoardName bundle:[NSBundle mainBundle]];
    IAEEasyIncomesAndExpensesViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:kEasyIncomesAndExpensesViewControllerID];
    
    return viewController;
}

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.launchImage];
}

#pragma mark - viewWillAppear

- (void)performActionsAfterInsertedAsRootViewController
{
    if (self.mainViewController) {
        [self showMainViewController];
    } else if (self.passwordViewController) {
        [self presentViewController:self.passwordViewController animated:YES completion:nil];
    }
}

- (void)showMainViewController
{
    [self.view insertSubview:self.mainViewController.view aboveSubview:self.launchImage];
    self.mainViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

#pragma mark - IAEEasyIncomesAndExpensesViewControllerDelegate

- (void)lauchCompleteInEasyIncomesAndExpensesViewController:(IAEEasyIncomesAndExpensesViewController *)easyIncomesAndExpensesViewController
{
    [self.launchImage removeFromSuperview];
    self.launchImage = nil;
}

#pragma mark - Notifications

- (void)notificationApplicationDidEnterBackground:(NSNotification *)notification
{
    if ([[NSUserDefaults standardUserDefaults] isPasswordActivated]) {
        if (!self.launchImage) {
            [self.mainViewController.view removeFromSuperview];
            [self initLaunchImage];
            [self.view addSubview:self.launchImage];
        }
    }
}

- (void)notificationApplicationWillEnterForeground:(NSNotification *)notification
{
    if ([[NSUserDefaults standardUserDefaults] isPasswordActivated]) {
        [self initPasswordController];
        [self presentViewController:self.passwordViewController animated:YES completion:nil];
    }
}

#pragma mark - IAEHelpIndexViewControllerDelegate

- (void)dismissAll
{
    [self.passwordViewController dismissViewControllerAnimated:YES completion:^{
        if (self.mainViewController) {
            [self showMainViewController];
        } else {
            [self initNavigationControllerWithRootController];
            [self showMainViewController];
        }
        
        self.passwordViewController = nil;
    }];
}

@end
