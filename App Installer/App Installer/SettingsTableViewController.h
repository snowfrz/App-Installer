//
//  SettingsTableViewController.h
//  App Installer
//
//  Created by Justin Proulx on 2018-07-20.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsTableViewController : UITableViewController
{
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *udidTextField;
    
    UIActivityIndicatorView *activityIndicator;
}


@property NSString * username;
@property NSString * password;
@property NSString * udid;
@property NSString * teamID;


@end

NS_ASSUME_NONNULL_END
