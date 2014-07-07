//
//  PropertyInfo.m
//  MoreGifts
//
//  Created by XingGu Liu on 12-5-15.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "PropertyInfo.h"

@interface PropertyInfo(PrivateMethod)

-(BOOL)findOutPropertyType;

@end

@implementation PropertyInfo

@synthesize propertyName;

@synthesize propertyType;

@synthesize propertyAttributes;

-(id)initWithName:(NSString*)name attributes:(NSString*)attributes
{
    if(self = [super init])
    {
        propertyName = [name copy];
        propertyAttributes = [attributes copy];
        
        if(![self findOutPropertyType])
        {
            return nil;
        }
    }
    
    return self;
}

-(id)initWithProperty:(objc_property_t)property
{
    if(self = [super init])
    {
        propertyName = [NSString stringWithUTF8String:property_getName(property)];
        propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        
        if(![self findOutPropertyType])
        {
            return nil;
        }
    }
    
    return self;
}

-(NSString*)propertyClassName
{
    if(_propertyClassName != nil)
    {
        return _propertyClassName;
    }
    else
    {
        if([propertyAttributes hasPrefix:@"T@"])
        {
            NSRange range = [propertyAttributes rangeOfString:@"\","];
            NSRange rangeSubstr = NSMakeRange(3, range.location - 3);
            _propertyClassName = [propertyAttributes substringWithRange:rangeSubstr];
            
            return _propertyClassName;
        } 
        else 
        {
            return nil;
        }
    }
}

-(BOOL)findOutPropertyType
{
    if([propertyAttributes hasPrefix:@"Tc,"])
    {
        //char,BOOL,SignedByte
        propertyType = PropertyType_char;
    }
    else if([propertyAttributes hasPrefix:@"TB,"])
    {
        //bool
        propertyType = PropertyType_bool;
    }
    else if([propertyAttributes hasPrefix:@"TC,"])
    {
        //Byte,unsigned char
        propertyType = PropertyType_unsigned_char;
    }
    else if([propertyAttributes hasPrefix:@"Ts,"])
    {
        //short
        propertyType = PropertyType_short;
    }
    else if([propertyAttributes hasPrefix:@"TS,"])
    {
        //ushort
        propertyType = PropertyType_ushort;
    }
    else if([propertyAttributes hasPrefix:@"Ti,"])
    {
        //int,NSInteger
        propertyType = PropertyType_int;
    }
    else if([propertyAttributes hasPrefix:@"TI,"])
    {
        //uint, NSUInteger,unsigned int
        propertyType = PropertyType_uint;
    }
    else if([propertyAttributes hasPrefix:@"Tl,"])
    {
        //long
        propertyType = PropertyType_long;
    }
    else if([propertyAttributes hasPrefix:@"TL,"])
    {
        //unsigned long
        propertyType = PropertyType_ulong;
    }
    else if([propertyAttributes hasPrefix:@"Tq,"])
    {
        //long long
        propertyType = PropertyType_longlong;
    }
    else if([propertyAttributes hasPrefix:@"TQ,"])
    {
        //unsigned long long
        propertyType = PropertyType_ulonglong;
    }
    else if([propertyAttributes hasPrefix:@"Tf,"])
    {
        //float, Float32
        propertyType = PropertyType_float;
    }
    else if([propertyAttributes hasPrefix:@"TF,"])
    {
        //double, Float64
        propertyType = PropertyType_double;
    }
    else if([propertyAttributes hasPrefix:@"Td,"])
    {
        //double, Float64
        propertyType = PropertyType_double;
    }
    else if([propertyAttributes hasPrefix:@"T@\"NSString\","])
    {
        //NSString
        propertyType = PropertyType_NSString;
    }
    else if([propertyAttributes hasPrefix:@"T@\"NSDecimalNumber\","])
    {
        //NSDecimalNumber
        propertyType = PropertyType_NSDecimalNumber;
    }
    else if([propertyAttributes hasPrefix:@"T@\"NSDate\","])
    {
        //NSDate
        propertyType = PropertyType_NSDate;
    }
    else if([propertyAttributes hasPrefix:@"T@\"NSData\","])
    {
        //NSData
        propertyType = PropertyType_NSData;
    }
    else if([propertyAttributes hasPrefix:@"T@\","])
    {
        //Other data class
        propertyType = PropertyType_Other;
    }
    else {
        /*
        //Not supported primative type
        NSLog(@"findOutPropertyType() Not supported property type:%@",propertyAttributes);
        return NO;
        //@throw [NSException exceptionWithName:@"PropertyTypeCheckError" reason:[NSString stringWithFormat:@"Not supported property type:%@",propertyAttributes] userInfo:nil];
         */
        //to support the property type:NSArray
        propertyType = PropertyType_Other;
        
    }
    
    return YES;
}


@end
