//
//  WikisViewController.m
//  Pedia
//
//  Created by Chloe Stars on 8/14/12.
//
//

#import "WikisViewController.h"

@interface WikisViewController ()

@end

@implementation WikisViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"WikisViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Manage Wikis", @"Manage Wikis");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // change color of font to gray on the iPhone in the navigation bar
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        titleLabel.shadowColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor grayColor]; // change this color
        self.navigationItem.titleView = titleLabel;
        titleLabel.text = self.title;
        [titleLabel sizeToFit];
    }
    UIImage *image = [UIImage imageNamed:@"topbar.png"];
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
    doneButton.enabled = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)done {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Data Source Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 2;
    }
    else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                URLTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 12, tableView.bounds.size.width-80, 30)];
            }
            else {
                URLTextField = [[UITextField alloc] initWithFrame:CGRectMake(19, 12, tableView.bounds.size.width-80, 30)];
            }
            [URLTextField setAdjustsFontSizeToFitWidth:YES];
            [URLTextField setReturnKeyType:UIReturnKeyNext];
            [URLTextField setKeyboardType:UIKeyboardTypeURL];
            [URLTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [URLTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [URLTextField setPlaceholder:@"Enter URL"];
            [cell addSubview:URLTextField];
            return cell;
        }
        if (indexPath.row==1) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 12, tableView.bounds.size.width-80, 30)];
            }
            else {
                nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(19, 12, tableView.bounds.size.width-80, 30)];
            }
            [nameTextField setAdjustsFontSizeToFitWidth:YES];
            [nameTextField setReturnKeyType:UIReturnKeyDone];
            [nameTextField setKeyboardType:UIKeyboardTypeURL];
            [nameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [nameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [nameTextField setPlaceholder:@"Enter Name"];
            [cell addSubview:nameTextField];
            return cell;
        }
    }
    else {
        // for object array enumerator should go here
        if (indexPath.row==0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            
            cell.textLabel.text = @"Wikipedia"; //[suggestions objectAtIndex:indexPath.row]; //[object description];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            return cell;
        }
        if (indexPath.row==1) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            
            cell.textLabel.text = @"Batman (Wikia)"; //[suggestions objectAtIndex:indexPath.row]; //[object description];
            return cell;
        }
        if (indexPath.row==2) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            
            cell.textLabel.text = @"Call of Duty (Wikia)"; //[suggestions objectAtIndex:indexPath.row]; //[object description];
            return cell;
        }
    }
    // shuts up the warning about reaching end of void function
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section==1) {
        return YES;
    }
    else {
        return NO;
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
        case 0:
            return @"ADD NEW";
            break;
        case 1:
            return @"MANAGE";
            break;
        default:
            return @"";
            break;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // disable editing of the cells. can no longer swipe to delete
    if (indexPath.section==1) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleNone;
    }
}

@end
