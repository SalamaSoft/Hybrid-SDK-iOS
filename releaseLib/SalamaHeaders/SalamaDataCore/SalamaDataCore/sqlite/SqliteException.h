//
//  SqliteException.h
//  WorkHarder
//
//  Created by XingGu Liu on 12-5-6.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqliteException : NSException
{
    @private
    int _errorCode;
    NSString* _operation;
}

+(id)exceptionWithErrorCode:(int)errorCode operation:(NSString*)operation;

-(id)initWithErrorCode:(int)errorCode operation:(NSString*)operation;

-(int) getErrorCode;
-(NSString*) getOperation;

@end
