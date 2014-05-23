//
//  IAERootLauchingViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 12/09/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAERootLauchingViewController.h"
#import "IAEEasyIncomesAndExpensesViewController.h"
#import "IAEPasswordPanelViewController.h"
#import "KeychainItemWrapper.h"
#import "IAEInAppPurchaseStoreViewControllerDefs.h"

#pragma mark - constants

static NSString * const kMainStoryBoardName = @"Main";
static NSString * const kLaunchImageName = @"ipadlandscape_launchimage";
static NSString * const kEasyIncomesAndExpensesViewControllerID = @"EasyIncomesAndExpensesViewControllerID";
static const CGFloat kFadeInCourtainViewTransitionToProVersionEffectTime = 1.0;
static const CGFloat kFadeOutCourtainViewTransitionToProVersionEffectTime = 3.0;

@interface IAERootLauchingViewController ()

@property (nonatomic, strong) IAEPasswordPanelViewController *passwordViewController;
@property (nonatomic, strong) UINavigationController *mainViewController;
@property (nonatomic, strong) IAEEasyIncomesAndExpensesViewController *easyIncomesAndExpensesViewController;
@property (nonatomic, strong) UIImageView *launchImage;
@property (nonatomic, strong) UIView *courtainView;
@end

@implementation IAERootLauchingViewController

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initSuscriptionToGlobalNotifications];
        if ([[KeychainItemWrapper defaultKeychain] isPasswordActivated]) {
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterProVersionEnabledFromStore:)
                                                 name:kProVersionEnabledFromStore
                                               object:nil];
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
    self.easyIncomesAndExpensesViewController = [self instantiateFromStoryBoardEasyIncomesViewController];
    self.easyIncomesAndExpensesViewController.delegate = self;
    
    _mainViewController = [[UINavigationController alloc] initWithRootViewController:self.easyIncomesAndExpensesViewController];
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
        [self insertMainViewControllerView];
    } else if (self.passwordViewController) {
        [self presentViewController:self.passwordViewController animated:YES completion:nil];
    }
}

- (void)insertMainViewControllerView
{
    [self.view insertSubview:self.mainViewController.view aboveSubview:self.launchImage];
    self.mainViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

#pragma mark - IAEEasyIncomesAndExpensesViewControllerDelegate

- (void)lauchCompleteInEasyIncomesAndExpensesViewController:(IAEEasyIncomesAndExpensesViewController *)easyIncomesAndExpensesViewController
{
    [self removeImageFromView];
}

- (void)removeImageFromView
{
    [self.launchImage removeFromSuperview];
    self.launchImage = nil;
}

#pragma mark - Notifications

- (void)notificationApplicationDidEnterBackground:(NSNotification *)notification
{
    if ([[KeychainItemWrapper defaultKeychain] isPasswordActivated]) {
        if (!self.launchImage) {
            self.mainViewController.view.hidden = YES;
            [self initLaunchImage];
            [self.view addSubview:self.launchImage];
        }
    }
}

- (void)notificationApplicationWillEnterForeground:(NSNotification *)notification
{
    if ([self needToPresentPasswordController]) {
        [self initAndPresentPasswordViewController];
    }
}

- (BOOL)needToPresentPasswordController
{
    return [[KeychainItemWrapper defaultKeychain] isPasswordActivated] && !self.passwordViewController;
}

- (void)initAndPresentPasswordViewController
{
    [self initPasswordController];
    [self presentViewController:self.passwordViewController animated:YES completion:nil];
}

#pragma mark - IAEHelpIndexViewControllerDelegate

- (void)dismissAll
{
    [self.passwordViewController dismissViewControllerAnimated:YES completion:^{
        if (self.mainViewController) {
            self.mainViewController.view.hidden = NO;
            [self dissolveLaunchImageSmooth];
        } else {
            [self initNavigationControllerWithRootController];
            [self insertMainViewControllerView];
        }
        
        self.passwordViewController = nil;
    }];
}

- (void)dissolveLaunchImageSmooth
{
    [UIView animateWithDuration:0.5 animations:^{
        self.launchImage.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeImageFromView];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.courtainView) {
        [UIView animateWithDuration:kFadeOutCourtainViewTransitionToProVersionEffectTime animations:^{
            self.courtainView.alpha = 0.0;
         } completion:^(BOOL finished) {
            [self.courtainView removeFromSuperview];
             self.courtainView = nil;
         }];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

#pragma mark - Notificacion

- (void)notificationCenterProVersionEnabledFromStore:(NSNotification *)notification
{
    self.courtainView = [self createAndAddCourtainViewForTheTransitionToProVisualEffect];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:kFadeInCourtainViewTransitionToProVersionEffectTime animations:^{
        self.courtainView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.easyIncomesAndExpensesViewController resetToLaunchState];
    }];
}

- (UIView *)createAndAddCourtainViewForTheTransitionToProVisualEffect
{
    UIView *courtainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    UILabel *smileLabel = [[UILabel alloc] init];
    smileLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LTEXT_PURCHASEPROVERSION_COURTAIN_THANKYOU", @"") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:100],
                                                                                                               NSForegroundColorAttributeName: [UIColor blackColor],
                                                                                                                                                              NSKernAttributeName: @(1.5)}];
    [smileLabel sizeToFit];
    [courtainView addSubview:smileLabel];
    smileLabel.center = courtainView.center;
    //smileLabel.layer.affineTransform = CGAffineTransformMakeRotation(90);
    courtainView.backgroundColor = [UIColor whiteColor];
    courtainView.alpha = 0.0;
    [self.view addSubview:courtainView];
    [self.view bringSubviewToFront:courtainView];
    
    return courtainView;
}

@end
