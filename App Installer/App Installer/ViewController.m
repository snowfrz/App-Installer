//
//  ViewController.m
//  App Installer
//
//  Created by Justin Proulx on 2017-06-23.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
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
    [[[[rootDict[@"items"] objectAtIndex:0] objectForKey:@"assets"] objectAtIndex:0] setObject:appURL forKey:@"url"];
    
    [rootDict writeToFile:documentsDirectoryPlistPath atomically:YES];
    
    // Internet things
    // setup local
    NSString *boundary = [[NSUUID UUID] UUIDString];
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:documentsDirectoryPlistPath];
    
    // setup session
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // set body of the request
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition:form-data; name=\"file\"; filename=\"general.plist\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/x-plist\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:plistData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // seutup request
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString:@"https://file.io/?expires=1d"]];
    [request setHTTPMethod:@"POST"];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody:body];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          //NSLog(@"Response: %@", response.description);
                                          // the task completed without error
                                          if (!error) {
                                              // handle ui on the main thread
                                              dispatch_async(dispatch_get_main_queue(),^{
                                                  [self setInstallButtonToInstalling:NO];
                                              });
                                              
                                              //get download link from headers
                                              NSDictionary *headers = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                              NSLog(@"Error parsing headers: %@", error.localizedDescription);
                                              //NSLog(@"%@", headers);
                                              
                                              NSString *plistDownloadLink = [[NSString alloc] initWithString:[@"https://file.io/" stringByAppendingString:headers[@"key"]]];
                                              NSLog(@"%@", plistDownloadLink);
                                              
                                              [self downloadAppAt:plistDownloadLink];
                                          }
                                          // the task resulted in an error return the error
                                          else {
                                              dispatch_async(dispatch_get_main_queue(),^{
                                                  [self setInstallButtonToInstalling:NO];
                                                  
                                                  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Upload Failed" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                                                  [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                                                  [self presentViewController:alert animated:YES completion:nil];
                                                  //NSLog(@"Error: %@", error);
                                              });
                                          }
                                      }];
    
    [dataTask resume];
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
