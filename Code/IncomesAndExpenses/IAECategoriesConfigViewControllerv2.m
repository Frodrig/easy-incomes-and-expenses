//
//  IAECategoriesConfigViewControllerv2.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECategoriesConfigViewControllerv2.h"
#import "IAECategoryStore.h"
#import "IAECategoryConfigCell.h"
#import "IAECategoryConfigHeaderViewController.h"
#import "IAECategoriesConfigAddViewController.h"
#import "IAECategory.h"
#import "IAEBook.h"
#import "IAEAnimationManager.h"

@interface IAECategoriesConfigViewControllerv2 ()

@property (strong, nonatomic) IBOutlet UITableView *categoriesTableView;
@property (strong, nonatomic) IAECategoryConfigHeaderViewController *incomeHeader;
@property (strong, nonatomic) IAECategoryConfigHeaderViewController *expenseHeader;
@property (strong, nonatomic) NSIndexPath *recientCategoryCreatedIndexPath;
@property (strong, nonatomic) NSIndexPath *recientCategoryRenamedIndexPath;

@end

@implementation IAECategoriesConfigViewControllerv2

@synthesize categoriesTableView = categoriesTableView_;
@synthesize incomeHeader = incomeHeader_;
@synthesize expenseHeader = expenseHeader_;
@synthesize recientCategoryCreatedIndexPath = recientCategoryCreatedIndexPath_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.incomeHeader = [[IAECategoryConfigHeaderViewController alloc] initWithCategoryTitleLabel:NSLocalizedString(@"Income categories", @"Titulo para la categoria de ingresos") andTarget:self];
        self.expenseHeader = [[IAECategoryConfigHeaderViewController alloc] initWithCategoryTitleLabel:NSLocalizedString(@"Expense categories", @"Titulo para la categoria de gastos") andTarget:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryCreatedNotification:) name:@"CategoryCreated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryRenamedNotification:) name:@"CategoryRenamed" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.categoriesTableView registerNib:[UINib nibWithNibName:@"IAECategoryConfigCell" bundle:nil] forCellReuseIdentifier:@"IAECategoryConfigCell"];
    self.categoriesTableView.backgroundView = nil;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Cerrar") style:UIBarButtonItemStyleBordered target:self action:@selector(closeBarButtonPressed:)];
    
    self.navigationItem.title = NSLocalizedString(@"Categories", @"Categorias");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.recientCategoryCreatedIndexPath) {
        [[IAEAnimationManager sharedManager] bounceAnimation:[self.categoriesTableView cellForRowAtIndexPath:self.recientCategoryCreatedIndexPath] withDuration:1];
        self.recientCategoryCreatedIndexPath = nil;
    } else if (self.recientCategoryRenamedIndexPath) {
        IAECategoryConfigCell *cell = (IAECategoryConfigCell *)[self.categoriesTableView cellForRowAtIndexPath:self.recientCategoryRenamedIndexPath];
        [[IAEAnimationManager sharedManager] destroyViewGosthEffect:cell.categoryLabel withDuration:1 andDisplacement:44.0];
        [[IAEAnimationManager sharedManager] destroyViewGosthEffect:cell.categoryLabel withDuration:1 andDisplacement:-44.0];
        
        NSArray *container = self.recientCategoryRenamedIndexPath.section == 0 ? [[IAECategoryStore sharedCategoryStore] allUserCategoriesOfType:IncomeCategory] : [[IAECategoryStore sharedCategoryStore] allUserCategoriesOfType:ExpenseCategory];
        IAECategory *category = [container objectAtIndex:self.recientCategoryRenamedIndexPath.row-1];
        cell.categoryLabel.text = category.tag;
        
        self.recientCategoryRenamedIndexPath = nil;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)removeCategoryOfSelectedTableViewCell
{
    NSIndexPath *indexPathOfCategory = [self.categoriesTableView indexPathForSelectedRow];
    IAECategoryConfigCell *cell = (IAECategoryConfigCell *)[self. categoriesTableView cellForRowAtIndexPath:indexPathOfCategory];
    
    [[IAECategoryStore sharedCategoryStore] removeCategoryByTag:cell.categoryLabel.text];
    
    [self.categoriesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathOfCategory] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *userCategories = [[IAECategoryStore sharedCategoryStore] allUserCategoriesOfType:section == 0 ? IncomeCategory : ExpenseCategory];
    
    // Nota:
    // La celda añadida se debe a la categoria generica
    return userCategories.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"IAECategoryConfigCell";
    IAECategoryConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    IAECategory *category;
    if (indexPath.row == 0) {
        category = indexPath.section == 0 ? [[IAECategoryStore sharedCategoryStore] generalIncomeCategory] : [[IAECategoryStore sharedCategoryStore] generalExpenseCategory];
        cell.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255. blue:40.0/255.0 alpha:1.0];
        
    } else {
        NSArray *container = indexPath.section == 0 ? [[IAECategoryStore sharedCategoryStore] allUserCategoriesOfType:IncomeCategory] : [[IAECategoryStore sharedCategoryStore] allUserCategoriesOfType:ExpenseCategory];
        category =  [container objectAtIndex:indexPath.row-1];
        cell.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255. blue:50.0/255.0 alpha:1.0];
    }
    
    cell.categoryLabel.text = [category localizedTag];

    NSUInteger numConcepts = [[IAEBook sharedBook] findAllConceptsWithCategory:category].count;
    if (numConcepts == 0){
        cell.detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"No items", @"Sin conceptos"), numConcepts];
    } else if (numConcepts == 1) {
        cell.detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"With %d item", @"Para indicar conceptos asociados a una categoria cuando solo hay uno"), numConcepts];
    } else {
        cell.detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"With %d items", @"Para indicar conceptos asociados a una categoria cuando hay mas de uno"), numConcepts];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if (indexPath.row > 0) {
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (menu.menuItems != nil && menu.menuVisible) {
            [menu setMenuVisible:NO animated:YES];
        } else {
            [self.view becomeFirstResponder];
            
          //  if (nil == menu.menuItems) {
                UIMenuItem *deleteCategoryMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"Opcion menu de interaccion para borrar categoria") action:@selector(deleteCategoryMenuSelected:)];
                UIMenuItem *renameCategoryMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Rename", @"Opcion menu de interaccion para renombrar categoria") action:@selector(renameCategoryMenuSelected:)];
                menu.menuItems = [NSArray arrayWithObjects:renameCategoryMenuItem, deleteCategoryMenuItem, nil];
            //}
            
            CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
            rect.origin.y += rect.size.height / 1.5;
            [menu setTargetRect:rect inView:tableView];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *retView;
    if (section == 0) {
        retView = self.incomeHeader.view;
    } else {
        retView = self.expenseHeader.view;
    }
    
    return retView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.incomeHeader.view.bounds.size.height;
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Navigation

- (void)closeBarButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - AddCategoryButton

- (void)addCategoryPressed:(UIButton *)sender
{
    CategoryType categoryType = sender == self.incomeHeader.addCategoryButton ? IncomeCategory : ExpenseCategory;
    IAECategoriesConfigAddViewController *categoriesConfigAdd = [[IAECategoriesConfigAddViewController alloc] initWithCategoryType:categoryType andRenamingCategory:nil fromInputPanel:NO];
    [self.navigationController pushViewController:categoriesConfigAdd animated:YES];

}

#pragma mark - FloatingMenu

- (void)deleteCategoryMenuSelected:(id)sender
{
    IAECategoryConfigCell *cell = (IAECategoryConfigCell *)[self. categoriesTableView cellForRowAtIndexPath:[self.categoriesTableView indexPathForSelectedRow]];
    IAECategory *category = [[IAECategoryStore sharedCategoryStore] findCategoryByTag:cell.categoryLabel.text];
    NSUInteger numConceptsOfCategory = [[IAEBook sharedBook] findAllConceptsWithCategory:category].count;
    
    if (numConceptsOfCategory > 0) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Confirm remove", @"Advertenciai para confirmar el borrado de una categoria")
                                  message:NSLocalizedString(@"There are one or more items with this category. If you remove this category the items will change to the general category associated.", @"Descripcion de lo que ocurrira al borrar una categoria")
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Opcion para cancelar el borrado de una categoria")
                                  otherButtonTitles:NSLocalizedString(@"Remove", @"Opcion para confirmar el borrado de una categoria"), nil];
        
        [alertView show];
    }
    else {
        [self removeCategoryOfSelectedTableViewCell];
    }
}

- (void)renameCategoryMenuSelected:(id)sender
{
    IAECategoryConfigCell *cell = (IAECategoryConfigCell *)[self. categoriesTableView cellForRowAtIndexPath:[self.categoriesTableView indexPathForSelectedRow]];
    IAECategory *category = [[IAECategoryStore sharedCategoryStore] findCategoryByTag:cell.categoryLabel.text];
    IAECategoriesConfigAddViewController *categoriesConfigAdd = [[IAECategoriesConfigAddViewController alloc] initWithCategoryType:category.categoryType andRenamingCategory:category fromInputPanel:NO];
    [self.navigationController pushViewController:categoriesConfigAdd animated:YES];

}

#pragma mark - NotificationCenter

- (void)categoryCreatedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    IAECategory *categoryCreated = [userInfo objectForKey:@"Category"];
    NSUInteger section = categoryCreated.categoryType == IncomeCategory ? 0 : 1;
    NSUInteger categoryIndex = [[[IAECategoryStore sharedCategoryStore] allUserCategoriesOfType:categoryCreated.categoryType] indexOfObject:categoryCreated];
   
    self.recientCategoryCreatedIndexPath = [NSIndexPath indexPathForRow:categoryIndex + 1 inSection:section];
    
    [self.categoriesTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:self.recientCategoryCreatedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.categoriesTableView scrollToRowAtIndexPath:self.recientCategoryCreatedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)categoryRenamedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    IAECategory *categoryCreated = [userInfo objectForKey:@"Category"];
    NSUInteger section = categoryCreated.categoryType == IncomeCategory ? 0 : 1;
    NSUInteger categoryIndex = [[[IAECategoryStore sharedCategoryStore] allUserCategoriesOfType:categoryCreated.categoryType] indexOfObject:categoryCreated];
    
    self.recientCategoryRenamedIndexPath = [NSIndexPath indexPathForRow:categoryIndex + 1 inSection:section];
    
    [self.categoriesTableView scrollToRowAtIndexPath:self.recientCategoryRenamedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self removeCategoryOfSelectedTableViewCell];
    } 
}

@end
