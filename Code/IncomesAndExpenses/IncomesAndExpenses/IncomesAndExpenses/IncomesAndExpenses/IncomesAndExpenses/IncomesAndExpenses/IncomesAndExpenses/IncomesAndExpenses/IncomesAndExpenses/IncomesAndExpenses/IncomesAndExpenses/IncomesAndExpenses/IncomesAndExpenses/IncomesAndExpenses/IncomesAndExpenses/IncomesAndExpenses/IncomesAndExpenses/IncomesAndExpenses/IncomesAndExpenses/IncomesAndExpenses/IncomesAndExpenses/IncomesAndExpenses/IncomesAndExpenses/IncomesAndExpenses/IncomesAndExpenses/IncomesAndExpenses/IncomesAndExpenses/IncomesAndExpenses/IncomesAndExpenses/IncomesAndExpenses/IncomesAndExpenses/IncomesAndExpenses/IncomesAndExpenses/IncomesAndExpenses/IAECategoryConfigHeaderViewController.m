//
//  IAECategoryConfigHeaderViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECategoryConfigHeaderViewController.h"

@interface IAECategoryConfigHeaderViewController ()

@property (nonatomic, strong) NSString *titleLabel;
@property (nonatomic, weak) id target;

@end

@implementation IAECategoryConfigHeaderViewController

@synthesize categoryTypeLabel = categoryTitleLabel_;
@synthesize addCategoryButton = addCategoryButton_;


- (id)initWithCategoryTitleLabel:(NSString *)categoryTitle andTarget:(id)target
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.titleLabel = categoryTitle;
        self.target = target;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.categoryTypeLabel.text = self.titleLabel;
    [self.addCategoryButton addTarget:self.target action:@selector(addCategoryPressed:) forControlEvents:UIControlEventTouchDown];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCategoryTypeLabel:nil];
    [self setAddCategoryButton:nil];
    [super viewDidUnload];
}
@end
