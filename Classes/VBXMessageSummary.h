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


@interface VBXMessageSummary : NSObject {
    NSString *_key;
    NSString *_caller;
    NSString *_called;
    NSString *_assigned;
    NSString *_recordingURL;
    NSString *_shortSummary;
    NSString *_receivedTime;
    NSString *_lastUpdated;
    NSString *_folder;
    BOOL _archived;
    BOOL _unread;
    BOOL _archiving;
    
    NSString *_relativeReceivedTime;
}

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *caller;
@property (nonatomic, strong) NSString *called;
@property (nonatomic, strong) NSString *assigned;
@property (nonatomic, strong) NSString *recordingURL;
@property (nonatomic, strong) NSString *shortSummary;
@property (nonatomic, strong) NSString *receivedTime;
@property (nonatomic, strong) NSString *lastUpdated;
@property (nonatomic, strong) NSString *folder;
@property (nonatomic, assign, getter=isArchived) BOOL archived;
@property (nonatomic, assign, getter=isUnread) BOOL unread;
@property (nonatomic, assign, getter=isArchiving) BOOL archiving;

@property (nonatomic, readonly) BOOL isSms;
@property (nonatomic, strong) NSString *relativeReceivedTime;

@end
