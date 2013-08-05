//
//  IAEHeaderAboutAndOptionsSectionView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHeaderAboutAndOptionsCollectionReusableView.h"

@interface IAEHeaderAboutAndOptionsCollectionReusableView()


@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end

@implementation IAEHeaderAboutAndOptionsCollectionReusableView

static NSString * const familyFontName = @"HelveticaNeue-UltraLight";
static CGFloat fontSize = 41;
static CGFloat fontKern = 2.0;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)configureHeaderLabelWithText:(NSString *)text
{
    self.headerLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:[self createFontAttributes]];
}

- (NSDictionary *)createFontAttributes
{
    NSDictionary *attributes = @{NSFontAttributeName: [self createFont],
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSKernAttributeName: [NSNumber numberWithInteger: fontKern]};
    
    return attributes;
}

- (UIFont *)createFont
{
    UIFont *font = [UIFont fontWithName:familyFontName size:fontSize];
    return font;
}

@end
