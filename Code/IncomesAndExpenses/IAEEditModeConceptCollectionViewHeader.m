//
//  IAEEditModeConceptCollectionViewHeader.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEditModeConceptCollectionViewHeader.h"

@interface IAEEditModeConceptCollectionViewHeader()

@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation IAEEditModeConceptCollectionViewHeader

#pragma mark - Constants

static const NSUInteger kTagOfMonthLabel = 10;
static NSString * const kfamilyFontName = @"HelveticaNeue-Ultralight";
static const NSUInteger kfontSize = 34;
static const NSUInteger kfontKern = 5;

#pragma mark - Properties

- (void)setTitle:(NSString *)title
{
    if ([title  compare:_title] != NSOrderedSame) {
        _title = [title copy];
        [self reloadTitle];
    }
}

#pragma mark - Init

- (void)awakeFromNib
{
    _titleLabel = (UILabel *)[self viewWithTag:kTagOfMonthLabel];
}

#pragma mark - Reload

- (void)reloadTitle
{
    _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.title attributes:[self createAttributesForTitleAttributeText]];
}

- (NSDictionary *)createAttributesForTitleAttributeText
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:kfamilyFontName size:kfontSize],
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSKernAttributeName: @(kfontKern)};
    
    return attributes;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
