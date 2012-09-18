//
//  ArchivedViewController.m
//  Pedia
//
//  Created by Chloe Stars on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArchivedViewController.h"
#import "AppDelegate.h"
#import "ArticleViewController.h"
#import "ArchiveDownloader.h"

//#define NSLog TFLog

@interface ArchivedViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ArchivedViewController
@synthesize archiveTableView;
@synthesize managedObjectContext=managedObjectContext__;
@synthesize fetchedResultsController=fetchedResultsController_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ArchivedViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"Archived", @"Archived");
    self.contentSizeForViewInPopover = CGSizeMake(290.0, 435.0);
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
    // load data
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue,^{
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) {
            // Update to handle the error appropriately.
            NSLog(@"ArchivedViewController unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        // reload on main thread. keeps ui glitches from happening
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.archiveTableView reloadData];
        });
    });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Archiving -

- (IBAction)archiveArticle:(id)sender {
    [[ArchiveDownloader sharedDownloader] downloadArticle];
}

#pragma mark - UITableViewDataSource -

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
	return self.fetchedResultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
	
    if (sections.count > 0) 
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
	    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ArchiveCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
	[self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)_fetchedResultsController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ArchivedArticle *archivedArticle = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = archivedArticle.title;
	
	//[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        // remove associated archive file
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *fileURL = [[self applicationDocumentsDirectory]
                          URLByAppendingPathComponent:[(ArchivedArticle*)[self.fetchedResultsController objectAtIndexPath:indexPath] file]];
        [fileManager removeItemAtURL:fileURL error:nil];
        // then delete the object from CoreData
		[context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
		NSError *error;
        if (![context save:&error])
		{
			NSLog(@"ArchivedViewController unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		});
    } 
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([[fetchedResultsController_ sections] count] > 0)
	{
		return [[[fetchedResultsController_ sections] objectAtIndex:section] name];
	}
	else
	{
		return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    // deselect the current cell
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //ArchivedArticle *archivedArticle = (ArchivedArticle*)[fetchedResultsController_ objectAtIndexPath:indexPath];
    //ArchivedArticleStatic *archive = [[ArchivedArticleStatic alloc] init];
    //[archive setTitle:[archivedArticle title]];
    //[archive setData:[archivedArticle data]];
    //[archive setDate:[archivedArticle date]];
    // pass the title of the current item to the app to be loaded as the next article
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"gotoArchivedArticle" 
     object:(ArchivedArticle*)[fetchedResultsController_ objectAtIndexPath:indexPath]];// archive
    // return from the segue that pushed this view
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NSFetchedResultsController -

- (NSFetchedResultsController *)fetchedResultsController {
    
    // if we already fetched then just return what we have
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    else {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self setManagedObjectContext:[app archiveManagedObjectContext]];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"ArchivedArticle" inManagedObjectContext:managedObjectContext__];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    //[fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext__ sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    self.fetchedResultsController = theFetchedResultsController;
    NSLog(@"ArchivedViewController fetched objects:%@", [fetchedResultsController_ fetchedObjects]);
    fetchedResultsController_.delegate = self;
    
    return fetchedResultsController_;
    
}
#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	UITableView *tableView = self.archiveTableView;
    [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	UITableView *tableView = self.archiveTableView;
	
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
	UITableView *tableView = self.archiveTableView;
	
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
	UITableView *tableView = self.archiveTableView;
	[tableView endUpdates];
}

#pragma mark - Documents Directory -

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
