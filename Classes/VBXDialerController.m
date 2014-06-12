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

#import "VBXDialerController.h"
#import "VBXDialerAccessor.h"
#import "VBXOutgoingPhone.h"
#import "VBXResult.h"
#import "UIExtensions.h"
#import "NSExtensions.h"
#import "VBXUserDefaultsKeys.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "UIViewPositioningExtension.h"
#import "VBXGlobal.h"
#import "VBXMaskedImageView.h"
#import "VBXCallerIdController.h"
#import "VBXObjectBuilder.h"
#import "VBXConfiguration.h"

const static int KEY_BACKGROUND_COLOR = 0xfcfcfc;
const static int KEY_HIGHLIGHTED_BACKGROUND_COLOR = 0xb1b4b8;

@interface NumberAreaView : UIView <VBXConfigurable> {
    UILabel *_numberLabel;
}
@end

@implementation NumberAreaView

- (id)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 89)]) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numberLabel.text = @"123...text to be replaced later";
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
        _numberLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _numberLabel.minimumScaleFactor = 14.0f/30.0f;
        _numberLabel.numberOfLines = 1;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [_numberLabel sizeToFit];
        [self addSubview:_numberLabel];
        
        [self applyConfig];
    }
    return self;
}


- (void)setNumber:(NSString *)number {
    _numberLabel.text = number;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _numberLabel.width = 250;
    _numberLabel.left = round((self.width / 2) - (_numberLabel.width / 2));
    _numberLabel.top = round((self.height / 2) - (_numberLabel.height / 2));
}

- (void)applyConfig {
    self.backgroundColor = ThemedColor(@"dialerNumberAreaBackgroundColor", [UIColor whiteColor]);

    _numberLabel.textColor = ThemedColor(@"dialerNumberTextColor", [UIColor blackColor]);
}

@end


@interface CallerIdControl : UIControl <VBXConfigurable> {
    UILabel *_callerIdLabel;
    UILabel *_numberNameLabel;
    UILabel *_numberLabel;
    UITableViewCell *_chevronView;
}

@property (nonatomic, strong) VBXOutgoingPhone *callerID;

@end

@implementation CallerIdControl


- (id)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 50)]) {
        _callerIdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _callerIdLabel.text = LocalizedString(@"CALLER ID", @"Dailer: Label for caller id number.");
        _callerIdLabel.backgroundColor = [UIColor clearColor];
        _callerIdLabel.font = [UIFont boldSystemFontOfSize:13];
        [_callerIdLabel sizeToFit];
        [self addSubview:_callerIdLabel];    

        _numberNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numberNameLabel.font = [UIFont boldSystemFontOfSize:16];
        _numberNameLabel.adjustsFontSizeToFitWidth = YES;
        _numberNameLabel.minimumScaleFactor = 0.5f;
        _numberNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _numberNameLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_numberNameLabel];

        _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numberLabel.font = [UIFont systemFontOfSize:12];
        _numberLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_numberLabel];

        // silly hack to use the built-in chevron image
        _chevronView = [[UITableViewCell alloc] initWithFrame:(CGRect){{0,0},{15,20}}];
        _chevronView.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _chevronView.userInteractionEnabled = NO;
        [self addSubview:_chevronView];

        [self applyConfig];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    const CGFloat leftEdgePadding = 10;
    const CGFloat chevronPadding = 25;
    
    _callerIdLabel.left = leftEdgePadding;
    _callerIdLabel.top = round((self.height / 2) - (_callerIdLabel.height / 2));

    CGFloat numberLabelWidth = self.width - _callerIdLabel.width - 2*_callerIdLabel.left - chevronPadding;
    
    [_numberNameLabel sizeToFit];
    _numberNameLabel.width = numberLabelWidth;
    _numberNameLabel.right = self.width - chevronPadding;
    _numberNameLabel.bottom = round(self.height / 2) + 5;

    [_numberLabel sizeToFit];
    _numberLabel.width = numberLabelWidth;
    _numberLabel.right = self.width - chevronPadding;
    _numberLabel.top = round(self.height / 2) + 2;

    _chevronView.right = self.width + 3;
    _chevronView.top = 3;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self applyConfig];
}

- (void)setCallerId:(VBXOutgoingPhone *)callerID {
    _numberNameLabel.text = callerID.name;
    _numberLabel.text = callerID.phone;
    _callerID = callerID;
    [self setNeedsLayout];
}

- (void)applyConfig {
    if (self.isHighlighted) {
        self.backgroundColor = ThemedColor(@"dialerCallerIdNumberHighlightedBackgroundColor", RGBHEXCOLOR(KEY_HIGHLIGHTED_BACKGROUND_COLOR));

        _numberLabel.textColor = ThemedColor(@"dialerCallerIdNumberHighlightedTextColor", [UIColor blackColor]);
        _callerIdLabel.textColor = ThemedColor(@"dialerCallerIdLabelHighlightedTextColor", [UIColor blackColor]);
    } else {
        self.backgroundColor = ThemedColor(@"dialerCallerIdNumberBackgroundColor", RGBHEXCOLOR(KEY_BACKGROUND_COLOR));

        _numberLabel.textColor = ThemedColor(@"dialerCallerIdNumberTextColor", ThemedColor(@"primaryTextColor", [UIColor blackColor]));
        _callerIdLabel.textColor = ThemedColor(@"dialerCallerIdLabelTextColor", RGBHEXCOLOR(0x333333));
    }
}

@end


@interface CallKey : UIControl <VBXConfigurable> {
    UILabel *_label;
}
@end

@implementation CallKey

- (id)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 110, 61)]) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.text = LocalizedString(@"Call", @"Dialer: Label for call button");
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont boldSystemFontOfSize:28];
        _label.shadowOffset = CGSizeMake(0, -1);
        
        [_label sizeToFit];
        [self addSubview:_label];
        
        [self applyConfig];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _label.top = round((self.height / 2) - (_label.height / 2));
    _label.left = round((self.width / 2) - (_label.width / 2));
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self applyConfig];
}

- (void)applyConfig {
    if (self.isHighlighted) {
        self.backgroundColor = RGBHEXCOLOR(0x2e8a38);
        _label.textColor = ThemedColor(@"dialerCallKeyHighlightedTextColor", ThemedColor(@"dialerNumberKeyDigitHighlightedTextColor", [UIColor whiteColor]));
    } else {
        self.backgroundColor = RGBHEXCOLOR(0x48d457);
        _label.textColor = ThemedColor(@"dialerCallKeyTextColor", ThemedColor(@"dialerNumberKeyDigitTextColor", [UIColor whiteColor]));
    }    
}

@end


@interface AccessoryKey : UIControl <VBXConfigurable> {
    VBXMaskedImageView *_iconView;
}

@end

@implementation AccessoryKey

- (id)initWithImage:(UIImage *)image {
    if (self = [super initWithFrame:CGRectMake(0, 0, 105, 61)]) {
        _iconView = [[VBXMaskedImageView alloc] initWithImage:image];
        _iconView.backgroundColor = [UIColor clearColor];
        [_iconView sizeToFit];
        [self addSubview:_iconView];
        
        [self applyConfig];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self applyConfig];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _iconView.left = round((self.width / 2) - (_iconView.width / 2));
    _iconView.top = round((self.height / 2) - (_iconView.height / 2));
}

- (void)applyConfig {
    if (self.isHighlighted) {
        _iconView.startColor = ThemedColor(@"dialerSpecialKeyIconHighlightedGradientBeginColor", [UIColor blackColor]);
        _iconView.endColor = ThemedColor(@"dialerSpecialKeyIconHighlightedGradientEndColor", [UIColor blackColor]);
        self.backgroundColor = ThemedColor(@"dialerSpecialKeyIconHighlightedBackgroundColor", RGBHEXCOLOR(KEY_BACKGROUND_COLOR));
    } else {
        _iconView.startColor = ThemedColor(@"dialerSpecialKeyIconGradientBeginColor", [UIColor blackColor]);
        _iconView.endColor = ThemedColor(@"dialerSpecialKeyIconGradientEndColor", [UIColor blackColor]);
        self.backgroundColor = ThemedColor(@"dialerSpecialKeyIconBackgroundColor", RGBHEXCOLOR(KEY_HIGHLIGHTED_BACKGROUND_COLOR));
    }
    
    [_iconView setNeedsDisplay];    
}

@end

typedef enum {
    NumberKeyTypeMiddle,
    NumberKeyTypeSide
} NumberKeyType;

@interface NumberKey : UIControl <VBXConfigurable> {
    NumberKeyType _type;
    UILabel *_numberLabel;
    UILabel *_lettersLabel;
}

- (id)initWithType:(NumberKeyType)type number:(NSString *)number letters:(NSString *)letters;

- (NSString *)keyValue;

@end


@implementation NumberKey

- (id)initWithType:(NumberKeyType)type number:(NSString *)number letters:(NSString *)letters {
    if (self = [super initWithFrame:CGRectMake(0, 0, (type == NumberKeyTypeMiddle ? 110 : 105), 54)]) {
        _type = type;

        NSString *fontName = @"HelveticaNeue-Light";

        _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numberLabel.text = number;
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.font = [UIFont fontWithName:fontName size:28];
        [_numberLabel sizeToFit];
        [self addSubview:_numberLabel];
        
        _lettersLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _lettersLabel.text = letters;
        _lettersLabel.backgroundColor = [UIColor clearColor];
        _lettersLabel.font = [UIFont fontWithName:fontName size:11];
        [_lettersLabel sizeToFit];
        [self addSubview:_lettersLabel];
        
        [self applyConfig];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _numberLabel.top = 2;
    _numberLabel.left = round((self.width / 2) - (_numberLabel.width / 2));    
    
    _lettersLabel.bottom = self.height - 6;
    _lettersLabel.left = round((self.width / 2) - (_lettersLabel.width / 2));
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [RGBHEXCOLOR(0x929292) setStroke];
    CGRect r = self.bounds;
    r.origin.y -= 1;
    r.size.height += 1;
    if (_type == NumberKeyTypeSide) {
        r.origin.x -= 1;
        r.size.width += 2;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextStrokeRectWithWidth(ctx, r, 0.5f);
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self applyConfig];
}

- (NSString *)keyValue {
    return _numberLabel.text;
}

- (void)applyConfig {
    if (self.isHighlighted) {
        _numberLabel.textColor = ThemedColor(@"dialerNumberKeyDigitHighlightedTextColor", [UIColor blackColor]);
        _lettersLabel.textColor = ThemedColor(@"dialerNumberKeyLettersHighlightedTextColor", [UIColor blackColor]);
        self.backgroundColor = ThemedColor(@"dialerNumberKeyBackgroundColor", RGBHEXCOLOR(KEY_HIGHLIGHTED_BACKGROUND_COLOR));
    } else {
        self.backgroundColor = ThemedColor(@"dialerNumberKeyBackgroundColor", RGBHEXCOLOR(KEY_BACKGROUND_COLOR));
        _numberLabel.textColor = ThemedColor(@"dialerNumberKeyDigitTextColor", [UIColor blackColor]);
        _lettersLabel.textColor = ThemedColor(@"dialerNumberKeyLettersTextColor", [UIColor blackColor]);
    }
}

@end



@interface VBXDialerController () <VBXDialerAccessorDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, strong) NSString *phoneNumber;

@end


@implementation VBXDialerController

@synthesize userDefaults = _userDefaults;
@synthesize accessor = _accessor;
@synthesize phoneNumber = _phoneNumber;

- (id)initWithPhone:(NSString *)phone {
    if (self = [super init]) {
        _initialPhoneNumber = phone;
        
        self.title = LocalizedString(@"Dialer", @"Dialer: Title for screen.");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                target:self 
                                                                                action:@selector(cancelPressed)];
        
        // We don't want the back button for our screen to take up too much space
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Back", nil)
                                                                                  style:UIBarButtonItemStyleBordered 
                                                                                 target:nil 
                                                                                 action:nil];
    }
    return self;
}

- (void)dealloc {
    self.accessor.delegate = nil;
}

- (void)applyConfig {
    [super applyConfig];

    // Make all our children views refresh with the new colors (they might not exist yet, though)
    if (_dialerView != nil) {
        [_dialerView.subviews makeObjectsPerformSelector:@selector(applyConfig)];
    }
}

- (NSString *)selectedCallerID {
    VBXOutgoingPhone *selected = [_accessor.callerIDs objectAtIndex:_selectedCallerIDIndex];
    return selected.name;
}

- (NSString *)stripNonNumbers:(NSString *)str {
    int length = str.length;
    
    unichar *chars = malloc(sizeof(unichar) * str.length);
    unichar *newChars = malloc(sizeof(unichar) * str.length);
    
    [str getCharacters:chars];
    
    int j = 0;
    for (int i = 0; i < length; i++) {
        unichar c = chars[i];
        if (c >= '0' && c <= '9') {
            newChars[j++] = c;
        }
    }
    
    NSString *newStr = [NSString stringWithCharacters:newChars length:j];
    
    free(chars);
    free(newChars);
    
    return newStr;
}

- (NSString *)formatPhoneNumber:(NSString *)number {
    if (number.length <= 1) return number;
    
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([number rangeOfCharacterFromSet:nonDigits].location != NSNotFound) return number;

    if ([number hasPrefix:@"0"]) return number;
    
    if ([number hasPrefix:@"1"]) {
        if (number.length < 4) number = [number stringByPaddingToLength:4 withString:@" " startingAtIndex:0];
        NSString *area = [number substringWithRange:NSMakeRange(1, 3)];
        if (number.length == 4) {
            return [NSString stringWithFormat:@"1 (%@)", area];
        }
        if (number.length <= 7) {
            NSString *prefix = [number substringFromIndex:4];
            return [NSString stringWithFormat:@"1 (%@) %@", area, prefix];
        }
        if (number.length <= 11) {
            NSString *prefix = [number substringWithRange:NSMakeRange(4, 3)];
            NSString *suffix = [number substringFromIndex:7];
            return [NSString stringWithFormat:@"1 (%@) %@-%@", area, prefix, suffix];
        }
        return number;
    }
    
    if (number.length <= 3) return number;
    if (number.length <= 7) {
        NSString *prefix = [number substringToIndex:3];
        NSString *suffix = [number substringFromIndex:3];
        return [NSString stringWithFormat:@"%@-%@", prefix, suffix];
    }
    if (number.length <= 10) {
        NSString *area = [number substringToIndex:3];
        NSString *prefix = [number substringWithRange:NSMakeRange(3, 3)];
        NSString *suffix = [number substringFromIndex:6];
        return [NSString stringWithFormat:@"(%@) %@-%@", area, prefix, suffix];
    }
    return number;
}

- (void)refreshView {
    [_numberAreaView setNumber:[self formatPhoneNumber:_phoneNumber]];
}

- (void)callerIdPressed {
    VBXObjectBuilder *builder = [VBXObjectBuilder sharedBuilder];
    [self.navigationController pushViewController:[builder callerIdController] animated:YES];
    _callerIdPickerIsOpen = YES;
}

- (void)deleteAfterDelay {
    [self deletePressed];
    [self performSelector:@selector(deleteAfterDelay) withObject:nil afterDelay:0.1];
}

- (void)deleteStartTimer {
    [self performSelector:@selector(deleteAfterDelay) withObject:nil afterDelay:1.0];
}

- (void)deleteStopTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(deleteAfterDelay) object:nil];
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];

    _dialerView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    _callerIdControl = [[CallerIdControl alloc] init];
    [_dialerView addSubview:_callerIdControl];    
    _callerIdControl.left = 0; _callerIdControl.top = 0;
    
    [_callerIdControl addTarget:self action:@selector(callerIdPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _numberAreaView = [[NumberAreaView alloc] init];
    if (self.view.height >= 568) { // 4" screen
        _numberAreaView.height += 88;
    }
    [_dialerView addSubview:_numberAreaView];
    _numberAreaView.left = 0; _numberAreaView.top = _callerIdControl.bottom;
    
    NumberKey *num1 = [[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"1" letters:@""];
    NumberKey *num2 = [[NumberKey alloc] initWithType:NumberKeyTypeMiddle number:@"2" letters:@"ABC"];
    NumberKey *num3 = [[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"3" letters:@"DEF"];
    NumberKey *num4 = [[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"4" letters:@"GHI"];
    NumberKey *num5 = [[NumberKey alloc] initWithType:NumberKeyTypeMiddle number:@"5" letters:@"JKL"];
    NumberKey *num6 = [[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"6" letters:@"MNO"];
    NumberKey *num7 = [[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"7" letters:@"PQRS"];
    NumberKey *num8 = [[NumberKey alloc] initWithType:NumberKeyTypeMiddle number:@"8" letters:@"TUV"];
    NumberKey *num9 = [[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"9" letters:@"WXYZ"];
    NumberKey *num0 = [[NumberKey alloc] initWithType:NumberKeyTypeMiddle number:@"0" letters:@""];
    NumberKey *numPlus = [[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"+" letters:@""];
    NumberKey *numPound = [[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"#" letters:@""];
    
    [num1 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num2 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num3 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num4 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num5 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];    
    [num6 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num7 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num8 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num9 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num0 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];    
    [numPlus addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [numPound addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];    
    
    AccessoryKey *contacts = [[AccessoryKey alloc] initWithImage:[UIImage imageNamed:@"dialer-contacts-icon-mask.png"]];
    AccessoryKey *backspace = [[AccessoryKey alloc] initWithImage:[UIImage imageNamed:@"dialer-backspace-icon-mask.png"]];
    
    [contacts addTarget:self action:@selector(chooseContactPressed) forControlEvents:UIControlEventTouchUpInside];
    [backspace addTarget:self action:@selector(deletePressed) forControlEvents:UIControlEventTouchDown];    
    [backspace addTarget:self action:@selector(deleteStartTimer) forControlEvents:UIControlEventTouchDown];    
    [backspace addTarget:self action:@selector(deleteStopTimer) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];    
    
    CallKey *call = [[CallKey alloc] init];
    [call addTarget:self action:@selector(callPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [_dialerView addSubview:num1];
    [_dialerView addSubview:num2];
    [_dialerView addSubview:num3];
    [_dialerView addSubview:num4];
    [_dialerView addSubview:num5];
    [_dialerView addSubview:num6];
    [_dialerView addSubview:num7];
    [_dialerView addSubview:num8];
    [_dialerView addSubview:num9];
    [_dialerView addSubview:num0];
    [_dialerView addSubview:numPlus];
    [_dialerView addSubview:numPound];
    [_dialerView addSubview:contacts];
    [_dialerView addSubview:backspace];
    [_dialerView addSubview:call];
    
    num1.left = 0; num1.top = _numberAreaView.bottom;
    num2.left = num1.right; num2.top = num1.top;
    num3.left = num2.right; num3.top = num1.top;
    num4.left = 0; num4.top = num1.bottom;
    num5.left = num4.right; num5.top = num1.bottom;
    num6.left = num5.right; num6.top = num1.bottom;
    num7.left = 0; num7.top = num4.bottom;
    num8.left = num4.right; num8.top = num4.bottom;
    num9.left = num5.right; num9.top = num4.bottom;
    numPlus.left = 0; numPlus.top = num7.bottom;    
    num0.left = numPlus.right; num0.top = num7.bottom;
    numPound.left = num0.right; numPound.top = num7.bottom;
    
    contacts.left = 0; contacts.top = numPlus.bottom;
    backspace.right = self.view.width; backspace.top = numPlus.bottom;
    call.left = contacts.right; call.top = contacts.top;
    
    [self.view addSubview:_dialerView];
}

- (void)viewDidLoad {
    _callerID = [[VBXOutgoingPhone alloc] initWithDictionary:[_userDefaults dictionaryForKey:VBXUserDefaultsCallerId]];
    
    if (_callerID == nil) {
        _callerID = [_accessor.callerIDs objectAtIndex:0];
    }

    // Default to whatever our last used number was...
    [_callerIdControl setCallerId:_callerID];

    _accessor.delegate = self;
    [_accessor loadCallerIDs];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:)
        name:NSUserDefaultsDidChangeNotification object:nil];

    if (!_phoneNumber) self.phoneNumber = [NSMutableString string];
    
    [_phoneNumber setString:_initialPhoneNumber];
    [_numberAreaView setNumber:_phoneNumber];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self refreshView];
    
    if (_callerIdPickerIsOpen) {
        _callerIdPickerIsOpen = NO;
        _callerID = [[VBXOutgoingPhone alloc] initWithDictionary:[_userDefaults dictionaryForKey:VBXUserDefaultsCallerId]];
        [_callerIdControl setCallerId:_callerID];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _accessor.delegate = nil;
}

- (void)chooseContactPressed {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)makeCallAfterDelay {
    _callIsBeingScheduled = NO;
    [_accessor call:_phoneNumber usingCallerID:_callerID.phone];
}

- (void)callPressed {
    if (_callerID == nil || _callerID.phone.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Emtpy Caller ID", @"Dialer: Title for alert when caller id is not set")
                                                        message:LocalizedString(@"You must set your caller ID before placing a call.", @"Dialer: Body for alert when caller id is not set.")
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    } else if (VBXStripNonDigitsFromString(VBXFormatPhoneNumber(_phoneNumber)).length == 0) {
        // Just don't do anything.  The native dialer does nothing until you enter a number.
    } else {
        [self setPromptAndDimView:LocalizedString(@"Calling...", @"Dialer: Navigation bar prompt shown when call is being scheduled.")];
        [self performSelector:@selector(makeCallAfterDelay) withObject:nil afterDelay:1.5];
        
        _callIsBeingScheduled = YES;
    }
}

- (void)numberPressed:(id)sender {
    NumberKey *button = sender;
    [_phoneNumber appendString:[button keyValue]];
    [self refreshView];
}

- (void)deletePressed {
    if (_phoneNumber.length < 1) return;
    NSRange range = NSMakeRange([_phoneNumber length] - 1, 1);
    [_phoneNumber deleteCharactersInRange:range];
    [self refreshView];
}

- (void)cancelPressed {
    if (_callIsBeingScheduled) {
        // They pressed cancel right as we were about to place a call, so it only cancels the
        // call not the whole dialer
        [self unsetPromptAndUndim];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(makeCallAfterDelay) object:nil];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self refreshView];
}

#pragma mark PeoplePicker delegate methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {

    // We return YES so the details on this person is displayed.
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    
    NSString *name = [NSString stringWithFormat:@"%@ %@",
                      (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty)),
                      (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty))];
    
    
    ABMultiValueRef phoneProperty = ABRecordCopyValue(person, property);
	NSString *phone = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneProperty, identifier));
    CFRelease(phoneProperty);
    
    debug(@"Name = %@", name);
    debug(@"Phone Number = %@", phone);
    
    [_phoneNumber setString:[self stripNonNumbers:phone]];
    [self refreshView];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    // Don't do the default action - we'll handle closing the picker
    return NO;
}

#pragma mark DialerAccessor delegate methods

- (void)accessorCallerIDsResponseArrived:(VBXDialerAccessor *)accessor fromCache:(BOOL)fromCache {
    if (accessor.callerIDs.count > 0 && _callerIdControl.callerID.phone.length < 1) {
        _callerID = [_accessor.callerIDs objectAtIndex:0];
        [_userDefaults setValue:[_callerID dictionary] forKey:VBXUserDefaultsCallerId];
        [_callerIdControl setCallerId:_callerID];

    }
    [self refreshView];
}

- (void)removePromptAfterDelay {
    [self unsetPromptAndUndim];
}

- (void)accessorDidPlaceCall:(VBXDialerAccessor *)accessor {
    self.navigationItem.prompt = LocalizedString(@"Done! You'll get a call in a moment.", @"Dialer: Navigation bar prompt shown when call was successfully scheduled.");
    [self performSelector:@selector(removePromptAfterDelay) withObject:nil afterDelay:1.0];
}

- (void)accessor:(VBXDialerAccessor *)accessor callFailedWithError:(NSError *)error {
    debug(@"%@", [error detailedDescription]);
    [self unsetPromptAndUndim];

    if ([error isTwilioErrorWithCode:VBXErrorLoginRequired]) return;
    [UIAlertView showAlertViewWithTitle:LocalizedString(@"Call could not be placed", @"Dialer: Title for alert shown when call fails.") forError:error];
}

#pragma mark State saving

- (NSDictionary *)saveState {
    NSMutableDictionary *state = [NSMutableDictionary dictionary];
    
    if (_phoneNumber) { 
        [state setObject:_phoneNumber forKey:@"to"];
    }

    if (_callerID != nil) {
        [state setObject:[_callerID dictionary] forKey:@"from"];
    }
    
    return state;
}

- (void)restoreState:(NSDictionary *)state {
    
    // Make our view load early so we can fiddle with it.
    [self view];
    
    NSString *phoneValue = [state stringForKey:@"to"];
    id fromValue = [state objectForKey:@"from"];
    
    if (phoneValue) {
        self.phoneNumber = [NSMutableString stringWithString:phoneValue];
        [_numberAreaView setNumber:self.phoneNumber];
    }
    
    if (fromValue) {
        _callerID = [[VBXOutgoingPhone alloc] initWithDictionary:fromValue];
        [_callerIdControl setCallerId:_callerID];
    }
}

- (void)setPromptAndDimView:(NSString *)title {
    [super setPromptAndDimView:title];
    
    [UIView beginAnimations:@"StayInPlace" context:nil];
    [UIView setAnimationDuration:0.35];
    _dialerView.top -= 74 - TOOLBAR_HEIGHT;
    [UIView commitAnimations];
}

- (void)unsetPromptAndUndim {
    [super unsetPromptAndUndim];

    [UIView beginAnimations:@"StayInPlace" context:nil];
    [UIView setAnimationDuration:0.35];
    _dialerView.top = 0;
    [UIView commitAnimations];
}


@end
