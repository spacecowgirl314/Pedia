//
//  WikisViewController.m
//  Pedia
//
//  Created by Chloe Stars on 8/14/12.
//
//

#import "WikisViewController.h"
#import "AppDelegate.h"
#import "Wiki.h"

@interface WikisViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation WikisViewController
@synthesize managedObjectContext=managedObjectContext_;
@synthesize fetchedResultsController=fetchedResultsController_;

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
	
	// set background image pattern to be the same as the web view background image
	[self.wikiTableView setBackgroundView:nil];
	[self.wikiTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
	
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
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Data Source Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 3;
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
            [URLTextField setPlaceholder:@"Enter the API URL eg. http://site.com/something/api.php"];
			[URLTextField setBackgroundColor:[UIColor clearColor]];
			[cell setBackgroundColor:[UIColor clearColor]];
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
			[nameTextField setBackgroundColor:[UIColor clearColor]];
			[cell setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:nameTextField];
            return cell;
        }
		if (indexPath.row==2) {
			UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            cell.textLabel.text = @"Add Wiki";
			cell.backgroundColor = [UIColor clearColor];
            return cell;
		}
    }
    else {
        // for object array enumerator should go here
        if (indexPath.row==0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            
            cell.textLabel.text = @"Wikipedia"; //[suggestions objectAtIndex:indexPath.row]; //[object description];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
			cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
        if (indexPath.row==1) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            
            cell.textLabel.text = @"Batman (Wikia)"; //[suggestions objectAtIndex:indexPath.row]; //[object description];
			cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
        if (indexPath.row==2) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            
            cell.textLabel.text = @"Call of Duty (Wikia)"; //[suggestions objectAtIndex:indexPath.row]; //[object description];
			cell.backgroundColor = [UIColor clearColor];
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
	if (indexPath.section==0) {
		if (indexPath.row==2) {
			// check to see that both fields have something in them
			// TODO: Analyze URL to make sure it's a valid url
			if ([[URLTextField text] length]==0 || [[nameTextField text] length]==0) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Either field can not be left blank." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
				[alertView show];
				return;
			}
			// save to Core Data
			Wiki *historyEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Wiki" inManagedObjectContext:[self managedObjectContext]];
			
			[historyEntry setName:[nameTextField text]];
			[historyEntry setUrl:[URLTextField text]];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				NSError *error = nil;
				if (![self.managedObjectContext save:&error])
				{
					// TODO: Do something better than just aborting.
					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					//abort();
				}
			});
			// reload
			// clear text fields
			[URLTextField setText:@""];
			[nameTextField setText:@""];
		}
	}
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

#pragma mark - NSFetchedResultsController -

- (NSFetchedResultsController *)fetchedResultsController {
    
    // if we already fetched then just return what we have
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    // otherwise begin setting up from the managed object context from the app delegate
    else {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self setManagedObjectContext:[app wikiManagedObjectContext]];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Wiki" inManagedObjectContext:managedObjectContext_];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    //[fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext_ sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    self.fetchedResultsController = theFetchedResultsController;
    NSLog(@"HistoryViewController fetched objects:%@", [fetchedResultsController_ fetchedObjects]);
    fetchedResultsController_.delegate = self;
    
    return fetchedResultsController_;
    
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	UITableView *tableView = self.wikiTableView;
    [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	UITableView *tableView = self.wikiTableView;
	
	switch(type)
	{
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeUpdate:
			[self fetchedResultsController:controller configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
		default:
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	UITableView *tableView = self.wikiTableView;
	
	switch(type)
	{
		case NSFetchedResultsChangeInsert:
			[tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
		default:
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	UITableView *tableView = self.wikiTableView;
	[tableView endUpdates];
}

- (void)fetchedResultsController:(NSFetchedResultsController *)_fetchedResultsController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Wiki *wiki = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = wiki.name;
	
	//[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

@end
