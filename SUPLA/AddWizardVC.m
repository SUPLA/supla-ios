/*
 Copyright (C) AC SOFTWARE SP. Z O.O.
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import "AddWizardVC.h"
#import "SuplaApp.h"
#import "SAClassHelper.h"
#import "TFHpple.h"

#import <NetworkExtension/NetworkExtension.h>

#define RESULT_PARAM_ERROR   -3
#define RESULT_COMPAT_ERROR  -2
#define RESULT_CONN_ERROR    -1
#define RESULT_FAILED         0
#define RESULT_SUCCESS        1

#define STEP_NONE                              0
#define STEP_CHECK_REGISTRATION_ENABLED_TRY1   1
#define STEP_CHECK_REGISTRATION_ENABLED_TRY2   2
#define STEP_CONFIGURE                         3
#define STEP_DONE                              4

#define PAGE_STEP_1  1
#define PAGE_STEP_2  2
#define PAGE_STEP_3  3
#define PAGE_STEP_4  4
#define PAGE_ERROR   5
#define PAGE_DONE    6

@implementation SAConfigResult

@synthesize resultCode;

@synthesize name;
@synthesize state;
@synthesize version;
@synthesize guid;
@synthesize mac;

@end

@implementation SASetConfigOperation {
    int _result;
}

@synthesize SSID;
@synthesize PWD;
@synthesize Server;
@synthesize Email;
@synthesize delegate;

- (BOOL)postDataWithFields:(NSDictionary *)fields {
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.4.1"] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody:[[fields urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if ( response != nil && requestError == nil ) {
        NSString *html = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        return [[html lowercaseString] containsString:@"data saved"];
    }
    
    return NO;
}

-(void)_onOperationDone:(SAConfigResult*)result {
    if ( self.delegate != nil ) {
        [self.delegate performSelector:@selector(configResult:) withObject:result];
    }
};

- (void)onOperationDone:(SAConfigResult*)result  {

    [self performSelectorOnMainThread:@selector(_onOperationDone:) withObject:result waitUntilDone:NO];
}

- (void)main
{
    SAConfigResult *result = [[SAConfigResult alloc] init];
    
    if ( self.SSID == nil
        || self.SSID.length == 0
        || self.PWD == nil
        || self.PWD.length == 0
        || self.Server == nil
        || self.Server.length == 0
        || self.Email == nil
        || self.Email.length == 0 ) {
        
        result.resultCode = RESULT_PARAM_ERROR;
        [self onOperationDone:result];
        return;
    };
    
    NSData *response = nil;
    NSError *requestError = nil;

    int retryCount = 5;
    
    do {
    
        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.4.1"] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
        
        [request setHTTPMethod: @"GET"];
        
        NSURLResponse *urlResponse = nil;
        
        response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
        
        if ( requestError == nil && response != nil ) {
            break;
        } else {
            retryCount--;
            sleep(1);
        }
    
        if ( [self isCancelled] ) {
            return;
        }
        
    } while(retryCount > 0);
    
    if ( requestError != nil || response == nil ) {
        result.resultCode = RESULT_CONN_ERROR;
        [self onOperationDone:result];
        return;
    }
    
    {
        NSString *html = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSError  *error = nil;
        NSString *pattern = @"\\<h1\\>(.*)\\<\\/h1\\>\\<span\\>LAST\\ STATE:\\ (.*)\\<br\\>Firmware:\\ (.*)\\<br\\>GUID:\\ (.*)\\<br\\>MAC:\\ (.*)\\<\\/span\\>";
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
        NSArray *matches = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
        
        if ( error == nil && matches != nil && matches.count == 1 ) {
            NSTextCheckingResult *match = [matches objectAtIndex:0];
            if ([match numberOfRanges] == 6) {
                
                result.name = [html substringWithRange:[match rangeAtIndex:1]];
                result.state = [html substringWithRange:[match rangeAtIndex:2]];
                result.version = [html substringWithRange:[match rangeAtIndex:3]];
                result.guid = [html substringWithRange:[match rangeAtIndex:4]];
                result.mac = [html substringWithRange:[match rangeAtIndex:5]];
                
            }
        }
    }
    
    NSMutableDictionary *fields = [[NSMutableDictionary alloc] init];
    
    if ( result.name != nil ) {
        
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:response];
        NSArray *inputs = [doc searchWithXPathQuery:@"//input"];
        
        
        for(TFHppleElement *element in inputs) {
            
            NSDictionary *attr = [element attributes];
            if ( attr != nil ) {
                NSString *name = [attr objectForKey:@"name"];
                NSString *value = [attr objectForKey:@"value"];
                
                if ( name != nil && value != nil ) {
                    [fields setObject:value forKey:name];
                }
            }
            
        }
        
        NSArray *selects = [doc searchWithXPathQuery:@"//select"];
        
        for(TFHppleElement *element in selects) {
            NSArray *options = [element searchWithXPathQuery:@"//option[@selected=\"selected\"]"];
            if ( options.count == 1 ) {
                TFHppleElement *option = [options objectAtIndex:0];
                
                NSString *name = nil;
                NSString *value = nil;
                
                NSDictionary *attr = [element attributes];
                if ( attr != nil ) {
                    name = [attr objectForKey:@"name"];
                };
                
                attr = [option attributes];
                if ( attr != nil ) {
                    value = [attr objectForKey:@"value"];
                };
                
                if ( name != nil && value != nil ) {
                    [fields setObject:value forKey:name];
                }
            }
            
        }
    }
    
    if ( [fields objectForKey:@"sid"] == nil
        || [fields objectForKey:@"wpw"] == nil
        || [fields objectForKey:@"svr"] == nil
        || [fields objectForKey:@"eml"] == nil ) {
        
        result.resultCode = RESULT_COMPAT_ERROR;
        [self onOperationDone:result];
        
        return;
        
    }
    
    if ( [self isCancelled] ) {
        return;
    }
    
    retryCount = 3;
    
    [fields setObject:self.SSID forKey:@"sid"];
    [fields setObject:self.PWD forKey:@"wpw"];
    [fields setObject:self.Server forKey:@"svr"];
    [fields setObject:self.Email forKey:@"eml"];
    
    do {
        
        sleep(2);
        if ( [self postDataWithFields:fields] ) {
            
            [fields setObject:@"1" forKey:@"rbt"];

            result.resultCode = RESULT_SUCCESS;
            [self onOperationDone:result];
            
            return;
            
        } else {
            retryCount--;
        }
        
        if ( [self isCancelled] ) {
            return;
        }
        
    }while(retryCount > 0);
    
    
    result.resultCode = RESULT_FAILED;
    [self onOperationDone:result];
}

@end

@implementation SAAddWizardVC {
    NSTimer *_preloaderTimer;
    NSTimer *_watchDogTimer;
    NSTimer *_blinkTimer;
    int _preloaderPos;
    NSOperationQueue *_OpQueue;
    NSDate *_stepTime;
    int _step;
    int _pageId;
}

-(NSOperationQueue *)OpQueue {
    if ( _OpQueue == nil ) {
        _OpQueue = [[NSOperationQueue alloc] init];
    }
    
    return _OpQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[SAApp UI] showMenuBtn:NO];
    
    [self cleanUp];
    [self loadPrefs];
    
    self.edSSID.layer.cornerRadius = 5.0;
    self.edSSID.layer.borderWidth = 2;
    self.edSSID.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.edPassword.layer.cornerRadius = 5.0;
    self.edPassword.layer.borderWidth = 2;
    self.edPassword.layer.borderColor = self.edPassword.backgroundColor.CGColor;
    
    if ( [SAApp getAdvancedConfig] == YES ) {
        [self showError:NSLocalizedString(@"Add Wizard is only available when server connection has been set based on the email address entered in the settings.", NULL)];
        return;
    } else {
        int version = [[SAApp SuplaClient] getProtocolVersion];
        if ( version > 0 && version < 7 ) {
            [self showError:NSLocalizedString(@"The connected Server does not support this function!", NULL)];
            return;
        }
    }
    
    [self showPage:PAGE_STEP_1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegistrationEnabled:) name:kSARegistrationEnabledNotification object:nil];

    _watchDogTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *timer) {

        int timeout = 0;
        
        switch(_step) {
            case STEP_CHECK_REGISTRATION_ENABLED_TRY1:
            case STEP_CHECK_REGISTRATION_ENABLED_TRY2:
                timeout = 3;
                break;
            case STEP_CONFIGURE:
                timeout = 50;
                break;
        }
        
        if ( timeout > 0
            && _stepTime != nil
            && [[NSDate date] timeIntervalSinceDate:_stepTime] >= timeout ) {
            
            [self onWatchDogTimeout];
            
        }
        
    }];


}

-(void)viewDidDisappear:(BOOL)animated  {
    [self.OpQueue cancelAllOperations];
    [self preloaderVisible:NO];
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
    [self savePrefs];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void) cleanUp {
    if ( _watchDogTimer != nil ) {
        [_watchDogTimer invalidate];
        _watchDogTimer = nil;
    }
    
    if ( _blinkTimer != nil ) {
        [_blinkTimer invalidate];
        _blinkTimer = nil;
    }
}

-(void) loadPrefs {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [self.edSSID setText:[prefs stringForKey:@"wizard_ssid"]];

    if ( [prefs boolForKey:@"wizard_pwd_save"] ) {
        [self.cbSavePassword setOn:YES];
        [self.edPassword setText:[prefs stringForKey:@"wizard_pwd"]];
    } else {
        [self.cbSavePassword setOn:NO];
        [self.edPassword setText:@""];
    }
    
}

-(void) savePrefs {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setBool:self.cbSavePassword.isOn forKey:@"wizard_pwd_save"];
    [prefs setValue:self.edSSID.text forKey:@"wizard_ssid"];
    [prefs setValue:self.cbSavePassword.isOn ? self.edPassword.text : @"" forKey:@"wizard_pwd"];
    
}

-(void) onWatchDogTimeout {
    
    [_OpQueue cancelAllOperations];
    
    switch(_step) {
        case STEP_CHECK_REGISTRATION_ENABLED_TRY1:
            [self setStep:STEP_CHECK_REGISTRATION_ENABLED_TRY2];
            [[SAApp SuplaClient] getRegistrationEnabled];
            break;
        case STEP_CHECK_REGISTRATION_ENABLED_TRY2:
            [self showError:NSLocalizedString(@"Device registration availability information timeout!", NULL)];
            break;
        
        case STEP_CONFIGURE:
            [self showError:NSLocalizedString(@"Device Configuration Completion timeout!", NULL)];
            break;
    }
}

-(void)setStep:(int)step {
    
    if ( step == STEP_DONE || step == STEP_NONE ) {
        _stepTime = nil;
    } else {
        _stepTime = [NSDate date];
    }
    
    _step = step;
}

-(void)btnNextEnabled:(BOOL)enabled {
    self.btnNext1.enabled = enabled;
    self.btnNext2.enabled = enabled;
    self.btnNext3.enabled = enabled;
}

-(void)showPageView:(UIView*) pageView {
    
    for(UIView *subview in self.vPageContent.subviews) {
        [subview removeFromSuperview];
    }
    
    pageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
    pageView.frame =  self.vPageContent.frame;
    
    [self.vPageContent addSubview:    pageView];
}

-(void)showPage:(int)page {
    
    [self setStep:STEP_NONE];
    [self btnNextEnabled:YES];
    [self preloaderVisible:NO];
    [self.btnNext2 setAttributedTitle:NSLocalizedString(@"Next", NULL)];
    
    switch(page) {
        case PAGE_STEP_1:
            [self showPageView:self.vStep1];
            break;
        case PAGE_STEP_2:
            [self showPageView:self.vStep2];
            break;
        case PAGE_STEP_3:
        {
            _blinkTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *timer) {
                
                if ( _pageId == PAGE_STEP_3 ) {
                    self.vDot.hidden = !self.vDot.hidden;
                }
                
            }];
            
            [self showPageView:self.vStep3];
        }
            break;
        case PAGE_STEP_4:
            [self showPageView:self.vStep4];
            break;
        case PAGE_ERROR:
            [self showPageView:self.vError];
            break;
        case PAGE_DONE:
            [self showPageView:self.vDone];
            break;
    }
    
    _pageId = page;

}

- (void)showError:(NSString *)message {
    self.txtErrorMEssage.text = message;
    [self showPage:PAGE_ERROR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configResult:(SAConfigResult*)result {
    
    switch(result.resultCode) {
        case RESULT_PARAM_ERROR:
            [self showError:NSLocalizedString(@"Incorrect input parameters!", NULL)];
            break;
        case RESULT_COMPAT_ERROR:
            [self showError:NSLocalizedString(@"The connected device is not compatible with this Wizard!", NULL)];
            break;
        case RESULT_CONN_ERROR:
            [self showError:NSLocalizedString(@"Connection with the device cannot be set! Make sure, if the Wi-fi connection has been set for the I/O device.", NULL)];
            break;
        case RESULT_FAILED:
            [self showError:NSLocalizedString(@"Configuration Failed!", NULL)];
            break;
        case RESULT_SUCCESS:
            [self showPage:PAGE_DONE];
            break;
    }
    
}



-(void)preloaderVisible:(BOOL)visible {
    
    if ( _preloaderTimer ) {
        _preloaderPos = -1;
        [_preloaderTimer invalidate];
        _preloaderTimer = nil;
    }
    
    if ( visible ) {
        
        _preloaderPos = 0;
        
        _btnNext3_width.constant = 17;
        [self.btnNext3 setBackgroundImage:[UIImage imageNamed:@"btnnextr2.png"]];
        
        _preloaderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *timer) {
            
            if ( _preloaderPos == -1 ) {
                return;
            }
            
            NSString *str = @"";
            
            for(int a=0;a<10;a++) {
                str = [NSString stringWithFormat:@"%@%@", str, _preloaderPos == a ? @"|" : @"."];
            }
            
            _preloaderPos++;
            if ( _preloaderPos > 9 ) {
                _preloaderPos = 0;
            }
            
            [self.btnNext2 setAttributedTitle:str];
            
        }];
        
    } else {
        
        _btnNext3_width.constant = 40;
        [self.btnNext3 setBackgroundImage:[UIImage imageNamed:@"btnnextr.png"]];
        [self.btnNext2 setAttributedTitle:NSLocalizedString(@"Next", NULL)];
        
    }
    
}

-(NSString*)cloudHostName {
   return [[[SAApp getServerHostName] lowercaseString] containsString:@"supla.org"] ? @"cloud.supla.org" : [SAApp getServerHostName];
}

- (void)onRegistrationEnabled:(NSNotification *)notification {
    
    if ( notification.userInfo != nil )  {
        SARegistrationEnabled *reg_enabled = (SARegistrationEnabled *)[notification.userInfo objectForKey:@"reg_enabled"];
        
        if ( reg_enabled != nil ) {
            
            if ( [reg_enabled isIODeviceRegistrationEnabled] ) {
                [self showPage:PAGE_STEP_3];
            } else {
                [self showError:[NSString stringWithFormat:NSLocalizedString(@"I/O Device registration is currently off. To continue go to „I/O Devices” at %@ and enable the Device Add Button.", NULL), self.cloudHostName]];
            }
            
        };
    }
    
};

- (IBAction)nextTouchch:(id)sender {

    [self preloaderVisible:YES];
    [self btnNextEnabled:NO];
    
    switch(_pageId) {
        case PAGE_STEP_1:
            [self showPage:PAGE_STEP_2];
            break;
            
        case PAGE_STEP_2:
        {
            BOOL goNext = YES;
            
            if ( [self.edSSID.text isEqualToString:@""] ) {
                self.edSSID.layer.borderColor = [UIColor redColor].CGColor;
                goNext = NO;
            }
            
            if ( [self.edPassword.text isEqualToString:@""] ) {
                self.edPassword.layer.borderColor = [UIColor redColor].CGColor;
                goNext = NO;
            }
            
            if ( goNext ) {
                [self savePrefs];
                [self setStep:STEP_CHECK_REGISTRATION_ENABLED_TRY1];
                [[SAApp SuplaClient] getRegistrationEnabled];
            } else {
                [self preloaderVisible:NO];
                [self btnNextEnabled:YES];
            }
            
        }

            break;
        case PAGE_STEP_3:
            [self showPage:PAGE_STEP_4];
            [self.btnNext2 setAttributedTitle:NSLocalizedString(@"Start", NULL)];
            break;
        case PAGE_STEP_4:
        {
            [self setStep:STEP_CONFIGURE];
            
            [self.OpQueue cancelAllOperations];
            SASetConfigOperation *setConfigOp = [[SASetConfigOperation alloc] init];
            setConfigOp.SSID = self.edSSID.text;
            setConfigOp.PWD = self.edPassword.text;
            setConfigOp.Server = [SAApp getServerHostName];
            setConfigOp.Email = [SAApp getEmailAddress];
            setConfigOp.delegate = self;
            [self.OpQueue addOperation:setConfigOp];
        }
            break;
        case PAGE_DONE:
        case PAGE_ERROR:
            [self cancelTouch:nil];
            break;
    }
    
}

- (IBAction)cancelTouch:(id)sender {
    [self cleanUp];
    [self.OpQueue cancelAllOperations];
    [self savePrefs];
    [[SAApp UI] showMainVC];
    [[SAApp SuplaClient] reconnect];
}


- (IBAction)pwdViewTouchDown:(id)sender {
    self.edPassword.secureTextEntry = NO;
}

- (IBAction)pwdViewTouchCancel:(id)sender {
    self.edPassword.secureTextEntry = YES;
}
- (IBAction)wifiSettingsTouch:(id)sender {
    
    NSURL * urlCheck1 = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
    NSURL * urlCheck2 = [NSURL URLWithString:@"prefs:root=WIFI"];
    NSURL * urlCheck3 = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:urlCheck1])
    {
        [[UIApplication sharedApplication] openURL:urlCheck1];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:urlCheck2])
    {
        [[UIApplication sharedApplication] openURL:urlCheck2];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:urlCheck3])
    {
        [[UIApplication sharedApplication] openURL:urlCheck3];
    }
    else
    {
        NSLog(@"Unable to open settings app.");
    }
    
}
@end
