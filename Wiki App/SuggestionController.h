//
//  SuggestionController.h
//  Pedia
//
//  Created by Chloe Stars on 5/16/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuggestionController : NSObject <UITableViewDataSource, UITableViewDelegate> {
    NSArray *suggestions;
    UITableView *suggestionTableView;
}

@property (strong) UITableView *suggestionTableView;

- (void)setSuggestions:(NSArray*)_suggestions;

@end
