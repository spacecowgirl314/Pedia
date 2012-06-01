//
//  DetailViewController.m
//  Wiki App
//
//  Created by Chloe Stars on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "HTMLParser.h"
#import "HistoryItem.h"
#import "Reachability.h"


#define NSLog TFLog

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize historyController = _historyController;
@synthesize historyControllerPopover = _historyControllerPopover;
@synthesize bottomBar;
@synthesize articleSearchBox;
@synthesize articleView;
@synthesize historyArray;
@synthesize previousHistoryArray;
@synthesize titleLabel;
@synthesize tableOfContents;

#pragma mark - Search Field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == articleSearchBox) {
        // start thread in background for loading the page
        //[NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[articleSearchBox text]];
        // only allow to continue if we aren't already executing loading a page
        if (![loadingThread isExecuting]) {
            // just reuse the single tap detection from the overlay
            [self closeSearchField:nil];
            // VIRTUAL COPY FROM WEBVIEW METHOD AREA. COMBINE SOMETIME
            // we went back in our history and picked another article instead
            // do we chop off the rest of the forward history?
            [self futureHistoryChopping];
            if (![[articleSearchBox text] isEqualToString:@""]) {
            loadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadHTMLandParse:) object:[articleSearchBox text]];
            // done with the keyboard. hide it
            [articleSearchBox resignFirstResponder];
            [loadingThread start];
            }
            // also save history
            //[self processHistory:[articleSearchBox text]];
            processHistoryThread = [[NSThread alloc] initWithTarget:self selector:@selector(processHistory:) object:[articleSearchBox text]];
            [processHistoryThread start];
        }
    }
    return YES;
}

- (void)textFieldDidChange:(id)sender {
    // bring suggestion view out of hiding once we start typing
    if ([[articleSearchBox text] isEqualToString:@""]) {
        [suggestionTableView setHidden:YES];
    }
    else {
        [UIView animateWithDuration:0.50
                              delay:0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             [suggestionTableView setHidden:NO];
                         }
                         completion:^(BOOL finished){
                         }];
    }
    // Threads can't access UIKit. Grab text first and make it a block string.
    __block NSString *searchText = [articleSearchBox text];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue,^{
        WikipediaHelper *wikipediaHelper = [[WikipediaHelper alloc] init];
        NSArray *suggestions = [wikipediaHelper getSuggestionsFor:searchText];
        // Execute loading the table on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [suggestionController setSuggestions:suggestions];
        });
    });
}

// either when tapping the black overlay or when exiting the keyboard return everything to normal
- (void)closeSearchField:(UITapGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         [articleSearchBox resignFirstResponder];
                         self.navigationController.navigationBar.alpha = 1.0f;
                         overlay.alpha = 0.0f;
                         searchView.alpha = 0.0f;
                         [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
                     }
                     completion:^(BOOL finished){
                         [searchView setHidden:YES];
                         [overlay removeFromSuperview];
                         [searchUnderlay removeFromSuperview];
                     }];
}

#pragma mark - Button Actions

- (IBAction)showSearchField:(id)sender {
    // darken background
    overlay = [[UIView alloc] initWithFrame:super.view.bounds];
    overlay.backgroundColor = [UIColor blackColor];
    overlay.alpha = 0.0f;
    overlay.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    // touching the overaly closes the search view
    UITapGestureRecognizer *singleFingerTap = 
    [[UITapGestureRecognizer alloc] initWithTarget:self 
                                            action:@selector(closeSearchField:)];
    // Set required taps and number of touches
    [singleFingerTap setNumberOfTapsRequired:1];
    [singleFingerTap setNumberOfTouchesRequired:1];
    [overlay addGestureRecognizer:singleFingerTap];
    [self.view addSubview:overlay];
    // create the view for the search view to close the view when the table is hidden
    searchUnderlay = [[UIView alloc] initWithFrame:searchView.bounds];
    [searchView addSubview:searchUnderlay];
    [searchView sendSubviewToBack:searchUnderlay];
    // we can't reuse the other gesture recognizer. doing that disables it for the the previous view it was in
    UITapGestureRecognizer *anotherSingleFingerTap = 
    [[UITapGestureRecognizer alloc] initWithTarget:self 
                                            action:@selector(closeSearchField:)];
    // Set required taps and number of touches
    [anotherSingleFingerTap setNumberOfTapsRequired:1];
    [anotherSingleFingerTap setNumberOfTouchesRequired:1];
    [searchUnderlay addGestureRecognizer:anotherSingleFingerTap];
    [searchView setAlpha:0.0f];
    [searchView setHidden:NO];
    [self.view bringSubviewToFront:searchView];
    [articleSearchBox becomeFirstResponder];
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         self.navigationController.navigationBar.alpha = 0.5f;
                         overlay.alpha = 0.5f;
                         searchView.alpha = 1.0f;
                         [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
                     }
                     completion:^(BOOL finished){
                     }];
}

- (IBAction)loadArticle:(id)sender {
    if (![loadingThread isExecuting]) {
        loadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadHTMLandParse:) object:[articleSearchBox text]];
        [loadingThread start];
        //[NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[articleSearchBox text]];
        // also save history
        //[self processHistory:[articleSearchBox text]];
        processHistoryThread = [[NSThread alloc] initWithTarget:self selector:@selector(processHistory:) object:[articleSearchBox text]];
        [processHistoryThread start];
    }
}

- (IBAction)pressForward:(id)sender {
    if (![loadingThread isExecuting]) {
        //[articleView goForward];
        historyIndex--;
        HistoryItem *item = [historyArray objectAtIndex:[historyArray count]-historyIndex-1];
        loadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadHTMLandParse:) object:[item title]];
        [loadingThread start];
    }
    //[NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[item title]];
}

- (IBAction)pressBack:(id)sender {
    if (![loadingThread isExecuting]) {
        //[articleView goBack];
        historyIndex++;
        HistoryItem *item = [historyArray objectAtIndex:[historyArray count]-historyIndex-1];
        //loadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadHTMLandParse:) object:[item title]];
        //[loadingThread start];
        [NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[item title]];
    }
    // we definitely don't add to the history
    // we are going back in history
}

- (IBAction)shareArticle:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Mail Link to this Page", @"Mail Link to this Page"), NSLocalizedString(@"Message", @"Message"), NSLocalizedString(@"Tweet", @"Tweet"), nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    [actionSheet showFromRect:[(UIButton*)sender frame] inView:bottomBar animated:YES];
}

- (IBAction)selectArticleFromHistory:(id)sender {
    // lazy loading is a bad idea. we need to prepopulate the view before the user ever uses it
    /*if (_historyController == nil) {
     self.historyController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
     //historyController.delegate = self;
     self.historyControllerPopover = [[UIPopoverController alloc] initWithContentViewController:_historyController];               
     }*/
    //[_historyControllerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [_historyControllerPopover presentPopoverFromRect:[(UIButton*)sender frame] inView:bottomBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [TestFlight passCheckpoint:@"Viewed history"];
    // reload the history each time if iCloud is enabled
    // note that since it's already loaded the user won't notice anything except perhaps the table being reloaded with new history
    //[NSThread detachNewThreadSelector:@selector(loadHistory) toTarget:self withObject:nil];
}

#pragma mark - Sharing

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // get url
    WikipediaHelper *wikiHelper = [[WikipediaHelper alloc] init];
    NSString *articleURLString = [wikiHelper getURLForArticle:self.title];
    NSURL *articleURL = [NSURL URLWithString:articleURLString];
    if (buttonIndex == 0) {
        // share via email
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        [mailController setMailComposeDelegate:self];
        [mailController setSubject:[self title]];
        [mailController setMessageBody:articleURLString isHTML:NO];
        [self presentViewController:mailController animated:YES completion:NULL];
    }
    else if (buttonIndex == 1) {
        // share via messages
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        [messageController setMessageComposeDelegate:self];
        [messageController setBody:articleURLString];
        [self presentViewController:messageController animated:YES completion:NULL];
    }
    else if (buttonIndex == 2) {
        // share via twitter
        TWTweetComposeViewController *tweetController = [[TWTweetComposeViewController alloc] init];
        [tweetController addURL:articleURL];
        [self presentViewController:tweetController animated:YES completion:NULL];
        tweetController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
            
            [self dismissViewControllerAnimated:YES completion:NULL]; // recommended on iOS 5
            
        };
    }
}

// close the mail controller
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// close the message controller
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Main Parsing Method

// main parsing method
- (void)downloadHTMLandParse:(id)object {
    /*NSString *cssPath = [[NSBundle mainBundle] pathForResource:@"beautipedia" 
     ofType:@"css"];
     NSString *js = @"document.getElementsByTagName('link')[0].setAttribute('href','";
     NSString *js2 = [js stringByAppendingString:cssPath];
     NSString *finalJS = [js2 stringByAppendingString:@"');"];
     [articleView stringByEvaluatingJavaScriptFromString:finalJS];*/
    NSLog(@"loaded article %@", (NSString*)object);
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"titlebar"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    /*NSString *urlString = @"http://en.wikipedia.org/wiki/Steve%20Jobs";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"RETURNED:%@",returnString);*/
    WikipediaHelper *wikiHelper = [[WikipediaHelper alloc] init];
    //[wikiHelper setLanguage:]
    NSString *article = [wikiHelper getWikipediaHTMLPage:(NSString*)object];
    NSError *error = [[NSError alloc] init];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:article error:&error];
    // replace styling with our own
    HTMLNode *bodyNode = [parser body];
    
    NSString *appendHead = @"<link href=\"http://vlntno.me/_projects/wiki/style.css\" rel=\"stylesheet\" type=\"text/css\" /><meta name=\"viewport\" content=\"user-scalable=no\"><script type=\"text/javascript\" src=\"jquery-1.7.2.min.js\"></script><script type=\"text/javascript\" src=\"http://vlntno.me/_projects/wiki/wizardry.js\"></script>";
    NSString *newHTML = [NSString stringWithFormat: @"<html><head>%@</head><body>%@</body></html>", appendHead, [bodyNode rawContents]];
    //NSLog(@"new:%@",newHTML);
    // end replace styling
    NSString *path = [[NSBundle mainBundle] bundlePath];
    //NSString *cssPath = [path stringByAppendingPathComponent:@"style.css"]
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    //http://vlntno.me/_projects/wiki/style.css
    /*[articleView
     loadHTMLString:[@"<head><link href=\"http://vlntno.me/_projects/wiki/style.css\" rel=\"stylesheet\" type=\"text/css\" /><meta name=\"viewport\" content=\"user-scalable=no\"></head>" stringByAppendingString:article]
     baseURL:baseURL];*/
    //http://vlntno.me/_projects/wiki/style.css
    /*[articleView
     loadHTMLString:[@"<head><link href=\"http://vlntno.me/_projects/wiki/style.css\" rel=\"stylesheet\" type=\"text/css\" /><meta name=\"viewport\" content=\"user-scalable=no\"></head>" stringByAppendingString:article]
     baseURL:baseURL];*/
    dispatch_async(dispatch_get_main_queue(), ^{
        [articleView loadHTMLString:newHTML baseURL:baseURL];
        //[articleView loadRequest:request];
        //NSString *cssPath = [[NSBundle mainBundle] pathForResource:@"style" 
        //ofType:@"css"];
        /*NSString *js = @"document.getElementsByTagName('link')[0].setAttribute('href','";
        NSString *js2 = [js stringByAppendingString:@"style.css"];
        NSString *finalJS = [js2 stringByAppendingString:@"');"];
        NSString *awesome = [[NSString alloc] initWithFormat:@"window.addEventListener('load', function(e) {"
                             "var theLinks = document.getElementsByTagName('link');"
                             "for(i = 0; i < theLinks.length; i++) {"
                             "    var a = theLinks[i];"
                             "    if(a.rel == 'stylesheet') {"
                             "        a.setAttribute('href','style.css');"
                             "    }"
                             "}"
                             "}, false);"];
        [articleView stringByEvaluatingJavaScriptFromString:awesome];*/
    });
    //NSLog(@"HTML:%@",article);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //HTMLNode *bodyNode = [parser body];
    NSArray *tableOfContentsNode = [bodyNode findChildrenOfClass:@"toc"];
    // reset the tableOfContents before loading a new one
    [tableOfContents removeAllObjects];
    for (HTMLNode *tableOfContent in tableOfContentsNode) {
        NSArray *anchorsToContents = [tableOfContent findChildTags:@"a"];
        for (HTMLNode *anchor in anchorsToContents) {
            TableOfContentsAnchor *anchorItem = [[TableOfContentsAnchor alloc] init];
            // get anchor link that we can use to scroll down the page quick via the sidebar
            NSString *anchorHref = [anchor getAttributeNamed:@"href"];
            [anchorItem setHref:anchorHref];
            NSArray *spanNodes = [anchor findChildTags:@"span"];
            //NSLog(@"spanNodes:%@", [spanNodes description]);
            // search span for toctext/Title of entry in the Title of Contents
            for (HTMLNode *spanNode in spanNodes) {
                if ([[spanNode className] isEqualToString:@"toctext"]) {
                    // title of contents entry
                    NSString *titleOfContentsEntry = [spanNode contents];
                    if (titleOfContentsEntry==NULL) {
                        // if it is not directly inside the span then it's inside an italics tag
                        titleOfContentsEntry = [[spanNode findChildTag:@"i"] contents];
                    }
                    [anchorItem setTitle:titleOfContentsEntry];
                }
            }
            [tableOfContents addObject:anchorItem];
        }
    }
    // add all the to some array of sorts and add it to the sidebar
    //NSLog(@"HTML:%@", article);
    //NSLog(@"TOC: %@", [tableOfContents description]);
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"populateTableOfContents" 
     object:[(NSArray*)tableOfContents copy]];
    // set title of the nav bar to the article name
    [self setTitle:(NSString*)object];
    // if we are on the iPhone then additonally set the custom title view
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        titleLabel.text = (NSString*)object;
        [titleLabel sizeToFit];
    }
    // enable and disable the back and forward buttons here respectively
    // there is history. enable the back button
    NSLog(@"count of HistoryArray:%i", [historyArray count]);
    if ([historyArray count]!=0) {
        // if we have gone too far back in history don't let us go out of the array
        if (historyIndex==[historyArray count]-1) {
            [backButton setEnabled:NO];
        }
        // default to it being enabled. most of the time it will be
        else {
            [backButton setEnabled:YES];
        }
    }
    // if we are on the current page there should be no forward button
    if (historyIndex!=0) {
        [forwardButton setEnabled:YES];
    }
    // else we must be on a previous page. show the forward button
    else {
        [forwardButton setEnabled:NO];
    }
    [TestFlight passCheckpoint:@"Loaded an article"];
}

#pragma mark - iCloud

- (void)loadData:(NSNotification*)notification {
    // load this in a thread because selectors don't work with threads
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue,^{
        NSArray *results = [metadataQuery results];
        
        // NOTE: iCloud loading is really messy
        // reset the iCloud index
        iCloudIndex = 0;
        // reset count for dispatch loader
        iCloudCount = [results count];
        
        // load each item from iCloud
        for (NSMetadataItem *result in results) {
            NSURL *item = [result valueForAttribute:NSMetadataItemURLKey];
            //NSLog(@"item:%@", [item description]);
            NSData *data = [[NSMutableData alloc] initWithContentsOfURL:item];
            NSKeyedUnarchiver *unarchiver;
            @try
            {
                unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            }
            @catch (NSException *exception) {
                NSLog(@"Ignoring incomprehensible data");
            }
            // don't let a NULL get loaded
            if (unarchiver!=NULL) {
                HistoryItem *historyItem = [unarchiver decodeObjectForKey:@"HistoryItem"];
                NSLog(@"history item loaded:%@", [historyItem description]);
                [previousHistoryArray addObject:historyItem];
            }
            else if ([self downloadFileIfNotAvailable:item]) {
                // TODO: keep a count of how many need to be downloaded. only reload when count is full. saves having to reload multiple times
                [self waitForDownloadThenLoad:item];
                iCloudIndex++;
            }
        }
    });
}

- (void)queryDidReceiveNotification:(NSNotification *)notification {
    // load this in a thread because selectors don't work with threads
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue,^{
        NSArray *results = [metadataQuery results];
        
        // NOTE: iCloud loading is really messy
        // reset the iCloud index
        iCloudIndex = 0;
        // reset count for dispatch loader
        iCloudCount = [results count];
        
        for(NSMetadataItem *result in results) {
            if ([self downloadFileIfNotAvailable:[result valueForAttribute:NSMetadataItemURLKey]]) {
                // TODO: keep a count of how many need to be downloaded. only reload when count is full. saves having to reload multiple times
                [self waitForDownloadThenLoad:[result valueForAttribute:NSMetadataItemURLKey]];
                iCloudIndex++;
            }
        }
    });
}

- (BOOL)downloadFileIfNotAvailable:(NSURL*)file {
    NSNumber*  isIniCloud = nil;
    
    if ([file getResourceValue:&isIniCloud forKey:NSURLIsUbiquitousItemKey error:nil]) {
        // If the item is in iCloud, see if it is downloaded.
        if ([isIniCloud boolValue]) {
            NSNumber*  isDownloaded = nil;
            if ([file getResourceValue:&isDownloaded forKey:NSURLUbiquitousItemIsDownloadedKey error:nil]) {
                if ([isDownloaded boolValue])
                    return YES;
                
                // Download the file.
                NSFileManager*  fm = [NSFileManager defaultManager];
                NSError *downloadError = nil;
                [fm startDownloadingUbiquitousItemAtURL:file error:&downloadError];
                if (downloadError) {
                    NSLog(@"Error occurred starting download: %@", downloadError);
                }
                return NO;
            }
        }
    }
    
    // Return YES as long as an explicit download was not started.
    return YES;
}

- (void)waitForDownloadThenLoad:(NSURL *)file {
    NSLog(@"Waiting for file to download...");
    //id<ApplicationDelegate> appDelegate = [DataLoader applicationDelegate];
    while (true) {
        NSDictionary *fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:[file path] error:nil];
        NSNumber *size = [fileAttribs objectForKey:NSFileSize];
        
        [NSThread sleepForTimeInterval:0.1];
        NSNumber*  isDownloading = nil;
        if ([file getResourceValue:&isDownloading forKey:NSURLUbiquitousItemIsDownloadingKey error:nil]) {
            NSLog(@"iCloud download is moving: %d, size is %@", [isDownloading boolValue], size);
        }
        
        NSNumber*  isDownloaded = nil;
        if ([file getResourceValue:&isDownloaded forKey:NSURLUbiquitousItemIsDownloadedKey error:nil]) {
            NSLog(@"iCloud download has finished: %d", [isDownloaded boolValue]);
            if ([isDownloaded boolValue]) {
                [self dispatchLoad:file];
                return;
            }
        }
        
        NSNumber *downloadPercentage = nil;
        if ([file getResourceValue:&downloadPercentage forKey:NSURLUbiquitousItemPercentDownloadedKey error:nil]) {
            double percentage = [downloadPercentage doubleValue];
            NSLog(@"Download percentage is %f", percentage);
            //[appDelegate updateLoadingStatusString:[NSString stringWithFormat:@"Downloading from iCloud (%2.2f%%)", percentage]];
        }
    }
}

- (void)dispatchLoad:(NSURL*)file {
    NSLog(@"File:%@", [file description]);
    NSData *data = [[NSMutableData alloc] initWithContentsOfURL:file];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    // don't let a NULL get loaded
    if (unarchiver!=NULL) {
        HistoryItem *historyItem = [unarchiver decodeObjectForKey:@"HistoryItem"];
        NSLog(@"item:%@", [historyItem title]);
        // if it already exists remove it
        for (int i = 0; i<[previousHistoryArray count]; i++) {
            // wow what a mouthful, checks to see if the object is a duplicate
            if ([[(HistoryItem*)[previousHistoryArray objectAtIndex:i] title] isEqualToString:[historyItem title]]) {
                // was a duplicate, remove it
                [previousHistoryArray removeObjectAtIndex:i];
            }
        }
        [previousHistoryArray addObject:historyItem];
    }
    //iCloudCount++;
    // each time we add an object to the array from iCloud don't reload the table
    // only reload it when the count reaches the index maximum
    NSLog(@"index:%i count:%i", iCloudIndex, iCloudCount);
    if (iCloudIndex==iCloudCount-1) {
        // NOTE: By maintaining a separate array we keep from using the history in iCloud as part of our local session
        NSMutableArray *temporaryArray = [[NSMutableArray alloc] init];
        // append resulting array to the temporary array
        [temporaryArray addObjectsFromArray:[(NSArray*)historyArray copy]];
        // add the previous history to be populated also
        [temporaryArray addObjectsFromArray:[(NSArray*)previousHistoryArray copy]];
        // keep the array sorted by date by newest first
        [temporaryArray sortUsingComparator:^(id a, id b) {
            NSDate *first = [(HistoryItem*)a date];
            NSDate *second = [(HistoryItem*)b date];
            return [second compare:first];
        }];
        // popover controllers only work on the iPad
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"populateHistory"
         object:(NSArray*)temporaryArray];
    }
}

#pragma mark - History Loading and Saving

- (void)loadHistory {
    // start a new array. also doubles as wiping the array when reloading periodically
    previousHistoryArray = [[NSMutableArray alloc] init];
    //NSFileManager*  fm = [NSFileManager defaultManager];
    NSURL *ubiq = [[[NSFileManager defaultManager] 
                   URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
    NSArray *items;
    NSError *error;
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    items = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsDirectory includingPropertiesForKeys:[NSArray array] options:0 error:&error];
    // load each item from iCloud
    for (NSURL *item in items) {
        //NSLog(@"item:%@", [item description]);
        NSData *data = [[NSMutableData alloc] initWithContentsOfURL:item];
        NSKeyedUnarchiver *unarchiver;
        @try
        {
            unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        }
        @catch (NSException *exception) {
            NSLog(@"Ignoring incomprehensible data");
        }
        // don't let a NULL get loaded
        if (unarchiver!=NULL && !ubiq) {
            HistoryItem *historyItem = [unarchiver decodeObjectForKey:@"HistoryItem"];
            //NSLog(@"history item loaded:%@", [historyItem description]);
            [previousHistoryArray addObject:historyItem];
        }
    }
    // sort the objects by date
    [previousHistoryArray sortUsingComparator:^(id a, id b) {
        NSDate *first = [(HistoryItem*)a date];
        NSDate *second = [(HistoryItem*)b date];
        return [second compare:first];
    }];
    // now populate the view with the data we just loaded
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"populateHistory" 
     object:[(NSArray*)previousHistoryArray copy]];
}

- (void)processHistory:(NSString*)title {
    // TODO: Only add to history if the page is a valid article
    // check both history arrays for duplicate and remove it
    for (int i = 0; i<[historyArray count]; i++) {
        // wow what a mouthful, checks to see if the object is a duplicate
        if ([[(HistoryItem*)[historyArray objectAtIndex:i] title] isEqualToString:title]) {
            // was a duplicate, remove it
            [historyArray removeObjectAtIndex:i];
        }
    }
    for (int i = 0; i<[previousHistoryArray count]; i++) {
        // wow what a mouthful, checks to see if the object is a duplicate
        if ([[(HistoryItem*)[previousHistoryArray objectAtIndex:i] title] isEqualToString:title]) {
            // was a duplicate, remove it
            [previousHistoryArray removeObjectAtIndex:i];
        }
    }
    // Adding from local session
    // NOTE: By maintaining a separate array we keep from using the history in iCloud as part of our local session
    NSMutableArray *temporaryArray = [[NSMutableArray alloc] init];
    // add to the array
    HistoryItem *item = [[HistoryItem alloc] init];
    [item setTitle:title];
    [item setDate:[NSDate date]];
    [historyArray addObject:item];
    // append resulting array to the temporary array
    [temporaryArray addObjectsFromArray:[(NSArray*)historyArray copy]];
    // add the previous history to be populated also
    [temporaryArray addObjectsFromArray:[(NSArray*)previousHistoryArray copy]];
    // keep the array sorted by date by newest first
    [temporaryArray sortUsingComparator:^(id a, id b) {
        NSDate *first = [(HistoryItem*)a date];
        NSDate *second = [(HistoryItem*)b date];
        return [second compare:first];
    }];
    // popover controllers only work on the iPad
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"populateHistory" 
     object:(NSArray*)temporaryArray];
    // Save new history item to iCloud
    NSURL *iCloud = [[[NSFileManager defaultManager] 
                     URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
    NSString *file;
    // Save to iCloud if it works.
    if (iCloud) {
        NSLog(@"Saving to iCloud");
        NSString *documentsDirectory = [iCloud relativePath];
        file = [documentsDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@.plist",title]];
    }
    else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        file = [documentsDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@.plist",title]];
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
	[archiver encodeObject:item forKey:@"HistoryItem"];
	[archiver finishEncoding];
	
	[data writeToFile:file atomically:YES];
}

- (void)futureHistoryChopping {
    if (historyIndex!=0) {
        // reset the history index because we are now as forward as we can get
        //historyIndex=0;
        // chop what we don't need any more off the historyArray
        NSLog(@"attempting to get rid of old future history");
        NSLog(@"before: %@", [historyArray description]);
        // remove all the previous future history we don't need anymore
        for (int i = 0; i < historyIndex; i++) {
            NSLog(@"index:%i i:%i", historyIndex, i);
            [historyArray removeLastObject];
        }
        historyIndex=0;
        //[historyArray removeLastObject];
        //historyIndex=0;
        NSLog(@"here are the results from this attempt: %@", [historyArray description]);
    }
}

#pragma mark - UIWebView Management

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    // NOTE: this currently doesn't work for images. What this does is redirects requests to Wikipedia back to the API.
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        // we went back in our history and picked another article instead
        // do we chop off the rest of the forward history?
        [self futureHistoryChopping];
        // could also detect audio files in a similar manner. pronounciation seems to look like this En-us-Barack-Hussein-Obama.ogg
        NSString *searchForMe;
        NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([languageCode isEqualToString:@"en"]) {
            searchForMe = @"File:";
        }
        else if([languageCode isEqualToString:@"ja"]) {
            searchForMe = @"ファイル:";
        }
        NSRange range = [[url lastPathComponent] rangeOfString : searchForMe];
        // make sure we aren't loading an image
        if (range.location == NSNotFound) {
            //if (![loadingThread isExecuting]) {
            // strip underscores from lastPathComponent to make it user readable
            NSString *host = [url host];
            NSLog(@"host:%@", host);
            // work some magic here to ensure that we also have the proper apiURL regardless of locale
            // TODO: Make a instance variable of WikipediaHelper
            WikipediaHelper *wikiHelper = [[WikipediaHelper alloc] init];
            NSString *apiURLString = [wikiHelper apiUrl];
            NSURL *apiURL = [NSURL URLWithString:apiURLString];
            // if we are local, that is we're on wikipedia, do our thing
            if ([host isEqualToString:[apiURL host]]) {
                NSString *removeUnderscores = [[url lastPathComponent] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                [NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:removeUnderscores];
                // also save history
                //[self processHistory:removeUnderscores];
                processHistoryThread = [[NSThread alloc] initWithTarget:self selector:@selector(processHistory:) object:removeUnderscores];
                [processHistoryThread start];
            }
            // otherwise we open the page in Safari because it's external
            else {
                // TODO: also prompt to make sure we want to do this
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        // we found an image. display it
        else {
            [self downloadImageAndView:[url lastPathComponent]];
        }
        return NO;
    }
    else {
        return YES;
    }
    /*NSURL *url = request.URL;
    NSString *s = [url absoluteString];
    // Get the last path component from the URL. This doesn't include
    // any fragment.
    NSString* lastComponent = [url lastPathComponent];
    
    // Find that last component in the string from the end to make sure
    // to get the last one
    NSRange fragmentRange = [s rangeOfString:lastComponent
                                     options:NSBackwardsSearch];
    
    // Chop the fragment.
    NSString* newURLString = [s substringToIndex:fragmentRange.location];
    NSLog(@"url %@", url.absoluteString);
    NSLog(@"newURL %@", newURLString);*/
    //[NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[url lastPathComponent]];
    //NSLog(@"%@",[url lastPathComponent]);
    //NSString *urlString = url.absoluteString;
    //NSLog(urlString);
    //return YES;
}

#pragma mark - Image Viewing

- (void)downloadImageAndView:(id)object {
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"Image attempted:%@", (NSString*)object);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // darken background
        overlay = [[UIView alloc] initWithFrame:super.view.bounds];
        overlay.backgroundColor = [UIColor blackColor];
        overlay.alpha = 0.0f;
        overlay.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [self.view addSubview:overlay];
        [UIView animateWithDuration:0.50
                              delay:0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             self.navigationController.navigationBar.alpha = 0.5f;
                             overlay.alpha = 0.5f;
                         }
                         completion:^(BOOL finished){
                             //nil
                         }];
        // animate progess bar here
        WikipediaHelper *wikiHelper = [[WikipediaHelper alloc] init];
        //NSLog(@"Image url:%@", );
        NSString *imageURL = [wikiHelper getUrlOfImageFile:(NSString*)object];
        NSURL *url = [NSURL URLWithString:imageURL];
        int width = 200;
        int height = 20;
        imageBar = [[UIDownloadBar alloc] initWithURL:url
                                     progressBarFrame:CGRectMake(self.view.frame.size.width / 2 - width/2, self.view.frame.size.height / 2 - height/2, width, height)
                                              timeout:15
                                             delegate:self];
        imageBar.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        //[imageBar forceContinue];
        [self.view addSubview:imageBar];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // additionally pass the image string object to the prepare segue
        [self performSegueWithIdentifier: @"Image" 
                                  sender: object];
    }
    //NSData *data = [NSData dataWithContentsOfURL:url];
    //UIImage *image = [[UIImage alloc] initWithData:data];
    //[[articleView scrollView] setHidden:YES];
    /*[imageView setImage:image];
    [imageView setHidden:NO];
    [scrollView setHidden:NO];
    [self.view bringSubviewToFront:scrollView];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];*/
}

- (void)downloadBar:(UIDownloadBar *)downloadBar didFinishWithData:(NSData *)fileData suggestedFilename:(NSString *)filename {
    if (downloadBar==imageBar) {
        UIImage *image = [[UIImage alloc] initWithData:fileData];
        //[[articleView scrollView] setHidden:YES];
        [downloadBar removeFromSuperview];
        [imageView setImage:image];
        [imageView setHidden:NO];
        [scrollView setHidden:NO];
        [self.view bringSubviewToFront:scrollView];
    }
}

- (void)downloadBar:(UIDownloadBar *)downloadBar didFailWithError:(NSError *)error {
	NSLog(@"%@", error);
}

- (void)downloadBarUpdated:(UIDownloadBar *)downloadBar {}

- (void)closeImage:(NSNotification*)notification {
    // undim and remove the dim overlay so the main view can be active agian
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         self.navigationController.navigationBar.alpha = 1.0f;
                         overlay.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         // after being undimmed we no longer need this
                         [overlay removeFromSuperview];
                     }];
}

/*- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *cssPath = [path stringByAppendingPathComponent:@"style.css"];
    NSString *js = [NSString stringWithFormat:@"var headID = document.getElementsByTagName('head')[0];var cssNode = document.createElement('link');cssNode.type = 'text/css';cssNode.rel = 'stylesheet';cssNode.href = '%@';cssNode.media = 'screen';headID.appendChild(cssNode);", cssPath];
    [webView stringByEvaluatingJavaScriptFromString:js];
}*/

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

#pragma mark - Keyboard Stuff

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    /*NSLog(@"bottom bar: %@", NSStringFromCGRect([bottomBar frame]));
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         if(orientation == 0) {
                             //Default orientation
                         } 
                         //UI is in Default (Portrait) -- this is really a just a failsafe. 
                         else if(orientation == UIInterfaceOrientationPortrait) {
                             //Do something if the orientation is in Portrait
                             [bottomBar setFrame: CGRectMake(0, 910-263, 768, 50)];
                         }
                         else if(orientation == UIInterfaceOrientationPortraitUpsideDown) {
                             [bottomBar setFrame: CGRectMake(0, 910-263, 768, 50)];
                         }
                         else if(orientation == UIInterfaceOrientationLandscapeLeft) {
                             // Do something if Left
                             [bottomBar setFrame: CGRectMake(0, 654-352, 703, 50)];
                         }
                         else if(orientation == UIInterfaceOrientationLandscapeRight) {
                             //Do something if right
                             [bottomBar setFrame: CGRectMake(0, 654-352, 703, 50)];
                         }
                     }
                     completion:^(BOOL finished){
                         //nil
                     }];
    }*/
    
    //... do something
}

- (void)keyboardWasHidden:(NSNotification*)aNotification
{
    //[self closeSearchField:nil];
    /*NSLog(@"bottom bar: %@", NSStringFromCGRect([bottomBar frame]));
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [UIView animateWithDuration:0.50 
                          delay:0 
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         if(orientation == 0) {
                             //Default orientation
                         } 
                         //UI is in Default (Portrait) -- this is really a just a failsafe. 
                         else if(orientation == UIInterfaceOrientationPortrait) {
                             //Do something if the orientation is in Portrait
                             [bottomBar setFrame: CGRectMake(0, 910, 768, 50)];
                         }
                         else if(orientation == UIInterfaceOrientationPortraitUpsideDown) {
                             [bottomBar setFrame: CGRectMake(0, 910, 768, 50)];
                         }
                         else if(orientation == UIInterfaceOrientationLandscapeLeft) {
                             // Do something if Left
                             [bottomBar setFrame: CGRectMake(0, 654, 703, 50)];
                         }
                         else if(orientation == UIInterfaceOrientationLandscapeRight) {
                             //Do something if right
                             [bottomBar setFrame: CGRectMake(0, 654, 703, 50)];
                         }
                     }
                     completion:^(BOOL finished){
                         //nil
                     }];
    }*/
    
    //... do something
}

#pragma mark - Important for image viewing

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

#pragma mark - Setup the View

// this has precedence over view did load. before the view is loaded
- (void)awakeFromNib {
    // set tint color of all UIBarButtons to gray
    [[UIBarButtonItem appearance] setTintColor:[UIColor grayColor]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    
    // tell the reachability that we DO want to be reachable on 3G/EDGE/CDMA
    reach.reachableOnWWAN = YES;
    
    // here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    [reach startNotifier];
    //NSURL *ubiq = [[NSFileManager defaultManager] 
    //               URLForUbiquityContainerIdentifier:nil];
    /*if (ubiq) {
        NSLog(@"iCloud access at %@", ubiq);
        NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:ubiq includingPropertiesForKeys:nil options:nil error:nil];
        // load each item from iCloud
        for (NSURL *item in items) {
            
        }
        // TODO: Load document... 
    } else {
        // USER IS AN IDIOT. Demote them to local file usage.
        NSLog(@"No iCloud access");
    }*/
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    self.title = NSLocalizedString(@"Article", @"Article");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //articleSearchBox.inputAccessoryView = bottomBar;
        //self.navigationItem.leftBarButtonItem.tintColor = [UIColor grayColor];
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Contents", @"Contents");
        // this will appear as the title in the navigation bar
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0,1);
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor darkGrayColor]; // change this color
        self.navigationItem.titleView = titleLabel;
        titleLabel.text = NSLocalizedString(@"Article", @"");
        [titleLabel sizeToFit];
    }
    UIImage *image = [UIImage imageNamed:@"topbar.png"];
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    // listen for these notifications
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(keyboardWasShown:)
                          name:UIKeyboardDidShowNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardWasHidden:)
                          name:UIKeyboardDidHideNotification object:nil];
    // allow us to know when the app comes back from the foreground
    [defaultCenter addObserver:self selector:@selector(becomeActive:)
                          name:UIApplicationWillEnterForegroundNotification object:nil];
    // remove dimming after image has been closed
    [defaultCenter addObserver:self selector:@selector(closeImage:) 
                          name:@"closeImage" object:nil];
    // notifications for loading new pages and opening anchors
    [defaultCenter addObserver:self selector:@selector(gotoAnchor:)
                          name:@"gotoAnchor" object:nil];
    [defaultCenter addObserver:self selector:@selector(gotoArticle:)
                          name:@"gotoArticle" object:nil];
    // notifications for the suggestion controller
    [defaultCenter addObserver:self selector:@selector(closeSearchField:)
                          name:@"closeSearchView" object:nil];
    [defaultCenter addObserver:articleSearchBox selector:@selector(resignFirstResponder) 
                          name:@"resignSearchField" object:nil];
    // must prepare history engine first
    previousHistoryArray = [[NSMutableArray alloc] init];
    historyArray = [[NSMutableArray alloc] init];
    historyIndex = 0;
    // UIPopoverController only exists on the iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // allows us to prepopulate the view otherwise nsnotifications are going nowhere
        self.historyController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
        self.historyControllerPopover = [[UIPopoverController alloc] initWithContentViewController:_historyController];
    }
    NSURL *ubiq = [[[NSFileManager defaultManager] 
                    URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
    if (ubiq) {
        // watch iCloud folder
        metadataQuery = [[NSMetadataQuery alloc] init];
        [defaultCenter addObserver:self selector:@selector(queryDidReceiveNotification:) 
                              name:NSMetadataQueryDidUpdateNotification object:metadataQuery];
        [defaultCenter addObserver:self selector:@selector(loadData:) 
                              name:NSMetadataQueryDidFinishGatheringNotification object:metadataQuery];
        [metadataQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE '*'", NSMetadataItemFSNameKey]];
        [metadataQuery setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
        if ([metadataQuery startQuery]) {
            NSLog(@"Query started successfully");
        } else {
            NSLog(@"Query failed");
        }
    } else {
        [NSThread detachNewThreadSelector:@selector(loadHistory) toTarget:self withObject:nil];
    }
    //[articleSearchBox setInputAccessoryView:bottomBar];
    // transparent bottom bar image
    bottomBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottombar.png"]];
    searchView.backgroundColor = [UIColor clearColor];
    //articleView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen_bg@2x.png"]];
    [searchView.layer setOpaque:NO];
    [bottomBar.layer setOpaque:NO];
    bottomBar.opaque = NO;
    tableOfContents = [[NSMutableArray alloc] init];
    // make the image viewer work
    [scrollView setDelegate:self];
    [scrollView setClipsToBounds:YES];
    scrollView.minimumZoomScale = 1.0f;
    scrollView.maximumZoomScale = 2.0f;
    // set suggestion table view to be rounded
    suggestionTableView.layer.cornerRadius = 10;
    // wire the suggestions to the search box
    [articleSearchBox addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    // setup the suggestion controller
    suggestionController = [[SuggestionController alloc] init];
    [suggestionController setSuggestionTableView:suggestionTableView];
    [suggestionTableView setDataSource:suggestionController];
    [suggestionTableView setDelegate:suggestionController];
    //[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(reloadiCloud) userInfo:nil repeats:YES];
    GettingStartedViewController *gettingStartedViewController = [[GettingStartedViewController alloc] init];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:gettingStartedViewController];
        [self presentModalViewController:navigationController animated:YES];
    }
    else
    {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:gettingStartedViewController];
        [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
        [[self splitViewController] presentModalViewController:navigationController animated:YES];
    }
}

#pragma mark - Responds to Notifications

- (void)reachabilityChanged:(NSNotification*)notification {
    // internet is not available
    // show the internet not available page
    // alternatively, we could automatically open the offline reading dialog under this circumstance
    Reachability * reach = [notification object];
    
    if([reach isReachable]) {
        // all is good
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Internet is not available." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)becomeActive:(NSNotification*)object {
    // reload history if iCloud is active
    //[self loadHistory];
    //[NSThread detachNewThreadSelector:@selector(loadHistory) toTarget:self withObject:nil];
}

- (void)gotoAnchor:(NSNotification*)notification {
    // for jumping to an anchor
    // [webview stringByEvaluatingJavaScriptFromString:@"window.location.hash = '2002'"];
    TableOfContentsAnchor *anchor = [notification object];
    [articleView stringByEvaluatingJavaScriptFromString:[[NSString alloc] initWithFormat:@"window.location.hash = '%@'",[anchor href]]];
}

- (void)gotoArticle:(NSNotification*)notification {
    // jump straight to load a new article
    // likely to be used from the history
    [NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:(NSString*)[notification object]];
    // rewrite history
    //[self processHistory:(NSString*)[notification object]];
    processHistoryThread = [[NSThread alloc] initWithTarget:self selector:@selector(processHistory:) object:(NSString*)[notification object]];
    [processHistoryThread start];
    // dismiss the popover for the history controller if it is visible
    if ([_historyControllerPopover isPopoverVisible]) {
        [_historyControllerPopover dismissPopoverAnimated:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    // TODO: Set the Contents button image here
    barButtonItem.title = NSLocalizedString(@"Contents", @"Contents");
    barButtonItem.tintColor = [UIColor grayColor];
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"History"])
	{
        NSMutableArray *temporaryArray = [[NSMutableArray alloc] init];
        // append resulting array to the temporary array
        [temporaryArray addObjectsFromArray:[(NSArray*)historyArray copy]];
        // add the previous history to be populated also
        [temporaryArray addObjectsFromArray:[(NSArray*)previousHistoryArray copy]];
        // keep the array sorted by date by newest first
        [temporaryArray sortUsingComparator:^(id a, id b) {
            NSDate *first = [(HistoryItem*)a date];
            NSDate *second = [(HistoryItem*)b date];
            return [second compare:first];
        }];
        NSLog(@"temporary count of things:%i",[temporaryArray count]);
        HistoryViewController *historyViewController = segue.destinationViewController;
        NSNotification *notification = [NSNotification notificationWithName:@"History" object:temporaryArray];
        [historyViewController populateHistory:notification];
	}
    else if ([segue.identifier isEqualToString:@"Contents"])
	{
		MasterViewController *masterViewController = segue.destinationViewController;
        NSLog(@"actual contents:%@", [tableOfContents description]);
        NSLog(@"contents:%i", [tableOfContents count]);
        NSNotification *notification = [NSNotification notificationWithName:@"Contents" object:tableOfContents];
        [masterViewController populateTableOfContents:notification];
	}
    else if ([segue.identifier isEqualToString:@"Image"])
    {
        ImageViewController *imageViewController = segue.destinationViewController;
        [imageViewController imageLoadWithName:(NSString*)sender];
    }
}

@end
