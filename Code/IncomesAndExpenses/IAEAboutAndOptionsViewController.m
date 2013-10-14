//
//  IAEAboutAndOptionsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEAboutAndOptionsViewController.h"
#import "IAEHeaderAboutAndOptionsCollectionReusableView.h"
#import "IAESettingsAboutAndOptionsCollectionViewCell.h"
#import "IAEInfoAboutAndOptionsCollectionViewCell.h"

@interface IAEAboutAndOptionsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) BOOL dayModeWasActiveAtStart;

@end

@implementation IAEAboutAndOptionsViewController

#pragma mark - Constants

static NSString * const kUserDefaultsDayModeActive = @"dayModeActive";

static NSString * const kCollectionViewHeaderNibName = @"IAEHeaderAboutAndOptionsCollectionReusableView";
static NSString * const kCollectionViewHeaderIdentifier = @"IAEHeaderAboutAndOptions";
static NSString * const kCollectionViewSettingsCellNibName = @"IAESettingsAboutAndOptionsCollectionViewCell";
static NSString * const kCollectionviewSettingsCellIdentifier = @"IAESettingsCell";
static NSString * const kCollectionViewAboutCellNibName = @"IAEInfoAboutAndOptionsCollectionViewCell";
static NSString * const kCollectionViewAboutCellIdentifier = @"IAEInfoCell";
static NSString * const kCollectionViewProVersionCellNibName = @"IAEProVersionAboutAndOptionsCollectionViewCell";
static NSString * const kCollectionViewProVersionCellIdentifier = @"IAEProVersionCell";

static NSString * const kLTextAppUrl = @"LTEXT_URLPAGE";

static const NSUInteger kSettingsSectionIndex = 0;
static const NSUInteger kAboutSectionIndex = 1;

static NSString * const kSettingsHeaderSectionTextTag = @"LTEXT_SETTINGS_HEADERSECTION_TEXT";
static NSString * const kAboutHeaderSectionTextTag = @"LTEXT_ABOUT_HEADERSECTION_TEXT";
static NSString * const kProVersionHeaderSectionTextTag = @"LTEXT_PROVERSION_HEADERSECTION_TEXT";

static NSUInteger kSettingsOptionIndexInSegmentedControl = 0;
static NSUInteger kAboutOptionIndexInSegmentedControl = 1;

static NSString * const kLTextTitleForSegmentedAtIndex0 = @"LTEXT_SETTINGS_MENUSETTINGSOPTION";
static NSString * const kLTextTitleForSegmentedAtIndex1 = @"LTEXT_SETTINGS_ABOUTSETTINGSOPTION";

static NSString * const kNotificationDayModeOnName = @"dayModeToOn";
static NSString * const kNotificationDayModeOffName = @"dayModeToOff";

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self prepareGlobalSettingsInformation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepareGlobalSettingsInformation];
    }
    
    return self;
}

- (void)prepareGlobalSettingsInformation
{
    _dayModeWasActiveAtStart = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDayModeActive];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureSegmentedControl];
    [self configureCollectionView];
    [self configureNavigationItem];
}

- (void)configureSegmentedControl
{
    [self.segmentedControl setTitle:NSLocalizedString(kLTextTitleForSegmentedAtIndex0, @"") forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(kLTextTitleForSegmentedAtIndex1, @"") forSegmentAtIndex:1];
}

- (void)configureCollectionView
{
    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewSettingsCellNibName bundle:nil]
          forCellWithReuseIdentifier:kCollectionviewSettingsCellIdentifier];
    
    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewAboutCellNibName bundle:nil]
          forCellWithReuseIdentifier:kCollectionViewAboutCellIdentifier];

    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewHeaderNibName bundle:nil]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                  withReuseIdentifier:kCollectionViewHeaderIdentifier];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)configureNavigationItem
{
    self.navigationItem.title = NSLocalizedString(@"LTEXT_ABOUTANDOPTIONVC_TITLE", @"");
}

#pragma mark - Control Events

- (IBAction)doneButtonPressed:(id)sender
{
    [self notifyGlobalValueChangesIfAppropiate];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)notifyGlobalValueChangesIfAppropiate
{
    const BOOL actualDayModeActive = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDayModeActive];
    if (actualDayModeActive != self.dayModeWasActiveAtStart) {
        [self notifyDayModeChanged:actualDayModeActive];
    }
}

- (void)notifyDayModeChanged:(BOOL)dayModeOn
{
    NSString *notificationName = dayModeOn ? kNotificationDayModeOnName : kNotificationDayModeOffName;
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)segmentedControlPressed:(UISegmentedControl *)segmentedControl
{
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

#pragma mark - UICollectionViewFlowDelegate 

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(540, 50);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;
    if ([self isInSettingsSection]) {
        size = [IAESettingsAboutAndOptionsCollectionViewCell sizeOfItem];
    } else if ([self isInAboutSection]) {
        size = [IAEInfoAboutAndOptionsCollectionViewCell sizeOfItem];
    }
    
    return size;
}

- (NSUInteger)findNumberOfItemsBasedInSegmentedControl
{
    NSUInteger numberOfItems = 1;
    
    return numberOfItems;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell =  nil;
    if ([self isInSettingsSection]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionviewSettingsCellIdentifier forIndexPath:indexPath];
        [self configureSettingsCell:(IAESettingsAboutAndOptionsCollectionViewCell *)cell];
    } else if ([self isInAboutSection]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewAboutCellIdentifier forIndexPath:indexPath];
        [self configureAboutCell:(IAEInfoAboutAndOptionsCollectionViewCell *)cell];
    }
    
    return cell;
}

- (BOOL)isInAboutSection
{
    return self.segmentedControl.selectedSegmentIndex == kAboutOptionIndexInSegmentedControl;
}

- (BOOL)isInSettingsSection
{
    return self.segmentedControl.selectedSegmentIndex == kSettingsOptionIndexInSegmentedControl;
}

- (void)configureSettingsCell:(IAESettingsAboutAndOptionsCollectionViewCell *)cell
{
    // Comprobacion NSUserDefaults
}

- (void)configureAboutCell:(IAEInfoAboutAndOptionsCollectionViewCell *)cell
{
    cell.canSendMail = [MFMailComposeViewController canSendMail];
    cell.delegate = self;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    IAEHeaderAboutAndOptionsCollectionReusableView *header = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                          withReuseIdentifier:kCollectionViewHeaderIdentifier
                                                                                                 forIndexPath:indexPath];
    [self configureHeaderView:header forIndexPath:indexPath];
    
    return header;
}

- (void)configureHeaderView:(IAEHeaderAboutAndOptionsCollectionReusableView *)header forIndexPath:(NSIndexPath *)indexPath
{
    if ([self isInSettingsSection]) {
        [header configureHeaderLabelWithText:NSLocalizedString(kSettingsHeaderSectionTextTag, @"")];
    } else if ([self isInAboutSection]) {
        [header configureHeaderLabelWithText:NSLocalizedString(kAboutHeaderSectionTextTag, @"")];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItems = [self findNumberOfItemsBasedInSegmentedControl];
    
    return numberOfItems;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - IAEAboutAndOptionsViewController

- (void)urlButtonWasPressedInInfoAboutOptionsCollectionViewCell:(IAEInfoAboutAndOptionsCollectionViewCell *)cell
{
    [self launchSafariWithAppUrl];
}

- (void)launchSafariWithAppUrl
{
    NSString *urlString = NSLocalizedString(kLTextAppUrl, @"");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)feedbackEmailButtonWasPressedInInfoAboutOptionsCollectionViewCell:(IAEInfoAboutAndOptionsCollectionViewCell *)cell
{
    [self lauchMailComposerViewControllerForFeedback];
}

- (void)lauchMailComposerViewControllerForFeedback
{
    MFMailComposeViewController *appEmailViewController = [[MFMailComposeViewController alloc] init];
    appEmailViewController.mailComposeDelegate = self;
        
    NSString *subject = [NSLocalizedString(@"LTEXT_EMAIL_SUBJECT", @"Email feedback") stringByAppendingString:NSLocalizedString(@"LTEXT_VERSION", @"")];
    [appEmailViewController setSubject:subject];
    [appEmailViewController setToRecipients:[NSArray arrayWithObject:NSLocalizedString(@"LTEXT_EMAIL", @"")]];
        
    [self presentViewController:appEmailViewController animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
