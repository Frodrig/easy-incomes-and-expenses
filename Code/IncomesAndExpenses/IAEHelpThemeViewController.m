//
//  IAEHelpThemeViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpThemeViewController.h"
#import "IAEHelpTheme.h"
#import "IAEHelpPage.h"
#import "IAEHelpPageView.h"
#import "IAEColorHelper.h"

@interface IAEHelpThemeViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControll;
@property (strong, nonatomic) UIColor *pagePairColor;
@property (strong, nonatomic) UIColor *pageOddColor;
@property (strong, nonatomic) NSMutableArray *pageViews;

@end

@implementation IAEHelpThemeViewController

#pragma mark - Properties

- (NSMutableArray *)pageViews
{
    if (!_pageViews) {
        _pageViews = [[NSMutableArray alloc] init];
    }
    
    return _pageViews;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithHelpTheme:nil];
}

- (instancetype)initWithHelpTheme:(IAEHelpTheme *)helpTheme
{
    NSAssert(helpTheme, @"");
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _helpTheme = helpTheme;
        [self preparePageColors];
    }
    
    return self;
}

- (void)preparePageColors
{
    _pagePairColor = [[IAEColorHelper colorForEconomicIncomeValue] copy];
    _pagePairColor = [self convertColorToColorWithPageAlpha:_pagePairColor];
    
    _pageOddColor = [[IAEColorHelper colorForEconomicExpenseValue] copy];
    _pageOddColor = [self convertColorToColorWithPageAlpha:_pageOddColor];
}

- (UIColor *)convertColorToColorWithPageAlpha:(UIColor *)pageColor
{
    CGFloat colors[4];
    [pageColor getRed:&colors[0] green:&colors[1] blue:&colors[2] alpha:&colors[3]];
    UIColor *convertedColor = [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:0.3];
    
    return convertedColor;
}

#pragma mark - ViewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationController];
    [self configurePageControll];
    [self configureScrollView];
}

- (void)configureNavigationController
{
    self.title = _helpTheme.title;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed:)];
}

#pragma mark - Navigation Bar

- (void)doneButtonPressed:(UIBarButtonItem *)button
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)configurePageControll
{
    self.pageControll.numberOfPages = self.helpTheme.helpPages.count;
    self.pageControll.currentPage = 0;
}

- (void)configureScrollView
{
    self.scrollView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self vinculeScrollViewSize];
    [self vinculeScrollViewContent];
    //[self vinculeScrollViewInitialPosition];
}

- (void)vinculeScrollViewSize
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * self.helpTheme.helpPages.count, self.scrollView.bounds.size.height);
}

- (void)vinculeScrollViewContent
{
    for (NSUInteger helpPageIndex = 0; helpPageIndex < self.helpTheme.helpPages.count; ++helpPageIndex) {
        IAEHelpPage *helpPage = [self.helpTheme.helpPages objectAtIndex:helpPageIndex];
        CGRect helpPageViewFrame = CGRectMake(self.scrollView.bounds.size.width * helpPageIndex, 0.0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        IAEHelpPageView *pageView = [[IAEHelpPageView alloc] initWithFrame:helpPageViewFrame andTexts:helpPage.texts];
        //pageView.backgroundColor = [self colorForPageIndex:helpPageIndex];
        [self.scrollView addSubview:pageView];
        [self.pageViews addObject:pageView];
    }
}

- (void)vinculeScrollViewInitialPosition
{
    [self.scrollView scrollRectToVisible:CGRectZero animated:NO];
}

- (UIColor *)colorForPageIndex:(NSUInteger)pageIndex
{
    UIColor *color = pageIndex % 2 == 0 ? self.pagePairColor : self.pageOddColor;
        
    return color;
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger currentPage = scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    self.pageControll.currentPage = currentPage;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    const CGFloat actualPosition = scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    self.pageControll.currentPage = actualPosition;

    const CGFloat positionRight = ceilf(actualPosition);
    const CGFloat positionLeft = floorf(actualPosition);

    if (positionLeft != positionRight && positionRight < self.pageViews.count && positionLeft > -1) {
        IAEHelpPageView *rightPageView = [self.pageViews objectAtIndex:positionRight];
        [rightPageView setTextLabelsWithAlpha:actualPosition - positionLeft];
        IAEHelpPageView *leftPageView = [self.pageViews objectAtIndex:positionLeft];
        [leftPageView setTextLabelsWithAlpha:positionRight - actualPosition];
    }
}

@end
