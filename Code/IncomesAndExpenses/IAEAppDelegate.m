//
//  IAEAppDelegate.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 23/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEAppDelegate.h"
#import "IAEIncomeExpenseControllerViewController.h"
#import "IAEBook.h"

#import "IAEYear.h"
#import "IAEMonth.h"
#import "IAECategoryStore.h"

#import "IAEModeNavigationController.h"

@implementation IAEAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[self createYearTest];
    [self createYearBookIfProceed];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[IAEModeNavigationController alloc] initWithApropiateRootModeViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)createYearBookIfProceed
{
    // Si no hay ningun año registrado, se crea
    [[IAEBook sharedBook] loadMoreRecientYear];
    if (0 == [IAEBook sharedBook].years.count) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *yearComponent = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
        [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:yearComponent.year]];
    }
}

- (void)createYearTest
{
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2013]];
   /* [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2012]];
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2011]];
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2010]];
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2009]];
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2008]];
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2007]];*/
    [[IAEBook sharedBook] loadAll];
    
    for (IAEYear *yearIt in [IAEBook sharedBook].years) {
        for (IAEMonth *monthIt in yearIt.months) {
            for (int i = 0; i < 100; ++i) {
                [monthIt addConceptWithAmount:[NSDecimalNumber decimalNumberWithString:@"1000"] category:[[IAECategoryStore sharedCategoryStore] generalIncomeCategory] date:[NSDate timeIntervalSinceReferenceDate] andDescription:@"Test concept"];
            }
            for (int i = 0; i < 100; ++i) {
                [monthIt addConceptWithAmount:[NSDecimalNumber decimalNumberWithString:@"1000"] category:[[IAECategoryStore sharedCategoryStore] generalExpenseCategory] date:[NSDate timeIntervalSinceReferenceDate] andDescription:@"Test concept"];
            }
        }
    }
    
    [[IAEBook sharedBook] saveAll];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[IAEBook sharedBook] saveAll];

    IAEIncomeExpenseControllerViewController *rootController = (IAEIncomeExpenseControllerViewController *) self.window.rootViewController;
    [[NSUserDefaults standardUserDefaults] setInteger:[rootController actualDateStateYear] != nil ? [rootController actualDateStateYear].yearDate : -1 forKey:@"yearBeforeEnterBackground"];
    [[NSUserDefaults standardUserDefaults] setInteger:[rootController actualDateStateMonth] != nil ? [rootController actualDateStateMonth].month - 1: -1 forKey:@"monthBeforeEnterBackground"];
    [[NSUserDefaults standardUserDefaults] setBool:[rootController inputModeActive] forKey:@"inputModeBeforeEnterBackground"];

    [[IAEBook sharedBook] unloadAll];
    [rootController unloadConceptControllersGoingToBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Carga todo pero sin recargar, es decir, si ya estaba cargado no hace nada
    NSInteger yearToRestore = [[NSUserDefaults standardUserDefaults] integerForKey:@"yearBeforeEnterBackground"];
    if (yearToRestore != -1) {
        [[IAEBook sharedBook] loadYear:yearToRestore];
        IAEIncomeExpenseControllerViewController *rootController = (IAEIncomeExpenseControllerViewController *) self.window.rootViewController;
        [rootController loadConceptControllersToRestoreFromBackgroundWithActualLoadedYearAndMonth:[[NSUserDefaults standardUserDefaults] integerForKey:@"monthBeforeEnterBackground"]];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[IAEBook sharedBook] saveAll];
}


@end
