//
//  TableOfContentsAnchor.h
//  Wiki App
//
//  Created by Chloe Stars on 4/20/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableOfContentsAnchor : NSObject {
    NSString *title;
    NSString *href;
}

@property (strong) NSString *title;
@property (strong) NSString *href;

@end
