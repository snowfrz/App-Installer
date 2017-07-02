//
//  ViewController.h
//  App Installer
//
//  Created by Justin Proulx on 2017-06-23.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>

@interface ViewController : UIViewController <UITextFieldDelegate, SFSafariViewControllerDelegate>
{
    IBOutlet UITextField *URLTextField;
    IBOutlet UIButton *installButton;
    IBOutlet UIButton *scarButton;
}

- (void)pasteboardInstallAction;
- (void)urlSchemeInstallWithURL:(NSString *)url;

@end

