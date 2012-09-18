//
//  ArchiveDownloader.h
//  Pedia
//
//  Created by Chloe Stars on 7/24/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ArchivedArticle.h"
#import "WikipediaHelper.h"
#import "ASIHTTPRequest.h"
#import "ASIWebPageRequest.h"
#import "ASIDownloadCache.h"

@protocol ArchiveDownloaderDelegate <NSObject>
@required
- (NSString*)didBeginArchivingArticle;
@end

@interface ArchiveDownloader : NSObject <ASIHTTPRequestDelegate> {
    id <ArchiveDownloaderDelegate> delegate;
    ASIWebPageRequest *archiveRequest;
    NSString *articleTitle;
    NSString *uniqueID;
    NSManagedObjectContext *managedObjectContext__;
    NSString *soundPath;
    SystemSoundID audioEffect;
}

- (void)setup;
+ (id)sharedDownloader;
- (void)downloadArticle;

@property (retain) id delegate;
@property (nonatomic) NSString *articleTitle;
@property (nonatomic) ASIWebPageRequest *archiveRequest;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property UIProgressView *progressIndicator;

@end
