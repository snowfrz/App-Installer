//
//  ViewController.m
//  App Installer
//
//  Created by Justin Proulx on 2017-06-23.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "ViewController.h"
#import "AppInstaller.h"
#import "AppResigner.h"
#import "SAMKeychain.h"

@interface ViewController () {
    AppInstaller *installer;
    AppResigner *resigner;
    NSString *external_url;
}

@end

@implementation ViewController

- (IBAction)done:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress) name:@"ProgressUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressDoneWithNotification:) name:@"ProgressDone" object:nil];
    
    NSString * versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    while ([[versionString substringFromIndex:[versionString length] - 1] isEqualToString:@"."] || [[versionString substringFromIndex:[versionString length] - 1] isEqualToString:@"0"]) {
        versionString = [versionString substringToIndex:[versionString length] - 1];
    }
    
    versionLabel.text = [@"v" stringByAppendingString:versionString];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"resign"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"resign"];
    }
    
    [progressView setProgress:0.0 animated:NO];
    
    BOOL resign = [[[NSUserDefaults standardUserDefaults] objectForKey:@"resign"] boolValue];
    
    [resignSwitch setOn: resign];
    
    [self checkForUpdates];
    
    [super viewDidLoad];
    
    URLTextField.delegate = self;
    installButton.enabled = NO;
    [URLTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    installer = [AppInstaller new];
    resigner = [AppResigner new];
}

- (void)viewDidLayoutSubviews
{
    [instructionsTextView setContentOffset:CGPointZero animated:NO];
}

-(BOOL)shouldEnableInstallButton
{
    if([URLTextField.text isEqualToString:@""]) return NO;
    return [NSURL URLWithString:URLTextField.text] != nil;
}



#pragma mark – initial configuration
- (void)checkForUpdates
{
    //check for update
    NSURL  *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/Sn0wCh1ld/App-Installer/master/appinfo.plist"];
    NSData *appInfoData = [NSData dataWithContentsOfURL:url];
    
    if (appInfoData)
    {
        //get documents directory
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"appinfo.plist"];
        [appInfoData writeToFile:filePath atomically:YES];
        
        NSDictionary *appInfoDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        NSString *latestVersion = appInfoDictionary[@"Version"];
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        if ([latestVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending)
        {
            // latest version is higher than the current version
            // don't change versionning convention from major.minor.increment.quickfix
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Update available" message:[[@"A new version of App Installer has been released. Please download version " stringByAppendingString:latestVersion] stringByAppendingString:@" from GitHub and install it using Impactor"] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *githubLinkButtonAction = [UIAlertAction actionWithTitle:@"GitHub" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                     {
                                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Sn0wCh1ld/App-Installer/blob/master/README.md"]];
                                                     }];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:githubLinkButtonAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
}


#pragma mark – Text Field Delegate & Actions

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidChange:(UITextField *)textField {
    installButton.enabled = [self shouldEnableInstallButton];
}


#pragma mark – Interface Actions

- (IBAction)resignSwitchChanged:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:sender.isOn] forKey:@"resign"];
}

- (IBAction)openTwitter:(UIButton *)sender
{
    NSURL *handle;
    if ([sender.titleLabel.text isEqualToString:@"Justin"])
    {
        //twitter://user?screen_name=SCREEN_NAME
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=JustinAlexP"]];
        }
        else
        {
           handle = [NSURL URLWithString:@"https://twitter.com/JustinAlexP"];
        }
        
    }
    else if ([sender.titleLabel.text isEqualToString:@"AppleBetas"])
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=AppleBetasDev"]];
        }
        else
        {
            handle = [NSURL URLWithString:@"https://twitter.com/AppleBetasDev"];
        }
    }
    else if ([sender.titleLabel.text isEqualToString:@"nullriver"])
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=nullriver"]];
        }
        else
        {
            handle = [NSURL URLWithString:@"https://twitter.com/nullriver"];
        }
    }
    else if ([sender.titleLabel.text isEqualToString:@"CreatureSurvive"])
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=CreatureSurvive"]];
        }
        else
        {
            handle = [NSURL URLWithString:@"https://twitter.com/CreatureSurvive"];
        }
    }
    
    if (handle)
    {
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:handle entersReaderIfAvailable:NO];
        [self presentViewController:safari animated:YES completion:nil];
    }
}


- (void)pasteboardInstallAction
{
    [installButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    external_url = [UIPasteboard generalPasteboard].string;
    [self installApp];
}

- (void)urlSchemeInstallWithURL:(NSString *)url
{
    [installButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    external_url = url;
    [self installApp];
}

- (IBAction)installApp
{
    // if we have an external url use that else use the text field
    external_url = external_url ? : URLTextField.text;
    URLTextField.text = external_url;
    
    
    void(^installError)(NSError*) = ^(NSError *error) {
        // handle updating the UI
        [self setInstallButtonToState:nil andInstalling:NO];
        
        // clear our url when finished
        self->external_url = nil;
        
        // if the install request failed
        if (error)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Install Failed" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    };
    
    if (!resignSwitch.isOn)
    {
        // update the UI to show we're working
        [self setInstallButtonToState:@"Installing..." andInstalling:YES];
        [self classicInstallWithCompletionHandler:installError];
    }
    else
    {
        NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleIDUsername"];
        NSString * password = [SAMKeychain passwordForService:@"AppInstallerAppleID" account:username];
        NSString * udid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDID"];
        
        if ([username length] == 0 || [password length] == 0 || [udid length] == 0)
        {
            [self displayAlertWithTitle:@"Not logged in" andMessage:@"Tap the gear in the top left hand corner, then log in with the required credentials" plusActions:nil];
        }
        else
        {
            // update the UI to show we're working
            [self setInstallButtonToState:@"Downloading..." andInstalling:YES];
            [self resignInstallWithCompletionHandler:installError];
        }
    }
}

- (void)resignInstallWithCompletionHandler:(void(^)(NSError*))error
{
    NSLog(@"Installing app...");
    
    [resigner resignAppAtURL:external_url completionHandler:error];
}

- (void)classicInstallWithCompletionHandler:(void(^)(NSError*))error
{
    NSLog(@"Installing app...");
    
    [installer installAppWithURL:external_url completionHandler:error];
}

- (IBAction)scarButton
{
    NSLog(@"Fixing scars...");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-prefs:root=General&path=STORAGE_ICLOUD_USAGE/DEVICE_USAGE"]];
}

-(void)setInstallButtonToState:(nullable NSString *)installState andInstalling:(BOOL)installing
{
    installButton.userInteractionEnabled = !installing;
    [installButton setTitle:installing ? installState : @"Install" forState:UIControlStateNormal];
}

- (void)downloadAppAt:(NSString *)plistDownloadLink
{
    NSLog(@"path: %@", plistDownloadLink);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"itms-services://?action=download-manifest&url=" stringByAppendingString:plistDownloadLink]]];
}

- (void)updateProgress
{
    [progressView setProgress:resigner.progress animated:YES];
}

- (void)progressDoneWithNotification:(NSNotification *)notification
{
    NSString *message = notification.userInfo[@"Message"];
    BOOL installing = [notification.userInfo[@"Installing"] boolValue];
    
    [self setInstallButtonToState:message andInstalling:installing];
    [progressView setProgress:0 animated:NO];
}

- (void)displayAlertWithTitle:(NSString *)title andMessage:(NSString *)message plusActions:(nullable NSArray *)actions
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (actions == nil)
    {
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    }
    else
    {
        for (UIAlertAction * action in actions)
        {
            [alert addAction:action];
        }
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
