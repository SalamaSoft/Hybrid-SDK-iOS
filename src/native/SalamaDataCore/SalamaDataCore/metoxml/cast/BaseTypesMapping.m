//
//  BaseTypesMapping.m
//  MoreGifts
//
//  Created by XingGu Liu on 12-5-15.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "BaseTypesMapping.h"

@implementation BaseTypesMapping

//char_Display_Name;BOOL_Display_Name;SignedByte
static NSString* PropertyType_char_Display_Name = @"char";
//Byte_Display_Name;unsigned char
//static const NSString* PropertyType_unsigned_char_Display_Name;
//bool
static NSString* PropertyType_bool_Display_Name = @"bool"; 
//short
static NSString* PropertyType_short_Display_Name = @"short"; 
//ushort
//static const NSString* PropertyType_ushort_Display_Name; 
//int_Display_Name;NSInteger
static NSString* PropertyType_int_Display_Name = @"int"; 
//uint_Display_Name; NSUInteger_Display_Name;unsigned int_Display_Name;
//static const NSString* PropertyType_uint_Display_Name; 
//long
static NSString* PropertyType_long_Display_Name = @"long"; 
//unsigned long
//static const NSString* PropertyType_ulong_Display_Name; 
//long long
static NSString* PropertyType_longlong_Display_Name = @"long"; 
//unsigned long long
//static const NSString* PropertyType_ulonglong_Display_Name; 
//float_Display_Name; Float32
static NSString* PropertyType_float_Display_Name = @"float"; 
//double_Display_Name; Float64
static NSString* PropertyType_double_Display_Name = @"double"; 
//NSString
static NSString* PropertyType_NSString_Display_Name = @"String"; 
//NSDecimalNumber
static NSString* PropertyType_NSDecimalNumber_Display_Name = @"Decimal"; 
//NSDate
static NSString* PropertyType_NSDate_Display_Name = @"Date";
//NSData
static NSString* PropertyType_NSData_Display_Name = @"bytes";

//static NSString* PropertyType_All_Supported_Type_Names = @"char,bool,short,int,long,float,double,String,Decimal,Date,";

+(BOOL)isSupportedBaseTypeByDisplayName:(NSString*)propertyTypeDisplayName
{
    if(propertyTypeDisplayName != nil && propertyTypeDisplayName.length > 0)
    {
        if([propertyTypeDisplayName isEqualToString:PropertyType_NSString_Display_Name])
        {
            return YES;
        }
        else if([propertyTypeDisplayName isEqualToString:PropertyType_int_Display_Name])
        {
            return YES;
        }
        else if([propertyTypeDisplayName isEqualToString:PropertyType_longlong_Display_Name])
        {
            return YES;
        }
        else if([propertyTypeDisplayName isEqualToString:PropertyType_double_Display_Name])
        {
            return YES;
        }
        else if([propertyTypeDisplayName isEqualToString:PropertyType_bool_Display_Name])
        {
            return YES;
        }
        else if([propertyTypeDisplayName isEqualToString:PropertyType_char_Display_Name])
        {
            return YES;
        }
        else if([propertyTypeDisplayName isEqualToString:PropertyType_short_Display_Name])
        {
            return YES;
        }
        else if([propertyTypeDisplayName isEqualToString:PropertyType_float_Display_Name])
        {
            return YES;
        }
        else if([propertyTypeDisplayName isEqualToString:PropertyType_NSDate_Display_Name])
        {
            return YES;
        }
        else if([propertyTypeDisplayName isEqualToString:PropertyType_NSDecimalNumber_Display_Name])
        {
            return YES;
        }
        else 
        {
            return NO;
        }
    } 
    else 
    {
        return NO;
    }
    
}

+(BOOL)isSupportedBaseType:(PropertyType)propertyType
{

    if (propertyType == PropertyType_NSString)
    {
        return YES;
    }
    else if (propertyType == PropertyType_int)
    {
        return YES;
    }
    else if (propertyType == PropertyType_longlong)
    {
        return YES;
    }
    else if (propertyType == PropertyType_double)
    {
        return YES;
    }
    else if (propertyType == PropertyType_long)
    {
        return YES;
    }
    else if (propertyType == PropertyType_bool)
    {
        return YES;
    }
    else if (propertyType == PropertyType_short)
    {
        return YES;
    }
    else if (propertyType == PropertyType_float)
    {
        return YES;
    }
    else if(propertyType == PropertyType_char)
    {
        return YES;
    }
    else if (propertyType == PropertyType_NSDecimalNumber)
    {
        return YES;
    }
    else if (propertyType == PropertyType_NSDate)
    {
        return YES;
    }
    else if (propertyType == PropertyType_NSData)
    {
        return YES;
    }
//    else if (propertyType == PropertyType_ushort)
//    {
//        return NO;
//    }
//    else if (propertyType == PropertyType_uint)
//    {
//        return NO;
//    }
//    else if (propertyType == PropertyType_ulong)
//    {
//        return NO;
//    }
//    else if (propertyType == PropertyType_ulonglong)
//    {
//        return NO;
//    }
//    else if (propertyType == PropertyType_unsigned_char)
//    {
//        return NO;
//    }
//    else if (propertyType == PropertyType_Other)
//    {
//        return NO;
//    }
    else
    {
        return NO;
    }
}

+(NSString*)getSupportedBaseTypeDisplayName:(PropertyType)propertyType
{
    if (propertyType == PropertyType_NSString)
    {
        return PropertyType_NSString_Display_Name;
    }
    else if (propertyType == PropertyType_int)
    {
        return PropertyType_int_Display_Name;
    }
    else if (propertyType == PropertyType_longlong)
    {
        return PropertyType_longlong_Display_Name;
    }
    else if (propertyType == PropertyType_double)
    {
        return PropertyType_double_Display_Name;
    }
    else if (propertyType == PropertyType_long)
    {
        return PropertyType_long_Display_Name;
    }
    else if (propertyType == PropertyType_bool)
    {
        return PropertyType_bool_Display_Name;
    }
    else if (propertyType == PropertyType_short)
    {
        return PropertyType_short_Display_Name;
    }
    else if (propertyType == PropertyType_float)
    {
        return PropertyType_float_Display_Name;
    }
    else if(propertyType == PropertyType_char)
    {
        return PropertyType_char_Display_Name;
    }
    else if (propertyType == PropertyType_NSDecimalNumber)
    {
        return PropertyType_NSDecimalNumber_Display_Name;
    }
    else if (propertyType == PropertyType_NSDate)
    {
        return PropertyType_NSDate_Display_Name;
    }
    else if (propertyType == PropertyType_NSData)
    {
        return PropertyType_NSData_Display_Name;
    }
    else
    {
        return @"";
    }
}

+(BOOL)isSupportedBaseObjectType:(Class)type
{
    if([type isSubclassOfClass:[NSString class]])
    {
        return YES;
    }
    else if([type isSubclassOfClass:[NSDecimalNumber class]])
    {
        return YES;
    }
    else if([type isSubclassOfClass:[NSDate class]])
    {
        return YES;
    }
    else if([type isSubclassOfClass:[NSData class]])
    {
        return YES;
    }
    else {
        return NO;
    }
}


+(NSString*)getDisplayNameBySupportedBaseObjectType:(Class)type
{
    if([type isSubclassOfClass:[NSString class]])
    {
        return PropertyType_NSString_Display_Name;
    }
    else if([type isSubclassOfClass:[NSDecimalNumber class]])
    {
        return PropertyType_NSDecimalNumber_Display_Name;
    }
    else if([type isSubclassOfClass:[NSDate class]])
    {
        return PropertyType_NSDate_Display_Name;
    }
    else if([type isSubclassOfClass:[NSData class]])
    {
        return PropertyType_NSData_Display_Name;
    }
    else {
        return nil;
        //@throw [NSException exceptionWithName:@"Error in getSupportedBaseObjectTypeDisplayName()" reason:@"Only support NSString, NSDecimalNumber,NSDate,NSData" userInfo:nil];
    }
}

+(Class)getSupportedBaseObjectTypeByDisplayName:(NSString*)displayName
{
    if([displayName isEqualToString:PropertyType_NSString_Display_Name])
    {
        return [NSString class];
    }
    else if([displayName isEqualToString:PropertyType_NSDecimalNumber_Display_Name])
    {
        return [NSDecimalNumber class];
    }
    else if ([displayName isEqualToString:PropertyType_int_Display_Name])
    {
        return [NSDecimalNumber class];
    }
    else if ([displayName isEqualToString:PropertyType_longlong_Display_Name])
    {
        return [NSDecimalNumber class];
    }
    else if ([displayName isEqualToString:PropertyType_double_Display_Name])
    {
        return [NSDecimalNumber class];
    }
    else if ([displayName isEqualToString:PropertyType_long_Display_Name])
    {
        return [NSDecimalNumber class];
    }
    else if ([displayName isEqualToString:PropertyType_bool_Display_Name])
    {
        return [NSDecimalNumber class];
    }
    else if ([displayName isEqualToString:PropertyType_short_Display_Name])
    {
        return [NSDecimalNumber class];
    }
    else if ([displayName isEqualToString:PropertyType_float_Display_Name])
    {
        return [NSDecimalNumber class];
    }
    else if([displayName isEqualToString:PropertyType_char_Display_Name])
    {
        return [NSDecimalNumber class];
    }
    else if([displayName isEqualToString:PropertyType_NSDate_Display_Name])
    {
        return [NSDate class];
    }
    else if([displayName isEqualToString:PropertyType_NSData_Display_Name])
    {
        return [NSData class];
    }
    else {
        return NULL;
        //@throw [NSException exceptionWithName:@"Error in getSupportedBaseObjectTypeByDisplayName()" reason:@"Only support NSString, NSDecimalNumber,NSDate,NSData" userInfo:nil];
    }
}

+(NSString*)getStringBySupportedBaseObject:(id)obj
{
    Class type = [obj class];
    
    if([type isSubclassOfClass:[NSString class]])
    {
        return obj;
    }
    else if([type isSubclassOfClass:[NSDecimalNumber class]])
    {
        return [(NSDecimalNumber*)obj stringValue];
    }
    else if([type isSubclassOfClass:[NSDate class]])
    {
        return [BaseTypeConverter convertDateToString:obj];
    }
    else if([type isSubclassOfClass:[NSData class]])
    {
        return [BaseTypeConverter convertDataToString:obj];
    }
    else {
        return nil;
    }
}

+(id)getSupportedBaseObjectByString:(NSString*)stringValue type:(Class)type;
{
    if([type isSubclassOfClass:[NSString class]])
    {
        return stringValue;
    }
    else if([type isSubclassOfClass:[NSDecimalNumber class]])
    {
        return [NSDecimalNumber decimalNumberWithString:stringValue];
    }
    else if([type isSubclassOfClass:[NSDate class]])
    {
        return [BaseTypeConverter convertStringToDate:stringValue];
    }
    else if([type isSubclassOfClass:[NSData class]])
    {
        return [BaseTypeConverter convertStringToData:stringValue];
    }
    else {
        return nil;
    }
}



+(void)setPropertyValueWithStringValue:(NSString*)strValue data:(id)data propertyInfo:(PropertyInfo*)propertyInfo
{
    if(propertyInfo.propertyType == PropertyType_char)
    {
        [data setValue:[NSNumber numberWithInt:[strValue intValue]] forKey:propertyInfo.propertyName];
    }
    else if (propertyInfo.propertyType == PropertyType_NSDate)
    {
        [data setValue:[BaseTypeConverter convertStringToDate:strValue] forKey:propertyInfo.propertyName];
    }
    else if (propertyInfo.propertyType == PropertyType_NSData)
    {
        [data setValue:[BaseTypeConverter convertStringToData:strValue] forKey:propertyInfo.propertyName];
    }
    else if (propertyInfo.propertyType == PropertyType_Other)
    {
        //do nothing
    }
//    else if (propertyInfo.propertyType == PropertyType_NSString)
//    {
//        [data setValue:strValue forKey:propertyInfo.propertyName];
//    }
//    else if (propertyInfo.propertyType == PropertyType_int)
//    {
//        [data setValue:strValue forKey:propertyInfo.propertyName];
//    }
//    else if (propertyInfo.propertyType == PropertyType_longlong)
//    {
//        [data setValue:strValue forKey:propertyInfo.propertyName];
//    }
//    else if (propertyInfo.propertyType == PropertyType_double)
//    {
//        [data setValue:strValue forKey:propertyInfo.propertyName];
//    }
//    else if (propertyInfo.propertyType == PropertyType_long)
//    {
//        [data setValue:strValue forKey:propertyInfo.propertyName];
//    }
//    else if (propertyInfo.propertyType == PropertyType_bool)
//    {
//        [data setValue:strValue forKey:propertyInfo.propertyName];
//    }
//    else if (propertyInfo.propertyType == PropertyType_short)
//    {
//        [data setValue:strValue forKey:propertyInfo.propertyName];
//    }
//    else if (propertyInfo.propertyType == PropertyType_float)
//    {
//        [data setValue:strValue forKey:propertyInfo.propertyName];
//    }
//    else if (propertyInfo.propertyType == PropertyType_NSDecimalNumber)
//    {
//        [data setValue:strValue forKey:propertyInfo.propertyName];
//    }
    else
    {
        [data setValue:strValue forKey:propertyInfo.propertyName];
    }
}

+(NSString*)getPropertyStringValueWithData:(id)data propertyInfo:(PropertyInfo*)propertyInfo
{
    if (propertyInfo.propertyType == PropertyType_NSString)
    {
        return (NSString*)[data valueForKey:propertyInfo.propertyName];
    }
    else if (propertyInfo.propertyType == PropertyType_bool)
    {
        NSNumber* num = [data valueForKey:propertyInfo.propertyName];
        if([num intValue] != 0)
        {
            return @"True";
        }
        else {
            return @"False";
        }
    }
    else if (propertyInfo.propertyType == PropertyType_NSDecimalNumber)
    {
        id val = [data valueForKey:propertyInfo.propertyName];
        if([val isKindOfClass:[NSString class]])
        {
            return val;
        }
        else
        {
            return [val stringValue];
        }
    }
    else if (propertyInfo.propertyType == PropertyType_NSDate)
    {
        return [BaseTypeConverter convertDateToString:[data valueForKey:propertyInfo.propertyName]];
    }
    else if (propertyInfo.propertyType == PropertyType_NSData)
    {
        return [BaseTypeConverter convertDataToString:[data valueForKey:propertyInfo.propertyName]];
    }
    else if (propertyInfo.propertyType == PropertyType_Other)
    {
        return nil;
    }
//    else if (propertyInfo.propertyType == PropertyType_int)
//    {
//        return [[data valueForKey:propertyInfo.propertyName] stringValue];
//    }
//    else if (propertyInfo.propertyType == PropertyType_longlong)
//    {
//        return [[data valueForKey:propertyInfo.propertyName] stringValue];
//    }
//    else if (propertyInfo.propertyType == PropertyType_double)
//    {
//        return [[data valueForKey:propertyInfo.propertyName] stringValue];
//    }
//    else if (propertyInfo.propertyType == PropertyType_long)
//    {
//        return [[data valueForKey:propertyInfo.propertyName] stringValue];
//    }
//    else if (propertyInfo.propertyType == PropertyType_short)
//    {
//        return [[data valueForKey:propertyInfo.propertyName] stringValue];
//    }
//    else if (propertyInfo.propertyType == PropertyType_float)
//    {
//        return [[data valueForKey:propertyInfo.propertyName] stringValue];
//    }
//    else if(propertyInfo.propertyType == PropertyType_char)
//    {
//        return [[data valueForKey:propertyInfo.propertyName] stringValue];
//    }
    else
    {
        //The valueForKey for all the primative number type uses the NSNumber
        return [[data valueForKey:propertyInfo.propertyName] stringValue];
    }
}

@end
