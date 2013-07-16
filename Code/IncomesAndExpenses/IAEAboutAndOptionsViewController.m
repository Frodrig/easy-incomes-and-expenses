//
//  IAEAboutAndOptionsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEAboutAndOptionsViewController.h"

@interface IAEAboutAndOptionsViewController ()

//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation IAEAboutAndOptionsViewController

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
    //self.collectionView.delegate = self;
    //self.collectionView.delegate = self;
}

- (void)configureNavigationItem
{
    self.navigationItem.title = NSLocalizedString(@"TAG_ABOUTANDOPTIONVC_TITLE", @"");
}

#pragma mark - Control Events

- (IBAction)doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
