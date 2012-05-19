//
//  SidebarViewController.h
//  Pedia
//
//  Created by Chloe Stars on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentsController.h"

@interface SidebarViewController : UIViewController {
    IBOutlet UITableView *tableView;
    ContentsController *contentsController;
}

@end
