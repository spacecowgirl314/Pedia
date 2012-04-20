//
//  TableOfContentsAnchor.m
//  Wiki App
//
//  Created by Chloe Stars on 4/20/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import "TableOfContentsAnchor.h"

@implementation TableOfContentsAnchor
@synthesize title;
@synthesize href;

- (NSString*)description {
    return [[NSString alloc] initWithFormat:@"title:%@ href:%@", title, href];
}

@end
