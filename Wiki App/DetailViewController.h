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

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate> {
    IBOutlet UITextField *articleSearchBox;
    IBOutlet UIWebView *articleView;
    NSMutableArray *tableOfContents;
}

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UITextField *articleSearchBox;
@property (strong, nonatomic) IBOutlet UIWebView *articleView;

@end
