//
//  ContentsController.h
//  Pedia
//
//  Created by Chloe Stars on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ContentsController : NSObject <UITableViewDelegate, UITableViewDataSource> {
    UITableView *tableView;
    NSArray *tableOfContents;
    UINavigationController *navigationController;
}

- (id)initWithTableView:(UITableView*)_tableView;

@end
