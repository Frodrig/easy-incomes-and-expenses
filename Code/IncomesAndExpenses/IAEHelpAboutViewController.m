//
//  IAEHelpAboutViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpAboutViewController.h"
#import "Flurry.h"
#import "IAEHelpAboutCollectionViewCell.h"
#import "IAEHelpIndexViewControllerDelegate.h"

@interface IAEHelpAboutViewController ()

@end

@implementation IAEHelpAboutViewController

#pragma mark - Constantes

static NSString * const kLTextAppUrl = @"LTEXT_URLPAGE";

static NSString * const kCollectionViewAboutCellNibName = @"IAEHelpAboutCollectionViewCell";
static NSString * const kCollectionViewAboutCellIdentifier = @"IAEInfoCell";

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

    [self configureCollectionView];
    [self configureNavigationController];
}

- (void)configureCollectionView
{
    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewAboutCellNibName bundle:nil]
          forCellWithReuseIdentifier:kCollectionViewAboutCellIdentifier];
}

- (void)configureNavigationController
{
    self.title = NSLocalizedString(@"LTEXT_SETTINGSINDEX_3", @"");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed:)];
}

#pragma mark - Navigation Bar

- (void)doneButtonPressed:(UIBarButtonItem *)button
{
    [self.delegate dismissAll];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [IAEHelpAboutCollectionViewCell sizeOfItem];
    
    return size;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IAEHelpAboutCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewAboutCellIdentifier
                                                                                     forIndexPath:indexPath];
    [self configureAboutCell:cell];
    
    return cell;
}

- (void)configureAboutCell:(IAEHelpAboutCollectionViewCell *)cell
{
    cell.canSendMail = [MFMailComposeViewController canSendMail];
    cell.delegate = self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - IAEHelpAboutCollectionViewControllerDelegate

- (void)urlButtonWasPressedInHelpAboutCollectionViewCell:(IAEHelpAboutCollectionViewCell *)cell
{
    [self launchSafariWithAppUrl];
}

- (void)launchSafariWithAppUrl
{
    [Flurry logEvent:@"safary_openoficialurl"];
    
    NSString *urlString = NSLocalizedString(kLTextAppUrl, @"");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)feedbackEmailButtonWasPressedInHelpAboutCollectionViewCell:(IAEHelpAboutCollectionViewCell *)cell
{
    [self launchMailComposerViewControllerForFeedback];
}

- (void)launchMailComposerViewControllerForFeedback
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
