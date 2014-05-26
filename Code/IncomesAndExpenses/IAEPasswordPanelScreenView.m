//
//  IAEPasswordPanelScreenView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 10/12/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordPanelScreenView.h"
#import "IAEPasswordCheckView.h"

@interface IAEPasswordPanelScreenView()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *passwordCheckContainerView;

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
    IAEPasswordCheckView *passwordCheckView = [self findPasswordCheckViewAtPosition:position];
    [passwordCheckView showCheckWithAnimation:YES];
}

- (void)clearCodeAtPosition:(NSInteger)position
{
    [self clearCodeAtPosition:position withAnimation:YES];
}

- (void)clearCodeAtPosition:(NSInteger)position withAnimation:(BOOL)animation
{
    IAEPasswordCheckView *passwordCheckView = [self findPasswordCheckViewAtPosition:position];
    [passwordCheckView hideCheckWithAnimation:animation];
}

- (void)clearAllCodes
{
    for (NSUInteger position = 0; position < 4; position++) {
        [self clearCodeAtPosition:position withAnimation:NO];
    }
}

- (IAEPasswordCheckView *)findPasswordCheckViewAtPosition:(NSInteger)position
{
    const NSUInteger labelTag = position + 1;
    NSAssert(labelTag > 0, @"");
    NSAssert(labelTag < 5, @"");
    
    IAEPasswordCheckView *passwordCheckView = (IAEPasswordCheckView *)[self.passwordCheckContainerView viewWithTag:labelTag];
    return passwordCheckView;
}

- (void)executeFXInvalidPassword
{
    [UIView animateWithDuration:kFXInvalidPasswordDuration animations:^{
        self.backgroundColor = [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:0.2];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kFXInvalidPasswordDuration animations:^{
            self.backgroundColor = [UIColor clearColor];
        } completion:nil];
    }];
}


@end
