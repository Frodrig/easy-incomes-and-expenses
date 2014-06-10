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
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UINavigationBar *navigationBar;
@end

@implementation IAEHelpCarouselViewController

#pragma mark - Dealloc

- (void)dealloc
{
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark - Properties

- (NSArray *)helpScreens
{
    if (!_helpScreens) {
        _helpScreens = @[@"HelpScreen_01.jpg", @"HelpScreen_02.jpg", @"HelpScreen_03.jpg", @"HelpScreen_04.jpg", @"HelpScreen_05.jpg", @"HelpScreen_06.jpg"];
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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
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
        imageView.frame = self.scrollView.bounds;
        imageView.center = CGPointMake(CGRectGetMidX(self.scrollView.frame) + CGRectGetWidth(self.scrollView.frame) * helpScreenIndexIt, CGRectGetMidY(self.scrollView.frame));
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

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden
{
    return self.navigationBar == nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
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

- (void)onTapGesture:(UIGestureRecognizer *)gesture
{
    if (!self.navigationBar) {
        [self createAndVinculeNavigationBar];
    } else {
        [self removeNavigationBar];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)createAndVinculeNavigationBar
{
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64.0)];
    [self.navigationBar pushNavigationItem:[self createNavigationBarNavigationItem] animated:NO];
    [self.view addSubview:self.navigationBar];
}

- (UINavigationItem *)createNavigationBarNavigationItem
{
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"LTEXT_HELPCAROUSEL_NAVIGATIONBAR_TITLE", @"")];
    navigationItem.leftBarButtonItem = [self createNavigationBarExitButton];
    
    return navigationItem;
}

- (UIBarButtonItem *)createNavigationBarExitButton
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LTEXT_HELPCAROUSEL_NAVIGATIONBAR_EXITBUTTON", @"") style:UIBarButtonItemStyleDone target:nil action:@selector(doneButtonPressed:)];
    doneButton.tintColor = [UIColor colorWithWhite:0.4 alpha:1.0];

    return doneButton;
}

- (void)removeNavigationBar
{
    [self.navigationBar removeFromSuperview];
    self.navigationBar = nil;
}

- (void)doneButtonPressed:(id)sender
{
    [self dismiss];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate helpCaruoselViewControllerDidDismiss:self];
    }];
}

@end
