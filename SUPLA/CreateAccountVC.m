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

#import "CreateAccountVC.h"
#import "SuplaApp.h"

@interface SACreateAccountVC ()

@end

@implementation SACreateAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
// FIXME: implement
//    [[SAApp UI] showMenubarSettingsBtn];
    
    self.webView.hidden = YES;
    self.activityIndicator.hidden = NO;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
};

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ( [webView.request.URL.absoluteString isEqualToString:@"about:blank"] ) {
        
        NSString *url = NSLocalizedString(@"https://cloud.supla.org/register", nil);
        NSURL *nsUrl = [NSURL URLWithString:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
        
        [self.webView loadRequest:request];
        return;
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"$(document.body).addClass('in-app-register');"];
    
   self.webView.hidden = NO;
   self.activityIndicator.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    self.activityIndicator.hidden = YES;
    
    if (error != nil && error.localizedDescription != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
