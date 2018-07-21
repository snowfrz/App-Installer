//
//  SettingsTableViewController.m
//  App Installer
//
//  Created by Justin Proulx on 2018-07-20.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "RPVAccountChecker.h"
#import "SAMKeychain.h"
#import "EEAppleServices.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad
{
    _username = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleIDUsername"];
    _password = [SAMKeychain passwordForService:@"AppInstallerAppleID" account:_username];
    _udid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDID"];
    
    usernameTextField.text = _username;
    passwordTextField.text = _password;
    udidTextField.text = _udid;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [super viewDidLoad];
    
}

- (IBAction)logIn:(UIButton *)sender
{
    _username = usernameTextField.text;
    _password = passwordTextField.text;
    _udid = udidTextField.text;
    
    [[NSUserDefaults standardUserDefaults] setObject:_udid forKey:@"UDID"];
    [[NSUserDefaults standardUserDefaults] setObject:_username forKey:@"AppleIDUsername"];
    
    if ([_username length] == 0 || [_password length] == 0 || [_udid length] == 0)
    {
        [self displayAlertWithTitle:@"Field(s) missing" andMessage:@"Please fill out all the fields" plusActions:nil];
    }
    else
    {
        [activityIndicator startAnimating];
        activityIndicator.hidesWhenStopped = YES;
        UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        self.navigationItem.leftBarButtonItem = barButton;
        
        [[RPVAccountChecker sharedInstance] checkUsername:_username withPassword:_password andCompletionHandler:^(NSString *failureReason, NSString *resultCode, NSArray *teamIDArray)
        {
            
            if (teamIDArray)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SAMKeychain setPassword:self->_password forService:@"AppInstallerAppleID" account:self->_username];
                    
                    NSMutableArray *alertActions = [[NSMutableArray alloc] init];
                    for (NSDictionary *team in teamIDArray)
                    {
                        NSString *teamID = team[@"teamId"];
                        NSString *name = team[@"name"];
                        
                        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ (%@)", teamID, name] style:UIAlertActionStyleDefault handler:^(UIAlertAction * chooseTeamID){
                            [[NSUserDefaults standardUserDefaults] setObject:teamID forKey:@"TeamID"];
                            self->_teamID = teamID;
                            
                            [self checkDevelopmentCertificates];
                        }];
                        [alertActions addObject:action];
                    }
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                    [alertActions addObject:cancelAction];
                    
                    [self displayAlertWithTitle:@"Choose a team" andMessage:@"The following team IDs were found on your account. If you don't know what this is, or there is just one option, choose the first option." plusActions:alertActions];
                    
                });
            }
            else if ([resultCode isEqualToString:@"appSpecificRequired"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *appSpecificPasswordAction = [UIAlertAction actionWithTitle:@"Go" style:UIAlertActionStyleDefault handler:^(UIAlertAction * goToApple){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://appleid.apple.com"] options:@{} completionHandler:nil];
                    }];
                    
                    [self displayAlertWithTitle:@"App-Specific password required" andMessage:@"Go to appleid.apple.com and log in. Under security, there's a section called \"App-Specific Passwords\". Generate one, and use it instead of your Apple ID password in App Installer" plusActions:@[cancelAction, appSpecificPasswordAction]];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self displayAlertWithTitle:@"Failure" andMessage:failureReason plusActions:nil];
                });
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->activityIndicator stopAnimating];
            });
        }];
    }
}

- (void)checkDevelopmentCertificates
{
    [activityIndicator startAnimating];
    
    // Check whether the user needs to revoke any existing codesigning certificate.
    [EEAppleServices listTeamsWithCompletionHandler:^(NSError *error, NSDictionary *dictionary){
        if (error)
        {
            [self displayAlertWithTitle:@"Failure" andMessage:error.localizedDescription plusActions:nil];
            return;
        }
        
        // Check to see if the current Team ID is from a free profile.
        NSArray *teams = [dictionary objectForKey:@"teams"];
        
        BOOL isFreeUser = NO;
        for (NSDictionary *team in teams)
        {
            NSString *teamIdToCheck = [team objectForKey:@"teamId"];
            
            if ([teamIdToCheck isEqualToString:self->_teamID])
            {
                NSArray *currentMemberRoles = [[team objectForKey:@"currentTeamMember"] objectForKey:@"roles"];
                
                if ([currentMemberRoles containsObject:@"XCODE_FREE_USER"])
                {
                    isFreeUser = YES;
                    break;
                }
            }
        }
        
        NSLog(@"Is free user? %d", isFreeUser);
        
        if (isFreeUser)
        {
            [EEAppleServices listAllDevelopmentCertificatesForTeamID:self->_teamID withCompletionHandler:^(NSError *error, NSDictionary *dictionary){
                if (error)
                {
                    [self displayAlertWithTitle:@"Failure" andMessage:error.localizedDescription plusActions:nil];
                }
                
                // If the count of certs is > 1 existing profiles, we need the user to revoke one.
                NSArray *certificates = [dictionary objectForKey:@"certificates"];
                if (certificates.count > 1)
                {
                    NSLog(@"Need to remove an existing certificate!");
                    //[self letUserRevokeCertificates:certificates];
                }
                else
                {
                    // No need to revoke anything
                    [self checkDeviceRegistration];
                }
            }];
        }
        else
        {
            // No need to check development certificate counts.
            [self checkDeviceRegistration];
        }
    }];
}


- (void)checkDeviceRegistration
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [[RPVAccountChecker sharedInstance] registerCurrentDeviceForTeamID:self->_teamID withUsername:self->_username password:self->_password udid:self->_udid andCompletionHandler:^(NSError *error) {
            // Error only happens if user already has registered this device!
            
            if (!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self displayAlertWithTitle:@"Success" andMessage:@"Successfully logged in" plusActions:nil];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self displayAlertWithTitle:@"Failure" andMessage:@"Already logged in" plusActions:nil];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self->activityIndicator stopAnimating];
            });
        }];
    });
}

/*- (void)letUserRevokeCertificates:(NSArray*)certificates
 {
 dispatch_async(dispatch_get_main_queue(), ^(){
 UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
 
 for (id item in certificates)
 {
 <#statements#>
 }
 
 
 [self displayAlertWithTitle:@"Too many certificates" andMessage:@"Revoke a certificate" plusActions:<#(nullable NSArray *)#>];
 });
 }
 
 - (void)_revokeCertificate:(NSDictionary*)certificate withCompletion:(void (^)(NSError *error))completionHandler {
 [EEAppleServices signInWithUsername:self.username password:self.password andCompletionHandler:^(NSError *error, NSDictionary *plist) {
 if (!error) {
 [EEAppleServices revokeCertificateForSerialNumber:[certificate objectForKey:@"serialNumber"] andTeamID:self->_teamID withCompletionHandler:^(NSError *error, NSDictionary *dictionary) {
 
 completionHandler(error);
 }];
 }
 }];
 }*/

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

- (IBAction)getUDID:(UITableViewCell *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://showmyudid.com"]];
}

- (IBAction)Done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
