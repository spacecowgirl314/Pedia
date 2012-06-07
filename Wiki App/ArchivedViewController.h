//
//  ArchivedViewController.h
//  Pedia
//
//  Created by Chloe Stars on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ArchivedArticle.h"
#import "WikipediaHelper.h"
#import "ASIHTTPRequest.h"
#import "ASIWebPageRequest.h"
#import "ASIDownloadCache.h"

@interface ArchivedViewController : UIViewController <ASIHTTPRequestDelegate> {
    ASIWebPageRequest *archiveRequest;
    NSManagedObjectContext *managedObjectContext__;
    NSString *title;
}

- (IBAction)archiveArticle:(id)sender;

@property (nonatomic) NSString *title;
@property (nonatomic) ASIWebPageRequest *archiveRequest;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
