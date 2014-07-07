//
//  NativeService.m
//  Workmate
//
//  Created by XingGu Liu on 12-2-8.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "NativeService.h"

#import <objc/runtime.h>

#import "XmlContentEncoder.h"
#import "BaseTypeConverter.h"
#import "SimpleMetoXML.h"
#import "WebVariableStack.h"

/*
@interface NativeService(PriviteMethod)

+ (char)charFromStr:(NSString*)strVal;

-(void) initObjs;

-(void) releaseObjs;

-(id)findTarget:(NSString*)targetName thisView:(id)thisView;

-(NSString*) getParamStringValue:(NSString*)paramXml;

-(BOOL)hasChildrenOfParamXml:(NSString *)paramXml;

-(id)findValueFromWebVariableStack:(NSString*)varName thisView:(id)thisView;

- (void)setNumberTypeArgumentOfInvocation:(NSInvocation*)invocation argType:(char)argType param:(NSString*)param index:(int)index;

@end
*/

@implementation NativeService

//@synthesize thisView;

static NSString* JS_PREFIX_NATIVE_SERVICE = @"nativeService://";
static NSString* JS_PREFIX_NATIVE_SERVICE_LOWER = @"nativeservice://";

static NSString* SPECIAL_SERVICE_THIS_VIEW = @"thisView";

+(id) parseNativeServiceCmd:(NSString*)cmd
{
    if([cmd hasPrefix:JS_PREFIX_NATIVE_SERVICE] || [cmd hasPrefix:JS_PREFIX_NATIVE_SERVICE_LOWER])
    {
        return [InvokeMsg invokeMsgWithXml:[InvokeMsg decodeURLString:[cmd substringFromIndex:16]]];
    }
    else
    {
        return nil;
    }
}

/* old version
+(InvokeMsg*) parseNativeServiceCmd:(NSString*)cmd
{
    if([cmd hasPrefix:JS_PREFIX_NATIVE_SERVIVE])
    {
        NSString *cmdContent = [cmd substringFromIndex:[JS_PREFIX_NATIVE_SERVIVE length]];
        
        NSArray *array1 = [cmdContent componentsSeparatedByString:@","];
        
        InvokeMsg *invokeMsg = [[InvokeMsg alloc] init];
        
        invokeMsg.target = [[NSString alloc] initWithString:[array1 objectAtIndex:0]];
        
        invokeMsg.method = [[NSString alloc] initWithString:[array1 objectAtIndex:1]];
        
        invokeMsg.callBackWhenSucceed = [[NSString alloc] initWithString:[array1 objectAtIndex:2]];
        
        invokeMsg.callBackWhenError = [[NSString alloc] initWithString:[array1 objectAtIndex:3]];

        if([array1 count] > 4)
        {
            NSRange rangeParams;
            rangeParams.location = 2;
            rangeParams.length = [array1 count] - 2;
            
            invokeMsg.params = [array1 subarrayWithRange:rangeParams];
        }
        
        array1 = nil;
        
        return invokeMsg;
    }
    else
    {
        return nil;
    }
}
*/

-(id) init
{
	if(self=[super init])
	{
        //Super init succeeded
        [self initObjs];
	}
    
    return self;
}

-(void) dealloc
{
    //release objs
    [self releaseObjs];
    
#ifdef CLANG_OBJC_ARC_DISABLED
	[super dealloc];
#endif
    
    SSLogDebug(@"WebController::dealloc");
}

+ (char)charFromStr:(NSString *)strVal
{
    if(strVal == nil)
    {
        return 0;
    }
    else
    {
        if(strVal.length == 1)
        {
            return [strVal characterAtIndex:0];
        }
        else
        {
            NSString* strValLowerCase = [strVal lowercaseString];
            if([strValLowerCase isEqualToString:@"true"])
            {
                return 1;
            }
            else if ([strValLowerCase isEqualToString:@"false"])
            {
                return 0;
            }
            else
            {
                return [strVal characterAtIndex:0];
            }
        }
    }
}

-(void) initObjs
{
    _targetDict = [[NSMutableDictionary alloc] init];
}

-(void) releaseObjs
{
    [_targetDict removeAllObjects];
    _targetDict = nil;
}

-(void)registerService:(NSString*)serviceName service:(id)service
{
    [_targetDict setObject:service forKey:serviceName];
    //SSLogDebug(@"NativeService registerService() serviceName:%@", serviceName);
}

-(id) invoke:(NSString*)targetName method:(NSString*)methodName params:(NSArray*)params thisView:(id)thisView
{
    //find the target named targetName
    id target;

    //Because thisView is supposed to be used in the most cases, so judge it at first. 
    if([SPECIAL_SERVICE_THIS_VIEW isEqualToString:targetName])
    {
        target = thisView;
    }
    else 
    {
        target = [self findTarget:targetName thisView:thisView];
    }
    
    NSInteger paramsCount = 0;
    int paramsArgCount = 2;
    if(params != nil)
    {
        paramsCount = params.count;
    }
    paramsArgCount += paramsCount;
    
    //find method signature
    NSMethodSignature* signature = nil;
    SEL selector;
    Method invokeMethod = nil;

    if(paramsCount == 0)
    {
        selector = NSSelectorFromString(methodName);
        
        signature = [target methodSignatureForSelector:selector];
    }
    else 
    {
        unsigned int methodCount = 0;
        Method* methodList = nil;
        NSString* methodNameTmp = nil;
        int argCount = 0;

        Class clsTmp = [target class];

        while(clsTmp != nil)
        {
            //find all the super class
            methodList = class_copyMethodList(clsTmp, &methodCount);
            
            for(int i = 0; i < methodCount; i++)
            {
                methodNameTmp = NSStringFromSelector(method_getName(methodList[i]));
                argCount = method_getNumberOfArguments(methodList[i]);
                //SSLogDebug(@"method[%i]:%@ argCount:%i paramsArgCount:%i", i, methodNameTmp, argCount, paramsArgCount);
                
                if([methodNameTmp hasPrefix:methodName]
                   && ((methodNameTmp.length == methodName.length && paramsArgCount == 2)
                       ||
                       (argCount == paramsArgCount
                        && [methodNameTmp characterAtIndex:methodName.length] == ':'
                        )
                       )
                    )
                {
                    selector = NSSelectorFromString(methodNameTmp);
                    signature = [target methodSignatureForSelector:selector];
                    invokeMethod = methodList[i];
                    break;
                }
            }
            
            free(methodList);

            if(signature != nil)
            {
                break;
            }

            clsTmp = [clsTmp superclass];
            if(clsTmp == nil)
            {
                break;
            }
            //NSLog(@"target super class:%@", NSStringFromClass(clsTmp));
        }//while
        
    }
    
    //invoke
    //SSLogDebug(@"signature:%@ paramsCount:%i", signature, paramsCount);
    
    @try {
        if(signature)
        {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            
            [invocation retainArguments];
            
            [invocation setTarget:target];
            [invocation setSelector:selector];
            
            int index;
            char argType;
            NSString* paramXml = nil;
            
            for(int i = 0; i < paramsCount; i++)
            {
                paramXml = [params objectAtIndex:i];
                
                index = i + 2;
                
                const char* argTypeStr = [signature getArgumentTypeAtIndex:index];
                argType = argTypeStr[0];
                
                if(argType == '@')
                {
                    //xml value
                    /* No need to check if it is String type. The SimpleMetoXml will convert the xml to the right object type.
                     if(![self hasChildrenOfParamXml:paramXml])
                     {
                     //Treat it as String
                     NSString* paramVal = [SimpleMetoXML stringToObject:paramXml dataType:[NSString class]];
                     
                     [invocation setArgument:&paramVal atIndex:index];
                     }
                     else
                     */
                    {
                        //other type, treated as object
                        
                        id param = [SimpleMetoXML stringToObject:paramXml];
                        
                        if([param isKindOfClass:[NSString class]] && [param hasPrefix:@"$"])
                        {
                            if([param hasPrefix:@"$$"])
                            {
                                //decode: "$$" -> "$"
                                NSString* var = [param substringFromIndex:1];
                                [invocation setArgument:&var atIndex:index];
                            }
                            else if([param hasPrefix:@"$"])
                            {
                                //value stack
                                id var = [self findValueFromWebVariableStack:[param substringFromIndex:1] thisView:thisView];
                                [invocation setArgument:&var atIndex:index];
                            }
                            else
                            {
                                [invocation setArgument:&param atIndex:index];
                            }
                        }
                        else
                        {
                            [invocation setArgument:&param atIndex:index];
                        }
                    }
                    
                }
                else
                {
                    //xml value
                    if(argType == 'c' || argType == 'C')
                    {
                        id paramVal = [SimpleMetoXML stringToObject:paramXml];
                        unsigned char cParamVal;
                        
                        if([paramVal isKindOfClass:[NSDecimalNumber class]])
                        {
                            cParamVal = [(NSDecimalNumber*)paramVal intValue];
                        }
                        else if ([paramVal isKindOfClass:[NSString class]])
                        {
                            cParamVal = [NativeService charFromStr:paramVal];
                        }
                        else
                        {
                            cParamVal = [NativeService charFromStr:[paramVal stringValue]];
                        }
                        
                        [invocation setArgument:&cParamVal atIndex:index];
                    }
                    else
                    {
                        NSString* strParamVal = [self getParamStringValue:paramXml];
                        
                        [self setNumberTypeArgumentOfInvocation:invocation argType:argType param:strParamVal index:index];
                    }
                }
                
            }
            
            //invoke
            //SSLogDebug(@"invoke:%@", methodName);
            [invocation invoke];
            
            if(signature.methodReturnLength)
            {
                NSLog(@"methodReturnType:%s", signature.methodReturnType);
                __unsafe_unretained id returnValue;
                //id __weak returnValue = nil;
                //id returnValue = nil;
                //id returnValue;
                
                if(signature.methodReturnType[0] == '@')
                {
                    [invocation getReturnValue:&returnValue];
                }
                else if(signature.methodReturnType[0] == 'q')
                {
                    long long returnValueTmp;
                    [invocation getReturnValue:&returnValueTmp];
                    returnValue = [NSString stringWithFormat:@"%lld", returnValueTmp];
                }
                else if(signature.methodReturnType[0] == 'i')
                {
                    int returnValueTmp;
                    [invocation getReturnValue:&returnValueTmp];
                    returnValue = [NSString stringWithFormat:@"%d", returnValueTmp];
                }
                else if(signature.methodReturnType[0] == 'f')
                {
                    float returnValueTmp;
                    [invocation getReturnValue:&returnValueTmp];
                    returnValue = [NSString stringWithFormat:@"%f", returnValueTmp];
                }
                else if(signature.methodReturnType[0] == 'd')
                {
                    double returnValueTmp;
                    [invocation getReturnValue:&returnValueTmp];
                    returnValue = [NSString stringWithFormat:@"%f", returnValueTmp];
                }
                else if(signature.methodReturnType[0] == 'c')
                {
                    char returnValueTmp;
                    [invocation getReturnValue:&returnValueTmp];
                    returnValue = [NSString stringWithFormat:@"%d", returnValueTmp];
                }
                else if(signature.methodReturnType[0] == 'D')
                {
                    long double returnValueTmp;
                    [invocation getReturnValue:&returnValueTmp];
                    returnValue = [NSString stringWithFormat:@"%Lf", returnValueTmp];
                }
                
                return returnValue;
            }
            else
            {
                return nil;
            }
        }
        else 
        {
            return nil;
        }
    }
    @catch (NSException *exception) {
        //SSLogError(@"error name:%@ reasone:%@", exception.name, exception.reason);
        //return nil;
        @throw exception;
    }
    @finally {
    }
}

- (void)setNumberTypeArgumentOfInvocation:(NSInvocation*)invocation argType:(char)argType param:(NSString*)param index:(int)index
{
    if(argType == 'i') 
    {
        int paramVal = [param intValue];
        [invocation setArgument:&paramVal atIndex:index];
    }
    else if(argType == 'L') 
    {
        unsigned long paramVal = [param longLongValue];
        [invocation setArgument:&paramVal atIndex:index];
    }
    else if(argType == 'd') 
    {
        double paramVal = [param doubleValue];
        [invocation setArgument:&paramVal atIndex:index];
    }
    else if(argType == 'c')
    {
        char paramVal = [param characterAtIndex:0];
        [invocation setArgument:&paramVal atIndex:index];
    }
    else if(argType == 'B') 
    {
        bool paramVal = [BaseTypeConverter convertStringToBool:param];
        [invocation setArgument:&paramVal atIndex:index];
    }
    else if(argType == 's') 
    {
        short paramVal = [param intValue];
        [invocation setArgument:&paramVal atIndex:index];
    }
    else if(argType == 'S') 
    {
        unsigned short paramVal = [param intValue];
        [invocation setArgument:&paramVal atIndex:index];
    }
    else if(argType == 'I') 
    {
        unsigned int paramVal = [param longLongValue];
        [invocation setArgument:&paramVal atIndex:index];
    }
    else if(argType == 'l') 
    {
        long paramVal = [param longLongValue];
        [invocation setArgument:&paramVal atIndex:index];
    }
    else if(argType == 'q') 
    {
        long long paramVal = [param longLongValue];
        [invocation setArgument:&paramVal atIndex:index];
    }
    else if(argType == 'Q') 
    {
        NSDecimalNumber* decimal = [NSDecimalNumber decimalNumberWithString:param];
        unsigned long long paramVal = [decimal unsignedLongLongValue];
        
        [invocation setArgument:&paramVal atIndex:index];
    }
    else if(argType == 'f') 
    {
        float paramVal = [param floatValue];
        [invocation setArgument:&paramVal atIndex:index];
    }
}

//Private methods below
-(id)findTarget:(NSString*)targetName thisView:(id)thisView
{
    NSRange range = [targetName rangeOfString:@"."];

    id targetObj = nil;
    NSString* targetObjName = nil;
    
    if(range.location == NSNotFound)
    {
        targetObjName = targetName;
    }
    else 
    {
        targetObjName = [targetName substringToIndex:range.location];
    }
    
    if([SPECIAL_SERVICE_THIS_VIEW isEqualToString:targetObjName])
    {
        targetObj = thisView;
    }
    else if([targetObjName hasPrefix:@"$"])
    {
        //value stack
        if([thisView conformsToProtocol:@protocol(WebVariableStack)])
        {
            NSString* varName = [targetObjName substringFromIndex:1];

            targetObj = [self findValueFromWebVariableStack:varName thisView:thisView];
            
            if(targetObj == nil)
            {
                return nil;
            }
        }
        else 
        {
            //not support variable stack
            return nil;
        }
    }
    else
    {
        //dict
        targetObj = [_targetDict objectForKey:targetObjName];
        if(targetObj == nil)
        {
            return nil;
        }
    }

    if(range.location == NSNotFound)
    {
        return targetObj;
    }
    else 
    {
        NSString* targetPropertyPath = [targetName substringFromIndex:(range.location + 1)];
        if([targetPropertyPath rangeOfString:@"."].location == NSNotFound)
        {
            return [targetObj valueForKey:targetPropertyPath];
        }
        else {
            return [targetObj valueForKeyPath:targetPropertyPath];
        }
    }
}

-(id)findValueFromWebVariableStack:(NSString*)varName thisView:(id)thisView
{
    id targetObj = nil;
    
    targetObj = [((id<WebVariableStack>)thisView) getVariable:varName scope:WebVariableStackScopeTemp];
    if(targetObj == nil)
    {
        targetObj = [((id<WebVariableStack>)thisView) getVariable:varName scope:WebVariableStackScopePage];
    }
    if(targetObj == nil && [varName isEqualToString:SPECIAL_SERVICE_THIS_VIEW])
    {
        return thisView;
    }
    else
    {
        return targetObj;
    }
}

-(BOOL)hasChildrenOfParamXml:(NSString *)paramXml
{
    //<xxx><aaa></aaa></xxx>
    NSRange rangeOfLastTagEnd = [paramXml rangeOfString:@"</" options:NSBackwardsSearch];
    
    NSRange rangeOf2ndSearch;
    rangeOf2ndSearch.location = 0;
    rangeOf2ndSearch.length = rangeOfLastTagEnd.location;
    
    NSRange rangeOfLastChildTagEnd = [paramXml rangeOfString:@"</" options:NSBackwardsSearch range:rangeOf2ndSearch];
    
    if(rangeOfLastChildTagEnd.location != NSNotFound)
    {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSString *)getParamStringValue:(NSString *)paramXml
{
    //get string in these tags: <String>xxxx</String>, <Number>xxxxxx</Number>
    NSRange rangeOfFirstRT = [paramXml rangeOfString:@">"];
    NSRange rangeOfLastLT = [paramXml rangeOfString:@"<" options:NSBackwardsSearch];
    
    if(rangeOfFirstRT.location != NSNotFound && rangeOfLastLT.location != NSNotFound)
    {
        NSRange rangeOfValue;
        
        rangeOfValue.location = rangeOfFirstRT.location + 1;
        rangeOfValue.length = rangeOfLastLT.location - rangeOfValue.location;
        
        if(rangeOfValue.length == 0)
        {
            return @"";
        }
        else 
        {
            return [paramXml substringWithRange:rangeOfValue];
        }
    }
    else
    {
        //Format error
        SSLogError(@"NativeService Error in parsing the InvokeMsg: param format is invalid. param:%@", paramXml);
        return @"";
    }
    
}

///////////////////////////////////// Test ////////////////////////////////////////
/*
-(void)test1
{
    //id target = [WebManager webController].nativeService;
    //[self testMethodInfoAndPrintLog:self method:@"testMethod1"];
    
    [self test2:self];
    
    
    //[self testMethodInfoAndPrintLog:self method:@"testMethod2"];

    //[self testMethodInfoAndPrintLog:self method:@"testMethodInfo:p:p:"];
    
    //[self testMethodInfoAndPrintLog:self method:@"testStaticMethodInfo:"];
}

-(void)test2:(id)target
{
    unsigned int methodCount = 0;
    Method* methodList = class_copyMethodList([target class], &methodCount);
    NSString* methodName = nil;
    int argCount = 0;
    NSMethodSignature* signature = nil;
    SEL selector;
    char argType[50];
    memset(argType, 0, 50);
    
    for(int i = 0; i < methodCount; i++)
    {
        methodName = NSStringFromSelector(method_getName(methodList[i]));
        argCount = method_getNumberOfArguments(methodList[i]);

        selector = NSSelectorFromString(methodName);
        
        signature = [target methodSignatureForSelector:selector];

        //struct objc_method_description* methodDesc = method_getDescription(methodList[i]);
        const char* typeEncoding = method_getTypeEncoding(methodList[i]);
        NSLog(@"method[%i]:%@ argCount:%i typeEncoding:%s", i, methodName, argCount, typeEncoding);
        
        for(int j = 0; j < argCount; j++)
        {
            method_getArgumentType(methodList[i], j, argType, 50);

            NSLog(@"---->arg[%i].type:%s", j, argType);
        }
    }
    
    free(methodList);
}

-(void)test3
{
    [self registerService:@"this" service:self];
    
    [self invoke:@"this" method:@"testMethod2" params:[NSArray arrayWithObjects:@"test1", @"true", @"1234", nil]];
}

-(long long)testMethod1
{
    return 0;
}

-(long long)testMethod2:(NSString*)p1 p2:(bool)p2 p3:(short)p3
{
    NSLog(@"testMethod2:%@ p2:%hi p3:%hi", p1, (short)p2, p3);
    return 0;
}

-(long long)testMethodInfo:(char)p1 p2:(bool)p2 p3:(short)p3 p4:(int)p4 p5:(long)p5 p6:(long long)p6 
                        p7:(float)p7 p8:(double)p8 p9:(NSString*)p9 p10:(NSNumber*)p10 p11:(NSDecimalNumber*)p11 p12:(NSDate*)p12 p13:(NSData*)p13
{
    return 0;
}

+(long long)testStaticMethodInfo:(char)p1 p2:(bool)p2 p3:(short)p3 p4:(int)p4 p5:(long)p5 p6:(long long)p6 
p7:(float)p7 p8:(double)p8 p9:(NSString*)p9 p10:(NSNumber*)p10 p11:(NSDecimalNumber*)p11 p12:(NSDate*)p12 p13:(NSData*)p13
{
    return 0;
}
*/

@end
