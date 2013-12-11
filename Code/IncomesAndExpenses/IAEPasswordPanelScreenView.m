//
//  IAEPasswordPanelScreenView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 10/12/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordPanelScreenView.h"

@interface IAEPasswordPanelScreenView()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *labelCodesContainerView;

@end

@implementation IAEPasswordPanelScreenView

#pragma mark - Constants

static NSString * const kCodeSymbol = @"*";
static NSString * const kClearCodeSymbol = @"";

static float kFXInvalidPasswordDuration = 0.25;

#pragma mark - Init

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


- (void)setMessage:(NSString *)message
{
    self.messageLabel.text = message;
}

- (void)addCodeAtPosition:(NSInteger)position
{
    [self vinculeCodeSymbol:kCodeSymbol toLabelCodeAtPosition:position];
}

- (void)clearCodeAtPosition:(NSInteger)position
{
    [self vinculeCodeSymbol:kClearCodeSymbol toLabelCodeAtPosition:position];
}

- (void)clearAllCodes
{
    for (NSUInteger position = 0; position < 4; position++) {
        [self vinculeCodeSymbol:kClearCodeSymbol toLabelCodeAtPosition:position];
    }
}

- (void)vinculeCodeSymbol:(NSString *)codeSymbol toLabelCodeAtPosition:(NSUInteger)position
{
    UILabel *label = [self findLabelCodeAtPosition:position];
    label.text = codeSymbol;
}

- (UILabel *)findLabelCodeAtPosition:(NSInteger)position
{
    const NSUInteger labelTag = position + 1;
    NSAssert(labelTag > 0, @"");
    NSAssert(labelTag < 5, @"");
    
    UILabel *label = (UILabel *)[self.labelCodesContainerView viewWithTag:labelTag];
    return label;
}

- (void)executeFXInvalidPassword
{
    [UIView animateWithDuration:kFXInvalidPasswordDuration animations:^{
        self.backgroundColor = [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:0.2];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kFXInvalidPasswordDuration animations:^{
            self.backgroundColor = [UIColor whiteColor];
        } completion:nil];
    }];
}


@end
