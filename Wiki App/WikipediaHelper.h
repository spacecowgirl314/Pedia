//
//  WikipediaHelper.h
//  prine.ch
//
//  Created by Robin Oster on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WikipediaHelper : NSObject<NSURLConnectionDelegate> {
    NSString *apiUrl;
    NSMutableArray *imageBlackList;
    float downloadProgress;
    long downloadSize;
}

@property (nonatomic, retain) NSString *apiUrl;
@property (nonatomic, retain) NSMutableArray *imageBlackList;

// Fetches an wikipedia article from the wikipedia api
- (NSString *) getWikipediaArticle:(NSString *)name;

// Returns the HTML page from an wikipedia article search by the name
- (NSString *) getWikipediaHTMLPage:(NSString *)name;

// Return the Main image of an wikipedia article search by the name
- (NSString *) getUrlOfMainImage:(NSString *)name;

// Return the image url of the File: string we are given in an article
- (NSString*) getUrlOfImageFile:(NSString*)filename;

// Checks if the returned image is on the blacklist
- (BOOL) isOnBlackList:(NSString *)imageURL;

@end
