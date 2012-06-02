//
//  HistoryItem.h
//  Wiki App
//
//  Created by Chloe Stars on 4/23/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface HistoryItem : NSManagedObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *date;

@end

@interface HistoryItemLocal : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *date;

@end
