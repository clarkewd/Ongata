/**
 * "The contents of this file are subject to the Mozilla Public License
 *  Version 1.1 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 
 *  Software distributed under the License is distributed on an "AS IS"
 *  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *  License for the specific language governing rights and limitations
 *  under the License.
 
 *  The Original Code is OpenVBX, released February 18, 2011.
 
 *  The Initial Developer of the Original Code is Twilio Inc.
 *  Portions created by Twilio Inc. are Copyright (C) 2010.
 *  All Rights Reserved.
 
 * Contributor(s):
 **/

#import "VBXResourceLoader.h"
#import "VBXResourceRequest.h"
#import "VBXURLLoader.h"
#import "VBXCache.h"
#import "UIExtensions.h"
#import "NSURLExtensions.h"
#import "NSExtensions.h"
#import "VBXUserDefaultsKeys.h"
#import "VBXGlobal.h"

@interface VBXResourceLoader () <VBXURLLoaderDelegate>

@end


@implementation VBXResourceLoader {
    NSMutableArray *_urlLoaders;
}

+ (VBXResourceLoader *)loader {
    return [[VBXResourceLoader new] autorelease];
}

- (id)init {
    if (self = [super init]) {
        _urlLoaders = [NSMutableArray new];
    }
    return self;
}

@synthesize successAction = _successAction;
@synthesize errorAction = _errorAction;
@synthesize answersAuthChallenges = _answersAuthChallenges;
@synthesize cache = _cache;
@synthesize userDefaults = _userDefaults;
@synthesize baseURL = _baseURL;

- (void)setTarget:(id<VBXResourceLoaderTarget>)target {
    __block id<VBXResourceLoaderTarget> weakTarget = target;
    self.successAction = ^(VBXResourceLoader *loader, id object, BOOL usingCache, BOOL hadTrustedCertificate){
        [weakTarget loader:loader didLoadObject:object fromCache:usingCache hadTrustedCertificate:hadTrustedCertificate];
    };
    self.errorAction = ^(VBXResourceLoader *loader, NSError *error){
        [weakTarget loader:loader didFailWithError:error];
    };
}

- (void)dealloc {
    [self cancelAllRequests];
    [_urlLoaders release];
    [_successAction release];
    [_errorAction release];
    self.cache = nil;
    self.userDefaults = nil;
    self.baseURL = nil;
    [super dealloc];
}

- (NSString *)keyForRequest:(NSURLRequest *)request {
    return [[request URL] absoluteString];
}

- (BOOL)finishWithData:(NSData *)data fromCache:(BOOL)fromCache hadTrustedCertificate:(BOOL)hadTrustedCertificate {
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error != nil) {
        debug(@"Got error (%@) while parsing JSON: %@", error, [[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding] autorelease]);
        if (_errorAction) {
            _errorAction(self, [NSError twilioErrorForBadJSON:[error description]]);
        }
        return NO;
    }
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = object;
    
        if ([dict containsKey:@"error"] && ([[dict objectForKey:@"error"] boolValue])) {
            if (_errorAction) {
                _errorAction(self, [NSError twilioErrorForServerError:[dict objectForKey:@"message"]]);
            }
            return NO;
        }
    }

    if (_successAction) {
        _successAction(self, object, fromCache, hadTrustedCertificate);
    }
    
    return YES;
}

- (NSURLRequest *)URLRequestForRequest:(VBXResourceRequest *)request {
    NSURL *url = _baseURL ? _baseURL : [_userDefaults VBXURLForKey:VBXUserDefaultsBaseURL];
    NSMutableURLRequest *urlRequest = [request URLRequestWithBaseURL:url];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest addValue:[[UIDevice currentDevice] systemIdentifier] forHTTPHeaderField:@"X-Openvbx-Client"];
    [urlRequest addValue:CLIENT_VERSION forHTTPHeaderField:@"X-Openvbx-Client-Version"];
    return urlRequest;
}

- (void)loadRequest:(VBXResourceRequest *)request {
    [self loadRequest:request usingCache:YES];
}

- (void)loadRequest:(VBXResourceRequest *)request usingCache:(BOOL)usingCache {
    debug(@"%@", request);
    NSURLRequest *urlRequest = [self URLRequestForRequest:request];
    if (usingCache && [request isGet]) {
        NSString *cacheKey = [self keyForRequest:urlRequest];
        NSData *data = [_cache dataForKey:cacheKey];
        if (data) {
            [self finishWithData:data fromCache:YES hadTrustedCertificate:[_cache hadTrustedCertificateForDataForKey:cacheKey]];
        }
    }
     
    VBXURLLoader *urlLoader = [VBXURLLoader loadRequest:urlRequest andInform:self answerAuthChallenges:_answersAuthChallenges];
    [_urlLoaders addObject:urlLoader];
}

- (void)cancelAllRequests {
    [_urlLoaders makeObjectsPerformSelector:@selector(cancel)];
}

- (void)loader:(VBXURLLoader *)loader didFinishWithData:(NSData *)data {
    [_urlLoaders removeObject:loader];
    
    [_cache cacheData:data hadTrustedCertificate:loader.hadTrustedCertificate forKey:[self keyForRequest:loader.request]];            
    [self finishWithData:data fromCache:NO hadTrustedCertificate:loader.hadTrustedCertificate];
}

- (void)loader:(VBXURLLoader *)loader didFailWithError:(NSError *)error {
    [_urlLoaders removeObject:loader];
    debug(@"%@", error);
    if (_errorAction) {
        _errorAction(self, error);
    }
}

@end
