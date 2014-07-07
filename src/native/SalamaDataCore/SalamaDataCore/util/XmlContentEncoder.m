//
//  XmlContentEncoder.m
//  GetGifts
//
//  Created by XingGu Liu on 12-5-13.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "XmlContentEncoder.h"

@implementation XmlContentEncoder

+(NSString*)stringByEncodeXmlSpecialChars:(NSString*)inputString
{
    if(inputString == nil)
    {
        return @"";
    }
    
    char* cEncoded = [XmlContentEncoder encodeXmlSpecialChars:[inputString UTF8String]];

    NSString* encodedStr = [NSString stringWithUTF8String:cEncoded];
    
    free(cEncoded);
    
    return encodedStr;
}

+(char*) encodeXmlSpecialChars:(const char*)input;
{
    const char *cur = input;
    char *buffer = NULL;
    char *output = NULL;
    int buffer_size = 0;
    if (input == NULL) return(NULL);
    
    /*
     * allocate an translation buffer.
     */
    buffer_size = 1000;
    buffer = (char *) malloc(buffer_size * sizeof(char));
    
    if (buffer == NULL) {
        return(NULL);
    }
    output = buffer;
    
    while (*cur != '\0') {
        if (output - buffer > buffer_size - 10) {
            int indx = output - buffer;

            buffer_size += 500;
            buffer = (char*)realloc(buffer, buffer_size);
            output = &buffer[indx];
        }
        
        /*
         * By default one have to encode at least '<', '>', '"' and '&' !
         */
        if (*cur == '<') {
            *output++ = '&';
            *output++ = 'l';
            *output++ = 't';
            *output++ = ';';
        } else if (*cur == '>') {
            *output++ = '&';
            *output++ = 'g';
            *output++ = 't';
            *output++ = ';';
        } else if (*cur == '&') {
            *output++ = '&';
            *output++ = 'a';
            *output++ = 'm';
            *output++ = 'p';
            *output++ = ';';
        } else if (*cur == '"') {
            *output++ = '&';
            *output++ = 'q';
            *output++ = 'u';
            *output++ = 'o';
            *output++ = 't';
            *output++ = ';';
        /*    
        } else if (*cur == '\r') {
            *output++ = '&';
            *output++ = '#';
            *output++ = '1';
            *output++ = '3';
            *output++ = ';';
        */    
        } else if (*cur == '\'') {
            *output++ = '&';
            *output++ = 'a';
            *output++ = 'p';
            *output++ = 'o';
            *output++ = 's';
            *output++ = ';';
        } else {
            /*
             * Works because on UTF-8, all extended sequences cannot
             * result in bytes in the ASCII range.
             */
            *output++ = *cur;
        }
        cur++;
    }
    *output++ = 0;
    return(buffer);
}

+(char*) encodeXmlContentForVariableInScript:(const char*)input;
{
    const char *cur = input;
    char *buffer = NULL;
    char *output = NULL;
    int buffer_size = 0;
    if (input == NULL) return(NULL);
    
    /*
     * allocate an translation buffer.
     */
    buffer_size = 1000;
    buffer = (char *) malloc(buffer_size * sizeof(char));
    
    if (buffer == NULL) {
        return(NULL);
    }
    output = buffer;
    
    while (*cur != '\0') {
        if (output - buffer > buffer_size - 10) {
            int indx = output - buffer;
            
            buffer_size += 500;
            buffer = (char*)realloc(buffer, buffer_size);
            output = &buffer[indx];
        }
        
        /*
         * By default one have to encode at least '<', '>', '"' and '&' !
         */
        if (*cur == '<') {
            *output++ = '&';
            *output++ = 'l';
            *output++ = 't';
            *output++ = ';';
        } else if (*cur == '>') {
            *output++ = '&';
            *output++ = 'g';
            *output++ = 't';
            *output++ = ';';
        } else if (*cur == '&') {
            *output++ = '&';
            *output++ = 'a';
            *output++ = 'm';
            *output++ = 'p';
            *output++ = ';';
        } else if (*cur == '"') {
            *output++ = '&';
            *output++ = 'q';
            *output++ = 'u';
            *output++ = 'o';
            *output++ = 't';
            *output++ = ';';
        } else if (*cur == '\r') {
            *output++ = '\\';
            *output++ = 'r';
        } else if (*cur == '\n') {
            *output++ = '\\';
            *output++ = 'n';
        } else if (*cur == '\'') {
            *output++ = '&';
            *output++ = 'a';
            *output++ = 'p';
            *output++ = 'o';
            *output++ = 's';
            *output++ = ';';
        } else {
            /*
             * Works because on UTF-8, all extended sequences cannot
             * result in bytes in the ASCII range.
             */
            *output++ = *cur;
        }
        cur++;
    }
    *output++ = 0;
    return(buffer);
}

@end
