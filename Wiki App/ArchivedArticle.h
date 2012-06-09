//
//  ArchivedArticle.h
//  Pedia
//
//  Created by Chloe Stars on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ArchivedArticle : NSManagedObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) NSDate *date;

@end