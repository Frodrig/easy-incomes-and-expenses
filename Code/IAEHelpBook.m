//
//  IAEHelpBook.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpBook.h"
#import "IAEHelpTheme.h"

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
        [self createThemes];
    }
    
    return self;
}

- (void)createThemes
{
    NSMutableArray *themesCreated = [[NSMutableArray alloc] init];
    
    NSString *prefixLTextThemes = [NSString stringWithFormat:@"LTEXT_HELPCONTENT_"];
    NSUInteger themeIndex = 1;
    BOOL allThemesCreated = NO;
    while (!allThemesCreated) {
        NSString *unlocLTextTheme = [NSString stringWithFormat:@"%@%lu", prefixLTextThemes, (unsigned long)themeIndex];
        NSString *locLTextTheme = [[NSBundle mainBundle] localizedStringForKey:unlocLTextTheme value:@"" table:nil];
        allThemesCreated = [locLTextTheme compare:unlocLTextTheme] == NSOrderedSame;
        if (!allThemesCreated) {
            IAEHelpTheme *theme = [[IAEHelpTheme alloc] initWithThemeIndex:themeIndex];
            [themesCreated addObject:theme];
        }
        
        themeIndex++;
    }
    
    _themes = [NSArray arrayWithArray:themesCreated];
}

#pragma mark - Description

- (void)description
{
    NSLog(@"IAEHelpBook description");
    NSLog(@"Themes total: %lu", (unsigned long)self.themes.count);
    NSLog(@"%@", [self.themes description]);
}

@end
