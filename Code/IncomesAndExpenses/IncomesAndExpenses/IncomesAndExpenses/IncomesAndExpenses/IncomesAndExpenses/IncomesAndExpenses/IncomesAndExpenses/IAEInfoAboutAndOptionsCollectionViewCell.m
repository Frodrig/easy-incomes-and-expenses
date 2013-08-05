//
//  IAEInfoAboutAndOptionsCollectionViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEInfoAboutAndOptionsCollectionViewCell.h"
#import "IAEInfoAboutAndOptionsCollectionViewCellDelegate.h"

@implementation IAEInfoAboutAndOptionsCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)feedbackButtonPressed:(id)sender
{
    [self.delegate feedbackEmailButtonWasPressedIninfoAboutOptionsCollectionViewCell:self];
}

@end
