//
//  ViewController.m
//  App Installer
//
//  Created by Justin Proulx on 2017-06-23.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    URLTextField.delegate = self;
    installButton.enabled = NO;
    [URLTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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

#pragma mark Interface Actions

- (IBAction)goToJustinTwitter:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/JustinAlexP"]];
}
- (IBAction)goToAppleBetasTwitter:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/AppleBetasDev"]];
}
- (IBAction)goTonullriverTwitter:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/nullriver"]];
}


- (IBAction)installApp:(id)sender
{
    [self setInstallButtonToInstalling:YES];
    
    //Get .plist
    NSString *appBundlePath = [[NSBundle mainBundle] pathForResource:@"general" ofType:@"plist"];
    
    //get documents directory
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //delete previous install file if it exists
    if ([fileManager fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@"general.plist"]])
    {
        [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"general.plist"] error:nil];
    }
    
    //copy new file to documents directory
    [fileManager copyItemAtPath:appBundlePath toPath:[documentsDirectory stringByAppendingPathComponent:@"general.plist"] error:nil];
    
    NSString *documentsDirectoryPlistPath = [documentsDirectory stringByAppendingPathComponent:@"general.plist"];
    
    //get root
    NSMutableDictionary *rootDict = [[NSMutableDictionary alloc] initWithContentsOfFile:documentsDirectoryPlistPath];
    
    NSString *appURL = URLTextField.text;
    
    //sets the url to the correct place
    [[[[[rootDict objectForKey:@"items"] objectAtIndex:0] objectForKey:@"assets"] objectAtIndex:0] setObject:appURL forKey:@"url"];
    
    [rootDict writeToFile:documentsDirectoryPlistPath atomically:YES];
    
    // Internet things
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:documentsDirectoryPlistPath];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
    
    manager.responseSerializer = responseSerializer;
    
    [manager POST:@"https://file.io/?expires=1d"
             parameters:nil
             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:plistData name:@"file" fileName:@"general.plist" mimeType:@"application/x-plist"];
        
        // etc.
    }
             progress:nil
             success:^(NSURLSessionDataTask *task, id responseObject)
    {
        [self setInstallButtonToInstalling:NO];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Ready to install." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
        //get download link from headers
        NSDictionary *headers = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        //NSLog(@"%@", headers);
        NSString *plistDownloadLink = [[NSString alloc] initWithString:[@"https://file.io/" stringByAppendingString:[headers objectForKey:@"key"]]];
        //NSLog(@"%@", plistDownloadLink);
        
        [self downloadAppAt:plistDownloadLink];
        
        
        //NSLog(@"Response: %@", responseObject);
    }
          failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        [self setInstallButtonToInstalling:NO];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Upload Failed" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        NSLog(@"Error: %@", error);
    }];
}

-(void)setInstallButtonToInstalling:(BOOL)installing
{
    installButton.userInteractionEnabled = !installing;
    [installButton setTitle:installing ? @"Installing…" : @"Install" forState:UIControlStateNormal];
}

- (void)downloadAppAt:(NSString *)plistDownloadLink
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"itms-services://?action=download-manifest&url=" stringByAppendingString:plistDownloadLink]]];
}

@end
