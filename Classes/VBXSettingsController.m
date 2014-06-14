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

#import "VBXSettingsController.h"
#import "VBXUserDefaultsKeys.h"
#import "UIViewPositioningExtension.h"
#import "VBXTableView.h"
#import "NSExtensions.h"
#import "NSURLExtensions.h"
#import "VBXTextFieldCell.h"
#import "VBXButtonCell.h"
#import "VBXFooterTextCell.h"
#import "VBXDataSource.h"
#import "VBXSectionedDataSource.h"
#import "VBXAppDelegate.h"
#import "VBXSetNumberController.h"
#import "VBXLicenseController.h"
#import "VBXObjectBuilder.h"
#import "VBXGlobal.h"
#import "VBXConfiguration.h"

@interface VBXSettingsController () <UITableViewDelegate, UITextFieldDelegate, VBXSetNumberControllerDelegate>
@end


@implementation VBXSettingsController

@synthesize userDefaults = _userDefaults;
@synthesize builder = _builder;
@synthesize configAccessor = _configAccessor;

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (id)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Done", @"Settings: Title for done button in upper right.")
                                                                           style:UIBarButtonItemStyleDone 
                                                                          target:self
                                                                           action:@selector(done)];
        self.title = LocalizedString(@"Settings", @"Settings: Title for screen");
    }
    return self;
}


- (UIView *)tableBackgroundView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = _tableView.backgroundColor;
    return view;
}

- (void)loadView {
    [super loadView];
    
    _callbackPhoneField = [[VBXTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    _callbackPhoneField.textLabel.text = LocalizedString(@"Your Number", @"Settings: Label for callback number field.");
    _callbackPhoneField.detailTextLabel.text = VBXFormatPhoneNumber([_userDefaults stringForKey:VBXUserDefaultsCallbackPhone]);
    _callbackPhoneField.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _logoutButton = [[VBXButtonCell alloc] initWithText:LocalizedString(@"Logout", @"Settings: Label for logout button.") reuseIdentifier:nil];
    _licenseButton = [[VBXButtonCell alloc] initWithText:LocalizedString(@"Software Licenses", @"Settings: Label for license button.") reuseIdentifier:nil];

    NSString *serverPrefix = [NSString stringWithFormat:LocalizedString(@"Server:", @"Settings: Label that appears before the server."), nil];
    NSString *serverURL = [_userDefaults objectForKey:VBXUserDefaultsBaseURL];
    NSString *serverUser = [NSString stringWithFormat:LocalizedString(@"\nLogged in as %@", @"Settings: Indicates the current account being used.\n\n"), [_userDefaults stringForKey:VBXUserDefaultsEmailAddress]];
    NSString *serverText = [NSString stringWithFormat:@"%@ %@\n%@", serverPrefix, serverURL, serverUser];
    VBXFooterTextCell *serverLabel = [[VBXFooterTextCell alloc] initWithText:serverText reuseIdentifier:nil];
    serverLabel.contentInsets = UIEdgeInsetsMake(12, 0, 12, 0);
    [serverLabel setBackgroundView:[self tableBackgroundView]];

    _cellDataSource = [VBXSectionedCellDataSource dataSourceWithHeadersCellsAndFooters:
                      // Callback phone number
                      @"",
                      _callbackPhoneField,
                      LocalizedString(@"When you place phone calls using Ongata, you'll be called at this number to make the connection.", @"Settings: description text shown below phone number in the settings app, explains why we need the phone number."),
                      // Server info / Login info
                      @"\n",
                      serverLabel,
					  @"\n",
					  @"",
                      // Logout Button
                      _logoutButton,
					  // License Button
					  _licenseButton,
					  @"",
                      nil];

    self.tableView.alwaysBounceVertical = NO;
    self.tableView.dataSource = _cellDataSource;
    self.tableView.delegate = _cellDataSource;
    _cellDataSource.proxyToDelegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)fadeToMainFlow:(UIView *)blackView {
    [UIView animateWithDuration:0.75 animations:^{
        blackView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [blackView removeFromSuperview];
    }];
}

- (void)fadeToDark {
    UIView *blackView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    blackView.backgroundColor = [UIColor blackColor];
    blackView.alpha = 0.0;
    blackView.userInteractionEnabled = YES;

    [[UIApplication sharedApplication].keyWindow addSubview:blackView];

    [UIView animateWithDuration:0.75 animations:^{
        blackView.alpha = 1.0;
    } completion:^(BOOL finished) {
        VBXAppDelegate *appDelegate = (VBXAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate showSetupFlow];

        [appDelegate.window bringSubviewToFront:blackView];

        [self performSelector:@selector(fadeToMainFlow:) withObject:blackView afterDelay:0.0];
    }];
}

- (void)logout {
    [self fadeToDark];
    VBXClearAllData();
}

- (void)phoneNumberWasValidated:(UIViewController *)sender {
    [sender.navigationController dismissViewControllerAnimated:YES completion:nil];
    _callbackPhoneField.detailTextLabel.text = [_userDefaults stringForKey:VBXUserDefaultsCallbackPhone];    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == _logoutButton) {        
        [self logout];
	} else if (cell == _licenseButton) {
		VBXLicenseController *controller = [_builder setLicenseController];
		[self.navigationController pushViewController:controller animated:YES];
    } else if (cell == _callbackPhoneField) {
        VBXSetNumberController *controller = [_builder setNumberController];
        controller.delegate = self;
        controller.finishedButtonText = LocalizedString(@"Save", @"Settings: Button title used for the done action in the set number controller when invoked from settings.");
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
