//
//  IAEAppDelegate.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 23/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "IAEAppDelegate.h"
#import "IAEBook.h"
#import "IAEYear.h"
#import "IAEMonth.h"
#import "IAECategoryStore.h"
#import "IAERootLauchingViewController.h"

@implementation IAEAppDelegate

#pragma mark - Constants 

static NSString * const kUserDefaultsDayModeActiveKey = @"dayModeActive";
static NSString * const kUserDefaultsReportAmountMode = @"reportAmountMode";
static NSString * const kUserDefaultsReportAmountModeTotalAmountValue = @"totalAmounts";

#pragma mark - didFinishLaunching

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self prepareCrashlytics];
    [self processProcessInfoEnvironment];
    [self createYearBookIfProceed];
    [self prepareDefaults];
    [self createWindowRootLaunchingViewControllerAndMakeVisible];
    
    return YES;
}
    
- (void)prepareCrashlytics
{
    [Crashlytics startWithAPIKey:@"ed113bdf0c248b243b565ef1fdac0f966317a7b8"];

    [Crashlytics setObjectValue:NSLocalizedString(@"LTEXT_VERSION", @"") forKey:@"Version Number"];
    [Crashlytics setObjectValue:NSLocalizedString(@"LTEXT_CATEGORY_VERSION", @"") forKey:@"Version Type"];
    [Crashlytics setObjectValue:NSLocalizedString(@"LTEXT_LANGUAGE", @"") forKey:@"Language"];
}

- (void)processProcessInfoEnvironment
{
    NSNumber *testEnviromentVariable = [[NSProcessInfo processInfo].environment valueForKey:@"createTestDataAtLaunch"];
    if ([testEnviromentVariable boolValue]) {
        [[IAEBook sharedBook] deleteAllAndSave];
        [self createYearTest2];
    }
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

- (void)prepareDefaults
{
    // Defaults del registration  domain
    NSDictionary *defaults = @{ kUserDefaultsDayModeActiveKey: [NSNumber numberWithBool:NO],
                                kUserDefaultsReportAmountMode: kUserDefaultsReportAmountModeTotalAmountValue };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)createWindowRootLaunchingViewControllerAndMakeVisible
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[IAERootLauchingViewController alloc] init];
    [self.window makeKeyAndVisible];
}

#pragma mark - Notifications

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    //[self saveContext];
    [[IAEBook sharedBook] saveAll];
}

#pragma mark - Test

- (void)createYearTest
{
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2013]];
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2010]];
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2007]];
    [[IAEBook sharedBook] loadAll];
    
    for (IAEYear *yearIt in [IAEBook sharedBook].years) {
        for (IAEMonth *monthIt in yearIt.months) {
            for (int i = 0; i < 50; ++i) {
                [monthIt addConceptWithAmount:[NSDecimalNumber decimalNumberWithString:@"1000"] category:[[IAECategoryStore sharedCategoryStore] generalExpenseCategory] date:[NSDate timeIntervalSinceReferenceDate] dayOfTheMonth:arc4random_uniform(10) andDescription:@"Test concept"];
            }
            for (int i = 0; i < 50; ++i) {
                [monthIt addConceptWithAmount:[NSDecimalNumber decimalNumberWithString:@"100"] category:[[IAECategoryStore sharedCategoryStore] generalIncomeCategory] date:[NSDate timeIntervalSinceReferenceDate] andDescription:@"Test concept"];
            }
        }
    }
    
    [[IAEBook sharedBook] saveAll];
    [[IAEBook sharedBook] unloadAll];
}

- (void)createYearTest2
{
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2013]];
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2010]];
    [[IAEBook sharedBook] createYear:[NSNumber numberWithInteger:2007]];
    [[IAEBook sharedBook] loadAll];
    
    for (IAEYear *yearIt in [IAEBook sharedBook].years) {
        for (IAEMonth *monthIt in yearIt.months) {
            for (int i = 1; i < 100; ++i) {
                [monthIt addConceptWithAmount:[NSDecimalNumber decimalNumberWithString:@"100"] category:[[IAECategoryStore sharedCategoryStore] generalExpenseCategory] date:[NSDate timeIntervalSinceReferenceDate] dayOfTheMonth:i andDescription:@"Test concept"];
            }
        }
    }
    
    [[IAEBook sharedBook] saveAll];
    [[IAEBook sharedBook] unloadAll];
}

@end
