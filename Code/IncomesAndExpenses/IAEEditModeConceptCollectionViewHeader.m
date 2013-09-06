//
//  IAEEditModeConceptCollectionViewHeader.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEditModeConceptCollectionViewHeader.h"
#import "IAENibUtils.h"

@interface IAEEditModeConceptCollectionViewHeader()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *infoLabel;

@end

@implementation IAEEditModeConceptCollectionViewHeader

#pragma mark - Constants

static const NSUInteger kTagOfMonthTitleLabel = 10;
static NSString * const kFamilyFontNameForTitle = @"HelveticaNeue-Ultralight";
static const NSUInteger kFontSizeForTitle = 34;
static const NSUInteger kFontKernForTitle = 10;

static const NSUInteger kTagOfMonthInfoLabel = 20;
static NSString * const kFamilyFontNameForInfo = @"HelveticaNeue-Ultralightitalic";
static const NSUInteger kFontSizeForInfo = 21;
static const NSUInteger kFontKernForInfo = 1;

static NSString * const kNibName = @"IAEEditModeConceptCollectionViewHeader";

#pragma mark - Class

+ (CGSize)sizeOfItem
{
    static CGSize sizeOfItem;
    if (CGSizeEqualToSize(sizeOfItem, CGSizeZero)) {
        sizeOfItem = [IAENibUtils findSizeOfTheBaseViewOfNibNamed:kNibName];
    }
    
    return sizeOfItem;
}

#pragma mark - Properties

- (void)setTitle:(NSString *)title
{
    if ([title  compare:_title] != NSOrderedSame) {
        _title = [title copy];
        [self reloadTitle];
    }
}

- (void)setInfo:(NSString *)info
{
    if ([info  compare:_info] != NSOrderedSame) {
        _info = [info copy];
        [self reloadInfo];
    }
}

#pragma mark - Init

- (void)awakeFromNib
{
    _titleLabel = (UILabel *)[self viewWithTag:kTagOfMonthTitleLabel];
    _infoLabel = (UILabel *)[self viewWithTag:kTagOfMonthInfoLabel];
}

#pragma mark - Reload

- (void)reloadTitle
{
    NSDictionary *attributes = [self createTextAttributesWithfamilyfont:kFamilyFontNameForTitle size:kFontSizeForTitle andKern:kFontKernForTitle];
    _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.title attributes:attributes];
}

- (void)reloadInfo
{
    NSDictionary *attributes = [self createTextAttributesWithfamilyfont:kFamilyFontNameForInfo size:kFontSizeForInfo andKern:kFontKernForInfo];
    _infoLabel.attributedText = [[NSAttributedString alloc] initWithString:self.info attributes:attributes];
}

- (NSDictionary *)createTextAttributesWithfamilyfont:(NSString *)familyFont size:(NSUInteger)size andKern:(NSUInteger)kern
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:familyFont size:size],
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSKernAttributeName: @(kern)};
    
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
