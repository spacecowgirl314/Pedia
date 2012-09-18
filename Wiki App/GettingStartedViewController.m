//
//  GettingStartedViewController.m
//  Pedia
//
//  Created by Chloe Stars on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GettingStartedViewController.h"

//#define NSLog TFLog

@interface GettingStartedViewController ()

@end

@implementation GettingStartedViewController
@synthesize scrollView;
@synthesize pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"GettingStartedViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Getting Started", @"Getting Started");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // change color of font to gray on the iPhone in the navigation bar
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        titleLabel.shadowColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor grayColor]; // change this color
        self.navigationItem.titleView = titleLabel;
        titleLabel.text = self.title;
        [titleLabel sizeToFit];
    }
    UIImage *image = [UIImage imageNamed:@"topbar.png"];
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Next") style:UIBarButtonItemStyleDone target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = nextButton;
    nextButton.enabled = YES;
    
    NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor], nil];
    for (int i = 0; i < colors.count; i++) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        // real views from nib should be inserted here
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        //subview.autoresizingMask = UIViewAutoresizingFlexibleHeight + UIViewAutoresizingFlexibleWidth;
        //subview.autoresizesSubviews = YES;
        subview.backgroundColor = [colors objectAtIndex:i];
        [self.scrollView addSubview:subview];
    }
    
    NSLog(@"GettingStartedViewController frame:%@", NSStringFromCGRect(self.view.frame));
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * colors.count, self.scrollView.frame.size.height);
    // prevent flickering
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (!pageControlBeingUsed) {
        // Update the page when more than 50% of the previous/next page is visible
        CGFloat pageWidth = self.scrollView.frame.size.width;
        int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
    // change button to done if we reached the end of scroll view
    if (self.pageControl.currentPage+1==self.pageControl.numberOfPages) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"Done");
    }
    else {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Next", @"Next");
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    pageControlBeingUsed = YES;
}

- (void)next {
    // check if we're done and dimiss if so
    if (self.pageControl.currentPage+1==self.pageControl.numberOfPages) {
        // don't let this run again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstRun"];
        [self dismissModalViewControllerAnimated:YES];
    }
    // move the page controller forward
    CGRect frame;
    self.pageControl.currentPage++;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    pageControlBeingUsed = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // only let the iPad rotate during the Getting Started
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait ||
                interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ||
                interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
    else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

@end
