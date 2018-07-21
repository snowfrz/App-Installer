//
//  AppResigner.h
//  App Installer
//
//  Created by Justin Proulx on 2018-07-19.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppResigner : NSObject <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>
{
    
}

@property (nonatomic, retain) NSMutableData *appDataToDownload;
@property (nonatomic) float downloadSize;
@property (nonatomic) float progress;

- (void)resignAppAtURL:(NSString *)downloadLink completionHandler:(void (^)(NSError *))completion;

@end

NS_ASSUME_NONNULL_END
