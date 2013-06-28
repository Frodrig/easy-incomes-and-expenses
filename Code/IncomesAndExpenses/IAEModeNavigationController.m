//
//  IAEModeNavigationController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEModeNavigationController.h"
#import "IAEOrientationHelper.h"
#import "IAEEditModeViewController.h"
#import "IAEReportModeViewController.h"

@interface IAEModeNavigationController ()

@property(nonatomic, strong) UIStoryboard *mainStoryBoard;

@end

@implementation IAEModeNavigationController

- (instancetype)initWithApropiateRootModeViewController
{
    [self loadMainStoryBoard];
    
    UIViewController *rootController = [self createRootViewController];
    if (rootController) {
        self = [super initWithRootViewController:rootController];
    } else {
        self = nil;
    }
    
    return self;
}

- (void)loadMainStoryBoard
{
    _mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
}

- (UIViewController *)createRootViewController
{
    UIInterfaceOrientation deviceInterfaceOrientation = [IAEOrientationHelper getInterfaceOrientation];
    return [self createAndConfigureModeViewControllerForOrientation:deviceInterfaceOrientation];
}

- (UIViewController *)createAndConfigureModeViewControllerForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSAssert(_mainStoryBoard, @"No hay story board vinculado");

    UIViewController *retViewController = nil;
    if ([IAEOrientationHelper isPortraitOrientationForInterfaceOrientation:interfaceOrientation]) {
        retViewController = [_mainStoryBoard instantiateViewControllerWithIdentifier:@"ReportModeViewController"];
    } else if ([IAEOrientationHelper isLandscapeOrientationForInterfaceOrientation:interfaceOrientation]) {
        retViewController = [_mainStoryBoard instantiateViewControllerWithIdentifier:@"EditModeViewController"];
    }
    
    NSAssert(retViewController, @"Problemas creando el view controller");
    retViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    return retViewController;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    return nil;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass
{
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self performTransitionToViewControllerForInterfaceOrientation:toInterfaceOrientation withDuration:duration];
}

- (void)performTransitionToViewControllerForInterfaceOrientation:(UIInterfaceOrientation)destinationInterfaceOrientation
                                                    withDuration:(NSTimeInterval)duration
{
    UIViewController *destinationViewController = [self modeViewControllerForInterfaceOrientation:destinationInterfaceOrientation];
    if ([self.visibleViewController class] != [destinationViewController class]) {
        
        if (self.viewControllers.count == 1) {
            [self pushViewController:destinationViewController animated:NO];
        } else {
            NSAssert(self.viewControllers.count == 2, @"Deberia de haber dos controles colocados");
            [self popViewControllerAnimated:NO];
        }
    }
}

- (UIViewController *)modeViewControllerForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIViewController *retViewController = [self findModeViewControllerInNavigationControllerStackForOrientation:interfaceOrientation];
    if (nil == retViewController) {
        retViewController = [self createAndConfigureModeViewControllerForOrientation:interfaceOrientation];
    }
    
    return retViewController;
}

- (UIViewController *)findModeViewControllerInNavigationControllerStackForOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    Class classOfTheDestinationModeViewController = [self classForModeViewControllerForOrientation:interfaceOrientation];
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController class] == classOfTheDestinationModeViewController) {
            return viewController;
        }
    }
    
    return nil;
}

- (Class)classForModeViewControllerForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    Class retClass = nil;
    
    if ([IAEOrientationHelper isPortraitOrientationForInterfaceOrientation:interfaceOrientation]) {
        retClass = [IAEReportModeViewController class];
    } else if ([IAEOrientationHelper isLandscapeOrientationForInterfaceOrientation:interfaceOrientation]) {
        retClass = [IAEEditModeViewController class];
    }
    
    return retClass;
}


@end
