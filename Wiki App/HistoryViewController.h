//
//  HistoryViewController.h
//  Wiki App
//
//  Created by Chloe Stars on 4/21/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UITableViewController {
    NSMutableArray *_entries;
}

@property (nonatomic) NSMutableArray *entries;

@end
