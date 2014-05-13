//
//  IAEHelpPage.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpPage.h"

@interface IAEHelpPage()

@property (nonatomic, readonly) NSString *ltextPrefix;

@end

@implementation IAEHelpPage

- (instancetype)initWithThemeIndex:(NSUInteger)themeIndex pageIndex:(NSUInteger)pageIndex andLTextPrefix:(NSString *)ltextPrefix;
{
    self = [super init];
    if (self) {
        _themeIndex = themeIndex;
        _pageIndex = pageIndex;
        _ltextPrefix = ltextPrefix;
        
        [self readTextData];
    }
    
    return self;
}

- (void)readTextData
{
    NSMutableArray *dataRead = [[NSMutableArray alloc] init];
    
    NSString *ltextPrefix = [NSString stringWithFormat:@"%@%lu_%lu_", _ltextPrefix, (unsigned long)_themeIndex, (unsigned long)_pageIndex];
    NSUInteger textIndex = 1;
    BOOL endReadTextData = NO;
    while (!endReadTextData) {
        NSString *nextTextDataUnlocalizedLabel = [NSString stringWithFormat:@"%@%lu", ltextPrefix, (unsigned long)textIndex];
        NSString *nextTextDataLocalizedLabel = [[NSBundle mainBundle] localizedStringForKey:nextTextDataUnlocalizedLabel value:@"" table:nil];
        endReadTextData = [nextTextDataLocalizedLabel compare:nextTextDataUnlocalizedLabel] == NSOrderedSame;
        if (!endReadTextData) {
            [dataRead addObject:nextTextDataLocalizedLabel];
        }
        
        textIndex++;
    }
    
    _texts = [NSArray arrayWithArray:dataRead];
}

#pragma mark - Description

- (void)description
{
    NSLog(@"HelpPage index: %lu - theme index: %lu", (unsigned long)self.pageIndex, (unsigned long)self.themeIndex);
    NSLog(@"Content %@", [self.texts description]);
}

@end
