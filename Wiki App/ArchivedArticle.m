//
//  ArchivedArticle.m
//  Pedia
//
//  Created by Chloe Stars on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArchivedArticle.h"

@implementation ArchivedArticle
@dynamic title;
@dynamic file;
@dynamic date;

- (id)copyWithZone: (NSZone *)zone
{
    return self;
}

@end