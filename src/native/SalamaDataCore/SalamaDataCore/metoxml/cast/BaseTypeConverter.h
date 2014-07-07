//
//  BaseTypeConverter.h
//  MoreGifts
//
//  MetoXml is designed for communicating between multiple platform(java,C#,objective-c),
//  so unsigned number is not supported.
//
//  Created by XingGu Liu on 12-5-16.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseTypeConverter : NSObject

+(char)convertStringToChar:(NSString*)val;
+(NSString*)convertCharToString:(char)Val;

+(bool)convertStringToBool:(NSString*)val;
+(NSString*)convertBoolToString:(bool)Val;

+(BOOL)convertStringToBOOL:(NSString*)val;
+(NSString*)convertBOOLToString:(BOOL)Val;

+(short)convertStringToShort:(NSString*)val;
+(NSString*)convertShortToString:(short)Val;

+(int)convertStringToInt:(NSString*)val;
+(NSString*)convertIntToString:(int)Val;

+(long)convertStringToLong:(NSString*)val;
+(NSString*)convertLongToString:(long)Val;

+(long long)convertStringToLongLong:(NSString*)val;
+(NSString*)convertLongLongToString:(long long)Val;

+(float)convertStringToFloat:(NSString*)val;
+(NSString*)convertFloatToString:(float)Val;

+(double)convertStringToDouble:(NSString*)val;
+(NSString*)convertDoubleToString:(double)Val;

+(NSDecimalNumber*)convertStringToDecimal:(NSString*)val;
+(NSString*)convertDecimalNumberToString:(NSDecimalNumber*)Val;

//use GMT date format in C#
+(NSDate*)convertStringToDate:(NSString*)val;
+(NSString*)convertDateToString:(NSDate*)val;

//Use base64 encode
+(NSData*)convertStringToData:(NSString*)val;
+(NSString*)convertDataToString:(NSData*)val;

@end
