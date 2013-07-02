//
//  IAEYearConfigCardViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 21/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAEYear;

@interface IAEYearConfigCardViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *goToYearButton;
@property (nonatomic, weak, readonly) IAEYear *year;

- (id)initWithYear:(IAEYear *)year;
- (id)initWithActualYearCard:(IAEYear *)year;

@end
