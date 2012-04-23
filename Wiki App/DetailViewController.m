//
//  DetailViewController.m
//  Wiki App
//
//  Created by Chloe Stars on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "HTMLParser.h"

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


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == articleSearchBox) {
        [NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[articleSearchBox text]];
    }
    return YES;
}

- (IBAction)loadArticle:(id)sender {
    [NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[articleSearchBox text]];
}

- (IBAction)pressForward:(id)sender {
    [articleView goForward];
}

- (IBAction)pressBack:(id)sender {
    [articleView goBack];
}

- (IBAction)submitFeedback:(id)sender {
    [TestFlight openFeedbackView];
}

- (void)downloadHTMLandParse:(id)object {
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
     loadHTMLString:[@"<head><link href=\"http://vlntno.me/_projects/wiki/style.css\" rel=\"stylesheet\" type=\"text/css\" /></head>" stringByAppendingString:article]
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
    NSLog(@"HTML:%@", article);
    //NSLog(@"TOC: %@", [tableOfContents description]);
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"populateTableOfContents" 
     object:[(NSArray*)tableOfContents copy]];
    [tableOfContents removeAllObjects];
    [TestFlight passCheckpoint:@"Loaded an article"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    // NOTE: this currently doesn't work for images. What this does is redirects requests to Wikipedia back to the API.
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [NSThread detachNewThreadSelector:@selector(downloadHTMLandParse:) toTarget:self withObject:[url lastPathComponent]];
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

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // Caution, this notification can be sent even when the keyboard is already visible
    // You'll want to check for and handle that situation
    //NSDictionary* info = [aNotification userInfo];
    
    //NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    //CGSize keyboardSize = [aValue CGRectValue].size;
    NSLog(@"bottom bar: %@", NSStringFromCGRect([bottomBar frame]));
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == 0) {
        //Default orientation
    } 
    //UI is in Default (Portrait) -- this is really a just a failsafe. 
    else if(orientation == UIInterfaceOrientationPortrait) {
        //Do something if the orientation is in Portrait
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
    if(orientation == 0) {
        //Default orientation
    } 
    //UI is in Default (Portrait) -- this is really a just a failsafe. 
    else if(orientation == UIInterfaceOrientationPortrait) {
        //Do something if the orientation is in Portrait
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(keyboardWasShown:)
                          name:UIKeyboardDidShowNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardWasHidden:)
                          name:UIKeyboardDidHideNotification object:nil];
    // transparent bottom bar image
    bottomBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottombar.png"]];
    
    [bottomBar.layer setOpaque:NO];
    bottomBar.opaque = NO;
    tableOfContents = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(gotoAnchor:) 
                                                 name:@"gotoAnchor" 
                                               object:nil];
}

- (void)gotoAnchor:(NSNotification*)notification {
    // for jumping to an anchor
    // [webview stringByEvaluatingJavaScriptFromString:@"window.location.hash = '2002'"];
    TableOfContentsAnchor *anchor = [notification object];
    [articleView stringByEvaluatingJavaScriptFromString:[[NSString alloc] initWithFormat:@"window.location.hash = '%@'",[anchor href]]];
}

- (IBAction)selectArticleFromHistory:(id)sender {
    if (_historyController == nil) {
        self.historyController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
        //historyController.delegate = self;
        self.historyControllerPopover = [[UIPopoverController alloc] initWithContentViewController:_historyController];               
    }
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
