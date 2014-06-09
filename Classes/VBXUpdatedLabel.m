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

 *  (c) NanoTech 2014
 **/

#import "VBXUpdatedLabel.h"

@implementation VBXUpdatedLabel

@synthesize lastUpdatedDate;

- (id)init {
    return [self initWithFrame:(CGRect){{0,0},{200,18}}];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)applyConfig {
    self.textColor = ThemedColor(@"toolBarInfoTextColor", [UIColor blackColor]);
}

- (void)setLastUpdatedDate:(NSDate *)date {
    lastUpdatedDate = date;
    if (date) {
        self.parts = VBXStringPartsForUpdatedAtDate(date);
    } else {
        self.parts = @[];
    }
}

@end
