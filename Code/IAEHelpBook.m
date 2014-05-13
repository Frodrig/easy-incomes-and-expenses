//
//  IAEHelpBook.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpBook.h"
#import "IAEHelpTheme.h"

@interface IAEHelpBook()

@property (nonatomic, strong) NSArray *allVersionThemesText;

@end

@implementation IAEHelpBook

#pragma mark - Clase

+ (instancetype)sharedHelpBook
{
    static IAEHelpBook *helpBook = nil;
    if (!helpBook) {
        helpBook = [[IAEHelpBook alloc] init];
    }
    
    return helpBook;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createThemesData];
        [self createThemesObjects];
    }
    
    return self;
}

- (void)createThemesData
{
    [self createAllVersionThemesData];
}

- (void)createAllVersionThemesData
{
    _allVersionThemesText = @[@"LTEXT_HELPCONTENT_ALLVERSIONS_1",
                              @"LTEXT_HELPCONTENT_ALLVERSIONS_2",
                              @"LTEXT_HELPCONTENT_ALLVERSIONS_3",
                              @"LTEXT_HELPCONTENT_ALLVERSIONS_4",
                              @"LTEXT_HELPCONTENT_ALLVERSIONS_5",
                              @"LTEXT_HELPCONTENT_ALLVERSIONS_6",
                              @"LTEXT_HELPCONTENT_ALLVERSIONS_7",
                              @"LTEXT_HELPCONTENT_ALLVERSIONS_8"];
}

- (void)createThemesObjects
{
    [self createAllVersionThemesObjects];
}

- (void)createAllVersionThemesObjects
{
    NSMutableArray *themesCreated = [[NSMutableArray alloc] init];
    for (NSUInteger allVersionThemeIndex = 0; allVersionThemeIndex < _allVersionThemesText.count; ++allVersionThemeIndex) {
        IAEHelpTheme *theme = [[IAEHelpTheme alloc] initWithThemeIndex:allVersionThemeIndex + 1 andType:HelpThemeAllVersion];
        [themesCreated addObject:theme];
    }

    _allVersionThemes = [NSArray arrayWithArray:themesCreated];
}

#pragma mark - Description

- (void)description
{
    NSLog(@"IAEHelpBook description");
    NSLog(@"Themes total: %lu", (unsigned long)self.allVersionThemes.count);
    NSLog(@"%@", [self.allVersionThemes description]);
}

@end
