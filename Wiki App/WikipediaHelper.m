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
        //NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
        /*if([languageCode isEqualToString:@"en"]) {
            apiUrl = @"http://en.wikipedia.org";
            //apiUrl = @"http://www.minecraftwiki.net";
        }
        else if([languageCode isEqualToString:@"ja"]) {
            apiUrl = @"http://ja.wikipedia.org";
        }*/
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

/** Returns HTML for the given article name.
 @param name The name of the article.
 */
- (NSString *) getWikipediaArticle:(NSString *)name {
	// manufacture host URL
	NSURL *siteURL = [NSURL URLWithString:apiUrl];
	NSString *hostURL = [[NSString alloc] initWithFormat:@"http://%@", [siteURL host]];
	
    // Create new SBJSON parser object
    //SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    // JSON Request url
    NSURLRequest *request;
    
    // escape the string with UTF8 so that multilanguages work
    //NSString *url = [[NSString alloc] initWithFormat:@"%@/w/api.php?action=query&prop=revisions&titles=%@&rvprop=content&rvparse&format=json&redirects", apiUrl, [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	
    NSString *url = [[NSString alloc] initWithFormat:@"%@/wiki/%@", hostURL, [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	//NSString *url = [[NSString alloc] initWithFormat:@"%@/%@", hostURL, [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"WikipediaHelper url:%@", url);
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // Perform request and get JSON back as a NSData object
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    // Get JSON as a NSString from NSData response
    /*NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    // parse the JSON response into an object
    // Here we're using NSArray since we're parsing an array of JSON status objects
    NSDictionary *wikipediaResponseObject = [parser objectWithString:json_string error:nil];
    
    NSArray *htmlTemp = [[[wikipediaResponseObject objectForKey:@"query"] objectForKey:@"pages"] allValues];
    
    if(![[htmlTemp objectAtIndex:0] objectForKey:@"revisions"]) {
        return @"";
    }
    
    NSString *htmlSrc = [[[[htmlTemp objectAtIndex:0] objectForKey:@"revisions"] objectAtIndex:0] objectForKey:@"*"];*/
    
    return [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]; //htmlSrc;
}

// used for sharing
/** Returns a properly valid URL contiainging a link to the given article name.
 @param name The name of the article.
 */
- (NSString *) getURLForArticle:(NSString *)name {
	// manufacture host URL
	NSURL *siteURL = [NSURL URLWithString:apiUrl];
	NSString *hostURL = [[NSString alloc] initWithFormat:@"http://%@", [siteURL host]];
	
    // remove spaces from name and replace with underscore for the url
    NSString *articleName = [name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *wikiUrl = [hostURL stringByAppendingString:@"/wiki/"];
    NSString *urlString = [wikiUrl stringByAppendingString:[articleName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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
    NSLog(@"WikipediaHelper connection progress: %f", downloadProgress);
    // Broadcast a notification with the progress change, or call a delegate
}

/** Returns a processed form of the HTML returned by [WikipediaHelper getWikipediaArticle:].
 @param name The name of the article.
 */
- (NSString *) getWikipediaHTMLPage:(NSString *)name {
	// manufacture host URL
	NSURL *siteURL = [NSURL URLWithString:apiUrl];
	NSString *hostURL = [[NSString alloc] initWithFormat:@"http://%@", [siteURL host]];
	
    // Fetch wikipedia article
    NSString *htmlSrc = [self getWikipediaArticle:name];
    
    if([htmlSrc isEqualToString:@""])
        return htmlSrc;
    
    // NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"h3" withString:@"h2"];
    
    NSString *wikiString = [NSString stringWithFormat:@"%@/wiki/", hostURL];
    NSString *ahrefWikiString = [NSString stringWithFormat:@"<a href=\"%@/wiki\"", hostURL];
    NSString *ahrefWikiStringReplacement = [NSString stringWithFormat:@"<a target=\"blank\" href=\"%@/wiki\"", hostURL];
    
    NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"/wiki/" withString:wikiString];
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:ahrefWikiString withString:ahrefWikiStringReplacement];
    
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"//upload.wikimedia.org" withString:@"http://upload.wikimedia.org"];
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"class=\"editsection\"" withString:@"style=\"visibility: hidden\""];
    
    
    // Append html and body tags, Add some style
    /*formatedHtmlSrc = [NSString stringWithFormat:@"<body>%@<span class=\"attribution\">The article above is based on this article of the free encyclopedia Wikipedia and it is licensed under &ldquo;Creative Commons Attribution/Share Alike&rdquo;.</span></body>", formatedHtmlSrc];*/
    
    return formatedHtmlSrc;
}

/** Returns a string containing the URL to the given image filename.
 @param filename The filename of the image.
 */
- (NSString*) getUrlOfImageFile:(NSString*)filename {
    //http://commons.wikimedia.org/w/api.php?action=query&prop=imageinfo&titles=File:Cameras.jpg&iiprop=url&format=json
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSURLRequest *request;
    
    NSString *url = [[NSString alloc] initWithFormat:@"%@?action=query&prop=imageinfo&titles=%@&iiprop=url&format=json", apiUrl, [filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
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
	NSLog(@"Received image URL:%@", imageUrl);
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

/** Returns an array containing the suggestions for the given string.
 @param string The string to get suggestions for.
 */
- (NSArray*)getSuggestionsFor:(NSString*)string {
    // parse
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSURLRequest *request;
    
    //http://en.wikipedia.org/w/api.php?action=opensearch&search=gr&limit=100&namespace=0&format=json
    NSString *url = [[NSString alloc] initWithFormat:@"%@?action=opensearch&search=%@&limit=100&namespace=0&format=json", apiUrl, [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
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

/**
 Returns a dictionary with codes and language names
 */
- (NSArray*)getSupportedLanguages {
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@?action=query&meta=siteinfo&siprop=languages&format=json", apiUrl];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
	NSDictionary *query = [dictionary valueForKey:@"query"];
	NSArray *languages = [query valueForKey:@"languages"];
	
	return languages;
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
