//
//  SidebarViewController.m
//  Pedia
//
//  Created by Chloe Stars on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SidebarViewController.h"

//#define NSLog TFLog

@interface SidebarViewController ()

@end

@implementation SidebarViewController

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"Contents", @"Contents");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // change color of font to white on the iPad in the side bar
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        titleLabel.shadowColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor]; // change this color
        self.navigationItem.titleView = titleLabel;
        titleLabel.text = self.title;
        [titleLabel sizeToFit];
    }
    UIImage *image = [UIImage imageNamed:@"contents-title.png"];
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sidebar-linen.png"]];
    contentsController = [[ContentsController alloc] initWithTableView:tableView];
    [tableView setDelegate:contentsController];
    [tableView setDataSource:contentsController];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
