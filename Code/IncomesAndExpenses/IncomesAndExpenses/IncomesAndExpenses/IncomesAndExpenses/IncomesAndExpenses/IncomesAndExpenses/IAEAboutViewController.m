//
//  IAEAboutViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 28/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEAboutViewController.h"
#import "IAEViewUtils.h"
#import "IAEConstants.h"

@interface IAEAboutViewController ()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation IAEAboutViewController

@synthesize backgroundView = backgroundView_;
@synthesize popoverFatherController = popoverFatherController_;

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
    [IAEViewUtils addRoundedCorners:UIRectCornerAllCorners withRadius:10.0 toView:self.backgroundView];
    self.view.backgroundColor = [IAEConstants sectionsSettingsBackgroundColor];
    self.navigationItem.title = NSLocalizedString(@"About", @"Titulo about");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.contentSizeForViewInPopover = CGSizeMake(300.0, 155.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackgroundView:nil];
    [super viewDidUnload];
}
- (IBAction)buttonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://easyincomesandexpenses.frodrig.com"]];
    [self.popoverFatherController dismissPopoverAnimated:NO];
    [self.popoverFatherController.delegate popoverControllerDidDismissPopover:self.popoverFatherController];
}

@end
