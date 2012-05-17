//
//  WikipediaHelper.m
//  Naturvielfalt
//
//  Created by Robin Oster on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WikipediaHelper.h"
#import "SBJsonParser.h"

@implementation WikipediaHelper
@synthesize apiUrl, imageBlackList;

- (id)init {
    self = [super init];
    if (self) {
        // Standard values for the api URL
        // EN
        NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
        if([languageCode isEqualToString:@"en"]) {
            apiUrl = @"http://en.wikipedia.org";
        }
        else if([languageCode isEqualToString:@"ja"]) {
            apiUrl = @"http://ja.wikipedia.org";
        }
        // below doesn't work out of the box
        //apiUrl = [[NSString alloc] initWithFormat:@"http://%@.wikipedia.org",NSLocaleLanguageCode];
        
        // DE
        // apiUrl = @"http://de.wikipedia.org";
        
        
        imageBlackList = [[NSMutableArray alloc] init];
        
        [imageBlackList addObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Padlock-silver.svg/20px-Padlock-silver.svg.png"];
        
        [imageBlackList addObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Disambig-dark.svg/25px-Disambig-dark.svg.png"];
        
        [imageBlackList addObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Qsicon_L%C3%BCcke.svg/24px-Qsicon_L%C3%BCcke.svg.png"];
        
        [imageBlackList addObject:@"http://upload.wikimedia.org/wikipedia/en/thumb/9/94/Symbol_support_vote.svg/15px-Symbol_support_vote.svg.png"];
    }
    return self;
}

- (NSString *) getWikipediaArticle:(NSString *)name {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    // JSON Request url
    NSURLRequest *request;
    
    // escape the string with UTF8 so that multilanguages work
    NSString *url = [[NSString alloc] initWithFormat:@"%@/w/api.php?action=query&prop=revisions&titles=%@&rvprop=content&rvparse&format=json&redirects", apiUrl, [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"url:%@", url);
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // Perform request and get JSON back as a NSData object
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    // Get JSON as a NSString from NSData response
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    // parse the JSON response into an object
    // Here we're using NSArray since we're parsing an array of JSON status objects
    NSDictionary *wikipediaResponseObject = [parser objectWithString:json_string error:nil];
    
    NSArray *htmlTemp = [[[wikipediaResponseObject objectForKey:@"query"] objectForKey:@"pages"] allValues];
    
    if(![[htmlTemp objectAtIndex:0] objectForKey:@"revisions"]) {
        return @"";
    }
    
    NSString *htmlSrc = [[[[htmlTemp objectAtIndex:0] objectForKey:@"revisions"] objectAtIndex:0] objectForKey:@"*"];
    
    return htmlSrc;
}

// used for sharing
- (NSString *) getURLForArticle:(NSString *)name {
    // remove spaces from name and replace with underscore for the url
    NSString *articleName = [name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *wikiUrl = [apiUrl stringByAppendingString:@"/wiki/"];
    NSString *urlString = [wikiUrl stringByAppendingString:articleName];
    return urlString;
}

- (void)connection: (NSURLConnection*) connection didReceiveResponse: (NSHTTPURLResponse*) response
{
    NSInteger statusCode = [response statusCode];
    if (statusCode == 200) {
        downloadSize = [response expectedContentLength];
    }
}

- (void) connection: (NSURLConnection*) connection didReceiveData: (NSData*) data
{
    //[data_ appendData: data];
    downloadProgress = ((float) [data length] / (float) downloadSize);
    NSLog(@"progress: %f", downloadProgress);
    // Broadcast a notification with the progress change, or call a delegate
}

- (NSString *) getWikipediaHTMLPage:(NSString *)name {
    // Fetch wikipedia article
    NSString *htmlSrc = [self getWikipediaArticle:name];
    
    if([htmlSrc isEqualToString:@""])
        return htmlSrc;
    
    // NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"h3" withString:@"h2"];
    
    NSString *wikiString = [NSString stringWithFormat:@"%@/wiki/", apiUrl];
    NSString *ahrefWikiString = [NSString stringWithFormat:@"<a href=\"%@/wiki\"", apiUrl];
    NSString *ahrefWikiStringReplacement = [NSString stringWithFormat:@"<a target=\"blank\" href=\"%@/wiki\"", apiUrl];
    
    NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"/wiki/" withString:wikiString];
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:ahrefWikiString withString:ahrefWikiStringReplacement];
    
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"//upload.wikimedia.org" withString:@"http://upload.wikimedia.org"];
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"class=\"editsection\"" withString:@"style=\"visibility: hidden\""];
    
    
    // Append html and body tags, Add some style
    formatedHtmlSrc = [NSString stringWithFormat:@"<body>%@<br/><br/><br/>The article above is based on this article of the free encyclopedia Wikipedia and it is licensed under “Creative Commons Attribution/Share Alike”.</body>", formatedHtmlSrc];
    
    return formatedHtmlSrc;
}

- (NSString*) getUrlOfImageFile:(NSString*)filename {
    //http://commons.wikimedia.org/w/api.php?action=query&prop=imageinfo&titles=File:Cameras.jpg&iiprop=url&format=json
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSURLRequest *request;
    
    NSString *url = [[NSString alloc] initWithFormat:@"%@/w/api.php?action=query&prop=imageinfo&titles=%@&iiprop=url&format=json", apiUrl, [filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // Perform request and get JSON back as a NSData object
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    // Get JSON as a NSString from NSData response
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    // parse the JSON response into an object
    // Here we're using NSArray since we're parsing an array of JSON status objects
    NSDictionary *wikipediaResponseObject = [parser objectWithString:json_string error:nil];
    
    // NOTE: when an image doesn't exist we only have the query object and not pages object
    NSArray *pages = [[[wikipediaResponseObject objectForKey:@"query"] objectForKey:@"pages"] allValues];
    NSDictionary *page = [pages objectAtIndex:0];
    NSDictionary *imageinfo = [[page objectForKey:@"imageinfo"] objectAtIndex:0];
    NSString *imageUrl = [imageinfo objectForKey:@"url"];
    return imageUrl;
}

- (NSString *) getUrlOfMainImage:(NSString *)name {
    
    // Fetch wikipedia article
    NSString *htmlSrc = [self getWikipediaArticle:name];
    
    // Otherwise images have an incorrect url
    NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"//upload.wikimedia.org" withString:@"http://upload.wikimedia.org"];
    
    if([htmlSrc isEqualToString:@""])
        return htmlSrc;
    
    NSArray *splitonce = [formatedHtmlSrc componentsSeparatedByString:@"src=\""];

    NSString *finalSplitString = [[NSString alloc]  initWithString:[splitonce objectAtIndex:1]];
    NSArray *finalSplit = [finalSplitString  componentsSeparatedByString:@"\""];

    NSString *imageURL = [[NSString alloc]  initWithString:[finalSplit objectAtIndex:0]];
    imageURL = [imageURL stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]];

    int i = 1;
    
    while([self isOnBlackList:imageURL]) { 
        // Get the next image tag
        finalSplitString = [[NSString alloc]  initWithString:[splitonce objectAtIndex:i]];
        
        finalSplit = [finalSplitString  componentsSeparatedByString:@"\""];
        
        imageURL = [[NSString alloc]  initWithString:[finalSplit objectAtIndex:0]];
        imageURL = [imageURL stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]];
        
        i++;
    }
    
    return imageURL;
}

- (NSArray*)getSuggestionsFor:(NSString*)string {
    // parse
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSURLRequest *request;
    
    //http://en.wikipedia.org/w/api.php?action=opensearch&search=gr&limit=100&namespace=0&format=json
    NSString *url = [[NSString alloc] initWithFormat:@"%@/w/api.php?action=opensearch&search=%@&limit=100&namespace=0&format=json", apiUrl, [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // Perform request and get JSON back as a NSData object
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    // Get JSON as a NSString from NSData response
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    // parse the JSON response into an object
    // Here we're using NSArray since we're parsing an array of JSON status objects
    NSArray *wikipediaResponseObject = [parser objectWithString:json_string error:nil];
    
    // NOTE: when an image doesn't exist we only have the query object and not pages object
    NSArray *suggestions = [wikipediaResponseObject objectAtIndex:1];
    return suggestions;
}

- (BOOL) isOnBlackList:(NSString *)imageURL {
    // Check if its not the correct image (Sometimes there are articles where the first image is an icon..)
    for(NSString *img in imageBlackList) {
        if([img isEqualToString:imageURL]) {
            return true;
        }
    }
    
    return false;
}

@end
