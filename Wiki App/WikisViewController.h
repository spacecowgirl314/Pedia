//
//  WikisViewController.h
//  Pedia
//
//  Created by Chloe Stars on 8/14/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface WikisViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    IBOutlet UITableView *wikiTableView;
    UITextField *URLTextField;
    UITextField *nameTextField;
	NSManagedObjectContext *managedObjectContext_;
	NSFetchedResultsController *fetchedResultsController_;
}

@property IBOutlet UITableView *wikiTableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

- (void)reloadFetchedResults:(NSNotification*)notification;

@end
