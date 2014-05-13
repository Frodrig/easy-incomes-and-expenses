//
//  IAEHelpTheme.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpTheme.h"
#import "IAEHelpPage.h"

@implementation IAEHelpTheme

- (instancetype)initWithThemeIndex:(NSUInteger)themeIndex andType:(IAEHelpThemeType)type;
{
    self = [super init];
    if (self) {
        _themeIndex = themeIndex;
        _type = type;
        [self readTitleData];
        [self createHelpPages];
    }
    
    return self;
}

- (void)readTitleData
{
    NSString *unlocalizedLText = [NSString stringWithFormat:@"%@%lu", [self findStaticPrefixThemeLTextForActualType], (unsigned long)_themeIndex];
    _title = NSLocalizedString(unlocalizedLText, @"");
}

- (void)createHelpPages
{
    NSMutableArray *helpPagesCreated = [[NSMutableArray alloc] init];
    
    NSString *prefixThemeLTextPage = [NSString stringWithFormat:@"%@%lu_", [self findStaticPrefixThemeLTextForActualType], (unsigned long)_themeIndex];
    NSUInteger helpPageIndex = 1;
    BOOL endReadHelpPages = NO;
    while (!endReadHelpPages) {
        NSString *unlocLTextOfFirstTextOfFirstPageOfTheme = [NSString stringWithFormat:@"%@%lu_1", prefixThemeLTextPage, (unsigned long)helpPageIndex];
        NSString *locLTextOfFirstTextOfFirstPageOfTheme = [[NSBundle mainBundle] localizedStringForKey:unlocLTextOfFirstTextOfFirstPageOfTheme
                                                                                                 value:@""
                                                                                                 table:nil];
        endReadHelpPages = [locLTextOfFirstTextOfFirstPageOfTheme compare:unlocLTextOfFirstTextOfFirstPageOfTheme] == NSOrderedSame;
        if (!endReadHelpPages) {
            IAEHelpPage *helpPage = [[IAEHelpPage alloc] initWithThemeIndex:_themeIndex pageIndex:helpPageIndex andLTextPrefix:[self findStaticPrefixThemeLTextForActualType]];
            [helpPagesCreated addObject:helpPage];
        }
        
        helpPageIndex++;
    }
    
    _helpPages = [NSArray arrayWithArray:helpPagesCreated];
}

- (NSString *)findStaticPrefixThemeLTextForActualType
{
    NSString *retPrefix = nil;
    
    if (_type == HelpThemeAllVersion) {
        retPrefix = @"LTEXT_HELPCONTENT_ALLVERSIONS_";
    } else if (_type == HelpThemeProVersion) {
        retPrefix = @"LTEXT_HELPCONTENT_PROVERSION_";
    }
    
    return retPrefix;
}

- (void)description
{
    NSLog(@"Theme index: %lu", (unsigned long)self.themeIndex);
    NSLog(@"Theme title: %@", self.title);
    NSLog(@"Theme pages: %lu", (unsigned long)self.helpPages.count);
    NSLog(@"%@", [self.helpPages description]);
}

@end
