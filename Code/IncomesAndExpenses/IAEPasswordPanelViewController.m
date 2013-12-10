//
//  IAEPasswordPanelViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 10/12/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordPanelViewController.h"
#import "IAEPasswordPanelScreenView.h"
#import "UIView+LoadFromXib.m"
#import "IAESettingsViewControllerDefs.h"

@interface IAEPasswordPanelViewController ()

@property (nonatomic) ModeType mode;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *keyboardView;

@end

@implementation IAEPasswordPanelViewController


#pragma mark - constants

static const NSInteger kBasePanelPasswordTag = 100;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return nil;
}

- (id)init
{
    return nil;
}

- (instancetype)initWithMode:(ModeType)mode
{
    self = [super initWithNibName:@"IAEPasswordPanelViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        _mode = mode;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureNavigationController];
}

- (void)configureNavigationController
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = [self findTitleForNavigationControllerWithModeType:self.mode];
}

-(NSString *)findTitleForNavigationControllerWithModeType:(ModeType)mode
{
    NSString *retTitle;
    
    if (mode == MT_Activate) {
        retTitle = @"LTEXT_PASSWORDPANEL_ACTIVATEMODETITLE";
    } else if (mode == MT_Deactivate) {
        retTitle = @"LTEXT_PASSWORDPANEL_DEACTIVATEMODETITLE";
    } else if (mode == MT_Change) {
        retTitle = @"LTEXT_PASSWORDPANEL_CHANGEMODETITLE";
    }
    
    retTitle = NSLocalizedString(retTitle, @"");
    
    return retTitle;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureScrollViewBasedInMode];
}

- (void)configureScrollViewBasedInMode
{
    if (self.mode == MT_Activate) {
        [self addCreatePasswordPanelScreen];
    } else if (self.mode == MT_Deactivate) {
        [self addInsertToValidatePasswordPanelScreen];
    } else if (self.mode == MT_Change) {
        [self addInsertToChangePasswordPanelScreen];
    }
    
    NSLog(@"SV: %@", NSStringFromCGSize(self.scrollView.contentSize));
}

- (void)addCreatePasswordPanelScreen
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 2, self.scrollView.bounds.size.height);
    
    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOCREATE" atScrollViewPosition:0];
    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOCONFIRM" atScrollViewPosition:1];
}

- (void)addInsertToValidatePasswordPanelScreen
{
    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOVALIDATE" atScrollViewPosition:0];
}

- (void)addInsertToChangePasswordPanelScreen
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 3, self.scrollView.bounds.size.height);

    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOCHANGE" atScrollViewPosition:0];
    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOCREATE" atScrollViewPosition:1];
    [self createAndInsertPasswordPanelScreenViewWithMessage:@"LTEXT_PASSWORDPANEL_SCREENMESSAGE_INSERTOCONFIRM" atScrollViewPosition:2];
}

- (void)createAndInsertPasswordPanelScreenViewWithMessage:(NSString *)message atScrollViewPosition:(NSInteger)position
{
    IAEPasswordPanelScreenView *panel = (IAEPasswordPanelScreenView *)[UIView viewFromXib:@"IAEPasswordPanelScreenView" withOwner:self];
    panel.frame = CGRectMake(self.scrollView.bounds.size.width * position, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    panel.tag = [self createTagForPasswordPanelAtPosition:position];
    [panel setMessage:NSLocalizedString(message, @"")];
    
    NSLog(@"PP: %@", NSStringFromCGRect(panel.frame));

    [self.scrollView addSubview:panel];
}

- (IAEPasswordPanelScreenView *)findPasswordPanelScreenAtPosition:(NSInteger)position
{
    const NSInteger tag = [self createTagForPasswordPanelAtPosition:position];
    IAEPasswordPanelScreenView *panel = (IAEPasswordPanelScreenView *)[self.scrollView viewWithTag:tag];
    
    return panel;
}

- (NSInteger)createTagForPasswordPanelAtPosition:(NSInteger)position
{
    const NSInteger tag = kBasePanelPasswordTag + position;
    
    return tag;
}






@end
