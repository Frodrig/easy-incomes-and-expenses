//
//  IAECategoryTableViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 05/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECategoryTableViewCell.h"
#import "UIView+RoundedCorners.h"
#import "IAECircleDecoratorView.h"

@interface IAECategoryTableViewCell()

@property (weak, nonatomic) UIView *backgroundContainerView;

@end

@implementation IAECategoryTableViewCell

#pragma mark - Const

static NSString * const kUserDefaultsQuestionButtonForGeneralCategory = @"questionButtonForGeneralCategory";

static const NSUInteger kTagOfBackgroundContainerView = 10;
static const NSUInteger kTagOfCategoryLabel = 20;
static const NSUInteger kTagOfContainerForStrokeCategoryLabelView = 25;
static const NSUInteger kTagOfOpenDecoratorView = 30;
static const NSUInteger kTagOfNumberOfConceptsLabel = 40;
static const NSUInteger kTagOfQuestionButton = 100;

static const CGFloat kDurationOfStrokeStateAnimation = 0.25;
static const CGFloat kAlphaInStrokeState = 0.25;

#pragma mark - Properties

- (UIView *)backgroundContainerView
{
    if (!_backgroundContainerView) {
        _backgroundContainerView = [self viewWithTag:kTagOfBackgroundContainerView];
    }
    
    return _backgroundContainerView;
}

- (UILabel *)categoryLabel
{
    if (!_categoryLabel) {
        _categoryLabel = (UILabel *)[self viewWithTag:kTagOfCategoryLabel];
    }
    
    return _categoryLabel;
}

- (UIView *)containerForStrokeCategoryLabelView
{
    if (!_containerForStrokeCategoryLabelView) {
        _containerForStrokeCategoryLabelView = [self viewWithTag:kTagOfContainerForStrokeCategoryLabelView];
    }
    
    return _containerForStrokeCategoryLabelView;
}

- (IAECircleDecoratorView *)openDecoratorView
{
    if (!_openDecoratorView) {
        _openDecoratorView = (IAECircleDecoratorView *)[self viewWithTag:kTagOfOpenDecoratorView];
    }
    
    return _openDecoratorView;
}

- (UILabel *)numberOfConceptsLabel
{
    if (!_numberOfConceptsLabel) {
        _numberOfConceptsLabel = (UILabel *)[self viewWithTag:kTagOfNumberOfConceptsLabel];
    }
    
    return _numberOfConceptsLabel;
}

- (UIButton *)questionButton
{
    if (!_questionButton) {
        _questionButton = (UIButton *)[self viewWithTag:kTagOfQuestionButton];
    }
    
    return _questionButton;
}

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [self.questionButton addTarget:self action:@selector(questionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - StrokeState

- (void)goToStrokeStateWithAnimation:(BOOL)animation
{
    [self changeToStrokeState:YES withAnimation:animation];
}

- (void)exitOfStrokeStateWithAnimation:(BOOL)animation
{
    [self changeToStrokeState:NO withAnimation:animation];
}

- (void)changeToStrokeState:(BOOL)strokeState withAnimation:(BOOL)animation
{
    if (strokeState != self.isInStrokeState) {
        _isInStrokeState = strokeState;
        CGFloat alphaValue = strokeState ? kAlphaInStrokeState : 1.0;
        [UIView animateWithDuration:animation ? kDurationOfStrokeStateAnimation : 0 animations:^{
            self.categoryLabel.alpha = alphaValue;
            self.openDecoratorView.alpha = alphaValue;
            self.numberOfConceptsLabel.alpha = alphaValue;
        }];
    }
}

- (void)questionButtonPressed:(UIButton *)button
{
    [self deactiveQuestionButtonFlagInUserDefaults];
    [self launchAndShowAlertViewForQuestionButton];
}

- (void)deactiveQuestionButtonFlagInUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:kUserDefaultsQuestionButtonForGeneralCategory];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)launchAndShowAlertViewForQuestionButton
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"LTEXT_CATEGORYSELECTOR_ALERTVIEW_QUESTIONBUTTON_TITLE", @"")
                              message:NSLocalizedString(@"LTEXT_CATEGORYSELECTOR_ALERTVIEW_QUESTIONBUTTON_MESSAGE", @"")
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"LTEXT_CATEGORYSELECTOR_ALERTVIEW_QUESTIONBUTTON_OK", @"")
                              otherButtonTitles:nil];

    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.questionButton.hidden = YES;
}

@end
