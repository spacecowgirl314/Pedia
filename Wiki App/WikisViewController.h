//
//  WikisViewController.h
//  Pedia
//
//  Created by Chloe Stars on 8/14/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol WikisViewControllerDelegate <NSObject>
-(void)reloadSelectedWiki;
@end

@interface WikisViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
	id <WikisViewControllerDelegate> delegate;
    IBOutlet UITableView *wikiTableView;
    UITextField *URLTextField;
    UITextField *nameTextField;
	NSManagedObjectContext *managedObjectContext_;
	NSFetchedResultsController *fetchedResultsController_;
	NSArray *languages;
}

@property IBOutlet UITableView *wikiTableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property id <WikisViewControllerDelegate> delegate;

- (void)reloadFetchedResults:(NSNotification*)notification;

@end
