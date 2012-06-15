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

@protocol ArchivedViewControllerDelegate <NSObject>
@required
- (NSString*)didBeginArchivingArticle;
@end

@interface ArchivedViewController : UIViewController <ASIHTTPRequestDelegate, NSFetchedResultsControllerDelegate> {
    id <ArchivedViewControllerDelegate> delegate;
    IBOutlet UITableView *archiveTableView;
    ASIWebPageRequest *archiveRequest;
    NSManagedObjectContext *managedObjectContext__;
    NSFetchedResultsController *fetchedResultsController_;
    NSString *articleTitle;
    SystemSoundID audioEffect;
}

- (IBAction)archiveArticle:(id)sender;

@property (retain) id delegate;
@property (strong) IBOutlet UITableView *archiveTableView;
@property (nonatomic) NSString *articleTitle;
@property (nonatomic) ASIWebPageRequest *archiveRequest;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

@end
