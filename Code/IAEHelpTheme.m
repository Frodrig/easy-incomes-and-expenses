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

- (instancetype)initWithThemeIndex:(NSUInteger)themeIndex
{
    self = [super init];
    if (self) {
        _themeIndex = themeIndex;
        [self readTitleData];
        [self createHelpPages];
    }
    
    return self;
}

- (void)readTitleData
{
    NSString *unlocalizedLText = [NSString stringWithFormat:@"LTEXT_HELPCONTENT_%d", _themeIndex];
    _title = NSLocalizedString(unlocalizedLText, @"");
}

- (void)createHelpPages
{
    NSMutableArray *helpPagesCreated = [[NSMutableArray alloc] init];
    
    NSString *prefixThemeLTextPage = [NSString stringWithFormat:@"LTEXT_HELPCONTENT_%d_", _themeIndex];
    NSUInteger helpPageIndex = 1;
    BOOL endReadHelpPages = NO;
    while (!endReadHelpPages) {
        NSString *unlocLTextOfFirstTextOfFirstPageOfTheme = [NSString stringWithFormat:@"%@%d_1", prefixThemeLTextPage, helpPageIndex];
        NSString *locLTextOfFirstTextOfFirstPageOfTheme = [[NSBundle mainBundle] localizedStringForKey:unlocLTextOfFirstTextOfFirstPageOfTheme
                                                                                                 value:@""
                                                                                                 table:nil];
        endReadHelpPages = [locLTextOfFirstTextOfFirstPageOfTheme compare:unlocLTextOfFirstTextOfFirstPageOfTheme] == NSOrderedSame;
        if (!endReadHelpPages) {
            IAEHelpPage *helpPage = [[IAEHelpPage alloc] initWithThemeIndex:_themeIndex andPageIndex:helpPageIndex];
            [helpPagesCreated addObject:helpPage];
        }
        
        helpPageIndex++;
    }
    
    _helpPages = [NSArray arrayWithArray:helpPagesCreated];
}

- (void)description
{
    NSLog(@"Theme index: %d", self.themeIndex);
    NSLog(@"Theme title: %@", self.title);
    NSLog(@"Theme pages: %d", self.helpPages.count);
    NSLog(@"%@", [self.helpPages description]);
}

@end
