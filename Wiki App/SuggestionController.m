//
//  SuggestionController.m
//  Pedia
//
//  Created by Chloe Stars on 5/16/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import "SuggestionController.h"

@implementation SuggestionController
@synthesize suggestionTableView;

- (void)setSuggestions:(NSMutableArray*)_suggestions {
    suggestions = _suggestions;
    NSLog(@"suggestion count:%i", [suggestions count]);
    [suggestionTableView reloadData];
}

#pragma mark - View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // dismiss the keyboard
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"resignSearchField" 
     object:nil];
}

#pragma mark - Data Source Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return _objects.count;
    return suggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuggestionCell"];
    
    cell.textLabel.text = [suggestions objectAtIndex:indexPath.row]; //[object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
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
    [TestFlight passCheckpoint:@"Used a suggestion"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // pass the title of the current item to the app to be loaded as the next article
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"gotoArticle" 
     object:[suggestions objectAtIndex:indexPath.row]];
    // dissmiss search view and reset suggestions
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"closeSearchView" 
     object:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // disable editing of the cells. can no longer swipe to delete
    return UITableViewCellEditingStyleNone;
}

@end
