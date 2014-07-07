/**
 *  @file DeleteMethod.m
 *  HttpClient
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

#import "DeleteMethod.h"
#import "DelegateMessenger.h"


@implementation DeleteMethod

-(void)prepareURLRequestWithURL:(NSURL*)methodURL withRequest:(NSMutableURLRequest*)request {
	//Set the destination URL
	[request setURL:methodURL];
	//Set the method type
	[request setHTTPMethod:@"DELETE"];
}

-(HttpResponse*)executeSynchronouslyAtURL:(NSURL*)methodURL {
	//Create a new URL request object
	NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
	
	[self prepareURLRequestWithURL:methodURL withRequest:request];
	
	//Execute the HTTP method, saving the return data
	NSHTTPURLResponse * response;
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	
	HttpResponse * returnResponse = [[HttpResponse alloc] initWithHttpURLResponse:response withData:returnData];

#ifdef CLANG_OBJC_ARC_DISABLED
	return [returnResponse autorelease];
#else
	return returnResponse;
#endif
}

-(void)executeAsynchronouslyAtURL:(NSURL*)methodURL withDelegate:(id<HttpClientDelegate,NSObject>)delegate {
	//Create a new URL request object
	NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
	
	[self prepareURLRequestWithURL:methodURL withRequest:request];
	
	DelegateMessenger * messenger = [DelegateMessenger delegateMessengerWithDelegate:delegate];
	
	[NSURLConnection connectionWithRequest:request delegate:messenger];
}

@end
