//
//  ViewController.m
//  App Installer
//
//  Created by Justin Proulx on 2017-06-23.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "ViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "GCDWebUploader.h"

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)goToTwitter:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/JustinAlexP"]];
}

- (IBAction)installApp:(id)sender
{
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
    
    //open web server
    GCDWebUploader* webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsDirectory];
    [webUploader start];
    
    NSString *deviceIPAddress = [self getIPAddress];
    
    NSURL *plistURL = [NSURL URLWithString:[[@"itms-services://?action=download-manifest&url=http://" stringByAppendingString:deviceIPAddress] stringByAppendingString:@"/general.plist"]];
    
    [[UIApplication sharedApplication] openURL:plistURL];
    
   //[webUploader stop];
}

//shoutout to Saurabh from https://stackoverflow.com/questions/6807788/how-to-get-ip-address-of-iphone-programmatically for this method
- (NSString *)getIPAddress
{
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

- (void)viewDidLoad
{
    URLTextField.delegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
