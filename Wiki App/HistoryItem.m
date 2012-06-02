//
//  HistoryItem.m
//  Wiki App
//
//  Created by Chloe Stars on 4/23/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import "HistoryItem.h"

@implementation HistoryItem
@dynamic title;
@dynamic date;

- (NSString*)description {
    return [[NSString alloc] initWithFormat:@"Title: %@ Date:%@", self.title, [self.date description]];
}

@end

@implementation HistoryItemLocal
@synthesize title;
@synthesize date;

- (NSString*)description {
    return [[NSString alloc] initWithFormat:@"Title: %@ Date:%@", self.title, [self.date description]];
}

@end