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
#import "VBXAudioPlaybackController.h"

@protocol VBXAudioControlDelegate;

@interface VBXAudioControl : UIView {
    UIButton *_controlButton;
    UIActivityIndicatorView *_activityIndicator;
    
    id<VBXAudioControlDelegate> __weak _delegate;
    id _context;
    
    BOOL _isPlayButton;
    BOOL _isPauseButton;
    BOOL _isStopButton;
}

@property (nonatomic, weak) id<VBXAudioControlDelegate> delegate;
@property (nonatomic, strong) id context;

- (void)showPlayButton;
- (void)showPauseButton;
- (void)showStopButton;

@end

@protocol VBXAudioControlDelegate
- (void)audioControlDidPressControl:(VBXAudioControl *)audioControl;
@end