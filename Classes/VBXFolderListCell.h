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

#import <UIKit/UIKit.h>
#import "VBXTableViewCell.h"

@class RoundedNumberView;
@class VBXMaskedImageView;
@class VBXFolderSummary;
@class VBXConfiguration;

@interface VBXFolderListCell : VBXTableViewCell {
    VBXConfiguration *_configuration;
    
    UILabel *_label;
    VBXMaskedImageView *_icon;
    RoundedNumberView *_numberView;
    NSInteger _number;
}
@property (nonatomic, strong) VBXConfiguration *configuration;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) VBXMaskedImageView *icon;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)showFolderSummary:(VBXFolderSummary *)folderSummary;

@end
