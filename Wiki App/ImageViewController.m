//
//  ImageViewController.m
//  Pedia
//
//  Created by Chloe Stars on 5/11/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import "ImageViewController.h"
#import "WikipediaHelper.h"

//#define NSLog TFLog

@interface ImageViewController ()

@end

@implementation ImageViewController
@synthesize scrollView;

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
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    titleLabel.shadowColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor grayColor]; // change this color
    self.navigationItem.titleView = titleLabel;
    // make the image viewer work
    [scrollView setDelegate:self];
    [scrollView setImageScrollViewDelegate:self];
    [scrollView setClipsToBounds:YES];
    scrollView.minimumZoomScale = 1.0f;
    scrollView.maximumZoomScale = 2.0f;
}

#pragma mark Important for image viewing

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

- (BOOL)isFinishedDownloading {
    return imageIsDownloaded;
}

- (void)imageLoadWithName:(NSString*)name {
    // make sure action sheet won't work yet
    imageIsDownloaded = NO;
    // animate progess bar here
    WikipediaHelper *wikiHelper = [[WikipediaHelper alloc] init];
    //NSLog(@"Image url:%@", );
    NSString *imageURL = [wikiHelper getUrlOfImageFile:name];
    NSURL *url = [NSURL URLWithString:imageURL];
    
    // make sure we aren't loading an vector image
    NSLog(@"extension:%@", [url pathExtension]);
    if ([[url pathExtension] isEqualToString:@"svg"]) {
        imageIsVector = YES;
        NSLog(@"Abandon ship we've got a vector image!");
    }
    
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
        // set title to the resolution size of the image
        NSString *resolutionString = [[NSString alloc] initWithFormat:@"%ix%i", (int)image.size.width, (int)image.size.height];
        titleLabel.text = resolutionString;
        [titleLabel sizeToFit];
        
        if (imageIsVector) {
            UIWebView *vectorView = [[UIWebView alloc] init];
            [vectorView setScalesPageToFit:YES];
            [vectorView loadData:fileData MIMEType:@"image/svg+xml" textEncodingName:@"utf-8" baseURL:nil];
            [vectorView setUserInteractionEnabled:NO];
            
            [scrollView setVectorView:vectorView];
        }
        else {
            [imageView setImage:image];
            [imageView setHidden:NO];
        }
        [scrollView setHidden:NO];
        [self.view bringSubviewToFront:scrollView];
        // enable the action sheet to work
        imageIsDownloaded = YES;
    }
}

- (void)downloadBar:(UIDownloadBar *)downloadBar didFailWithError:(NSError *)error {
    if (error) {
        NSLog(@"ImageViewConroller downloadBar error: %@", error);
    }
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
