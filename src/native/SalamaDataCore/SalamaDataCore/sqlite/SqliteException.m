//
//  SqliteException.m
//  WorkHarder
//
//  Created by XingGu Liu on 12-5-6.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "SqliteException.h"

@implementation SqliteException

+(id)exceptionWithErrorCode:(int)errorCode operation:(NSString*)operation
{
    
    return [[SqliteException alloc] initWithErrorCode:errorCode operation:operation];
}

-(id)initWithErrorCode:(int)errorCode operation:(NSString*)operation
{
    self = [super initWithName:@"SqliteException" reason:[NSString stringWithFormat:@"%d %@", errorCode, operation] userInfo:nil];
    
    _errorCode = errorCode;
    
    _operation = [NSString stringWithString:operation];
    
    return self;
}

-(int) getErrorCode
{
    return _errorCode;
}

-(NSString*) getOperation
{
    return _operation;
}


@end
