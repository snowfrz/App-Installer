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
}

@end

@implementation ViewController

- (void)viewDidLoad
{
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

#pragma mark Text Field Delegate & Actions

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

#pragma mark Interface Actions

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
    
    if (handle)
    {
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:handle entersReaderIfAvailable:NO];
        safari.delegate = self;
        [self presentViewController:safari animated:YES completion:nil];
    }
}

-(void)setURL:(NSString *)url
{
    [URLTextField setText:url];
    [self textFieldDidChange:URLTextField];
}
- (IBAction)installApp
{
    // update the UI to show were working
    [self setInstallButtonToInstalling:YES];

   [installer installAppWithURL:URLTextField.text completionHandler:^(NSError *error) {
       // handle updating the UI
       [self setInstallButtonToInstalling:NO];

       // if the install request failed
       if (error)
       {
           UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Upload Failed" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
           [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
           [self presentViewController:alert animated:YES completion:nil];
       }
   }];
}

-(void)setInstallButtonToInstalling:(BOOL)installing
{
    installButton.userInteractionEnabled = !installing;
    [installButton setTitle:installing ? @"Installing…" : @"Install" forState:UIControlStateNormal];
}

@end
