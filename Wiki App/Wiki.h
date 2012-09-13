//
//  Wiki.h
//  Pedia
//
//  Created by Chloe Stars on 8/14/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Wiki : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * enabled;

@end
