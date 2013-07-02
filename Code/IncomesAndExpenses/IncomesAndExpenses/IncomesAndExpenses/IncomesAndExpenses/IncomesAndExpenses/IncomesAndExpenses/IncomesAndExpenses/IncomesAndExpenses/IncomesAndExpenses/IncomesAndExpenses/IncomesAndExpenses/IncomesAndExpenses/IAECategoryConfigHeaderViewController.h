//
//  IAECategoryConfigHeaderViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAECategoryConfigHeaderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *categoryTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *addCategoryButton;

- (id)initWithCategoryTitleLabel:(NSString *)categoryTitle andTarget:(id)target;

@end
