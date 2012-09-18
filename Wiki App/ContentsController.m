//
//  ContentsController.m
//  Pedia
//
//  Created by Chloe Stars on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ContentsController.h"
#import "TableOfContentsAnchor.h"

//#define NSLog TFLog

@implementation ContentsController

#pragma mark - init for iPad

- (id)initWithTableView:(UITableView*)_tableView {
    tableView = _tableView;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // style the table
        //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linen_sidebar.png"]];
        [tableView setSeparatorColor:[UIColor darkGrayColor]];
        //tableView.backgroundView = imageView;
        tableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        // set the table view to be rounded
        tableView.layer.cornerRadius = 10;
        tableView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        tableView.layer.borderWidth = 2.0f;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(populateTableOfContents:) 
                                                 name:@"populateTableOfContents" 
                                               object:nil];
    return self;
}

#pragma mark - init for iPhone/iPod

- (id)initWithTableView:(UITableView *)_tableView navigationController:(UINavigationController*)_navigationController {
    tableView = _tableView;
    navigationController = _navigationController;
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(populateTableOfContents:) 
                                                 name:@"populateTableOfContents" 
                                               object:nil];
    return self;
}

#pragma mark - Notifications

// goes with the notification
- (void)populateTableOfContents:(NSNotification*)notification {
    // reset array to nothing
    tableOfContents = [[NSArray alloc] init];
    // reload reset data
    [tableView reloadData];
    tableOfContents = (NSArray*)[notification object];
    // only animate the cells being added on the iPad. It slows down the interface ready time on the iPhone.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        // in order to animate each cell being added we have to iterate through the array add an index for each object that exists
        for (int i=0; i < tableOfContents.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:indexPath];
        }
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // don't need to animate loading the cells on iPhone
        [tableView reloadData];
    }
}

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

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"ContentsCell"];
    
    //NSDate *object = [_objects objectAtIndex:indexPath.row];
    TableOfContentsAnchor *anchor = [tableOfContents objectAtIndex:indexPath.row];
    // this style is specific to the iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.textLabel.text = [anchor title]; //[object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
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

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"gotoAnchor" 
     object:[tableOfContents objectAtIndex:indexPath.row]];
    // return from the segue that pushed this view
    //[self.navigationController popViewControllerAnimated:YES];
    //[TestFlight passCheckpoint:@"Opened an Anchor"];
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
