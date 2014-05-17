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

#import <Foundation/Foundation.h>

@class VBXResourceRequest;
@class VBXCache;
@class VBXResourceLoader;
@protocol VBXResourceLoaderTarget;

typedef void (^VBXResourceLoaderSuccessAction)(VBXResourceLoader *loader, id object, BOOL usingCache, BOOL hadTrustedCertificate);
typedef void (^VBXResourceLoaderErrorAction)(VBXResourceLoader *, NSError *);

@interface VBXResourceLoader : NSObject

+ (VBXResourceLoader *)loader;

@property (nonatomic, copy) VBXResourceLoaderSuccessAction successAction;
@property (nonatomic, copy) VBXResourceLoaderErrorAction errorAction;
@property (nonatomic, assign) BOOL answersAuthChallenges;
@property (nonatomic, retain) VBXCache *cache;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) NSURL *baseURL;

- (void)setTarget:(id<VBXResourceLoaderTarget>)target; // sets successAction and errorAction

- (void)loadRequest:(VBXResourceRequest *)request;
- (void)loadRequest:(VBXResourceRequest *)request usingCache:(BOOL)usingCache;
- (void)cancelAllRequests;

- (NSURLRequest *)URLRequestForRequest:(VBXResourceRequest *)request;
- (NSString *)keyForRequest:(NSURLRequest *)request;

@end

@protocol VBXResourceLoaderTarget <NSObject>
- (void)loader:(VBXResourceLoader *)loader didLoadObject:(id)object fromCache:(BOOL)cache hadTrustedCertificate:(BOOL)hadTrustedCertificate;
- (void)loader:(VBXResourceLoader *)loader didFailWithError:(NSError *)error;
@end
