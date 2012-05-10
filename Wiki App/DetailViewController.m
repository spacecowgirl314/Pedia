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
            loadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadHTMLandParse:) object:[articleSearchBox text]];
            // done with the keyboard. hide it
            [articleSearchBox resignFirstResponder];
            [loadingThread start];
            // also save history
            [self processHistory:[articleSearchBox text]];
        }
    }
    return YES;
}

- (IBAction)showSearchField:(id)sender {
    // darken background
    overlay = [[UIView alloc] initWithFrame:super.view.bounds];
    overlay.backgroundColor = [UIColor blackColor];
    overlay.alpha = 0.0f;
    overlay.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:overlay];
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
                     }
                     completion:^(BOOL finished){
                         // nothing to see here
                         UITapGestureRecognizer *singleFingerTap = 
                         [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                 action:@selector(closeSearchField:)];
                         [overlay addGestureRecognizer:singleFingerTap];
                     }];
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
                     }
                     completion:^(BOOL finished){
                         [searchView setHidden:YES];
                         [overlay removeFromSuperview];
                     }];
}

- (IBAction)loadArticle:(id)sender {
    if (![loadingThread isExecuting]) {
        loadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadHTMLandParse:) object:[articleSearchBox text]];
        [loadingThread start];
        //[NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[articleSearchBox text]];
        // also save history
        [self processHistory:[articleSearchBox text]];
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
        loadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadHTMLandParse:) object:[item title]];
        [loadingThread start];
    }
    //[NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[item title]];
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
}

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

// main parsing method
- (void)downloadHTMLandParse:(id)object {
    NSLog(@"loaded article %@", (NSString*)object);
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"titlebar"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    WikipediaHelper *wikiHelper = [[WikipediaHelper alloc] init];
    //[wikiHelper setLanguage:]
    NSString *article = [wikiHelper getWikipediaHTMLPage:(NSString*)object];
    NSError *error = [[NSError alloc] init];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:article error:&error];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    //NSString *cssPath = [path stringByAppendingPathComponent:@"style.css"]
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    //http://vlntno.me/_projects/wiki/style.css
    [articleView
     loadHTMLString:[@"<head><link href=\"style.css\" rel=\"stylesheet\" type=\"text/css\" /><meta name=\"viewport\" content=\"user-scalable=no\"></head>" stringByAppendingString:article]
     baseURL:baseURL];
    NSLog(@"HTML:%@",article);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    HTMLNode *bodyNode = [parser body];
    NSArray *tableOfContentsNode = [bodyNode findChildrenOfClass:@"toc"];
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
    [tableOfContents removeAllObjects];
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

#pragma mark - History Loading and Saving

- (void)loadHistory {
    // start a new array. also doubles as wiping the array when reloading periodically
    previousHistoryArray = [[NSMutableArray alloc] init];
    //NSFileManager*  fm = [NSFileManager defaultManager];
    NSURL *ubiq = [[NSFileManager defaultManager] 
                   URLForUbiquityContainerIdentifier:nil];
    NSArray *items;
    NSError *error;
    // iCloud is enabled. Use it
    if (ubiq) {
        NSLog(@"iCloud access at %@", ubiq);
        items = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:ubiq includingPropertiesForKeys:[NSArray array] options:0 error:&error];
        metadataQuery = [[NSMetadataQuery alloc] init];
        [metadataQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE '*'", NSMetadataItemFSNameKey]];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(queryDidReceiveNotification:) 
                                                     name:NSMetadataQueryDidUpdateNotification 
                                                   object:metadataQuery];
        [metadataQuery startQuery];
    }
    else {
        NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        items = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsDirectory includingPropertiesForKeys:[NSArray array] options:0 error:&error];
    }
    // load each item from iCloud
    for (NSURL *item in items) {
        //NSLog(@"item:%@", [item description]);
        NSData *data = [[NSMutableData alloc] initWithContentsOfURL:item];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        // don't let a NULL get loaded
        if (unarchiver!=NULL) {
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

- (void)queryDidReceiveNotification:(NSNotification *)notification {
    NSArray *results = [metadataQuery results];
    
    for(NSMetadataItem *item in results) {
        NSString *filename = [item valueForAttribute:NSMetadataItemDisplayNameKey];
        NSNumber *filesize = [item valueForAttribute:NSMetadataItemFSSizeKey]; 
        NSDate *updated = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        NSLog(@"%@ (%@ bytes, updated %@)", filename, filesize, updated);
    }
}

- (void)processHistory:(NSString*)title {
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
    NSURL *iCloud = [[NSFileManager defaultManager] 
                     URLForUbiquityContainerIdentifier:nil];
    NSString *file;
    // Save to iCloud if it works.
    if (iCloud) {
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
            NSString *removeUnderscores = [[url lastPathComponent] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
            [NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:removeUnderscores];
            // also save history
            [self processHistory:removeUnderscores];
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

- (void)downloadImageAndView:(id)object {
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"Image attempted:%@", (NSString*)object);
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
    [self closeSearchField:nil];
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

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
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
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor grayColor];
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Contents", @"Contents");
        // this will appear as the title in the navigation bar
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor grayColor]; // change this color
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
    //[articleSearchBox setInputAccessoryView:bottomBar];
    // transparent bottom bar image
    bottomBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottombar.png"]];
    searchView.backgroundColor = [UIColor clearColor];
    articleView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen_bg@2x.png"]];
    [searchView.layer setOpaque:NO];
    [bottomBar.layer setOpaque:NO];
    bottomBar.opaque = NO;
    tableOfContents = [[NSMutableArray alloc] init];
    historyArray = [[NSMutableArray alloc] init];
    // UIPopoverController only exists on the iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // allows us to prepopulate the view otherwise nsnotifications are going nowhere
        self.historyController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
        self.historyControllerPopover = [[UIPopoverController alloc] initWithContentViewController:_historyController];
        // Load history from previous sessions. Also from sessions on other devices via iCloud.
        [self loadHistory];
        historyIndex = 0;
    }
    // make the image viewer work
    [scrollView setDelegate:self];
    [scrollView setClipsToBounds:YES];
    scrollView.minimumZoomScale = 1.0f;
    scrollView.maximumZoomScale = 2.0f;
}

- (void)becomeActive:(NSNotification*)object {
    // reload history if iCloud is active
    [self loadHistory];
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
    [self processHistory:(NSString*)[notification object]];
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
		//HistoryViewController *historyViewController = segue.destinationViewController;
        //[historyViewController viewDidLoad];
        // Load history from previous sessions. Also from sessions on other devices via iCloud.
        //[self loadHistory];
        //historyIndex = 0;
		//historyViewController.delegate = self;
	}
}

@end
