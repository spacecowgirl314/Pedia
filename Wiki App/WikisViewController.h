//
//  WikisViewController.h
//  Pedia
//
//  Created by Chloe Stars on 8/14/12.
//
//

#import <UIKit/UIKit.h>

@interface WikisViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *wikiTableView;
    UITextField *URLTextField;
    UITextField *nameTextField;
}

@property IBOutlet UITableView *wikiTableView;

@end
