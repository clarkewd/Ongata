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


@interface VBXFolderSummary : NSObject {
    NSString *_key;
    NSString *_name;
    NSInteger _total;
    NSInteger _new;
    NSInteger _read;
    NSInteger _archived;
}

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger new;
@property (nonatomic, assign) NSInteger read;
@property (nonatomic, assign) NSInteger archived;

@end
