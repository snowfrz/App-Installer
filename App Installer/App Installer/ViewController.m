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
    
    
    
    
    //Internet things
    NSURL *fileURL = [NSURL URLWithString:documentsDirectoryPlistPath];
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:documentsDirectoryPlistPath];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
    
    manager.responseSerializer = responseSerializer;
    
    [manager POST:@"https://file.io/?expires=1d" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {
        [formData appendPartWithFileData:plistData name:@"file" fileName:@"general.plist" mimeType:@"application/x-plist"];
        
        // etc.
    }
         progress:nil success:^(NSURLSessionDataTask *task, id responseObject)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Ready to install" delegate:self cancelButtonTitle: @"OK" otherButtonTitles:nil];
        [alert show];
        
        //get download link from headers
        NSDictionary *headers = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        //NSLog(@"%@", headers);
        plistDownloadLink = [[NSString alloc] initWithString:[@"https://file.io/" stringByAppendingString:[headers objectForKey:@"key"]]];
        //NSLog(@"%@", plistDownloadLink);
        
        [self downloadApp];
        
        
        //NSLog(@"Response: %@", responseObject);
    }
          failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:[[@"Upload failed.\nReason: \"" stringByAppendingString:[error localizedDescription]] stringByAppendingString:@"\""]  delegate:self cancelButtonTitle: @"OK" otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"Error: %@", error);
    }];
}

- (void)downloadApp
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"itms-services://?action=download-manifest&url=" stringByAppendingString:plistDownloadLink]]];
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
