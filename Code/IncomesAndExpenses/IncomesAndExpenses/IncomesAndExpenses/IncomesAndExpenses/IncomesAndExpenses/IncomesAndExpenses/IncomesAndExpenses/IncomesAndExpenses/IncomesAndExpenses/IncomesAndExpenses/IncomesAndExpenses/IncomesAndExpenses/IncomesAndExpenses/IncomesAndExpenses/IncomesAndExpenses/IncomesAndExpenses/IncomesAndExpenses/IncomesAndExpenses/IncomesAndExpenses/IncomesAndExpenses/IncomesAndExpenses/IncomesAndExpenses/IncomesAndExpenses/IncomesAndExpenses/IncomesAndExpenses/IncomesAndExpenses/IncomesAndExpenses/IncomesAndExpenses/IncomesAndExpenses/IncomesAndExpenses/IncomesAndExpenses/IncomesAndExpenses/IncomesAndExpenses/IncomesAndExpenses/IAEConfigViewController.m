//
//  IAEConfigViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 10/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEConfigViewController.h"
#import "IAEYearsConfigViewController.h"

@interface IAEConfigViewController ()
@property (weak, nonatomic) IBOutlet UITableView *configOptionsTableView;
@property (strong, nonatomic) NSArray *configOptions;
@end

@implementation IAEConfigViewController

@synthesize configOptionsTableView = configOptionsTableView_;
@synthesize configOptions = configOptions_;

- (NSArray *)configOptions
{
    if (nil == configOptions_)
        configOptions_ = [NSArray arrayWithObjects:@"Years", nil];
    
    return configOptions_;
}

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
    self.navigationItem.title = NSLocalizedString(@"Config", @"Titulo seccion configuracion");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close",@"Opcion cerrar")  style:UIBarButtonSystemItemCancel target:self action:@selector(closeConfigModalViewControllerPressed:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIDeviceOrientationIsLandscape(toInterfaceOrientation);
}

#pragma mark - ToolBar Notifications

- (void)closeButtonPressed:(id)send
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setConfigOptionsTableView:nil];
    [super viewDidUnload];
}

#pragma mark - TableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellConfigOption";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:22.0];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
      //  cell.editingAccessoryType = UITableViewCellEditingStyleInsert;
    }
    
    NSString *configOption = [self.configOptions objectAtIndex:indexPath.row];
    
    cell.textLabel.text = configOption;
    
    return cell;
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.configOptions.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 0 -> Categories
    // 1 -> Years
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.selected = NO;
    
    switch (indexPath.row)
    {
        case 0:
        {
            IAEYearsConfigViewController *yearsConfigViewController = [[IAEYearsConfigViewController alloc] init];
            
            [self.navigationController pushViewController:yearsConfigViewController animated:YES];
        } break;
            
        default:
            break;
    }
}

#pragma mark - Toolbar Notification Events

- (void)closeConfigModalViewControllerPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
