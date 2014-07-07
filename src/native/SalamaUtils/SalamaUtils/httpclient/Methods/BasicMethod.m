/**
 *  @file BasicMethod.m
 * HttpClient
 *
 *  Copyright (c) 2010 Scott Slaugh, Brigham Young University
 *   
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *   
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 *
 */

#import "BasicMethod.h"
#import "Constants.h"
#import "DelegateMessenger.h"

@interface BasicMethod()

+ (NSString *)encodeURLComponentString:(NSString *)urlStr encoding:(NSStringEncoding)encoding;

@end

@implementation BasicMethod

@synthesize requestTimeoutInterval;
@synthesize encoding;

-(id)init {
	self = [super init];
	
	if (self != nil) {
		//Initialize the dictionary used for storing parameters
		params = [[NSMutableDictionary alloc] init];
        self.encoding = NSUTF8StringEncoding;
	}
	
	return self;
}

-(void)addParameter:(NSString*)paramData withName:(NSString*)paramName {
	//Add the parameter to the parameters dictionary
	[params setValue:paramData forKey:paramName];
}

-(void)addParametersFromDictionary:(NSDictionary*)dict {
	for (id key in dict) {
		[params setValue:[dict objectForKey:key] forKey:key];
	}
}

-(void)prepareMethod:(NSURL*)methodURL methodType:(NSString*)methodType dataInBody:(bool)dataInBody contentType:(NSString*)contentType withRequest:(NSMutableURLRequest*)request {
	//Set the destination URL
	[request setURL:methodURL];
	//Set the method type
	[request setHTTPMethod:methodType];
	//Set the content-type
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	
	//Create a data object to hold the body while we're creating it
	NSMutableData * body = [[NSMutableData alloc] init];
	
	//Loop over all the items in the parameters dictionary and add them to the body
	int cCount = 0;
	for (NSString* cKey in params) {
		cCount++;
		//If we've already added at least one data item, we need to add the & character between each new data item
		if (cCount > 1) {
			[body appendData:[@"&" dataUsingEncoding:encoding]];
		}
		
		//Add the parameter(No need encode in "POST" method)
        if(dataInBody)
        {
            [body appendData:[[NSString stringWithFormat:@"%@=%@", cKey, [params valueForKey:cKey]] dataUsingEncoding:encoding]];
        }
        else
        {
            [body appendData:[[NSString stringWithFormat:@"%@=%@", cKey, [BasicMethod encodeURLComponentString:[params valueForKey:cKey] encoding:encoding]] dataUsingEncoding:encoding]];
        }
	}
	
	//Add the body data in either the actual HTTP body or as part of the URL query
	if (dataInBody) { //For post methods, we add the parameters to the body
		[request setHTTPBody:body];
	} //For get methods, we have to add parameters to the url
	else {
		//Get a mutable string so that we can add the parameters to the end as query arguments
		NSMutableString * newURLString = [[NSMutableString alloc] initWithString:[methodURL absoluteString]];
		//Convert the body data into a string
		NSString * bodyString = [[NSString alloc] initWithData:body encoding:encoding];
		//Append the body data as a URL query
		[newURLString appendFormat:@"?%@", bodyString];
		//Create a new URL, escaping characters as necessary
        //Already encoded in adding parameters ---------
		//NSURL * newURL = [NSURL URLWithString:[newURLString stringByAddingPercentEscapesUsingEncoding:encoding]];
		NSURL * newURL = [NSURL URLWithString:newURLString];

#ifdef CLANG_OBJC_ARC_DISABLED
		[bodyString release];
		[newURLString release];
#else
        bodyString = nil;
        newURLString = nil;
#endif
		//Set the url request's url to be this new URL with the query appended
		[request setURL:newURL];
	}
	
#ifdef CLANG_OBJC_ARC_DISABLED
	[body release];
#else
    body = nil;
#endif
}

-(HttpResponse*)executeMethodSynchronously:(NSURL*)methodURL methodType:(NSString*)methodType dataInBody:(bool)dataInBody contentType:(NSString*)contentType {
	
	//Create a new URL request object
	NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    
    if(requestTimeoutInterval > 0)
    {
        [request setTimeoutInterval:requestTimeoutInterval];
    }
	
	[self prepareMethod:methodURL methodType:methodType dataInBody:dataInBody contentType:contentType withRequest:request];
	
	//Execute the HTTP method, saving the return data
	NSHTTPURLResponse * response;
    NSError* error;
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	HttpResponse * responseObject = [[HttpResponse alloc] initWithHttpURLResponse:response withData:returnData];
	
#ifdef CLANG_OBJC_ARC_DISABLED
	return [responseObject autorelease];
#else
    return responseObject;
#endif
    
}

-(void)executeMethodAsynchronously:(NSURL*)methodURL methodType:(NSString*)methodType dataInBody:(bool)dataInBody contentType:(NSString*)contentType withDelegate:(id<HttpClientDelegate,NSObject>)delegate {
	NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];

    if(requestTimeoutInterval > 0)
    {
        [request setTimeoutInterval:requestTimeoutInterval];
    }

	[self prepareMethod:methodURL methodType:methodType dataInBody:dataInBody contentType:contentType withRequest:request];
	
	//Execute the HTTP method
	DelegateMessenger * messenger = [DelegateMessenger delegateMessengerWithDelegate:delegate];
	
	[NSURLConnection connectionWithRequest:request delegate:messenger];
}

/*
+ (NSString *)encodeURLString:(NSString *)urlStr encoding:(CFStringEncoding)encoding
{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  (CFStringRef)urlStr,
                                                                  NULL,
                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                  encoding);
    NSString* encodedStr = (__bridge_transfer NSString*) escaped;
#ifdef CLANG_OBJC_ARC_DISABLED
	return [encodedStr autorelease];
#else
    return encodedStr;
#endif
}
*/
+ (NSString *)encodeURLComponentString:(NSString *)urlStr encoding:(NSStringEncoding)encoding
{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString* encodedStr =  [[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];;
#ifdef CLANG_OBJC_ARC_DISABLED
	return [encodedStr autorelease];
#else
    return encodedStr;
#endif
}


@end
