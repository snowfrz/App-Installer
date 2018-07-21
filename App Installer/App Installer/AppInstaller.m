//
//  AppInstaller.m
//  App Installer
//
//  Created by CreatureSurvive on 2017-06-29.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "AppInstaller.h"


@implementation AppInstaller {
    NSString *_url;
}

- (void)installAppWithURL:(NSString *)downloadLink completionHandler:(void (^)(NSError *))completion {

    // no need to create multiple URLsessions, lets cache this for the lifetime of the app
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:configuration];
    });

    // create our task
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:[self manifestPostRequestWithURL:downloadLink] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        // the task completed without error do things
        if (!error)
        {
            // parse the headers into a dictionary so we can get the download link from them
            NSDictionary *headers = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];

            // attempt to download our app
            [self downloadAppWithManifestURL:[@"https://file.io/" stringByAppendingString:headers[@"key"]]];
        }
        
        // return the completion
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
    
    // make sure we start the task
    [dataTask resume];
}

- (NSData *)manifestDataWithURL:(NSString *)downloadLink {
    // setup local variables
    NSString *appBundlePath = [[NSBundle mainBundle] pathForResource:@"general" ofType:@"plist"];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // create plist if it doesnt exist in our documents directory;
    if (![fileManager fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@"general.plist"]])
    {
        //copy new file to documents directory
        [fileManager copyItemAtPath:appBundlePath toPath:[documentsDirectory stringByAppendingPathComponent:@"general.plist"] error:nil];
    }

    NSString *documentsDirectoryPlistPath = [documentsDirectory stringByAppendingPathComponent:@"general.plist"];

    // check if the our last url is equal to the new url
    if ((_url != nil) &! [_url isEqualToString:downloadLink])
    {
        // no need to update the manifest just return it
        return [fileManager contentsAtPath:documentsDirectoryPlistPath];
    }

    // get the existing manifest as a dictionary to edit
    NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] initWithContentsOfFile:documentsDirectoryPlistPath];

    // sets the url of the manifest to the requested download link
    manifestDict[@"items"][0][@"assets"][0][@"url"] = downloadLink;
    [manifestDict writeToFile:documentsDirectoryPlistPath atomically:YES];

    // return the path to our updated manifest
    return [fileManager contentsAtPath:documentsDirectoryPlistPath];
}


- (NSURLRequest *)manifestPostRequestWithURL:(NSString *)downloadLink
{
    NSString *boundary = [[NSUUID UUID] UUIDString];

    // set body of the request and insert our manifest data
    // this is ugly, but its the only way i've found that works
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition:form-data; name=\"file\"; filename=\"general.plist\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/x-plist\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[self manifestDataWithURL:downloadLink]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // setup request
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString:@"https://file.io/?expires=1d"]];
    [request setHTTPMethod:@"POST"];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody:body];

    return [request copy];
}

- (void)downloadAppWithManifestURL:(NSString *)downloadLink
{
//    NSLog(@"path: %@", downloadLink);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"itms-services://?action=download-manifest&url=" stringByAppendingString:downloadLink]]];
    });
}
@end
