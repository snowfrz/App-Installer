//
// Created by Dana Buehre on 6/29/17.
// Copyright (c) 2017 Low Budget Animation Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppInstaller : NSObject

- (void)installAppWithURL:(NSString *)downloadLink completionHandler:(void (^)(NSError *))completion;

@end
