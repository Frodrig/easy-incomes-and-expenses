//
//  IAERootLauchingViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 12/09/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAERootLauchingViewController.h"
#import "IAEEasyIncomesAndExpensesViewController.h"

@interface IAERootLauchingViewController ()

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
        [self initNavigationControllerWithRootController];
        [self initLaunchImage];
    }
    return self;
}

- (void)initLaunchImage
{
    _launchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kLaunchImageName]];
    _launchImage.backgroundColor = [UIColor clearColor];
}

- (void)initNavigationControllerWithRootController
{
    UIViewController *rootViewController = [self instantiateFromStoryBoardEasyIncomesViewController];
    _mainViewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    _mainViewController.navigationBar.tintColor = [UIColor colorWithWhite:kGlobalTintColorForWhiteComponent alpha:1.0];
}

- (UIViewController *)instantiateFromStoryBoardEasyIncomesViewController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kMainStoryBoardName bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:kEasyIncomesAndExpensesViewControllerID];
    
    return viewController;
}

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.launchImage];
}

#pragma mark - viewWillAppear

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view insertSubview:self.mainViewController.view aboveSubview:self.launchImage];
}

#pragma mark - viewDidAppear

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.launchImage performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:10];
}

@end
