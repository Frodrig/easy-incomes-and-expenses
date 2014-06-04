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
    NSLog(@"SCROLL VIEW contentSize %@", NSStringFromCGSize(self.scrollView.contentSize));
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
        NSLog(@"ImageView CENTER %@", NSStringFromCGPoint(imageView.center));
        
        [self.scrollView addSubview:imageView];
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
