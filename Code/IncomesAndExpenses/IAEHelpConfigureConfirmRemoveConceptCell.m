//
//  IAEConfirmRemoveConceptCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 17/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpConfigureConfirmRemoveConceptCell.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAENibUtils.h"

static NSString * const kNibName = @"IAEConfirmRemoveConceptCell";

@interface IAEHelpConfigureConfirmRemoveConceptCell()
@property (weak, nonatomic) IBOutlet UISwitch *confirmSwitch;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation IAEHelpConfigureConfirmRemoveConceptCell

+ (CGSize)sizeOfItem
{
    static CGSize size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = [IAENibUtils findSizeOfTheBaseViewOfNibNamed:kNibName];
    }
    
    return size;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [self configureConfirmSwitch];
    [self configureDescriptionLabel];
}

- (void)configureConfirmSwitch
{
    self.confirmSwitch.on = [[NSUserDefaults standardUserDefaults] isRemoveConceptConfirmationActive];
}

- (void)configureDescriptionLabel
{
    self.descriptionLabel.text = NSLocalizedString(@"LTEXT_ABOUTANDOPTIONS_CONFIRMREMOVECONCEPT_TEXT", @"");
}

- (IBAction)confirmSwithPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] changeRemoveConceptConfirmation];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
