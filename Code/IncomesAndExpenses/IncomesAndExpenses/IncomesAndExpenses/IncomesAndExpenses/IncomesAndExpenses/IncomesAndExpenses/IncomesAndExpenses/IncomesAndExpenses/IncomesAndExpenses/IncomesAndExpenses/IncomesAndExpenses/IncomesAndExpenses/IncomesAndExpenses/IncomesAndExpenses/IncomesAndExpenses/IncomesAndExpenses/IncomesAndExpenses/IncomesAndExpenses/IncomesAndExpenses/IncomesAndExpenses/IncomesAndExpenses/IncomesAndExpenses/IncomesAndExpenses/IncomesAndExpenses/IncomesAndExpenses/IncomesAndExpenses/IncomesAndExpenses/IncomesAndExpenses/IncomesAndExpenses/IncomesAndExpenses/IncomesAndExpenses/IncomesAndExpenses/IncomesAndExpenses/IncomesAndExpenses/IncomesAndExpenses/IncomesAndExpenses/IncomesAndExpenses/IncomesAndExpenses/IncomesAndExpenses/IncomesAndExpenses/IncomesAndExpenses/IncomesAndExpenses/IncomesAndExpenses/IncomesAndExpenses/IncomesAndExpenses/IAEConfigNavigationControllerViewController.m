//
//  IAEConfigNavigationControllerViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 10/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEConfigNavigationControllerViewController.h"

@interface IAEConfigNavigationControllerViewController ()

@end

@implementation IAEConfigNavigationControllerViewController

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
	// Do any additional setup after loading the view.
    self.navigationBar.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// NOTA: La unica razón de la existencia de esta clase es que cuando lanzamos un controller de forma modal el teclado no se
// quita solo con hacer un resign. Hay que llamar a este metodo. MOVIDON.
- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIDeviceOrientationIsLandscape(toInterfaceOrientation);
}

@end
