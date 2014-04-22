//
//  IAEContextSubmenuView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 21/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEContextSubmenuView.h"

static const NSUInteger kAlertViewExecuteRemoveAllButtonIndex = 1;

@interface IAEContextSubmenuView()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *exportCSVOptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *removeAllConceptsOptionLabel;
@end

@implementation IAEContextSubmenuView

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureOptionsLabels];
    }
    return self;
}

- (void)awakeFromNib
{
    [self configureOptionsLabels];
}

- (void)configureOptionsLabels
{
    [self configureExportCSVOptionLabel];
    [self configureRemoveAllConceptsOptionLabel];
}

- (void)configureExportCSVOptionLabel
{
    self.exportCSVOptionLabel.text = NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_OPTION_EXPORTCSV", @"");
}

- (void)configureRemoveAllConceptsOptionLabel
{
    self.removeAllConceptsOptionLabel.text = NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_OPTION_REMOVEALLCONCEPTS", @"");
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self isExportCSVOptionTouchedFromTouches:touches]) {
        [self.delegate exportCSVOptionWasPressedInContextSubmenuView:self];
    } else if ([self isRemoveAllOptionTouchedFromTouches:touches]) {
        [self launchAlertViewForRemoveAllOptionsConfirmation];
    }
}

- (BOOL)isExportCSVOptionTouchedFromTouches:(NSSet *)touches
{
    return CGRectContainsPoint(self.exportCSVOptionLabel.frame, [self locationFromTouches:touches]);
}

- (BOOL)isRemoveAllOptionTouchedFromTouches:(NSSet *)touches
{
    return CGRectContainsPoint(self.removeAllConceptsOptionLabel.frame, [self locationFromTouches:touches]);
}

- (CGPoint)locationFromTouches:(NSSet *)touches
{
    UITouch *touch = touches.anyObject;
    return [touch locationInView:self];
}

#pragma mark - UIAlertView

- (void)launchAlertViewForRemoveAllOptionsConfirmation
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_ALERTVIEWREMOVEALLCONCEPTS_TITLE", @"")
                                                        message:[self findAlertViewForRemoveAllOptionsConfirmationMessage]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_ALERTVIEWREMOVEALLCONCEPTS_CANCELOPTION", @"")
                                              otherButtonTitles:NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_ALERTVIEWREMOVEALLCONCEPTS_REMOVEOPTION", @""), nil];
    [alertView show];
}

- (NSString *)findAlertViewForRemoveAllOptionsConfirmationMessage
{
    NSString *retMsg = nil;
    if ([self.datasource isActualContextAMonthForContextSubmenuView:self]) {
        retMsg = NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_ALERTVIEWREMOVEALLCONCEPTS_MSG_MONTH", @"");
    } else if ([self.datasource isActualContextAYearForContextSubmenuView:self]) {
        retMsg = NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_ALERTVIEWREMOVEALLCONCEPTS_MSG_YEAR", @"");
    }
    
    return retMsg;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == kAlertViewExecuteRemoveAllButtonIndex) {
        [self.delegate removeAllConceptsOptionWasPressedInContextSubmenuView:self];
    }
}

@end
