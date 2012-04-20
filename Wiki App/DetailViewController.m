//
//  DetailViewController.m
//  Wiki App
//
//  Created by Chloe Stars on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "HTMLParser.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;

- (IBAction)loadArticle:(id)sender {
    WikipediaHelper *wikiHelper = [[WikipediaHelper alloc] init];
    NSString *article = [wikiHelper getWikipediaHTMLPage:[[articleSearchBox text]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = [[NSError alloc] init];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:article error:&error];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    //NSString *cssPath = [path stringByAppendingPathComponent:@"style.css"]
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [articleView
     loadHTMLString:[@"<head><link href=\"style.css\" rel=\"stylesheet\" type=\"text/css\" /></head>" stringByAppendingString:article]
     baseURL:baseURL];
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
            NSLog(@"spanNodes:%@", [spanNodes description]);
            // search span for toctext/Title of entry in the Title of Contents
            for (HTMLNode *spanNode in spanNodes) {
                HTMLNode *toctext = [spanNode findChildOfClass:@"toctext"];
                // title of contents entry
                NSString *titleOfContentsEntry = [toctext rawContents];
                [anchorItem setTitle:titleOfContentsEntry];
            }
            [tableOfContents addObject:anchorItem];
        }
    }
    // add all the to some array of sorts and add it to the sidebar
    NSLog(@"%@", article);
    NSLog(@"TOC: %@", [tableOfContents description]);
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    tableOfContents = [[NSMutableArray alloc] init];
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
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
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
