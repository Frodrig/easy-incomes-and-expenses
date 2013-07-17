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

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation IAEAboutAndOptionsViewController

static NSString * const collectionViewHeaderNibName = @"IAEHeaderAboutAndOptionsCollectionReusableView";
static NSString * const collectionViewHeaderIdentifier = @"IAEHeaderAboutAndOptions";
static NSString * const collectionViewSettingsCellNibName = @"IAESettingsAboutAndOptionsCollectionViewCell";
static NSString * const collectionviewSettingsCellIdentifier = @"IAESettingsCell";
static NSString * const collectionViewAboutCellNibName = @"IAEInfoAboutAndOptionsCollectionViewCell";
static NSString * const collectionViewAboutCellIdentifier = @"IAEInfoCell";

static NSUInteger numberOfSectionsInCollectionView = 2;

static NSUInteger settingsSectionIndex = 0;
static NSUInteger aboutSectionIndex = 1;

static NSString * const settingsHeaderSectionTextTag = @"LTEXT_SETTINGS_HEADERSECTION_TEXT";
static NSString * const aboutHeaderSectionTextTag = @"LTEXT_ABOUT_HEADERSECTION_TEXT";

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
    
    [self configureCollectionView];
    [self configureNavigationItem];
}

- (void)configureCollectionView
{
    [self.collectionView registerNib:[UINib nibWithNibName:collectionViewSettingsCellNibName bundle:nil]
          forCellWithReuseIdentifier:collectionviewSettingsCellIdentifier];
    
    [self.collectionView registerNib:[UINib nibWithNibName:collectionViewAboutCellNibName bundle:nil]
          forCellWithReuseIdentifier:collectionViewAboutCellIdentifier];
    
    [self.collectionView registerNib:[UINib nibWithNibName:collectionViewHeaderNibName bundle:nil]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                  withReuseIdentifier:collectionViewHeaderIdentifier];
    
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewFlowDelegate 

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(540, 50);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;
    if ([self isSettingsSectionForIndex:indexPath.section]) {
        size = CGSizeMake(540, 71);
    } else if ([self isAboutSectionForIndex:indexPath.section]) {
        size = CGSizeMake(540, 386);
    }
    
    return size;
}

- (BOOL)isSettingsSectionForIndex:(NSUInteger)index
{
    return index == settingsSectionIndex;
}

- (BOOL)isAboutSectionForIndex:(NSUInteger)index
{
    return index == aboutSectionIndex;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell =  nil;
    if ([self isSettingsSectionForIndex:indexPath.section]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionviewSettingsCellIdentifier forIndexPath:indexPath];
        [self configureSettingsCell:(IAESettingsAboutAndOptionsCollectionViewCell *)cell];
    } else if ([self isAboutSectionForIndex:indexPath.section]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewAboutCellIdentifier forIndexPath:indexPath];
        [self configureAboutCell:(IAEInfoAboutAndOptionsCollectionViewCell *)cell];
    }
    
    return cell;
}

- (void)configureSettingsCell:(IAESettingsAboutAndOptionsCollectionViewCell *)cell
{
    // Comprobacion NSUserDefaults
}

- (void)configureAboutCell:(IAEInfoAboutAndOptionsCollectionViewCell *)cell
{
    cell.delegate = self;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    IAEHeaderAboutAndOptionsCollectionReusableView *header = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                          withReuseIdentifier:collectionViewHeaderIdentifier
                                                                                                 forIndexPath:indexPath];
    [self configureHeaderView:header forIndexPath:indexPath];
    
    return header;
}

- (void)configureHeaderView:(IAEHeaderAboutAndOptionsCollectionReusableView *)header forIndexPath:(NSIndexPath *)indexPath
{
    if ([self isSettingsSectionForIndex:indexPath.section]) {
        [header configureHeaderLabelWithText:NSLocalizedString(settingsHeaderSectionTextTag, @"")];
    } else if ([self isAboutSectionForIndex:indexPath.section]) {
        [header configureHeaderLabelWithText:NSLocalizedString(aboutHeaderSectionTextTag, @"")];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItems = 0;
    if ([self isSettingsSectionForIndex:section]) {
        numberOfItems = 1;
    } else if ([self isAboutSectionForIndex:section]) {
        numberOfItems = 1;
    }
    
    return numberOfItems;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return numberOfSectionsInCollectionView;
}

#pragma mark - IAEAboutAndOptionsViewController

- (void)feedbackEmailButtonWasPressedIninfoAboutOptionsCollectionViewCell:(IAEInfoAboutAndOptionsCollectionViewCell *)cell
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
