//
//  IAETextRawSelectorMenuView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 26/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAETextRawSelectorMenuView.h"
#import "IAETextRawSelectorMenuViewDataSource.h"
#import "IAETextRawSelectorMenuViewDelegate.h"
#import "UIView+RoundedCorners.h"


@interface IAETextRawSelectorMenuView()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *selectorLineView;

@end

@implementation IAETextRawSelectorMenuView

#pragma mark - Constants

static const NSUInteger kTagBaseValue = 100;

static const CGFloat kHeightOfTheLineSelector = 2;
static const CGFloat kYMarginOfTheLineSelector = 3;

static const CGFloat kDurationOfContainerViewEnableDisableEffect = 0.5;
static const CGFloat kAlphaValueOfContainerViewInDisabledMode = 0.25;

static const CGFloat kDurationOfAnimationOption = 0.5;
static const CGFloat kDurationOfAnimationOptionDestroyWithGosth = 0.75;
static const CGFloat kDistanceOfAnimationOptionDestroyWithGosth = 25;
static const CGFloat kMinimumAlphaOfAnimationOptionDestroyWithGosth = 0.1;

#pragma mark - properties

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        _containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_containerView];
    }
    
    return _containerView;
}

- (UIView *)selectorLineView
{
    if (!_selectorLineView) {
        CGSize sizeOfOptions = [self.dataSource sizeOfOptionsInTextRawSelectorMenu:self];
        _selectorLineView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                     self.bounds.size.height - kHeightOfTheLineSelector - kYMarginOfTheLineSelector,
                                                                     sizeOfOptions.width, kHeightOfTheLineSelector)];
    }
    
    return _selectorLineView;
}

- (void)setDataSource:(id<IAETextRawSelectorMenuViewDataSource>)dataSource
{
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setCurrentOptionIndexSelected:(NSUInteger)optionIndexSelected
{
    // Nota: No generaremos llamada a delegado desde aqui. Solo se generara por evento en controles
    if (self.dataSource && optionIndexSelected != _currentOptionIndexSelected) {
        [self changeIndicatorFromOptionIndex:_currentOptionIndexSelected toNewCurrentOptionIndex:optionIndexSelected];
        _currentOptionIndexSelected = optionIndexSelected;
        if ([self.dataSource selectorTypeInTextRawSelectorMenu:self] == TEXTRAWMENUVIEW_SELECTOR_BOTTOMLINE) {
            UIButton *option = [self findMenuOptionWithIndex:optionIndexSelected];
            self.selectorLineView.center = CGPointMake(option.center.x, self.selectorLineView.center.y);
        }
    }
}

- (void)setOptionsEnabled:(BOOL)optionsEnabled
{
    if (optionsEnabled != _optionsEnabled) {
        [self enableOptions:optionsEnabled];
        [self enableSelectorLine:optionsEnabled];
        [self enableContainerView:optionsEnabled];
        _optionsEnabled = optionsEnabled;
    }
}

- (void)enableOptions:(BOOL)enable
{
    NSSet *options = [self findAllMenuOptions];
    [options enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UIButton *option = (UIButton *)obj;
        option.enabled = enable;
    }];
}

- (void)enableSelectorLine:(BOOL)enable
{
    self.selectorLineView.hidden = !enable;
}

- (void)enableContainerView:(BOOL)enable
{
    [UIView animateWithDuration:kDurationOfContainerViewEnableDisableEffect animations:^{
        self.containerView.alpha = enable ? 1.0 : kAlphaValueOfContainerViewInDisabledMode;
    }];
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        [self setInitialValues];
    }
    
    return self;
}

- (void)setInitialValues
{
    _optionsEnabled = YES;
}

#pragma mark - reloadData

- (void)reloadData
{
    NSAssert(self.dataSource, @"");
    
    [self removeAllMenuOptions];
    [self adjustContainerViewSize];
    [self createAndAddMenuOptions];
    [self adjustFrameUsingMenuOptions];
    [self prepareSelector];
}

- (void)reloadOptionsStringNames
{
    NSAssert(self.dataSource, @"");
    
    NSUInteger numberOfItems = [self.dataSource numberOfOptionsInTextRawSelectorMenu:self];
    for (NSUInteger itemIt = 0; itemIt < numberOfItems; ++itemIt) {
        [self reloadOptionStringNameAtIndex:itemIt];
    }
}

- (void)reloadOptionStringNameAtIndex:(NSUInteger)index
{
    NSString *newTitle = [self.dataSource textRawSelectorMenu:self optionStringNameAtIndex:index];
    NSUInteger tagOfItemIt = [self createTagForButtonAtIndex:index];
    UIButton *option = (UIButton *)[self viewWithTag:tagOfItemIt];
    [option setAttributedTitle:[self createAttributedStringForOptionAtIndex:index withString:newTitle]
                      forState:UIControlStateNormal];

}

- (void)removeAllMenuOptions
{
    NSMutableSet *menuOptions = [[NSMutableSet alloc] initWithSet:[self findAllMenuOptions]];
    while (menuOptions.count > 0) {
        UIButton *optionToRemove = (UIButton *)[menuOptions anyObject];
        [optionToRemove removeFromSuperview];
        [menuOptions removeObject:optionToRemove];
    }
}

- (NSSet *)findAllMenuOptions
{
    NSMutableSet *menuOptions = [[NSMutableSet alloc] initWithCapacity:self.subviews.count];
    for (UIView *viewIt in self.containerView.subviews) {
        if ([viewIt isKindOfClass:[UIButton class]]) {
            [menuOptions addObject:viewIt];
        }
    }
    
    return [NSSet setWithSet:menuOptions];
}

- (void)prepareSelector
{
    self.selectorLineView = nil;
    if ([self.dataSource selectorTypeInTextRawSelectorMenu:self] == TEXTRAWMENUVIEW_SELECTOR_BOTTOMLINE) {
        self.selectorLineView.backgroundColor = [[self.dataSource colorForSelectorIndicatorInTextRawSelectorMenu:self] copy];
        [self.containerView addSubview:self.selectorLineView];
    }
}

- (void)adjustContainerViewSize
{
    CGSize sizeOfOption = [self.dataSource sizeOfOptionsInTextRawSelectorMenu:self];
    NSUInteger numberOfOptions = [self.dataSource numberOfOptionsInTextRawSelectorMenu:self];
    self.containerView.frame = CGRectMake(0, 0, sizeOfOption.width * numberOfOptions, sizeOfOption.height);
}

- (void)createAndAddMenuOptions
{
    NSUInteger numberOfOptions = [self.dataSource numberOfOptionsInTextRawSelectorMenu:self];
    for (int optionIt = 0; optionIt < numberOfOptions; optionIt++) {
        UIButton *button = [self createOptionButtonAtIndex:optionIt];
        [self.containerView addSubview:button];
    }
}

- (UIButton *)createOptionButtonAtIndex:(NSUInteger)optionIt
{
    UIButton *option = [[UIButton alloc] initWithFrame:[self calculeFrameForOptionButtonAtIndex:optionIt]];
    [option setAttributedTitle:[self createAttributedStringForOptionAtIndex:optionIt] forState:UIControlStateNormal];
    option.backgroundColor = [self.backgroundColor copy];
    option.opaque = YES;
    option.tag = [self createTagForButtonAtIndex:optionIt];
    [option addTarget:self action:@selector(optionButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    return option;
}

- (CGRect)calculeFrameForOptionButtonAtIndex:(NSUInteger)optionIt
{
    CGSize sizeOfOption = [self.dataSource sizeOfOptionsInTextRawSelectorMenu:self];
    CGRect frame = CGRectMake(self.frame.origin.x + sizeOfOption.width * optionIt,
                              0,
                              sizeOfOption.width,
                              sizeOfOption.height);
    
    return frame;
}

- (NSAttributedString *)createAttributedStringForOptionAtIndex:(NSUInteger)optionIt
{
    NSString *optionStringName = [self.dataSource textRawSelectorMenu:self optionStringNameAtIndex:optionIt];
    NSAttributedString *attributedString = [self createAttributedStringForOptionAtIndex:optionIt withString:optionStringName];
    
    return attributedString;
}
- (NSAttributedString *)createAttributedStringForOptionAtIndex:(NSUInteger)optionIt withString:(NSString *)string
{
    NSDictionary *optionStringProperties = [self createPropertiesForOptionStringAtIndex:optionIt];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:optionStringProperties];
    
    return attributedString;
}

- (NSDictionary *)createPropertiesForOptionStringAtIndex:(NSUInteger)optionIt
{
    UIFont *font = [UIFont fontWithName:[self.dataSource fontFamilyNameOfOptionsInTextRawSelectorMenu:self]
                                   size:[self.dataSource fontSizeOfOptionsInTextRawSelectorMenu:self]];
    CGFloat kernValue = [self.dataSource textRawSelectorMenu:self kernOfOptionsAtIndex:optionIt];
    NSDictionary *properties = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [self.dataSource colorForOptionsInTextRawSelectorMenu:self],
                                 NSKernAttributeName: [NSNumber numberWithFloat:kernValue]};
    
    return properties;
}

- (NSUInteger)createTagForButtonAtIndex:(NSUInteger)optionIt
{
    return kTagBaseValue + optionIt;
}

- (NSUInteger)optionIndexFromTagOfOptionButton:(UIButton *)button
{
    return button.tag - kTagBaseValue;
}

- (void)adjustFrameUsingMenuOptions
{
    NSSet *menuOptions = [self findAllMenuOptions];
    if (menuOptions.count > 0) {
        CGRect frame = CGRectInfinite;
        for (UIButton *button in menuOptions) {
            if (CGRectEqualToRect(frame, CGRectInfinite)) {
                frame = button.frame;
            } else {
                frame = CGRectMake(MIN(frame.origin.x, button.frame.origin.x),
                                   frame.origin.y,
                                   frame.size.width + button.frame.size.width,
                                   frame.size.height);
            }
        }
        
        self.frame = frame;
    }
}

- (void)changeIndicatorFromOptionIndex:(NSUInteger)currentOptionIndex toNewCurrentOptionIndex:(NSUInteger)newCurrentOptionIndex
{
    [self deactiveSelectionOnOptionIndex:currentOptionIndex];
    [self activeSelectionOnOptionIndex:newCurrentOptionIndex];
}

- (void)deactiveSelectionOnOptionIndex:(NSUInteger)optionIndex
{
    IAETextRawSelectorMenuViewSelectorType selectorType = [self.dataSource selectorTypeInTextRawSelectorMenu:self];
    UIButton *option = [self findMenuOptionWithIndex:optionIndex];
    if (selectorType == TEXTRAWMENUVIEW_SELECTOR_BACKGROUNDCOLOR) {
        option.backgroundColor = [self.superview.backgroundColor copy];
        [option addRoundedCorners:0 withRadius:0];
    } else {
        self.selectorLineView.hidden = YES;
    }
}

- (void)activeSelectionOnOptionIndex:(NSUInteger)optionIndex
{
    IAETextRawSelectorMenuViewSelectorType selectorType = [self.dataSource selectorTypeInTextRawSelectorMenu:self];
    UIButton *option = [self findMenuOptionWithIndex:optionIndex];
    if (selectorType == TEXTRAWMENUVIEW_SELECTOR_BACKGROUNDCOLOR) {
        option.backgroundColor = [[self.dataSource colorForSelectorIndicatorInTextRawSelectorMenu:self] copy];
        [option addRoundedCorners:[self.dataSource borderMaskForOptionsInTextRawSelectorMenu:self]
         withRadius:[self.dataSource radiusForOptionsInTextRawSelectorMenu:self]];
    } else {
        self.selectorLineView.hidden = NO;
    }
}

- (UIButton *)findMenuOptionWithIndex:(NSUInteger)optionIndex
{
    UIButton *menuOption = nil;
    
    NSSet *options = [self findAllMenuOptions];
    for (UIButton *buttonIt in options) {
        NSUInteger indexOfButtonIt = [self optionIndexFromTagOfOptionButton:buttonIt];
        if (indexOfButtonIt == optionIndex) {
            menuOption = buttonIt;
            break;
        }
    }
    
    return menuOption;
}

- (CGRect)rectOfOptionAtIndex:(NSUInteger)index
{
    CGRect retRectOfOption = CGRectZero;
    UIButton *option = [self findMenuOptionWithIndex:index];
    if (option) {
        retRectOfOption = option.frame;
    }
    
    return retRectOfOption;
}


#pragma mark - UIControlEvents

- (void)optionButtonPressed:(UIButton *)sender
{
    NSUInteger index = [self optionIndexFromTagOfOptionButton:sender];
    [self changeToOptionIndex:index andSendToDelegate:YES];
}

- (void)changeToOptionIndex:(NSUInteger)index
{
    [self changeToOptionIndex:index andSendToDelegate:NO];
}

- (void)changeToOptionIndex:(NSUInteger)index andSendToDelegate:(BOOL)sendToDelegate
{
    const NSUInteger numberOfOptions = [self.dataSource numberOfOptionsInTextRawSelectorMenu:self];
    if (index < numberOfOptions) {
        if (index != self.currentOptionIndexSelected) {
            BOOL permissionToSelectOptionIndex = YES;
            if (sendToDelegate) {
                permissionToSelectOptionIndex = [self.delegate canSelectOptionIndex:index inTextRawSelectorMenuView:self];
            }
            if (permissionToSelectOptionIndex) {
                self.currentOptionIndexSelected = index;
                if (sendToDelegate) {
                    [self.delegate optionIndex:index wasSelectedInTextRawSelectorMenuView:self];
                }
            }
        } else {
            if (sendToDelegate) {
                [self.delegate optionIndex:index wasReSelectedInTextRawSelectorMenuView:self];
            }
        }
    }
}

#pragma mark - Animation 

- (void)animateOptionAtIndex:(NSUInteger)index withAnimationType:(TextRawSelectorAnimationType)animationType
{
    UIButton *option = [self findMenuOptionWithIndex:index];
    if (animationType == TextRawSelectorAnimation_Blink) {
        [self animateWithBlinkTheOption:option];
    } else if (animationType == TextRawSelectorAnimation_Rotation) {
        [self animationWithRotationTheOption:option];
    } else if (animationType == TextRawSelectorAnimation_DestroyWithGosthAndReload) {
        [self animationWithDestroyWithGosthTheOption:option atIndex:index];
    }
}

- (void)animateWithBlinkTheOption:(UIButton *)option
{
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:kDurationOfAnimationOption animations:^{
        option.alpha = 0.1;
    } completion:^(BOOL finished) {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:kDurationOfAnimationOption animations:^{
            option.alpha = 1.0;
        }];
    }];
}

- (void)animationWithRotationTheOption:(UIButton *)option
{
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:kDurationOfAnimationOption animations:^{
        option.transform = CGAffineTransformRotate(option.transform, -M_PI/12);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kDurationOfAnimationOption animations:^{
            option.transform = CGAffineTransformRotate(option.transform, M_PI/6);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kDurationOfAnimationOption animations:^{
                option.transform = CGAffineTransformRotate(option.transform, -M_PI/12);
            }];
        }];
    }];
}

- (void)animationWithDestroyWithGosthTheOption:(UIButton *)option atIndex:(NSUInteger)index
{
    UIButton *cloneOption = [self cloneOptionButton:option];
    [self.containerView addSubview:cloneOption];

    [UIView setAnimationBeginsFromCurrentState:TRUE];
    [UIView animateWithDuration:kDurationOfAnimationOptionDestroyWithGosth animations:^{
        cloneOption.center = CGPointMake(cloneOption.center.x, cloneOption.center.y + kDistanceOfAnimationOptionDestroyWithGosth);
        cloneOption.alpha = kMinimumAlphaOfAnimationOptionDestroyWithGosth;
    } completion:^(BOOL finished) {
        [cloneOption removeFromSuperview];
    }];
}

- (UIButton *)cloneOptionButton:(UIButton *)option
{
    UIButton *cloneOption = [UIButton buttonWithType:option.buttonType];
    cloneOption.frame = option.frame;
    [cloneOption setAttributedTitle:[option attributedTitleForState:UIControlStateNormal] forState:UIControlStateNormal];
    cloneOption.backgroundColor = [UIColor clearColor];
    
    return cloneOption;

}


@end
