//
//  IAEDayCalendarSelectorViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 18/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEDayCalendarSelectorViewController.h"

@interface IAEDayCalendarSelectorViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIView *daysOfTheWeekContainerView;
@property (weak, nonatomic) IBOutlet UIView *daysOfTheMonthContainerView;

@end

@implementation IAEDayCalendarSelectorViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
