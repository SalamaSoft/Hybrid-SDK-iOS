//
//  XmlContentEncoder.h
//  GetGifts
//
//  Created by XingGu Liu on 12-5-13.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XmlContentEncoder : NSObject

+(NSString*)stringByEncodeXmlSpecialChars:(NSString*)inputString;

+(char*) encodeXmlSpecialChars:(const char*)input;

@end
