//
//  ArchivedViewController.m
//  Pedia
//
//  Created by Chloe Stars on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArchivedViewController.h"
#import "AppDelegate.h"

@interface ArchivedViewController ()

@end

@implementation ArchivedViewController
@synthesize title;
@synthesize archiveRequest;
@synthesize managedObjectContext=managedObjectContext__;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ArchivedViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.contentSizeForViewInPopover = CGSizeMake(290.0, 435.0);
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self setManagedObjectContext:[app archiveManagedObjectContext]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)archiveArticle:(id)sender {
    // Acquire the article name from ArticleViewController
    title = @"Steve Jobs";
    WikipediaHelper *wikipediaHelper = [[WikipediaHelper alloc] init];
    NSURL *url = [NSURL URLWithString:[wikipediaHelper getURLForArticle:title]];
    
    [[self archiveRequest] setDelegate:nil];
    [[self archiveRequest] cancel];
    
    [self setArchiveRequest:[ASIWebPageRequest requestWithURL:url]];
    [[self archiveRequest] setDelegate:self];
    [[self archiveRequest] setDidFailSelector:@selector(webPageFetchFailed:)];
    [[self archiveRequest] setDidFinishSelector:@selector(webPageFetchSucceeded:)];
    
    // Tell the request to embed external resources directly in the page
    [[self archiveRequest] setUrlReplacementMode:ASIReplaceExternalResourcesWithData];
    
    // It is strongly recommended you use a download cache with ASIWebPageRequest
    // When using a cache, external resources are automatically stored in the cache
    // and can be pulled from the cache on subsequent page loads
    [[self archiveRequest] setDownloadCache:[ASIDownloadCache sharedCache]];
    
    // Ask the download cache for a place to store the cached data
    // This is the most efficient way for an ASIWebPageRequest to store a web page
    [[self archiveRequest] setDownloadDestinationPath:
     [[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:[self archiveRequest]]];
    
    [[self archiveRequest] startAsynchronous];
}

- (void)webPageFetchFailed:(ASIHTTPRequest *)theRequest
{
    // Obviously you should handle the error properly...
    NSLog(@"ArchivedViewController error: %@",[theRequest error]);
}

- (void)webPageFetchSucceeded:(ASIHTTPRequest *)theRequest
{
    NSLog(@"ArticleViewController downloadDestinationPath:%@", [theRequest downloadDestinationPath]);
    NSString *response = [NSString stringWithContentsOfFile:
                          [theRequest downloadDestinationPath] encoding:[theRequest responseEncoding] error:nil];
    // Note we're setting the baseURL to the url of the page we downloaded. This is important!
    // TODO: Clean the Cached files left behind by ASIWebRequest.
    //NSLog(@"ArchivedViewController response: %@", response);
    
    ArchivedArticle *archiveEntry = [NSEntityDescription insertNewObjectForEntityForName:@"ArchivedArticle" inManagedObjectContext:[self managedObjectContext]];
    
    [archiveEntry setTitle:title];
    [archiveEntry setData:response];
    [archiveEntry setDate:[NSDate date]];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        // TODO: Do something better than just aborting.
        NSLog(@"ArchivedViewController unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
