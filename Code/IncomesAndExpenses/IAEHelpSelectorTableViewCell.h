//
//  IAEHelpSelectorTableViewCell.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 13/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEHelpSelectorTableViewCellDelegate.h"

@interface IAEHelpSelectorTableViewCell : UITableViewCell

@property (nonatomic, weak) id<IAEHelpSelectorTableViewCellDelegate> delegate;

@end
