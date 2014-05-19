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

#import "VBXMessageAttribute.h"
#import "VBXMessageDetail.h"
#import "VBXTicketStatus.h"
#import "VBXUser.h"

@interface VBXMessageAttribute ()

@property (nonatomic, copy) id (^valueGetter)();
@property (nonatomic, copy) void (^valueSetter)(id);

@property (nonatomic, assign) NSString *(^titleGetter)();
@property (nonatomic, assign) NSString *(^detailGetter)();

@end

@implementation VBXMessageAttribute

+ (VBXMessageAttribute *)assignedUserAttributeForMessage:(VBXMessageDetail *)detail name:(NSString *)name {
    VBXMessageAttribute *attribute = [VBXMessageAttribute new];
    attribute.messageDetail = detail;
    attribute.key = @"assigned";
    attribute.name = name;
    attribute.options = detail.activeUsers;
    attribute.valueGetter = ^{ return [detail assignedUser]; };
    attribute.valueSetter = ^(VBXUser *user){ [detail setAssignedUser:user]; };
    attribute.titleGetter = ^(VBXUser *user){ return user.fullName; };
    attribute.detailGetter = ^(VBXUser *user){ return user.email; };

    return attribute;
}

+ (VBXMessageAttribute *)ticketStatusAttributeForMessage:(VBXMessageDetail *)detail name:(NSString *)name {
    VBXMessageAttribute *attribute = [VBXMessageAttribute new];
    attribute.messageDetail = detail;
    attribute.key = @"ticket_status";
    attribute.name = name;
    attribute.options = [NSArray arrayWithObjects:
                         [VBXTicketStatus ticketStatusWithValue:@"open"],
                         [VBXTicketStatus ticketStatusWithValue:@"closed"],
                         [VBXTicketStatus ticketStatusWithValue:@"pending"],
                         nil];
    attribute.valueGetter = ^{ return [detail ticketStatus]; };
    attribute.valueSetter = ^(id status){ [detail setTicketStatus:status]; };
    attribute.titleGetter = ^(id value){ return [value title]; };
    return attribute;
}

@synthesize messageDetail = _messageDetail;
@synthesize key = _key;
@synthesize name = _name;
@synthesize options = _options;

@synthesize valueGetter;
@synthesize valueSetter;
@synthesize pendingValue = _pendingValue;

@synthesize titleGetter;
@synthesize detailGetter;


- (id)value {
    return self.valueGetter();
}

- (void)setValue:(id)value {
    self.valueSetter(value);
}

- (NSInteger)selectedIndex {
    return [_options indexOfObject:self.value];
}

- (BOOL)hasDetail {
    return detailGetter != nil;
}

- (NSString *)titleForValue:(id)value {
    return self.titleGetter(value);
}

- (NSString *)detailForValue:(id)value {
    return self.hasDetail ? self.detailGetter(value) : nil;
}

- (NSString *)keyForValue:(id)value {
    return [value key];
}

@end
