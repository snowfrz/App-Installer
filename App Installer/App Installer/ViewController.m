//
//  ViewController.m
//  App Installer
//
//  Created by Justin Proulx on 2017-06-23.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "ViewController.h"
#import "AppInstaller.h"

@interface ViewController () {
    AppInstaller *installer;
    NSString *external_url;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    versionLabel.text = [@"v" stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    [self checkForUpdates];
    
    [super viewDidLoad];
    
    URLTextField.delegate = self;
    installButton.enabled = NO;
    [URLTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    installer = [AppInstaller new];
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

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
}

#pragma mark – Interface Actions

- (IBAction)openTwiter:(UIButton *)sender {
    NSURL *handle;
    if ([sender.titleLabel.text isEqualToString:@"Justin"])
    {
        handle = [NSURL URLWithString:@"https://twitter.com/JustinAlexP"];
    }
    else if ([sender.titleLabel.text isEqualToString:@"AppleBetas"])
    {
        handle = [NSURL URLWithString:@"https://twitter.com/AppleBetasDev"];
    }
    else if ([sender.titleLabel.text isEqualToString:@"nullriver"])
    {
        handle = [NSURL URLWithString:@"https://twitter.com/nullriver"];
    }
    else if ([sender.titleLabel.text isEqualToString:@"CreatureSurvive"])
    {
        handle = [NSURL URLWithString:@"https://twitter.com/CreatureSurvive"];
    }
    
    if (handle)
    {
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:handle entersReaderIfAvailable:NO];
        safari.delegate = self;
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
    NSLog(@"Installing app...");
    // if we have an external url use that else use the text field
    external_url = external_url ? : URLTextField.text;
    URLTextField.text = external_url;
    
    // update the UI to show were working
    [self setInstallButtonToInstalling:YES];
    
    [installer installAppWithURL:external_url completionHandler:^(NSError *error) {
        // handle updating the UI
        [self setInstallButtonToInstalling:NO];
        
        // clear our url when finished
        external_url = nil;
        
        // if the install request failed
        if (error)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Upload Failed" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (IBAction)scarButton
{
    NSLog(@"Fixing scars...");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-prefs:root=General&path=STORAGE_ICLOUD_USAGE"]];
}

-(void)setInstallButtonToInstalling:(BOOL)installing
{
    installButton.userInteractionEnabled = !installing;
    [installButton setTitle:installing ? @"Installing…" : @"Install" forState:UIControlStateNormal];
}

- (void)downloadAppAt:(NSString *)plistDownloadLink
{
    NSLog(@"path: %@", plistDownloadLink);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"itms-services://?action=download-manifest&url=" stringByAppendingString:plistDownloadLink]]];
}

@end
