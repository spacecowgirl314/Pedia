//
//  ArchiveDownloader.m
//  Pedia
//
//  Created by Chloe Stars on 7/24/12.
//
//

#import "ArchiveDownloader.h"
#import "AppDelegate.h"

static ArchiveDownloader *sharedMyDownloader = nil;

@implementation ArchiveDownloader
@synthesize archiveRequest;
@synthesize articleTitle;
@synthesize delegate;
@synthesize managedObjectContext=managedObjectContext__;

+ (id)sharedDownloader {
    @synchronized(self) {
        if (sharedMyDownloader == nil) {
            sharedMyDownloader = [[self alloc] init];
            [sharedMyDownloader setup];
        }
    }
    return sharedMyDownloader;
}

// what should be in an init method but isn't
- (void)setup {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setManagedObjectContext:[app archiveManagedObjectContext]];
    // set up archive finished sound
    soundPath  = [[NSBundle mainBundle] pathForResource:@"xylophone_affirm" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath : soundPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
}

- (void)webPageFetchFailed:(ASIHTTPRequest *)theRequest
{
    // Obviously you should handle the error properly...
    NSLog(@"ArchivedDownloader error: %@",[theRequest error]);
}

- (void)webPageFetchSucceeded:(ASIHTTPRequest *)theRequest
{
    NSLog(@"ArchiveDownloader downloadDestinationPath:%@", [theRequest downloadDestinationPath]);
    //NSString *response = [NSString stringWithContentsOfFile:
    //                      [theRequest downloadDestinationPath] encoding:[theRequest responseEncoding] error:nil];
    // save to file
    
    // Note we're setting the baseURL to the url of the page we downloaded. This is important!
    // TODO: Clean the Cached files left behind by ASIWebRequest.
    //NSLog(@"ArchivedViewController response: %@", response);
    
    ArchivedArticle *archiveEntry = [NSEntityDescription insertNewObjectForEntityForName:@"ArchivedArticle" inManagedObjectContext:[self managedObjectContext]];
    
    [archiveEntry setTitle:articleTitle];
    [archiveEntry setFile:uniqueID];
    [archiveEntry setDate:[NSDate date]];
    
	dispatch_async(dispatch_get_main_queue(), ^{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        // TODO: Do something better than just aborting.
        NSLog(@"ArchiveDownloader unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
	});
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setAlertBody:[[NSString alloc] initWithFormat:@"Article %@ has finished downloading.", articleTitle]];
    [notification setAlertAction:@"Show"];
    [notification setFireDate:[NSDate date]];
    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
    [notification setSoundName:soundPath];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    AudioServicesPlaySystemSound(audioEffect);
}

- (void)downloadArticle {
    //Perform your tasks that your application requires
    
    // Acquire the article name from ArticleViewController
    articleTitle = [[self delegate] didBeginArchivingArticle];
    //NSLog(@"ArticleViewController archiving: %@", articleTitle);
    WikipediaHelper *wikipediaHelper = [[WikipediaHelper alloc] init];
    NSURL *url = [NSURL URLWithString:[wikipediaHelper getURLForArticle:articleTitle]];
    
    [[self archiveRequest] setDelegate:nil];
    [[self archiveRequest] cancel];
    
    [self setArchiveRequest:[ASIWebPageRequest requestWithURL:url]];
    [[self archiveRequest] setDelegate:self];
    [[self archiveRequest] setUserAgentString:@"Pedia"];
    [[self archiveRequest] setDidFailSelector:@selector(webPageFetchFailed:)];
    [[self archiveRequest] setDidFinishSelector:@selector(webPageFetchSucceeded:)];
	[[self archiveRequest] setDownloadProgressDelegate:_progressIndicator];
    
    // Tell the request to embed external resources directly in the page
    [[self archiveRequest] setUrlReplacementMode:ASIReplaceExternalResourcesWithData];
    
    // It is strongly recommended you use a download cache with ASIWebPageRequest
    // When using a cache, external resources are automatically stored in the cache
    // and can be pulled from the cache on subsequent page loads
    [[self archiveRequest] setDownloadCache:[ASIDownloadCache sharedCache]];
    
    // Ask the download cache for a place to store the cached data
    // This is the most efficient way for an ASIWebPageRequest to store a web page
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    uniqueID = (__bridge NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    NSURL *saveURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:uniqueID];
    [[self archiveRequest] setDownloadDestinationPath:[saveURL relativePath]];
    
    [[self archiveRequest] startAsynchronous];
}

#pragma mark - Documents Directory -

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
