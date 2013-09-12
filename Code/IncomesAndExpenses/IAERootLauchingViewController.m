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

static NSString * const mainStoryBoardName = @"Main";
static NSString * const easyIncomesAndExpensesViewControllerID = @"EasyIncomesAndExpensesViewControllerID";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _mainViewController = [self makeNavigationControllerWithRootController];
        _launchImage = [self makeLaunchImage];
    }
    return self;
}

- (UIImageView *)makeLaunchImage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipadlandscape_launchimage"]];
    imageView.backgroundColor = [UIColor clearColor];
    
    return imageView;
}

- (UINavigationController *)makeNavigationControllerWithRootController
{
    UIViewController *rootViewController = [self instantiateFromStoryBoardEasyIncomesViewController];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    navigationController.navigationBar.tintColor = [UIColor colorWithWhite:kGlobalTintColorForWhiteComponent alpha:1.0];
    
    return navigationController;
}

- (UIViewController *)instantiateFromStoryBoardEasyIncomesViewController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:mainStoryBoardName bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:easyIncomesAndExpensesViewControllerID];
    
    return viewController;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    [self.view addSubview:self.launchImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view insertSubview:self.mainViewController.view aboveSubview:self.launchImage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.launchImage performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:10];
    
    /*
    [UIView animateWithDuration:2 animations:^{
        self.launchImage.alpha = 0;
    } completion:^(BOOL finished) {
        [self.launchImage removeFromSuperview];
    }];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
