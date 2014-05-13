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
@property (nonatomic, strong) NSArray *proVersionThemesText;

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
    [self createProVersionThemesData];
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

- (void)createProVersionThemesData
{
    _proVersionThemesText = @[@"LTEXT_HELPCONTENT_PROVERSION_1",
                              @"LTEXT_HELPCONTENT_PROVERSION_2",
                              @"LTEXT_HELPCONTENT_PROVERSION_3",
                              @"LTEXT_HELPCONTENT_PROVERSION_4",
                              @"LTEXT_HELPCONTENT_PROVERSION_5",
                              @"LTEXT_HELPCONTENT_PROVERSION_6",
                              @"LTEXT_HELPCONTENT_PROVERSION_7"];
}

- (void)createThemesObjects
{
    [self createAllVersionThemesObjects];
    [self createProVersionThemesObjects];
}

- (void)createAllVersionThemesObjects
{
    _allVersionThemes = [self createArrayOfThemeObjectsType:HelpThemeAllVersion fromThemesText:_allVersionThemesText];
}

- (void)createProVersionThemesObjects
{
    _proVersionThemes = [self createArrayOfThemeObjectsType:HelpThemeProVersion fromThemesText:_proVersionThemesText];
}

- (NSArray *)createArrayOfThemeObjectsType:(IAEHelpThemeType)themeObjectType fromThemesText:(NSArray *)themesText
{
    NSMutableArray *themesCreated = [[NSMutableArray alloc] init];
    for (NSUInteger themeIndexIt = 0; themeIndexIt < themesText.count; ++themeIndexIt) {
        IAEHelpTheme *theme = [[IAEHelpTheme alloc] initWithThemeIndex:themeIndexIt + 1 andType:themeObjectType];
        [themesCreated addObject:theme];
    }
    
    return [NSArray arrayWithArray:themesCreated];
}

#pragma mark - Description

- (void)description
{
    NSLog(@"IAEHelpBook description");
    NSLog(@"Themes total: %lu", (unsigned long)self.allVersionThemes.count);
    NSLog(@"%@", [self.allVersionThemes description]);
}

@end
