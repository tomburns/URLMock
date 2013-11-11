//
//  UMOMockHTTPMessage.m
//  URLMock
//
//  Created by Prachi Gauriar on 11/9/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <URLMock/UMOMockHTTPMessage.h>
#import <URLMock/PGUtilities.h>

#pragma mark Constants

NSString *const kUMOMockHTTPMessageAcceptsHeaderField = @"accepts";
NSString *const kUMOMockHTTPMessageContentTypeHeaderField = @"content-type";
NSString *const kUMOMockHTTPMessageCookieHeaderField = @"cookie";
NSString *const kUMOMockHTTPMessageSetCookieHeaderField = @"set-cookie";

NSString *const kUMOMockHTTPMessageJSONContentTypeHeaderValue = @"application/json";
NSString *const kUMOMockHTTPMessageUTF8JSONContentTypeHeaderValue = @"application/json; charset=utf-8";
NSString *const kUMOMockHTTPMessageWWWFormURLEncodedContentTypeHeaderValue = @"application/x-www-form-urlencoded";
NSString *const kUMOMockHTTPMessageUTF8WWWFormURLEncodedContentTypeHeaderValue = @"application/x-www-form-urlencoded; charset=utf-8";


#pragma mark -

@implementation UMOMockHTTPMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
        _headers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Headers

- (NSDictionary *)headers
{
    return _headers;
}


- (void)setHeaders:(NSDictionary *)headers
{
    if (_headers == headers) return;
    
    [_headers removeAllObjects];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *field, NSString *value, BOOL *stop) {
        [self setValue:value.lowercaseString forHeaderField:field];
    }];
}


- (void)setValue:(NSString *)value forHeaderField:(NSString *)field
{
    _headers[field.lowercaseString] = value;
}


- (void)removeValueForHeaderField:(NSString *)field
{
    [_headers removeObjectForKey:field.lowercaseString];
}


#pragma mark - Body

- (id)JSONObjectFromBody
{
    return [NSJSONSerialization JSONObjectWithData:self.body options:0 error:NULL];
}


- (void)setBodyWithJSONObject:(id)JSONObject
{
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:NULL];
    if (!JSONData) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:PGExceptionString(self, _cmd, @"Invalid JSON object")
                                     userInfo:nil];
    }
    
    self.body = JSONData;
    if (!_headers[kUMOMockHTTPMessageContentTypeHeaderField]) {
        [self setValue:kUMOMockHTTPMessageUTF8JSONContentTypeHeaderValue forHeaderField:kUMOMockHTTPMessageContentTypeHeaderField];
    }
}


- (NSString *)stringFromBody
{
    return [self stringFromBodyWithEncoding:NSUTF8StringEncoding];
}


- (void)setBodyWithString:(NSString *)string
{
    [self setBodyWithString:string encoding:NSUTF8StringEncoding];
}


- (NSString *)stringFromBodyWithEncoding:(NSStringEncoding)encoding
{
    return [[NSString alloc] initWithData:self.body encoding:encoding];
}


- (void)setBodyWithString:(NSString *)string encoding:(NSStringEncoding)encoding
{
    self.body = [string dataUsingEncoding:encoding];
}

@end