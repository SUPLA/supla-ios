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

-(void)_onOperationDone:(NSNumber*)result {
    if ( self.delegate != nil ) {
        [self.delegate performSelector:@selector(setConfigResult:) withObject:result];
    }
};

- (void)onOperationDone:(int)result {
    [self performSelectorOnMainThread:@selector(_onOperationDone:) withObject:[NSNumber numberWithInt:result] waitUntilDone:NO];
}

- (void)main
{
    
    if ( self.SSID == nil
        || self.SSID.length == 0
        || self.PWD == nil
        || self.PWD.length == 0
        || self.Server == nil
        || self.Server.length == 0
        || self.Email == nil
        || self.Email.length == 0 ) {
        
        [self onOperationDone:RESULT_PARAM_ERROR];
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
        [self onOperationDone:RESULT_CONN_ERROR];
        return;
    }
        
    NSString *name = nil;
    NSString *state = nil;
    NSString *version = nil;
    NSString *guid = nil;
    NSString *mac = nil;
    
    {
        NSString *html = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSError  *error = nil;
        NSString *pattern = @"\\<h1\\>(.*)\\<\\/h1\\>\\<span\\>LAST\\ STATE:\\ (.*)\\<br\\>Firmware:\\ (.*)\\<br\\>GUID:\\ (.*)\\<br\\>MAC:\\ (.*)\\<\\/span\\>";
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
        NSArray *matches = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
        
        if ( error == nil && matches != nil && matches.count == 1 ) {
            NSTextCheckingResult *match = [matches objectAtIndex:0];
            if ([match numberOfRanges] == 6) {
                
                name = [html substringWithRange:[match rangeAtIndex:1]];
                state = [html substringWithRange:[match rangeAtIndex:2]];
                version = [html substringWithRange:[match rangeAtIndex:3]];
                guid = [html substringWithRange:[match rangeAtIndex:4]];
                mac = [html substringWithRange:[match rangeAtIndex:5]];
                
            }
        }
    }
    
    NSMutableDictionary *fields = [[NSMutableDictionary alloc] init];
    
    if ( name != nil ) {
        
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
        
        [self onOperationDone:RESULT_COMPAT_ERROR];
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
            [self onOperationDone:RESULT_SUCCESS];
            
            return;
            
        } else {
            retryCount--;
        }
        
        if ( [self isCancelled] ) {
            return;
        }
        
    }while(retryCount > 0);
    
    
    [self onOperationDone:RESULT_FAILED];
}

@end

@implementation SAAddWizardVC {
    NSTimer *_preloaderTimer;
    int _preloaderPos;
    NSOperationQueue *_OpQueue;
    int _x;
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

-(void)showStepView:(UIView*)stepView {
    
    for(UIView *subview in self.vStepContent.subviews) {
        [subview removeFromSuperview];
    }
    
    stepView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                  UIViewAutoresizingFlexibleHeight);
    stepView.frame =  self.vStepContent.frame;
    [self.vStepContent addSubview:stepView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[SAApp UI] showMenuBtn:NO];
    
    _x = 1;
    [self showStepView:self.vStep1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegistrationEnabled:) name:kSARegistrationEnabledNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated  {
    [self.OpQueue cancelAllOperations];
    [self preloaderVisible:NO];
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setConfigResult:(NSNumber*)result {
    NSLog(@"Result: %@", result);
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
        
    }
    
}

- (IBAction)nextTouchch:(id)sender {

    /*
     [self.OpQueue cancelAllOperations];
     SASetConfigOperation *setConfigOp = [[SASetConfigOperation alloc] init];
     setConfigOp.delegate = self;
     [self.OpQueue addOperation:setConfigOp];
     */
    
    /*
    NSArray * networkInterfaces = [NEHotspotHelper supportedNetworkInterfaces];
    NSLog(@"Networks %@",networkInterfaces);
     */
    
    [self preloaderVisible:YES];
    [[SAApp SuplaClient] getRegistrationEnabled];
    return;
    
    _x++;
    
    if ( _x > 6 ) _x = 1;
    
    switch(_x) {
        case 1:
            [self showStepView:self.vStep1];
            break;
        case 2:
            [self showStepView:self.vStep2];
            break;
        case 3:
            [self showStepView:self.vStep3];
            break;
        case 4:
        {
            [self showStepView:self.vStep4];
            break;
            /*
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
             */
        }
            break;
        case 5:
            [self showStepView:self.vError];
            break;
        case 6:
            [self showStepView:self.vDone];
            break;
    }

        
}

- (IBAction)cancelTouch:(id)sender {
    [self preloaderVisible:NO];
   // [[SAApp UI] showMainVC];
}

- (void)onRegistrationEnabled:(NSNotification *)notification {
    
    if ( notification.userInfo == nil ) return;
    
    SARegistrationEnabled *reg_enabled = (SARegistrationEnabled *)[notification.userInfo objectForKey:@"reg_enabled"];
    
    if ( reg_enabled == nil ) return;
    
    NSLog(@"RegEnabled %@, %@", reg_enabled.ClientRegistrationExpirationDate, reg_enabled.IODeviceRegistrationExpirationDate);
    
};
@end
