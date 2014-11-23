//
//  IAEBookTests.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 17/03/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SenTestingKit/SenTestingKit.h>
#import <CoreData/CoreData.h>
//#import <OCMock/OCMock.h>
#import "IAEBook.h"
#import "IAEYear.h"
#import "IAEMonth.h"
#import "IAECategory.h"
#import "IAECategoryStore.h"

@interface IAEBookTests : XCTestCase {
    // Core Data stack objects.
    NSManagedObjectModel *model;
    NSPersistentStoreCoordinator *coordinator;
    NSPersistentStore *store;
    NSManagedObjectContext *context;
    // Object to test.
    IAEBook *sut;
}

@end


@implementation IAEBookTests

#pragma mark - Set up and tear down

- (void) setUp {
    [super setUp];

    //[self createCoreDataStack];
    //[self createSut];
    
}


- (void) createCoreDataStack {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    model = [NSManagedObjectModel mergedModelFromBundles:@[bundle]];
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    store = [coordinator addPersistentStoreWithType: NSInMemoryStoreType
                                      configuration: nil
                                                URL: nil
                                            options: nil
                                              error: NULL];
    context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = coordinator;
}


- (void) createSut {
    //sut = [[IAEBook alloc] initWithManagedObjectModel:model andManagedObjectContext:context];
}


- (void) createYearsWithConcepts
{
    return;
    /*
    for (NSNumber *yearIt in @[@2014, @2013, @2010, @2001]) {
        IAEYear *yearObj = [sut createYear:yearIt];
        for (IAEMonth *monthObjectIt in yearObj.months) {
            for (int conceptToCreate = 0; conceptToCreate < 1000; conceptToCreate++) {
                IAECategory *category = arc4random() % 2 == 0 ? [IAECategoryStore sharedCategoryStore].generalIncomeCategory : [IAECategoryStore sharedCategoryStore].generalIncomeCategory;
                [monthObjectIt addConceptWithAmount:[NSDecimalNumber decimalNumberWithString:@""]
                                           category:category
                                               date:[NSDate timeIntervalSinceReferenceDate]
                                     andDescription:@"Test Concept"];
            }
        }
        
        [sut saveAll];
        [sut unloadAll];
    }
     */
}

- (void) tearDown {
    //[self releaseSut];
    //[self releaseCoreDataStack];

    [super tearDown];
}


- (void) releaseSut {
    sut = nil;
}


- (void) releaseCoreDataStack {
    context = nil;
    store = nil;
    coordinator = nil;
    model = nil;
}


#pragma mark - Basic test

- (void) testObjectIsNotNil {
    // Prepare

    // Operate

    // Check
    //XCTAssertNotNil(sut, @"The object to test must be created in setUp.");
}

@end
