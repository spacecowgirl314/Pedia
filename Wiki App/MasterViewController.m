//
//  MasterViewController.m
//  Wiki App
//
//  Created by Chloe Stars on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "TableOfContentsAnchor.h"

#define NSLog TFLog

@interface MasterViewController () {
    NSMutableArray *_objects;
    NSArray *tableOfContents;
}
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
//@synthesize tableOfContents;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // style the table
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linen_sidebar.png"]];
    [self.tableView setSeparatorColor:[UIColor grayColor]];
    self.tableView.backgroundView = imageView;
    self.title = NSLocalizedString(@"Contents", @"Contents");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // change item button color to match gray
        self.navigationItem.backBarButtonItem.tintColor = [UIColor grayColor];
        // change color of font to gray on the iPhone in the navigation bar
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor grayColor]; // change this color
        self.navigationItem.titleView = titleLabel;
        titleLabel.text = self.title;
        [titleLabel sizeToFit];
    }
    /*self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.opaque = YES;
    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];*/
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(populateTableOfContents:) 
                                                 name:@"populateTableOfContents" 
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

// goes with the notification
- (void)populateTableOfContents:(NSNotification*)notification {
    // reset array to nothing
    tableOfContents = [[NSArray alloc] init];
    // reload reset data
    [[self tableView] reloadData];
    tableOfContents = (NSArray*)[notification object];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i=0; i < tableOfContents.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:indexPath];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // don't need to animate loading the cells on iPhone
        [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

/*- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}*/

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return _objects.count;
    return tableOfContents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContentsCell"];

    //NSDate *object = [_objects objectAtIndex:indexPath.row];
    TableOfContentsAnchor *anchor = [tableOfContents objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [anchor title]; //[object description];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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
    // open anchor link here
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //NSDate *object = [_objects objectAtIndex:indexPath.row];
        //self.detailViewController.detailItem = object;
        // deselect the current cell
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[NSNotificationCenter defaultCenter] 
         postNotificationName:@"gotoAnchor" 
         object:[tableOfContents objectAtIndex:indexPath.row]];
        [TestFlight passCheckpoint:@"Opened an Anchor"];
    }*/
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"gotoAnchor" 
     object:[tableOfContents objectAtIndex:indexPath.row]];
    // return from the segue that pushed this view
    [self.navigationController popViewControllerAnimated:YES];
    [TestFlight passCheckpoint:@"Opened an Anchor"];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // disable editing of the cells. can no longer swipe to delete
    return UITableViewCellEditingStyleNone;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = [_objects objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }*/
}

@end
