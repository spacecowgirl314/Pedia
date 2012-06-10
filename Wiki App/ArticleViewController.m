//
//  ArticleViewController.m
//  Wiki App
//
//  Created by Chloe Stars on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArticleViewController.h"
#import "HTMLParser.h"
#import "HistoryItem.h"
#import "AppDelegate.h"
#import "UINavigationBar+DropShadow.h"


#define NSLog TFLog

@interface ArticleViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation ArticleViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize historyViewController = _historyViewController;
@synthesize historyViewControllerPopover = _historyViewControllerPopover;
@synthesize archivedViewController = _archivedViewController;
@synthesize archivedViewControllerPopover = _archivedViewControllerPopover;
@synthesize bottomBar;
@synthesize articleSearchBox;
@synthesize articleView;
@synthesize backgroundView;
@synthesize historyArray;
@synthesize previousHistoryArray;
@synthesize titleLabel;
@synthesize tableOfContents;
@synthesize managedObjectContext=managedObjectContext__;

#pragma mark - Search Field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == articleSearchBox) {
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
                         self.navigationController.navigationBar.alpha = 0.3f;
                         overlay.alpha = 0.7f;
                         searchView.alpha = 1.0f;
                         [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
                     }
                     completion:^(BOOL finished){
                     }];
}

- (IBAction)toggleDebugging:(id)sender {
    // shortest way to toggle something!
    isDebugging = isDebugging ? NO : YES;
    NSLog(@"ArticleViewController isDebugging: %i", isDebugging);
}

- (IBAction)selectArticleFromSaved:(id)sender {
    [_archivedViewControllerPopover presentPopoverFromRect:[(UIButton*)sender frame] inView:bottomBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    [_historyViewControllerPopover presentPopoverFromRect:[(UIButton*)sender frame] inView:bottomBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [TestFlight passCheckpoint:@"Viewed history"];
    // reload the history each time if iCloud is enabled
    // note that since it's already loaded the user won't notice anything except perhaps the table being reloaded with new history
    //[NSThread detachNewThreadSelector:@selector(loadHistory) toTarget:self withObject:nil];
}

#pragma mark - Sharing

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // get url
    NSString *articleURLString = [wikipediaHelper getURLForArticle:self.title];
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
    //NSLog(@"ArticleViewController loaded article %@", (NSString*)object);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *article;
    // if the object type is ArchivedArticle then we are loading from an archive
    if ([object isKindOfClass:[ArchivedArticle class]]) {
        article = (NSString*)[(ArchivedArticle*)object data];
    }
    else {
        // if there is no internet don't do jack ignore the request and politely tell the user it's not possible
        if (![reachability isReachable]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Internet is not available." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        article = [wikipediaHelper getWikipediaHTMLPage:(NSString*)object];
    }
    NSError *error = [[NSError alloc] init];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:article error:&error];
    // replace styling with our own
    HTMLNode *bodyNode = [parser body];
    
    // replace styling
    NSString *appendHead;
    //isDebugging = YES;
    if (!isDebugging) {
        appendHead = @"<link href=\"style.css\" rel=\"stylesheet\" type=\"text/css\" /><meta name=\"viewport\" content=\"user-scalable=no\"><script type=\"text/javascript\" src=\"jquery-1.7.2.min.js\"></script><script type=\"text/javascript\" src=\"wizardry.js\"></script>";
    }
    else {
        appendHead = @"<link href=\"http://vlntno.me/_projects/wiki/style.css\" rel=\"stylesheet\" type=\"text/css\" /><meta name=\"viewport\" content=\"user-scalable=no\"><script type=\"text/javascript\" src=\"jquery-1.7.2.min.js\"></script><script type=\"text/javascript\" src=\"http://vlntno.me/_projects/wiki/wizardry.js\"></script>";
    }
    NSString *newHTML = [NSString stringWithFormat: @"<html><head>%@</head><body style=\"background-color: transparent !important;\">", appendHead];
    // only retreive what's in the body
    for (HTMLNode *node in [bodyNode children]) {
        newHTML = [newHTML stringByAppendingString:[node rawContents]];
    }
    newHTML = [newHTML stringByAppendingString:@"<span class=\"attribution\">The article above is based on this article of the free encyclopedia Wikipedia and it is licensed under &ldquo;Creative Commons Attribution/Share Alike&rdquo;.</span></body></html>"];
    //NSLog(@"ArticleViewController new HTML:%@",newHTML);
    // end replace styling
    NSString *path = [[NSBundle mainBundle] bundlePath];
    //NSString *cssPath = [path stringByAppendingPathComponent:@"style.css"]
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    //http://vlntno.me/_projects/wiki/style.css
    //http://vlntno.me/_projects/wiki/wizardry.js
    dispatch_async(dispatch_get_main_queue(), ^{
        [articleView loadHTMLString:newHTML baseURL:baseURL];
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
    // pull the article name out of the archived article
    if ([object isKindOfClass:[ArchivedArticle class]]) {
        [self setTitle:[(ArchivedArticle*)object title]];
    }
    // set title of the nav bar to the article name
    else {
        [self setTitle:(NSString*)object];
    }
    // if we are on the iPhone then additonally set the custom title view
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([object isKindOfClass:[ArchivedArticle class]]) {
            titleLabel.text = [(ArchivedArticle*)object title];
            [titleLabel sizeToFit];
        }
        else {
            titleLabel.text = (NSString*)object;
            [titleLabel sizeToFit];
        }
    }
    [self checkToEnableButtons];
    [TestFlight passCheckpoint:@"Loaded an article"];
}

#pragma mark - History Loading and Saving

- (void)checkToEnableButtons {
    // enable and disable the back and forward buttons here respectively
    // there is history. enable the back button
    NSLog(@"ArticleViewController count of HistoryArray:%i", [historyArray count]);
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
}

- (void)processHistory:(NSString*)title {
    // if there is no internet don't record any history
    if (![reachability isReachable]) {
        return;
    }
    // TODO: Only add to history if the page is a valid article
    // Adding from local session
    // NOTE: By maintaining a separate array we keep from using the history in iCloud as part of our local session
    NSMutableArray *temporaryArray = [[NSMutableArray alloc] init];
    // add to the array
    HistoryItemLocal *item = [[HistoryItemLocal alloc] init];
    item.title = title;
    item.date = [NSDate date];
    [historyArray addObject:item];
    
    // Retrieve possible duplicate and change date instead of creating new one.
    // Retrieve the entity from the local store -- much like a table in a database
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HistoryItem" inManagedObjectContext:managedObjectContext__];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    // Set the predicate -- much like a WHERE statement in a SQL database
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", title];
    [request setPredicate:predicate];
    
    // Set the sorting -- mandatory, even if you're fetching a single record/object
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Request the data -- NOTE, this assumes only one match, that 
    // yourIdentifyingQualifier is unique. It just grabs the first object in the array. 
    NSError *otherError = nil;
    @try {
        HistoryItem *matchingItem = [[managedObjectContext__ executeFetchRequest:request error:&otherError] objectAtIndex:0];
        // if matched just update date. don't create new entry
        if ([matchingItem.title isEqualToString:title]) {
            [matchingItem setDate:[NSDate date]];
        }
    }
    @catch (NSException *exception) {
        // not matched create new
        HistoryItem *historyEntry = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryItem" inManagedObjectContext:[self managedObjectContext]];
        
        [historyEntry setTitle:title];
        [historyEntry setDate:[NSDate date]];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        // TODO: Do something better than just aborting.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // add the previous history to be populated also
    [temporaryArray addObjectsFromArray:[(NSArray*)previousHistoryArray copy]];
    // keep the array sorted by date by newest first
    [temporaryArray sortUsingComparator:^(id a, id b) {
        NSDate *first = [(HistoryItemLocal*)a date];
        NSDate *second = [(HistoryItemLocal*)b date];
        return [second compare:first];
    }];
}

- (void)futureHistoryChopping {
    if (historyIndex!=0) {
        // reset the history index because we are now as forward as we can get
        //historyIndex=0;
        // chop what we don't need any more off the historyArray
        NSLog(@"ArticleViewController is attempting to get rid of old future history.");
        NSLog(@"ArticleViewController before: %@", [historyArray description]);
        // remove all the previous future history we don't need anymore
        for (int i = 0; i < historyIndex; i++) {
            NSLog(@"ArticleViewController index:%i i:%i", historyIndex, i);
            [historyArray removeLastObject];
        }
        historyIndex=0;
        //[historyArray removeLastObject];
        //historyIndex=0;
        NSLog(@"ArticleViewController here are the results from this attempt: %@", [historyArray description]);
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
            NSLog(@"ArticleViewController host:%@", host);
            // work some magic here to ensure that we also have the proper apiURL regardless of locale
            // TODO: Make a instance variable of WikipediaHelper
            NSString *apiURLString = [wikipediaHelper apiUrl];
            NSURL *apiURL = [NSURL URLWithString:apiURLString];
            // if we are local, that is we're on wikipedia, do our thing. allow archived articles to load if file url
            if ([host isEqualToString:[apiURL host]] || [url isFileURL]) {
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
}

/*
 UIWebView *webView;
 float offset = webView.scrollView.contentOffset.y;
 */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    // make sure scroll view is articleView.
    // we need to make sure of this because we are the delegate to two UIScrollViews
    if (scrollView_==articleView.scrollView) {
        //NSLog(@"ArticleViewController scrolling UIWebView");
        //The webview is is scrolling
        float offset = articleView.scrollView.contentOffset.y;
        NSLog(@"ArticleViewController offset.y:%f", offset);
        if (offset<=0) {
            // add shadow to navigation top bar
            NSLog(@"ArticleViewController scroll at top");
            [self.navigationController.navigationBar removeDropShadow];
        }
        else {
            [self.navigationController.navigationBar applyDropShadow];
        }
    }
}

#pragma mark - Image Viewing

- (void)downloadImageAndView:(id)object {
    // if there is no internet don't allow us to view images
    if (![reachability isReachable]) {
        return;
    }
    // make sure action sheet won't work yet
    imageIsDownloaded = NO;
    NSLog(@"ArticleViewController image attempted:%@", (NSString*)object);
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
                             self.navigationController.navigationBar.alpha = 0.3f;
                             overlay.alpha = 0.7f;
                         }
                         completion:^(BOOL finished){
                             //nil
                         }];
        // animate progess bar here
        NSString *imageURL = [wikipediaHelper getUrlOfImageFile:(NSString*)object];
        NSURL *url = [NSURL URLWithString:imageURL];
        int width = 200;
        int height = 20;
        imageBar = [[UIDownloadBar alloc] initWithURL:url
                                     progressBarFrame:CGRectMake(self.view.frame.size.width / 2 - width/2, self.view.frame.size.height / 2 - height/2, width, height)
                                              timeout:15
                                             delegate:self];
        imageBar.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        [self.view addSubview:imageBar];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // additionally pass the image string object to the prepare segue
        [self performSegueWithIdentifier: @"Image" 
                                  sender: object];
    }
}

- (void)downloadBar:(UIDownloadBar *)downloadBar didFinishWithData:(NSData *)fileData suggestedFilename:(NSString *)filename {
    if (downloadBar==imageBar) {
        // enable the action sheet to work
        imageIsDownloaded = YES;
        UIImage *image = [[UIImage alloc] initWithData:fileData];
        [downloadBar removeFromSuperview];
        [imageView setImage:image];
        [imageView setHidden:NO];
        [scrollView setHidden:NO];
        [self.view bringSubviewToFront:scrollView];
    }
}

- (void)downloadBar:(UIDownloadBar *)downloadBar didFailWithError:(NSError *)error {
    if (error) {
        NSLog(@"ArticleViewController downloadBar error:%@", error);
    }
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

#pragma mark - Important for image viewing

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

- (BOOL)isFinishedDownloading {
    return imageIsDownloaded;
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
    // initialize the wikipedia helper
    wikipediaHelper = [[WikipediaHelper alloc] init];
    
    // load welcome page
    [articleView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"html"]isDirectory:NO]]];

    // remove shadows in UIWebView
    for(UIScrollView* webScrollView in [self.articleView subviews]) {
        if ([webScrollView isKindOfClass:[UIScrollView class]]) {
            for(UIView* subview in [webScrollView subviews]) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    ((UIImageView*)subview).image = nil;
                    subview.backgroundColor = [UIColor clearColor];
                }
            }
        }
    }
    
    // allocate a reachability object
    reachability = [Reachability reachabilityWithHostname:@"www.apple.com"];
    
    // tell the reachability that we DO want to be reachable on 3G/EDGE/CDMA
    reachability.reachableOnWWAN = YES;
    
    // here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    [reachability startNotifier];
    
    // setup core data for saving
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setManagedObjectContext:[app managedObjectContext]];
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
        // recognize tap to close search when hitting the label
        UITapGestureRecognizer *navigationSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSearchField:)];
        navigationSingleTap.numberOfTapsRequired = 1;
        [titleLabel setUserInteractionEnabled:YES];
        [titleLabel addGestureRecognizer:navigationSingleTap];
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
    // remove dimming after image has been closed
    [defaultCenter addObserver:self selector:@selector(closeImage:) 
                          name:@"closeImage" object:nil];
    // notifications for loading new pages and opening anchors
    [defaultCenter addObserver:self selector:@selector(gotoAnchor:)
                          name:@"gotoAnchor" object:nil];
    [defaultCenter addObserver:self selector:@selector(gotoArticle:)
                          name:@"gotoArticle" object:nil];
    [defaultCenter addObserver:self selector:@selector(gotoArchivedArticle:)
                          name:@"gotoArchivedArticle" object:nil];
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
        self.historyViewController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
        self.historyViewControllerPopover = [[UIPopoverController alloc] initWithContentViewController:_historyViewController];
        self.archivedViewController = [[ArchivedViewController alloc] init];
        self.archivedViewControllerPopover = [[UIPopoverController alloc] initWithContentViewController:_archivedViewController];
        self.archivedViewController.delegate = self;
    }
    // transparent bottom bar image
    bottomBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottombar.png"]];
    searchView.backgroundColor = [UIColor clearColor];
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    articleView.backgroundColor = [UIColor clearColor];
    articleView.opaque = NO;
    [searchView.layer setOpaque:NO];
    [bottomBar.layer setOpaque:NO];
    bottomBar.opaque = NO;
    tableOfContents = [[NSMutableArray alloc] init];
    // allows the shadow to the top bar to work
    //articleView.scrollView.delegate = self;
    // make the image viewer work
    [scrollView setDelegate:self];
    [scrollView setImageScrollViewDelegate:self];
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
    // Only run the Getting Started Once
    // ![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstRun"]
    if (NO) {
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Responds to Notifications

- (void)reachabilityChanged:(NSNotification*)notification {
    // internet is not available
    // show the internet not available page
    // alternatively, we could automatically open the offline reading dialog under this circumstance
    Reachability * reach = [notification object];
    
    if([reach isReachable]) {
        // run the regular check to see if the buttons should be enabled
        [self checkToEnableButtons];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Internet is not available." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        // disable history browsing because there is no internet
        [forwardButton setEnabled:NO];
        [backButton setEnabled:NO];
    }
}

- (void)gotoAnchor:(NSNotification*)notification {
    // for jumping to an anchor
    TableOfContentsAnchor *anchor = [notification object];
    [articleView stringByEvaluatingJavaScriptFromString:[[NSString alloc] initWithFormat:@"window.location.hash = '%@'",[anchor href]]];
}

- (void)gotoArticle:(NSNotification*)notification {
    // jump straight to load a new article
    // likely to be used from the history
    [NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:(NSString*)[notification object]];
    // write history
    processHistoryThread = [[NSThread alloc] initWithTarget:self selector:@selector(processHistory:) object:(NSString*)[notification object]];
    [processHistoryThread start];
    // dismiss the popover for the history controller if it is visible
    if ([_historyViewControllerPopover isPopoverVisible]) {
        [_historyViewControllerPopover dismissPopoverAnimated:YES];
    }
}

- (void)gotoArchivedArticle:(NSNotification*)notification {
    // pass the main parser the archived article
    [NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:(ArchivedArticle*)[notification object]];
    // write history
    processHistoryThread = [[NSThread alloc] initWithTarget:self selector:@selector(processHistory:) object:[(ArchivedArticle*)[notification object] title]];
    [processHistoryThread start];
    // dismiss the popover for the history controller if it is visible
    if ([_archivedViewControllerPopover isPopoverVisible]) {
        [_archivedViewControllerPopover dismissPopoverAnimated:YES];
    }
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
        // do nothing
	}
    else if ([segue.identifier isEqualToString:@"Contents"])
	{
		MasterViewController *masterViewController = segue.destinationViewController;
        NSLog(@"ArticleViewController actual contents:%@", [tableOfContents description]);
        NSLog(@"ArticleViewController contents:%i", [tableOfContents count]);
        NSNotification *notification = [NSNotification notificationWithName:@"Contents" object:tableOfContents];
        [masterViewController populateTableOfContents:notification];
	}
    else if ([segue.identifier isEqualToString:@"Archived"])
    {
        // grabbing the view controller and setting it's delegate to self allows it to grab the article title
        ArchivedViewController *archivedViewController = segue.destinationViewController;
        archivedViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"Image"])
    {
        ImageViewController *imageViewController = segue.destinationViewController;
        [imageViewController imageLoadWithName:(NSString*)sender];
    }
    // remove shadow from the navigation bar when segueing
    //[self.navigationController.navigationBar removeDropShadow];
}

#pragma mark - ArticleViewController Delegate -

- (NSString*)didBeginArchivingArticle {
    return self.title;
}

#pragma mark -

@end
