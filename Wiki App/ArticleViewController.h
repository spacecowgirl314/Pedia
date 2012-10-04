//
//  ArticleViewController.h
//  Wiki App
//
//  Created by Chloe Stars on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "WikipediaHelper.h"
#import "TableOfContentsAnchor.h"
#import "HistoryViewController.h"
#import "ArchivedViewController.h"
#import "MasterViewController.h"
#import "ImageViewController.h"
#import "SuggestionController.h"
#import "GettingStartedViewController.h"
#import "UIDownloadBar.h"
#import "Reachability.h"
#import "ImageScrollView.h"
#import "ArchiveDownloader.h"
#import "WikisViewController.h"

@interface ArticleViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, UIDownloadBarDelegate, ArchiveDownloaderDelegate, ImageScrollViewDelegate> {
    IBOutlet UITextField *articleSearchBox;
    IBOutlet UIWebView *articleView;
    IBOutlet UIView *bottomBar;
    IBOutlet UIView *searchView;
    IBOutlet UIView *backgroundView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *forwardButton;
	IBOutlet UIButton *shareButton;
	IBOutlet UIButton *contentsButton;
    IBOutlet UINavigationItem *detailItem;
    IBOutlet ImageScrollView *scrollView;
    IBOutlet UIImageView *imageView;
    IBOutlet UITableView *suggestionTableView;
    NSMutableArray *tableOfContents;
    HistoryViewController *_historyViewController;
    ArchivedViewController *_archivedViewController;
    UIPopoverController *_historyViewControllerPopover;
    UIPopoverController *_archivedViewControllerPopover;
    NSMutableArray *historyArray;
    NSMutableArray *previousHistoryArray;
    NSThread *loadingThread;
    NSThread *processHistoryThread;
    UIView *overlay;
    UIView *searchUnderlay;
    int historyIndex;
    UIDownloadBar *imageBar;
    UILabel *titleLabel;
    SuggestionController *suggestionController;
    NSManagedObjectContext *managedObjectContext__;
	NSManagedObjectContext *wikiManagedObjectContext__;
    BOOL isDebugging;
    WikipediaHelper *wikipediaHelper;
    Reachability *reachability;
    BOOL imageIsDownloaded;
    BOOL imageIsVector;
    UIWebView *vectorView;
	UIPopoverController *sharingPopoverController;
}

@property (strong, nonatomic) IBOutlet UITextField *articleSearchBox;
@property (strong, nonatomic) IBOutlet UIWebView *articleView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIView *bottomBar;
@property (nonatomic, retain) HistoryViewController *historyViewController;
@property (nonatomic, retain) UIPopoverController *historyViewControllerPopover;
@property (nonatomic, retain) UIPopoverController *sharingPopoverController;
@property (nonatomic, retain) ArchivedViewController *archivedViewController;
@property (nonatomic, retain) UIPopoverController *archivedViewControllerPopover;
@property (retain) NSMutableArray *historyArray;
@property (retain) NSMutableArray *previousHistoryArray;
@property (retain) UILabel *titleLabel;
@property (retain) NSMutableArray *tableOfContents;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *wikiManagedObjectContext;

- (IBAction)selectArticleFromHistory:(id)sender;
 
@end
