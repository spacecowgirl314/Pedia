//
//  HistoryViewController.h
//  Wiki App
//
//  Created by Chloe Stars on 4/21/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface HistoryViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSArray *_entries;
    NSManagedObjectContext *managedObjectContext_;
	NSFetchedResultsController *fetchedResultsController_;
}

@property (nonatomic) NSArray *entries;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

- (void)reloadFetchedResults:(NSNotification*)notification;
- (void)reloadTableView:(NSNotification*)notification;
+ (id)sharedInstance;

@end
