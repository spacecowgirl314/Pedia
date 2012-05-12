//
//  ImageViewController.m
//  Pedia
//
//  Created by Chloe Stars on 5/11/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import "ImageViewController.h"
#import "WikipediaHelper.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen_bg.png"]];
    UIImage *image = [UIImage imageNamed:@"topbar.png"];
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }  
    // change item button color to match gray
    self.navigationItem.backBarButtonItem.tintColor = [UIColor grayColor];
    // change color of font to gray on the iPhone in the navigation bar
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor grayColor]; // change this color
    self.navigationItem.titleView = titleLabel;
    titleLabel.text = @"200x200"; // change to 200x402 later
    [titleLabel sizeToFit];
    // make the image viewer work
    [scrollView setDelegate:self];
    [scrollView setClipsToBounds:YES];
    scrollView.minimumZoomScale = 1.0f;
    scrollView.maximumZoomScale = 2.0f;
}

#pragma mark Important for image viewing

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

- (void)imageLoadWithName:(NSString*)name {
    // animate progess bar here
    WikipediaHelper *wikiHelper = [[WikipediaHelper alloc] init];
    //NSLog(@"Image url:%@", );
    NSString *imageURL = [wikiHelper getUrlOfImageFile:name];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
