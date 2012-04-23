//
//  HistoryItem.h
//  Wiki App
//
//  Created by Chloe Stars on 4/23/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryItem : NSObject {
    NSString *title;
    NSDate *date;
}

@property (strong) NSString *title;
@property (strong) NSDate *date;

@end
