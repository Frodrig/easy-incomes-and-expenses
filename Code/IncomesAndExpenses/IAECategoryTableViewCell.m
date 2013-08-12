//
//  IAECategoryTableViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 05/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECategoryTableViewCell.h"
#import "UIView+RoundedCorners.h"

@interface IAECategoryTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *backgroundContainerView;

@end

@implementation IAECategoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    //[self.backgroundContainerView addRoundedCorners:UIRectCornerAllCorners withRadius:8.0];
}

@end
