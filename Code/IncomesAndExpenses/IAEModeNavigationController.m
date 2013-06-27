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
    NSAssert(_mainStoryBoard, @"No hay story board vinculado");
    
    UIViewController *retViewController = nil;
    if ([IAEOrientationHelper isActualOrientationPortraitOrientation]) {
        retViewController = [_mainStoryBoard instantiateViewControllerWithIdentifier:@"ReportModeViewController"];
    } else if ([IAEOrientationHelper isActualOrientationLandscapeOrientation]) {
        retViewController = [_mainStoryBoard instantiateViewControllerWithIdentifier:@"EditModeViewController"];
    }
    
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
    UIViewController *destinationViewController = [self createOfFindModeViewControllerForInterfaceOrientation:destinationInterfaceOrientation];
    if ([self.visibleViewController class] != [destinationViewController class]) {
        if (self.viewControllers.count == 1) {
            [self pushViewController:destinationViewController animated:YES];
        } else {
            NSAssert(self.viewControllers.count == 2, @"Deberia de haber dos controles colocados");
            [self popViewControllerAnimated:YES];
        }
    }
    
}

// ToDo: Refactorizar este metodo y particionarlo
// Buscamos el ser capaces de realizar la transición entre view controllers correctamente como punto de partida de todo

- (UIViewController *)createOfFindModeViewControllerForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIViewController *retViewController = nil;
    
    Class classOfTheDestinationModeViewController = [self classForModeViewControllerForOrientation:interfaceOrientation];
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController class] == classOfTheDestinationModeViewController) {
            retViewController = viewController;
            break;
        }
    }
    
    if (nil == retViewController) {
        
    }
    
    return retViewController;
    
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
