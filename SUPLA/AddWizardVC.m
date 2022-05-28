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
#import "TFHpple.h"
#import "SASuperuserAuthorizationDialog.h"
#import "SAWifi.h"
#import "SARegistrationEnabled.h"
#import "NSDictionary+SUPLA.h"
#import "UIButton+SUPLA.h"
#import "SUPLA-Swift.h"

#define RESULT_PARAM_ERROR   -3
#define RESULT_COMPAT_ERROR  -2
#define RESULT_CONN_ERROR    -1
#define RESULT_FAILED         0
#define RESULT_SUCCESS        1

#define STEP_NONE                              0
#define STEP_CHECK_REGISTRATION_ENABLED_TRY1   1
#define STEP_CHECK_REGISTRATION_ENABLED_TRY2   2
#define STEP_CHECK_REGISTRATION_ENABLED_TRY3   3
#define STEP_SUPERUSER_AUTHORIZATION           4
#define STEP_ENABLING_REGISTRATION             5
#define STEP_WIFI_AUTO_CONNECT                 6
#define STEP_CONFIGURE                         7
#define STEP_DONE                              8

#define PAGE_STEP_1  1
#define PAGE_STEP_2  2
#define PAGE_STEP_3  3
#define PAGE_STEP_4  4
#define PAGE_ERROR   5
#define PAGE_DONE    6

@implementation SAConfigResult

@synthesize resultCode;
@synthesize extendedResultError;
@synthesize extendedResultCode;

@synthesize name;
@synthesize state;
@synthesize version;
@synthesize guid;
@synthesize mac;
@synthesize needsCloudConfig;

@end

@implementation SASetConfigOperation {
    int _result;
    int _delay;
}

@synthesize SSID;
@synthesize PWD;
@synthesize Server;
@synthesize Email;
@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        _delay = 0;
    }
    
    return self;
}

- (id)initWithDelay:(int)delay {
    if (self = [super init]) {
        _delay = delay;
    }
    
    return self;
}

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
    if (_delay) {
        [NSThread sleepForTimeInterval:_delay];
    }
    
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
        if (requestError != nil) {
            result.extendedResultError = [NSString stringWithFormat:@"%ld - %@", (long)requestError.code, requestError.localizedDescription];
            result.extendedResultCode = (long)requestError.code;
        }
        [self onOperationDone:result];
        return;
    }
    
    {
        NSString *html = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSError  *error = nil;
        NSString *pattern = @"\\<h1\\>(.*)\\<\\/h1\\>\\<span\\>LAST\\ STATE:\\ (.*)\\<br\\>Firmware:\\ (.*)\\<br\\>GUID:\\ (.*)\\<br\\>MAC:\\ (.*)\\<\\/span\\>";
        
        if (html!=nil) {
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
                
                if ( name != nil  ) {
                    [fields setObject:value == nil ? @"" : value forKey:name];
                }
                
                if ( [name isEqualToString: @"no_visible_channels"] &&
                    [value isEqualToString: @"1"] ) {
                    result.needsCloudConfig = YES;
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
    
    if ( [fields objectForKey:@"upd"] != nil ) {
        [fields setObject:@"1" forKey:@"upd"];
    }
    
    if ( [fields objectForKey:@"pro"] != nil ) {
        // Set protocol to "Supla"
        [fields setObject:@"0" forKey:@"pro"];
    }
    
    do {
        
        sleep(2);
        if ( [self postDataWithFields:fields] ) {
            
            [fields setObject:@"1" forKey:@"rbt"];
            [self postDataWithFields:fields];
            sleep(1);
            
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



@interface SAAddWizardVC () <SASuperuserAuthorizationDialogDelegate>
@end

@implementation SAAddWizardVC {
    NSTimer *_watchDogTimer;
    NSTimer *_blinkTimer;
    NSOperationQueue *_OpQueue;
    NSDate *_stepTime;
    int _step;
    int _pageId;
    SAWifi *_wifiAutoConnect;
    BOOL _1stAttempt;
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

- (void)watchDogTimerFireMethod:(NSTimer *)timer {
    
    int timeout = 0;
    
    switch(_step) {
        case STEP_CHECK_REGISTRATION_ENABLED_TRY1:
        case STEP_CHECK_REGISTRATION_ENABLED_TRY2:
        case STEP_CHECK_REGISTRATION_ENABLED_TRY3:
            // The connection may be restarting
            timeout = 5;
            break;
        case STEP_ENABLING_REGISTRATION:
            timeout = 5;
            break;
        case STEP_WIFI_AUTO_CONNECT:
            timeout = 90;
            break;
        case STEP_CONFIGURE:
            timeout = 90;
            break;
    }
    
    if ( timeout > 0
        && _stepTime != nil
        && [[NSDate date] timeIntervalSinceDate:_stepTime] >= timeout ) {
        
        [self onWatchDogTimeout];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self cleanUp];
    [self loadPrefs];
    
    self.backButtonInsteadOfCancel = NO;
    self.edSSID.layer.cornerRadius = 5.0;
    self.edSSID.layer.borderWidth = 2;
    self.edSSID.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.edPassword.layer.cornerRadius = 5.0;
    self.edPassword.layer.borderWidth = 2;
    self.edPassword.layer.borderColor = self.edPassword.backgroundColor.CGColor;
    
    [self.btnSystemSettings setTitle:NSLocalizedString(@"Go to the system settings", NULL)];
    
    if ( ![SAApp.profileManager getCurrentAuthInfo].emailAuth ) {
        // TODO: Replace text
        [self showError:NSLocalizedString(@"Add Wizard is only available when server connection has been set based on the email address entered in the settings. (Disable advanced options in the settings)", NULL)];
        return;
    } else {
        int version = [[SAApp SuplaClient] getProtocolVersion];
        if ( version > 0 && version < 7 ) {
            [self showError:NSLocalizedString(@"The connected Server does not support this function!", NULL)];
            return;
        }
    }
    
    [self showPage:PAGE_STEP_1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRegistrationEnabled:)
                                             name:kSARegistrationEnabledNotification
                                             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSetRegistrationEnabledResult:)
                                             name:kSAOnSetRegistrationEnableResult
                                             object:nil];
    

    _watchDogTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(watchDogTimerFireMethod:) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

-(void)viewDidDisappear:(BOOL)animated  {
    [super viewDidDisappear:animated];
    
    [self.OpQueue cancelAllOperations];
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
    [self savePrefs];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)keyboardDidShow:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect edPasswordRect = [self.edPassword convertRect:self.edPassword.frame toView:self.vStep2];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.vStep2.transform = CGAffineTransformMakeTranslation(0, self.vStep2.frame.size.height - keyboardSize.height - edPasswordRect.origin.y);
    }];
}

- (void)keyboardDidHide:(NSNotification*)notification {
    [UIView animateWithDuration:0.2 animations:^{
        self.vStep2.transform = CGAffineTransformIdentity;
    }];
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
    
    [SAWifi cleanup];
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
            [self setStep:STEP_CHECK_REGISTRATION_ENABLED_TRY3];
            [[SAApp SuplaClient] getRegistrationEnabled];
            break;
        case STEP_CHECK_REGISTRATION_ENABLED_TRY3:
            [self showError:NSLocalizedString(@"Device registration availability information timeout!", NULL)];
            break;
        case STEP_ENABLING_REGISTRATION:
            [self showError:NSLocalizedString(@"Timeout for enabling registration has expired!", NULL)];
            break;
        case STEP_WIFI_AUTO_CONNECT:
            [self showError:NSLocalizedString(@"I/O Device connection setting timeout!", NULL)];
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

- (void)blinkTimerFireMethod:(NSTimer *)timer {
    
    if ( _pageId == PAGE_STEP_3 ) {
        self.vDot.hidden = !self.vDot.hidden;
    }
}

-(void)showPage:(int)page {
    [self setStep:STEP_NONE];
    self.btnNextEnabled = YES;
    self.preloaderVisible = NO;
    self.btnNextTitle = NSLocalizedString(@"Next", NULL);
    
    switch(page) {
        case PAGE_STEP_1:
            self.page = self.vStep1;
            break;
        case PAGE_STEP_2:
            self.page = self.vStep2;
            break;
        case PAGE_STEP_3:
        {
            _1stAttempt = YES;
            _blinkTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(blinkTimerFireMethod:) userInfo:nil repeats:YES];
            
            if ([SAWifi autoConnectIsAvailable]) {
                self.swAutoMode.on = NO;
                self.swAutoMode.hidden = NO;
                self.lAutoMode.hidden = NO;
            } else {
                self.swAutoMode.on = NO;
                self.swAutoMode.hidden = YES;
                self.lAutoMode.hidden = YES;
            }
            
            [self swAutoModeChanged:self.swAutoMode];
                        
            self.page = self.vStep3;
        }
            break;
        case PAGE_STEP_4:
            self.btnNextTitle = NSLocalizedString(@"Start", NULL);
            self.page = self.vStep4;
            break;
        case PAGE_ERROR:
            self.page = self.vError;
            break;
        case PAGE_DONE:
            self.page = self.vDone;
            break;
    }
    
    _pageId = page;

}

- (void)showErrorWithAttributedString:(NSAttributedString *)message {
    [self.txtErrorMEssage setAttributedText:message];
    [self showPage:PAGE_ERROR];
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
    
    [SAWifi cleanup];
    
    switch(result.resultCode) {
        case RESULT_PARAM_ERROR:
            [self showError:NSLocalizedString(@"Incorrect input parameters!", NULL)];
            break;
        case RESULT_COMPAT_ERROR:
            [self showError:NSLocalizedString(@"The connected device is not compatible with this Wizard!", NULL)];
            break;
        case RESULT_CONN_ERROR: {
            NSString *errInfo = @"";
            if (result.extendedResultCode == NSURLErrorNotConnectedToInternet && _1stAttempt) {
                _1stAttempt = NO;
                [NSThread sleepForTimeInterval:1];
                [self connectToWiFi];
                return;
            } else if (result.extendedResultError != nil && result.extendedResultError.length) {
                errInfo = [NSString stringWithFormat:@"\n[%@]", result.extendedResultError];
            }
            NSString *msg = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Connection with the device cannot be set!", NULL), errInfo];
            
            if (@available(iOS 14.0, *)) {
                [self showErrorWithAttributedString:[self messageExtendedWithNotificationOfPermissions:msg]];
            } else {
                [self showError:msg];
            }
        }
            break;
        case RESULT_FAILED:
            [self showError:NSLocalizedString(@"Configuration Failed!", NULL)];
            break;
        case RESULT_SUCCESS:
            
            self.lName.text = result.name;
            self.lFirmware.text = result.version;
            self.lMAC.text = result.mac;
            self.lLastState.text = result.state;
            
            if(result.needsCloudConfig) {
                [self showCloudFollowupPopup];
            }
            
            [self showPage:PAGE_DONE];
            break;
    }
    
}

- (void)showCloudFollowupPopup {
    UIAlertController *ctrl = [UIAlertController
                               alertControllerWithTitle: NSLocalizedString(@"Device setup", nil)
                               message: NSLocalizedString(@"This device does not have any channels visible in the application. To finish configuration go to cloud.supla.org", nil)
                               preferredStyle: UIAlertControllerStyleAlert];
    [ctrl addAction:
     [UIAlertAction actionWithTitle: NSLocalizedString(@"I understand", nil)
                              style: UIAlertActionStyleCancel
                            handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [ctrl addAction:
     [UIAlertAction actionWithTitle: NSLocalizedString(@"Go to CLOUD", nil)
                              style: UIAlertActionStyleDefault
                            handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion: ^{
            [[UIApplication sharedApplication] openURL:
             [NSURL URLWithString:@"https://cloud.supla.org"]];
        }];
    }]];

    [self presentViewController:ctrl animated:YES completion:nil];
     
}

- (IBAction)onDoneScreenCloudLinkTap: (UITapGestureRecognizer *)gr {
    
}

-(NSString*)cloudHostName {
    NSString *server = [SAApp.profileManager getCurrentAuthInfo].serverForCurrentAuthMethod;
   return [[server lowercaseString] containsString:@"supla.org"] ? @"cloud.supla.org" : server;
}

- (void)onRegistrationEnabled:(NSNotification *)notification {
    
    SARegistrationEnabled *reg_enabled =
    [SARegistrationEnabled notificationToRegistrationEnabled:notification];
    
    if ( reg_enabled != nil ) {
        
        if ( [reg_enabled isIODeviceRegistrationEnabled] ) {
            [self showPage:PAGE_STEP_3];
        } else {
            [self setStep:STEP_SUPERUSER_AUTHORIZATION];
            [SASuperuserAuthorizationDialog.globalInstance authorizeWithDelegate:self];
        }
        
    };
};

- (void)onSetRegistrationEnabledResult:(NSNotification *)notification {
    if ( notification.userInfo != nil )  {
        NSNumber *code = (NSNumber *)[notification.userInfo objectForKey:@"code"];
        if (code && [code intValue] == SUPLA_RESULTCODE_TRUE) {
            [self showPage:PAGE_STEP_3];
        }
    }
}

-(void) superuserAuthorizationSuccess {
    [SASuperuserAuthorizationDialog.globalInstance close];
    [self setStep:STEP_ENABLING_REGISTRATION];
    [[SAApp SuplaClient] setIODeviceRegistrationEnabledForTime:3600 clientRegistrationEnabledForTime:-1];
}

-(void) superuserAuthorizationCanceled {
    self.preloaderVisible = NO;
    self.btnNextEnabled = YES;
    self.btnNextTitle = NSLocalizedString(@"Next", NULL);
}

-(NSAttributedString*)messageExtendedWithNotificationOfPermissions:(NSString *)msg {
    NSString *msg2 = NSLocalizedString(@"Make sure that the application has permissions to discover and connect to devices in the local network. This means that the \"iOS->Settings->SUPLA->Local network\" permission must be turned on for the wizard to work properly.", NULL);
    
    return [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n%@", msg, msg2]];
}

-(void) connectToWiFi {
    [self setStep:STEP_WIFI_AUTO_CONNECT];
    
    if (_wifiAutoConnect == nil) {
        _wifiAutoConnect = [[SAWifi alloc] init];
    }
    
    [_wifiAutoConnect tryConnectWithCompletionHandler:^(BOOL success) {
        if (self->_step == STEP_WIFI_AUTO_CONNECT && self->_pageId == PAGE_STEP_3) {
            if (success) {
                [self startConfiguration];
            } else {
                [self->_OpQueue cancelAllOperations];
                [self showError:NSLocalizedString(@"No I/O Devices found! Please check if your I/O Device is ON and in configuration mode.", NULL)];
            }
        }
    }];
}

-(void) startConfigurationWithDelay:(int)delaySec {
    [self setStep:STEP_CONFIGURE];
    
    [self.OpQueue cancelAllOperations];
    SASetConfigOperation *setConfigOp = [[SASetConfigOperation alloc] initWithDelay:delaySec];
    setConfigOp.SSID = [self.edSSID.text
                        stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    setConfigOp.PWD = self.edPassword.text;
    
    AuthInfo *ai = [SAApp.profileManager getCurrentAuthInfo];
    
    setConfigOp.Server = ai.serverForEmail;
    setConfigOp.Email = ai.emailAddress;
    setConfigOp.delegate = self;
    [self.OpQueue addOperation:setConfigOp];
}

-(void) startConfiguration {
    [self startConfigurationWithDelay:0];
}

- (IBAction)nextTouch:(nullable id)sender {
    [super nextTouch:sender];

    self.preloaderVisible = YES;
    self.btnNextEnabled = NO;
    
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
                self.preloaderVisible = NO;
                self.btnNextEnabled = YES;
            }
            
        }

            break;
        case PAGE_STEP_3:
            if (self.swAutoMode.on) {
                [self connectToWiFi];
            } else {
                [self showPage:PAGE_STEP_4];
            }
            break;
        case PAGE_STEP_4:
            [self startConfiguration];
            break;
        case PAGE_DONE:
        case PAGE_ERROR:
            [self cancelOrBackTouch:nil];
            break;
    }
    
}

- (IBAction)cancelOrBackTouch:(nullable id)sender {
    [super cancelOrBackTouch:sender];
    
    [self cleanUp];
    [self.OpQueue cancelAllOperations];
    [self savePrefs];
    [[SAApp currentNavigationCoordinator] finish];
    [[SAApp SuplaClient] reconnect];
}


- (IBAction)pwdViewTouchDown:(id)sender {
    self.edPassword.secureTextEntry = !self.edPassword.secureTextEntry;
}

- (IBAction)wifiSettingsTouch:(id)sender {
    
    NSData *d1 = [[NSData alloc] initWithBase64EncodedString:@"QXBwLVByZWZzOnJvb3Q9V0lGSQ==" options:0];
    NSData *d2 = [[NSData alloc] initWithBase64EncodedString:@"cHJlZnM6cm9vdD1XSUZJ" options:0];
    
    NSURL * urlCheck1 = [NSURL URLWithString:[[NSString alloc] initWithData:d1 encoding:NSUTF8StringEncoding]];
    NSURL * urlCheck2 = [NSURL URLWithString:[[NSString alloc] initWithData:d2 encoding:NSUTF8StringEncoding]];
    
    if ([[UIApplication sharedApplication] canOpenURL:urlCheck1]) {
        [[UIApplication sharedApplication] openURL:urlCheck1];
    } else if ([[UIApplication sharedApplication] canOpenURL:urlCheck2]) {
        [[UIApplication sharedApplication] openURL:urlCheck2];
    } else {
        NSLog(@"Unable to open settings app.");
    }
}
- (IBAction)swAutoModeChanged:(id)sender {

    NSString *txt1 = NSLocalizedString(@"*Configuration mode is enabled by default on brand new products. It can also be enabled manually by pressing and holding CONFIG button or dimmer knob for around 5s.\n\n%@\n", NULL);
    
    NSString *txt2 = NSLocalizedString(self.swAutoMode.on
                                                   ? @"Press START to start configuration." :
                                                   @"Press Next to continue." ,NULL);

    self.btnNextTitle = NSLocalizedString(self.swAutoMode.on ? @"Start" : @"Next", NULL);
    self.lStep3Text2.text = [NSString stringWithFormat:txt1, txt2];
    self.lAutoModeWarning.hidden = !self.swAutoMode.on;
}
@end
