//
//  DetailViewController.h
//  Wiki App
//
//  Created by Chloe Stars on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WikipediaHelper.h"
#import "TableOfContentsAnchor.h"
#import "HistoryViewController.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate> {
    IBOutlet UITextField *articleSearchBox;
    IBOutlet UIWebView *articleView;
    IBOutlet UIView *bottomBar;
    NSMutableArray *tableOfContents;
    HistoryViewController *_historyController;
    UIPopoverController *_historyControllerPopover;
}

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UITextField *articleSearchBox;
@property (strong, nonatomic) IBOutlet UIWebView *articleView;
@property (strong, nonatomic) IBOutlet UIView *bottomBar;
@property (nonatomic, retain) HistoryViewController *historyController;
@property (nonatomic, retain) UIPopoverController *historyControllerPopover;

- (IBAction)selectArticleFromHistory:(id)sender;
 
@end
