//
//  AppResigner.m
//  App Installer
//
//  Created by Justin Proulx on 2018-07-19.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "AppResigner.h"
#import "AppInstaller.h"
#import "EEBackend.h"
#import "SSZipArchive.h"
#import "SAMKeychain.h"

@implementation AppResigner

- (void)resignAppAtURL:(NSString *)downloadLink completionHandler:(void (^)(NSError *))completion
{
    //make necessary file locations
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *temporaryDirectory = [self temporaryDirectoryWithReset:YES];
    NSString *unarchiveDirectory = [temporaryDirectory stringByAppendingPathComponent:@"General"];
    
    if (![fileManager fileExistsAtPath:unarchiveDirectory])
    {
        [fileManager createDirectoryAtPath:unarchiveDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    // first, download file
    [self downloadFileAtURL:downloadLink completionHandler:^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *userInfo = @{@"Message":@"Unpacking...", @"Installing":[NSNumber numberWithBool:YES]};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressDone" object:self userInfo:userInfo];
            
            // Next, unpack the .ipa into the correct directory structure
            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *appPath = [documentsDirectory stringByAppendingPathComponent:@"general.ipa"];
            
            [self unpackIPAAtFileLocation:appPath completionHandler:^(void){
                NSDictionary *userInfo = @{@"Message":@"Resigning...", @"Installing":[NSNumber numberWithBool:YES]};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressDone" object:self userInfo:userInfo];
                
                // Next, resign the unpacked app
                NSString * payloadDirectory = [[[self temporaryDirectoryWithReset:NO] stringByAppendingPathComponent:@"General"] stringByAppendingPathComponent:@"Payload"];
                NSError *error;
                NSString * dotAppFileName = [fileManager contentsOfDirectoryAtPath:payloadDirectory error:&error][0];
                NSString * pathToDotApp = [payloadDirectory stringByAppendingPathComponent:dotAppFileName];
                
                [self resignBundleAtFileLocation:pathToDotApp completionHandler:^(void){
                    NSDictionary *userInfo = @{@"Message":@"Packaging...", @"Installing":[NSNumber numberWithBool:YES]};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressDone" object:self userInfo:userInfo];
                    
                    //Next, repackage the newly signed app
                    NSString * appDirectory = [[self temporaryDirectoryWithReset:NO] stringByAppendingPathComponent:@"General"];
                    [self repackageAppDirectoryAtLocation:appDirectory completionHandler:^(void){
                        NSDictionary *userInfo = @{@"Message":@"Uploading...", @"Installing":[NSNumber numberWithBool:YES]};
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressDone" object:self userInfo:userInfo];
                        
                        // Next, re-upload the signed app
                        [self uploadIPAAtFileLocation:[[self temporaryDirectoryWithReset:NO] stringByAppendingPathComponent:@"General.ipa"] completionHandler:^(NSError *error, NSDictionary *headers){
                            NSDictionary *userInfo = @{@"Message":@"Installing...", @"Installing":[NSNumber numberWithBool:YES]};
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressDone" object:self userInfo:userInfo];
                            
                            // Finally, download and install the app
                            AppInstaller *installer = [AppInstaller new];
                            [installer installAppWithURL:[@"https://file.io/" stringByAppendingString:headers[@"key"]] completionHandler:^(NSError *error){
                                if (error)
                                {
                                    [self displayAlertWithTitle:@"Failure" andMessage:error.localizedDescription plusActions:nil];
                                }
                                NSDictionary *userInfo = @{@"Message":@"Install", @"Installing":[NSNumber numberWithBool:NO]};
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressDone" object:self userInfo:userInfo];
                            }];
                        }];
                    }];
                }];
            }];
        });
    }];
}

#pragma mark - Downloading File
- (void)downloadFileAtURL:(NSString *)downloadLink completionHandler:(void (^)(void))completion
{
    // no need to create multiple URLsessions, lets cache this for the lifetime of the app
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    
    _appDataToDownload = [[NSMutableData alloc] init];
    
    NSURL *url = [NSURL URLWithString:downloadLink];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url];
        
    [dataTask resume];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        //wait for it to finish
        while (self->_progress != 1){}
        
        completion();
    });
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
    
    _downloadSize = [response expectedContentLength];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [_appDataToDownload appendData:data];
    _progress = [_appDataToDownload length]/_downloadSize;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressUpdated" object:self];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (!error)
    {
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        NSString *appPath = [documentsDirectory stringByAppendingPathComponent:@"general.ipa"];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if ([manager fileExistsAtPath:appPath])
        {
            [manager removeItemAtPath:appPath error:&error];
        }
        
        [_appDataToDownload writeToFile:appPath atomically:YES];
    }
    else
    {
        [self displayAlertWithTitle:@"Failure" andMessage:error.localizedDescription plusActions:nil];
    }
}

#pragma mark - Unpacking IPA
- (void)unpackIPAAtFileLocation:(NSString *)fileLocation completionHandler:(void (^)(void))completion
{
    NSString *temporaryDirectory = [self temporaryDirectoryWithReset:NO];
    NSString *unarchiveDirectory = [temporaryDirectory stringByAppendingPathComponent:@"General"];
    NSString *zipFolder = [temporaryDirectory stringByAppendingPathComponent:@"General.zip"];
    
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //delete existing archives
    if ([fileManager fileExistsAtPath:zipFolder])
    {
        [fileManager removeItemAtPath:zipFolder error:&error];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        while (![fileManager fileExistsAtPath:fileLocation])
        {
            NSLog(@"Waiting for download");
        }
        
        NSError *error;
        
        // copy the file to the temp folder
        [fileManager copyItemAtPath:fileLocation toPath:zipFolder error:&error];
        
        // Unzip
        [SSZipArchive unzipFileAtPath:zipFolder toDestination:unarchiveDirectory];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

- (NSString *)temporaryDirectoryWithReset:(BOOL)reset
{
    NSString *tempDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"temp"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:tempDir])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return tempDir;
}

#pragma mark - Resignature
- (void)resignBundleAtFileLocation:(NSString *)fileLocation completionHandler:(void (^)(void))completion
{
    NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleIDUsername"];
    NSString * password = [SAMKeychain passwordForService:@"AppInstallerAppleID" account:username];
    NSString * teamID = [[NSUserDefaults standardUserDefaults] objectForKey:@"TeamID"];
    
    
    [EEBackend signBundleAtPath:fileLocation username:username password:password priorChosenTeamID:teamID withCompletionHandler:^(NSError *error){
        if (error)
        {
            // failure alert
            [self displayAlertWithTitle:@"Failure" andMessage:error.localizedDescription plusActions:nil];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

#pragma mark - Repackaging
- (void)repackageAppDirectoryAtLocation:(NSString *)directory completionHandler:(void (^)(void))completion
{
    NSString *zipPath = [directory stringByAppendingPathExtension:@"ipa"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    
    if ([manager fileExistsAtPath:zipPath])
    {
        [manager removeItemAtPath:zipPath error:&error];
    }
    
    [SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:directory];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completion();
    });
}

#pragma mark - Reuploading
- (void)uploadIPAAtFileLocation:(NSString *)location completionHandler:(void (^)(NSError * error, NSDictionary * headers))completion
{
    // no need to create multiple URLsessions, lets cache this for the lifetime of the app
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    
    // create our task
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:[self appPostRequest] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSDictionary *headers = [[NSDictionary alloc] init];
                                          // the task completed without error do things
                                          if (!error)
                                          {
                                              // parse the headers into a dictionary so we can get the download link from them
                                              headers = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                          }
                                          else
                                          {
                                              [self displayAlertWithTitle:@"Failure" andMessage:error.localizedDescription plusActions:nil];
                                          }
                                          
                                          // return the completion
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completion(error, headers);
                                          });
                                      }];
    
    // make sure we start the task
    [dataTask resume];
}

- (NSURLRequest *)appPostRequest
{
    NSString *boundary = [[NSUUID UUID] UUIDString];
    
    // set body of the request and insert our manifest data
    // this is ugly, but its the only way i've found that works
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition:form-data; name=\"file\"; filename=\"General.ipa\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[self appData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setup request
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString:@"https://file.io/?expires=1d"]];
    [request setHTTPMethod:@"POST"];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody:body];
    
    return [request copy];
}

- (NSData *)appData
{
    // setup local variables
    NSString *tempDirectory = [self temporaryDirectoryWithReset:NO];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    NSString *appPath = [tempDirectory stringByAppendingPathComponent:@"General.ipa"];
    
    // return the path to our updated manifest
    return [fileManager contentsAtPath:appPath];
}


#pragma mark - Alerts
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
    
    [[self getTopController] presentViewController:alert animated:YES completion:nil];
}

- (UIViewController *)getTopController
{
    //necessary stuff to show an alert from an NSObject subclass
    //finds the current view controller
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    //honestly not quire sure what this does
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end
