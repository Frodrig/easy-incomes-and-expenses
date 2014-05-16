//
//  IAEMainNavigationTitle.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 16/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEMainNavigationTitle.h"
#import "NSUserDefaults+EasyIncAndExp.h"

#pragma mark - Constants

static NSString * const kNotificationMainLabelTitleTouched = @"mainLabelTitleTouched";

#pragma mark - Implementation

@implementation IAEMainNavigationTitle

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(0, @"Se espera que se cargue desde un StoryBoard / XIB");
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureText];
    }
    
    return self;
}

- (void)configureText
{
    self.text = NSLocalizedString([[NSUserDefaults standardUserDefaults] isProVersionEnabled] ?@"LTEXT_MAINNAVIGATION_TITLE_PROVERSION" : @"LTEXT_MAINNAVIGATION_TITLE_NOPROVERSION" , @"");
}


#pragma mark - Interaction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMainLabelTitleTouched object:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
