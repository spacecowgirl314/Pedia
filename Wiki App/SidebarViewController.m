//
//  SidebarViewController.m
//  Pedia
//
//  Created by Chloe Stars on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SidebarViewController.h"


@interface SidebarViewController ()

@end

@implementation SidebarViewController

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"Contents", @"Contents");
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen_sidebar.png"]];
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
