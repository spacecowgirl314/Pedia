//
//  HistoryItem.m
//  Wiki App
//
//  Created by Chloe Stars on 4/23/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import "HistoryItem.h"

@implementation HistoryItem
@synthesize title;
@synthesize html;
@synthesize date;

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:title forKey:@"title"];
    [encoder encodeObject:html forKey:@"html"];
	[encoder encodeObject:date forKey:@"date"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if(self = [super init]) {
		self.title = [decoder decodeObjectForKey:@"title"];
        self.html = [decoder decodeObjectForKey:@"html"];
		self.date = [decoder decodeObjectForKey:@"date"];
	}
	return self;
}

- (NSString*)description {
    return [[NSString alloc] initWithFormat:@"Title: %@ Date:%@", title, [date description]];
}

@end
