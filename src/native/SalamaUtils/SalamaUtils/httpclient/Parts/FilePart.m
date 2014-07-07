/**
 * @file FilePart.m
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

#import "FilePart.h"
#import "HttpClientGzipUtility.h"
#import "Constants.h"

@implementation FilePart

-(id) initWithFile:(NSURL*)fileURL withName: (NSString*)paramName compressFile:(bool)compress {
	self = [super init];
	
	if (self != nil) {
#ifdef CLANG_OBJC_ARC_DISABLED
		name = [paramName retain];
		file = [fileURL retain];
#else
        name = nil;
        file = nil;
        
        name = paramName;
        file = fileURL;
#endif
		compressFile = compress;
		
	}
	
	return self;
}

+(FilePart*) filePartWithFile:(NSURL*)fileURL withName: (NSString*)paramName compressFile:(bool)compress {
#ifdef CLANG_OBJC_ARC_DISABLED
	return [[[FilePart alloc] initWithFile:fileURL withName:paramName compressFile:compress] autorelease];
#else
	return [[FilePart alloc] initWithFile:fileURL withName:paramName compressFile:compress];
#endif
}

-(void)appendData:(NSMutableData*)outputData {
	
	NSString * fileName = [[[file absoluteString] componentsSeparatedByString:@"/"] lastObject];
	
	//Get the file data
	NSData * fileData;
	
	if (compressFile) {
		NSData * tempFileData = [NSData dataWithContentsOfURL:file];
#ifdef CLANG_OBJC_ARC_DISABLED
		fileData = [[HttpClientGzipUtility gzipData:tempFileData] retain];
#else
		fileData = [HttpClientGzipUtility gzipData:tempFileData];
#endif
		
		if (fileData == nil) {
			NSLog(@"Compressed data is nil!");
		}
		else {
			fileName = [fileName stringByAppendingString:@".gz"];
		}
	}
	else {
		fileData = [NSData dataWithContentsOfURL:file];
	}
	
	[outputData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, fileName] dataUsingEncoding:encoding]];
//	[outputData appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n"] dataUsingEncoding:encoding]];
	[outputData appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:encoding]];
	[outputData appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:encoding]];
	[outputData appendData:[NSData dataWithData:fileData]];
	//[outputData appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:encoding]];
    [outputData appendData:[@"\r\n" dataUsingEncoding:encoding]];
}

-(void) dealloc {
#ifdef CLANG_OBJC_ARC_DISABLED
	if (name != nil)
		[name release];
	
	if (file != nil)
		[name release];
	
	[super dealloc];
#endif
}

@end
