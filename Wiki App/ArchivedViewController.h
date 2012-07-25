//
//  ArchivedViewController.h
//  Pedia
//
//  Created by Chloe Stars on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ArchivedArticle.h"
#import "WikipediaHelper.h"
#import "ASIHTTPRequest.h"
#import "ASIWebPageRequest.h"
#import "ASIDownloadCache.h"

@interface ArchivedViewController : UIViewController <NSFetchedResultsControllerDelegate> {
    IBOutlet UITableView *archiveTableView;
    NSManagedObjectContext *managedObjectContext__;
    NSFetchedResultsController *fetchedResultsController_;
    NSString *articleTitle;
}

- (IBAction)archiveArticle:(id)sender;

@property (strong) IBOutlet UITableView *archiveTableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

@end
