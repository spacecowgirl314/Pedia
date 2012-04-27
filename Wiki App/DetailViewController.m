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


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == articleSearchBox) {
        // start thread in background for loading the page
        //[NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[articleSearchBox text]];
        // only allow to continue if we aren't already executing loading a page
        if (![loadingThread isExecuting]) {
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

- (IBAction)submitFeedback:(id)sender {
    [TestFlight openFeedbackView];
}

- (void)downloadHTMLandParse:(id)object {
    NSLog(@"loaded article %@", (NSString*)object);
    // set title
    [detailItem setTitle:(NSString*)object];
    [detailItem setPrompt:(NSString*)object];
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"titlebar"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    WikipediaHelper *wikiHelper = [[WikipediaHelper alloc] init];
    NSString *article = [wikiHelper getWikipediaHTMLPage:[(NSString*)object stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = [[NSError alloc] init];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:article error:&error];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    //NSString *cssPath = [path stringByAppendingPathComponent:@"style.css"]
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    //http://vlntno.me/_projects/wiki/style.css
    [articleView
     loadHTMLString:[@"<head><link href=\"http://vlntno.me/_projects/wiki/style.css\" rel=\"stylesheet\" type=\"text/css\" /><meta name=\"viewport\" content=\"user-scalable=no\"></head>" stringByAppendingString:article]
     baseURL:baseURL];
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
    historyArray = [[NSMutableArray alloc] init];
    NSURL *ubiq = [[NSFileManager defaultManager] 
                   URLForUbiquityContainerIdentifier:nil];
    NSError *error;
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:ubiq includingPropertiesForKeys:[NSArray array] options:0 error:&error];
    // load each item from iCloud
    for (NSURL *item in items) {
        NSLog(@"item:%@", [item description]);
        NSData *data = [[NSMutableData alloc] initWithContentsOfURL:item];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        // don't let a NULL get loaded
        if (unarchiver!=NULL) {
            HistoryItem *historyItem = [unarchiver decodeObjectForKey:@"HistoryItem"];
            NSLog(@"history item loaded:%@", [historyItem description]);
            [historyArray addObject:historyItem];
        }
    }
    // sort the objects by date
    [historyArray sortUsingComparator:^(id a, id b) {
        NSDate *first = [(HistoryItem*)a date];
        NSDate *second = [(HistoryItem*)b date];
        return [second compare:first];
    }];
    // now populate the view with the data we just loaded
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"populateHistory" 
     object:[(NSArray*)historyArray copy]];
}

- (void)processHistory:(NSString*)title {
    // Adding from local session
    HistoryItem *item = [[HistoryItem alloc] init];
    [item setTitle:title];
    [item setDate:[NSDate date]];
    [historyArray addObject:item];
    // keep the array sorted by date by newest first
    [historyArray sortUsingComparator:^(id a, id b) {
        NSDate *first = [(HistoryItem*)a date];
        NSDate *second = [(HistoryItem*)b date];
        return [second compare:first];
    }];
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"populateHistory" 
     object:[(NSArray*)historyArray copy]];
    // Save to iCloud
    NSURL *iCloud = [[NSFileManager defaultManager] 
                     URLForUbiquityContainerIdentifier:nil];
	NSString *documentsDirectory = [iCloud relativePath];
	NSString *file = [documentsDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@.plist",title]];
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
        NSString *searchForMe = @"File:";
        NSRange range = [[url lastPathComponent] rangeOfString : searchForMe];
        // make sure we aren't loading an image
        if (range.location == NSNotFound) {
            //if (![loadingThread isExecuting]) {
            [NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[url lastPathComponent]];
            // TODO: strip underscores from lastPathComponent to make it user readable
            // also save history
            [self processHistory:[url lastPathComponent]];
        }
        // we found an image. do something with it.
        else {
            NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadImageAndView:) object:[url lastPathComponent]];
            [thread start];
            //UIAlertView *alertNow = [[UIAlertView alloc] initWithTitle:@"TODO" message:@"Image viewing not implemented yet" delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil, nil];
            //[alertNow show];
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"Image attempted:%@", (NSString*)object);
    WikipediaHelper *wikiHelper = [[WikipediaHelper alloc] init];
    //NSLog(@"Image url:%@", );
    NSString *imageURL = [wikiHelper getUrlOfImageFile:(NSString*)object];
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    //[[articleView scrollView] setHidden:YES];
    [imageView setImage:image];
    [imageView setHidden:NO];
    [scrollView setHidden:NO];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
    // Caution, this notification can be sent even when the keyboard is already visible
    // You'll want to check for and handle that situation
    //NSDictionary* info = [aNotification userInfo];
    
    //NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    //CGSize keyboardSize = [aValue CGRectValue].size;
    NSLog(@"bottom bar: %@", NSStringFromCGRect([bottomBar frame]));
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
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
    /*[UIView animateWithDuration:0.50 
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         // Move the bottom bar up. 352 for landscape 263 for portrait
                         [bottomBar setFrame: CGRectMake(0, 910-263, 768, 50)];
                     }
                     completion:^(BOOL finished){
                         //nil
                     }];*/
    
    //... do something
}

- (void)keyboardWasHidden:(NSNotification*)aNotification
{
    // Caution, this notification can be sent even when the keyboard is already visible
    // You'll want to check for and handle that situation
    //NSDictionary* info = [aNotification userInfo];
    
    //NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    //CGSize keyboardSize = [aValue CGRectValue].size;
    NSLog(@"bottom bar: %@", NSStringFromCGRect([bottomBar frame]));
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
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
    /*[UIView animateWithDuration:0.05 
                          delay:0 
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         // Move the bottom bar up. 352 for landscape 263 for portrait
                         [bottomBar setFrame: CGRectMake(0, 910, 768, 50)];
                     }
                     completion:^(BOOL finished){
                         //nil
                     }];*/
    
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
    // allow us to know when the app comes back from the foreground
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(becomeActive:)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"titlebar"] forBarMetrics:UIBarMetricsDefault];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(keyboardWasShown:)
                          name:UIKeyboardDidShowNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardWasHidden:)
                          name:UIKeyboardDidHideNotification object:nil];
    //[articleSearchBox setInputAccessoryView:bottomBar];
    // transparent bottom bar image
    bottomBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottombar.png"]];
    
    [bottomBar.layer setOpaque:NO];
    bottomBar.opaque = NO;
    tableOfContents = [[NSMutableArray alloc] init];
    // allows us to prepopulate the view otherwise nsnotifications are going nowhere
    self.historyController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
    self.historyControllerPopover = [[UIPopoverController alloc] initWithContentViewController:_historyController];
    // Load history from previous sessions. Also from sessions on other devices via iCloud.
    [self loadHistory];
    historyIndex = 0;
    // make the image viewer work
    [scrollView setDelegate:self];
    [scrollView setClipsToBounds:YES];
    scrollView.minimumZoomScale = 1.0f;
    scrollView.maximumZoomScale = 2.0f;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoAnchor:)
                                                 name:@"gotoAnchor"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoArticle:)
                                                 name:@"gotoArticle"
                                               object:nil];
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
    barButtonItem.title = NSLocalizedString(@"Contents", @"Contents");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
