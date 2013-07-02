//
//  IAECircularStringSelection.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 30/11/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//


#import "IAECircularStringSelection.h"

@implementation IAECircularStringSelection

@synthesize stringSelection = _stringSelection;
@synthesize index = _index;

- (id)init:(NSArray *)selection
{
    self = [super init];
    
    if (self)
    {
        _stringSelection = [selection copy];
        _index = 0;
    }
    
    return self;
}

- (void)advance
{
    ++_index;
    if (_index >= self.stringSelection.count)
        _index = 0;
}

- (void)rewind
{
    if (_index == 0)
        _index = self.stringSelection.count == 0 ? 0 : self.stringSelection.count - 1;
    else
        --_index;
}

- (NSString *)actualSelection
{
    return [self.stringSelection objectAtIndex:self.index];
}

@end
