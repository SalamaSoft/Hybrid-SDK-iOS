//
//  BaseTypeConverter.m
//  MoreGifts
//
//  Created by XingGu Liu on 12-5-16.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "BaseTypeConverter.h"

#import "../../util/GTM/Foundation/GTMBase64.h"

@interface BaseTypeConverter(PrivateMethod)

+(void)checkGMTFormatter;

@end

@implementation BaseTypeConverter

static NSString* GMT_DATE_TIME_FORMATTER_STYLE = @"yyyy-MM-dd HH:mm:ss.SSSSSZZ";

static NSDateFormatter* GMTFormatter;

+(void)checkGMTFormatter
{
    if(GMTFormatter == nil)
    {
        GMTFormatter =  [[NSDateFormatter alloc] init];
        [GMTFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSZZ"];
    }
}


+(char)convertStringToChar:(NSString*)val
{
    if(val != nil && val.length > 0)
    {
        return (char)[val intValue];
    }
    else {
        return 0;
    }
}

+(NSString*)convertCharToString:(char)val
{
    int i = (int)val;
    return [NSString stringWithFormat:@"%d", i];
}

+(bool)convertStringToBool:(NSString*)val
{
    if(val == nil)
    {
        return false;
    }
    
    NSString* lowerCase = [val lowercaseString];
    if( [lowerCase isEqualToString:@"true"])
    {
        return true;
    }
    else if( [lowerCase isEqualToString:@"false"])
    {
        return false;
    }
    else if( [lowerCase isEqualToString:@"0"])
    {
        return false;
    }
    else 
    {
        return true;
    }
}

+(NSString*)convertBoolToString:(bool)val
{
    if(val)
    {
        return @"True";
    }
    else 
    {
        return @"False";
    }
}

+(BOOL)convertStringToBOOL:(NSString*)val
{
    if([val intValue] == 0)
    {
        return NO;
    }
    else 
    {
        return true;
    }
}

+(NSString*)convertBOOLToString:(BOOL)val
{
    return [[NSNumber numberWithBool:val] stringValue];
}

+(short)convertStringToShort:(NSString*)val
{
    if(val != nil && val.length > 0)
    {
        return (short)[val intValue];
    }
    else 
    {
        return 0;
    }
}
+(NSString*)convertShortToString:(short)val
{
    return [NSString stringWithFormat:@"%hi", val];
}

+(int)convertStringToInt:(NSString*)val
{
    if(val != nil && val.length > 0)
    {
        return [val intValue];
    }
    else 
    {
        return 0;
    }
}
+(NSString*)convertIntToString:(int)val
{
    return [NSString stringWithFormat:@"%d", val];
}

+(long)convertStringToLong:(NSString*)val
{
    if(val != nil && val.length > 0)
    {
        return (long)[val longLongValue];
    }
    else 
    {
        return 0;
    }
}
+(NSString*)convertLongToString:(long)val
{
    return [NSString stringWithFormat:@"%ld", val];
}

+(long long)convertStringToLongLong:(NSString*)val
{
    if(val != nil && val.length > 0)
    {
        return (long)[val longLongValue];
    }
    else 
    {
        return 0;
    }
}
+(NSString*)convertLongLongToString:(long long)val
{
    return [NSString stringWithFormat:@"%lld", val];
}

+(float)convertStringToFloat:(NSString*)val
{
    if(val != nil && val.length > 0)
    {
        return [val floatValue];
    }
    else 
    {
        return 0;
    }
}
+(NSString*)convertFloatToString:(float)val
{
    return [NSString stringWithFormat:@"%f", val];
}

+(double)convertStringToDouble:(NSString*)val
{
    if(val != nil && val.length > 0)
    {
        return [val doubleValue];
    }
    else 
    {
        return 0;
    }
}
+(NSString*)convertDoubleToString:(double)val
{
    return [NSString stringWithFormat:@"%f", val];
}

+(NSDecimalNumber*)convertStringToDecimal:(NSString*)val
{
    if(val != nil && val.length > 0)
    {
        return [NSDecimalNumber decimalNumberWithString:val];
    }
    else 
    {
        return nil;
    }
}

+(NSString*)convertDecimalNumberToString:(NSDecimalNumber*)val
{
    if(val != nil)
    {
        return [val stringValue];
    }
    else 
    {
        return nil;
    }
}

//use GMT date format in C#
+(NSDate*)convertStringToDate:(NSString*)val
{
    if(val != nil && val.length > 0)
    {
        [BaseTypeConverter checkGMTFormatter];
        
        NSString* dateStrTmp = [val stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        return [GMTFormatter dateFromString:dateStrTmp]; 
    }
    else 
    {
        return nil;
    }
}
+(NSString*)convertDateToString:(NSDate*)val
{
    if(val != nil)
    {
        [BaseTypeConverter checkGMTFormatter];
        
        NSString* dateStr = [GMTFormatter stringFromDate:val]; 
        
        return [dateStr stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    }
    else 
    {
        return nil;
    }
}

//Use base64 encode
+(NSData*)convertStringToData:(NSString*)val
{
    if(val != nil && val.length > 0)
    {
        return [GTMBase64 decodeString:val];
    }
    else 
    {
        return nil;
    }
}
+(NSString*)convertDataToString:(NSData*)val
{
    if(val != nil && val.length > 0)
    {
        return [GTMBase64 stringByEncodingData:val];
    }
    else {
        return nil;
    }
}

@end
