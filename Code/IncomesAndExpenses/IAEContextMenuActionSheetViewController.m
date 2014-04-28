//
//  IAEContextMenuActionSheetViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 28/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEContextMenuActionSheetViewController.h"

@interface IAEContextMenuActionSheetViewController ()

@property (weak, nonatomic) IBOutlet UIButton *csvExportOptionButton;
@property (weak, nonatomic) IBOutlet UIButton *removeAllConceptsOptionButton;
@property (nonatomic) IAEContextMenuActionSheetOption enabledOption;

@end

@implementation IAEContextMenuActionSheetViewController

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSAssert(0, @"Use initWithOptionsEnabled / initWithOptionsDisabled / initWithEnabledOption");
    return nil;
}

- (instancetype)initWithOptionsEnabled
{
    self = [self initWithEnabledOption:IAEContextMenuActionSheetOptionAll];
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithOptionsDisabled
{
    self = [self initWithEnabledOption:IAEContextMenuActionSheetOptionOptionsNone];
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithEnabledOption:(IAEContextMenuActionSheetOption)enabledOption
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _enabledOption = enabledOption;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureOptionButtonsTitles];
    [self configureOptionButtonsBasedInEnabledOption];
 
}

- (void)configureOptionButtonsTitles
{
    [self.csvExportOptionButton setTitle:NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_OPTION_EXPORTCSV", @"") forState:UIControlStateNormal];
    [self.removeAllConceptsOptionButton setTitle:NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_OPTION_REMOVEALLCONCEPTS", @"") forState:UIControlStateNormal];
}

- (void)configureOptionButtonsBasedInEnabledOption
{
    self.csvExportOptionButton.enabled = self.enabledOption == IAEContextMenuActionSheetOptionAll || self.enabledOption == IAEContextMenuActionSheetOptionCSVExport;
    self.removeAllConceptsOptionButton.enabled = self.enabledOption == IAEContextMenuActionSheetOptionAll || self.enabledOption == IAEContextMenuActionSheetOptionRemoveAllConcepts;
}

#pragma mark - Button Events

- (IBAction)csvExportOptionButtonPressed:(id)sender
{
    [self.delegate contextMenuActionSheetViewController:self didSelectOption:IAEContextMenuActionSheetOptionCSVExport];
}

- (IBAction)removeAllConceptsOptionButtonPressed:(id)sender
{
    [self.delegate contextMenuActionSheetViewController:self didSelectOption:IAEContextMenuActionSheetOptionRemoveAllConcepts];
}


@end
