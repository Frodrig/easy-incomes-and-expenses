//
//  IAECategoryConfigCell.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAECategoryConfigCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
