//
//  IAEHelpCarouselViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/06/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpCarouselViewController.h"



@interface IAEHelpCarouselViewController ()

@property (weak, nonatomic) IBOutlet UIPageControl *pageController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *helpScreens;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation IAEHelpCarouselViewController

#pragma mark - Properties

- (NSArray *)helpScreens
{
    if (!_helpScreens) {
        _helpScreens = @[@"HelpScreen_01.jpg", @"HelpScreen_01.jpg", @"HelpScreen_01.jpg"];
    }
    
    return _helpScreens;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [self prepareScrollView];
    [self configurePageController];
    [self prepareAdjustButton];
}

- (void)prepareScrollView
{
    [self configureScrollView];
    [self addImagesToScrollView];
}

- (void)configureScrollView
{
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * self.helpScreens.count, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.bounces = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
}

- (void)addImagesToScrollView
{
    for (NSUInteger helpScreenIndexIt = 0; helpScreenIndexIt < self.helpScreens.count; ++helpScreenIndexIt) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.helpScreens[helpScreenIndexIt]]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.center = CGPointMake(CGRectGetMidX(self.scrollView.frame) + CGRectGetWidth(self.scrollView.frame) * helpScreenIndexIt, CGRectGetMidY(self.scrollView.frame));
        [self.scrollView addSubview:imageView];
    }
}

- (void)prepareAdjustButton
{
    [self localizeDoneButton];
    [self adjustDoneButtonPosition];
}

- (void)localizeDoneButton
{
    [self.doneButton setTitle:NSLocalizedString(@"LTEXT_HELPCAROUSEL_EXIT", @"") forState:UIControlStateNormal];
}

- (void)adjustDoneButtonPosition
{
    if (self.scrollView.subviews.count > 0) {
        UIImageView *referenceImage = self.scrollView.subviews[0];
        const NSUInteger border = (CGRectGetWidth(self.scrollView.frame) - CGRectGetWidth(referenceImage.frame)) / 2;
        self.doneButton.frame = CGRectMake(self.doneButton.frame.origin.x - border, self.doneButton.frame.origin.y, self.doneButton.frame.size.width, self.doneButton.frame.size.height);
    }
}

- (void)configurePageController
{
    self.pageController.numberOfPages = self.helpScreens.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updatePageControl];
}

- (void)updatePageControl
{
    self.pageController.currentPage = self.scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
}

#pragma mark - Events


- (IBAction)doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
