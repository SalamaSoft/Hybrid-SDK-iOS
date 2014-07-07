//
//  InvokeMsg.m
//  Workmate
//
//  Created by XingGu Liu on 12-2-12.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "InvokeMsg.h"

#import "SimpleMetoXML.h"

@interface InvokeMsg(PrivateMethod)

+ (InvokeMsg*) createOneInvokeMsgWithXmlNode:(xmlNodePtr)nodeTmp;


@end

@implementation InvokeMsg

@synthesize target;
@synthesize method;
@synthesize params;
@synthesize callBackWhenSucceed;
@synthesize callBackWhenError;

@synthesize isAsync;
@synthesize returnValueKeeper;
@synthesize keeperScope;

@synthesize notification;

+(NSString *)decodeURLString:(NSString*)str
{
    NSMutableString *resultString = [NSMutableString stringWithString:str];
    
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    
    NSString* decodedStr = [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return decodedStr;
}

+(id) invokeMsgWithXml:(NSString*)xml
{
    SSLogDebug(@"invokeMsgWithXml:%@", xml);
    
    xmlDocPtr xmlDoc = NULL;
    xmlNodePtr rootNode = NULL;
    xmlKeepBlanksDefault(0);
    
    @try {
        xmlDoc = xmlReadDoc(BAD_CAST([xml UTF8String]), "InvokeMsg.xml", NULL, XML_PARSE_NONET | XML_PARSE_NODICT | XML_PARSE_NOCDATA);
        
        rootNode = xmlDocGetRootElement(xmlDoc);
        
        if([[NSString stringWithUTF8String:(char*)rootNode->name] isEqualToString:@"List"])
        {
            xmlNodePtr dataNode = NULL;
            
            dataNode = rootNode->children;
            
            NSMutableArray* array = [[NSMutableArray alloc] init];
            
            while(dataNode != NULL)
            {
                [array addObject:[InvokeMsg createOneInvokeMsgWithXmlNode:dataNode]];
                
                dataNode = dataNode->next;
            }
            
            return array;
        }
        else
        {
            return [InvokeMsg createOneInvokeMsgWithXmlNode:rootNode];
        }
        
        
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        //xmlFreeNodeList(rootNode);
        xmlFreeDoc(xmlDoc);
        //xmlCleanupParser();
        //xmlCleanupMemory();
    }
}

+ (InvokeMsg*) createOneInvokeMsgWithXmlNode:(xmlNodePtr)dataNode
{
    xmlNodePtr nodeTmp = NULL;
    xmlNodePtr nodeTmp2 = NULL;
    
    NSString* nodeName = nil;
    NSString* nodeText = nil;
    
    NSString* nodeName2 = nil;
    NSString* nodeText2 = nil;

    InvokeMsg* invokeMsg = [[InvokeMsg alloc] init];
    
    nodeTmp = dataNode->children;

    while(nodeTmp != NULL)
    {
        nodeName = [NSString stringWithUTF8String:(char*)nodeTmp->name];
        
        if([@"params" isEqualToString:nodeName])
        {
            invokeMsg.params = [[NSMutableArray alloc] init];
            
            nodeTmp2 = nodeTmp->children;
            
            while(nodeTmp2 != NULL)
            {
                nodeName2 = [NSString stringWithUTF8String:(char*)nodeTmp2->name];
                
                if([@"String" isEqualToString:nodeName2])
                {
                    nodeText2 = [SimpleMetoXML getNodeContent:nodeTmp2];
                    
                    [((NSMutableArray*)invokeMsg.params) addObject:nodeText2]; 
                }
                
                nodeName2 = nil;
                
                nodeTmp2 = nodeTmp2->next;
            }
        }
        else
        {
            nodeText = [SimpleMetoXML getNodeContent:nodeTmp];
            
            if([@"target" isEqualToString:nodeName])
            {
                invokeMsg.target = nodeText;
            }
            else if([@"method" isEqualToString:nodeName])
            {
                invokeMsg.method = nodeText;
            }
            else if([@"callBackWhenSucceed" isEqualToString:nodeName])
            {
                invokeMsg.callBackWhenSucceed = nodeText;
            }
            else if([@"callBackWhenError" isEqualToString:nodeName])
            {
                invokeMsg.callBackWhenError = nodeText;
            }
            else if ([@"isAsync" isEqualToString:nodeName])
            {
                if([nodeText isEqualToString:@"true"])
                {
                    invokeMsg.isAsync = true;
                }
                else 
                {
                    invokeMsg.isAsync = false;
                }
            }
            else if ([@"returnValueKeeper" isEqualToString:nodeName])
            {
                invokeMsg.returnValueKeeper = nodeText;
            }
            else if ([@"keeperScope" isEqualToString:nodeName])
            {
                invokeMsg.keeperScope = nodeText;
            }
            else if ([@"notification" isEqualToString:nodeName])
            {
                invokeMsg.notification = nodeText;
            }
            
        }
        
        nodeName = nil;
        nodeTmp = nodeTmp->next;
    }
    
    return invokeMsg;
}

@end
