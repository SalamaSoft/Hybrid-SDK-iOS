//
//  PropertyInfo.h
//  MoreGifts
//
//  Created by XingGu Liu on 12-5-15.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/*
 Property Types are achieved from PropertyAttributes. These are the tested results of property attributes  below:
 ------------------------------------------
 PropertyName      PropertyAttributes
 ------------------------------------------
 fBOOl             Tc,N,VfBOOl
 fbool             TB,N,Vfbool
 fByte             TC,N,VfByte
 fSignedByte       Tc,N,VfSignedByte
 fchar             Tc,N,Vfchar
 fusignedchar      TC,N,Vfusignedchar
 fshort            Ts,N,Vfshort
 fushort           TS,N,Vfushort
 fint              Ti,N,Vfint
 fuint             TI,N,Vfuint
 fNSInteger        Ti,N,VfNSInteger
 fNSUInteger       TI,N,VfNSUInteger
 fusignedint       TI,N,Vfusignedint
 flong             Tl,N,Vflong
 fusignedlong      TL,N,Vfusignedlong
 flonglong         Tq,N,Vflonglong
 funsignedlonglong TQ,N,Vfunsignedlonglong
 ffloat            Tf,N,Vffloat
 fFloat32          Tf,N,VfFloat32
 fFloat64          Td,N,VfFloat64
 fdouble           Td,N,Vfdouble
 fNSString         T@"NSString",&,N,VfNSString
 fNSDecimalNumber  T@"NSDecimalNumber",&,N,VfNSDecimalNumber
 fNSDate           T@"NSDate",&,N,VfNSDate
 fNSData           T@"NSData",&,N,VfNSData
 ------------------------------------------

 Notes:
 1. The first item in attributes is the type infomation.
 2. & meanings pointer type.
 3. N meanings (nonatomic).
 4. W meanings (weak).
 5. C meanings (copy).
 
 */
typedef enum PropertyType{
    //char,BOOL,SignedByte
    PropertyType_char,
    //Byte,unsigned char
    PropertyType_unsigned_char,
    //bool
    PropertyType_bool, 
    //short
    PropertyType_short, 
    //ushort
    PropertyType_ushort, 
    //int,NSInteger
    PropertyType_int, 
    //uint, NSUInteger,unsigned int,
    PropertyType_uint, 
    //long
    PropertyType_long, 
    //unsigned long
    PropertyType_ulong, 
    //long long
    PropertyType_longlong, 
    //unsigned long long
    PropertyType_ulonglong, 
    //float, Float32
    PropertyType_float, 
    //double, Float64
    PropertyType_double, 
    //NSString
    PropertyType_NSString, 
    //NSDecimalNumber
    PropertyType_NSDecimalNumber, 
    //NSDate
    PropertyType_NSDate,
    //NSData
    PropertyType_NSData,
    //Other data class
    PropertyType_Other
} PropertyType;

@interface PropertyInfo : NSObject
{
    @private
    NSString* _propertyClassName;
}

@property (nonatomic, retain) NSString* propertyName;

@property (nonatomic, assign) PropertyType propertyType;

@property (nonatomic, retain) NSString* propertyAttributes;

-(id)initWithName:(NSString*)name attributes:(NSString*)attributes;

-(id)initWithProperty:(objc_property_t)property;

-(NSString*)propertyClassName;

@end
