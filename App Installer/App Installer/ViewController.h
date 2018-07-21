//
//  ViewController.h
//  App Installer
//
//  Created by Justin Proulx on 2017-06-23.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>

@interface ViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField *URLTextField;
    IBOutlet UIButton *installButton;
    IBOutlet UIButton *scarButton;
    
    IBOutlet UITextView *instructionsTextView;
    IBOutlet UILabel *versionLabel;
    
    IBOutlet UISwitch *resignSwitch;
    
    IBOutlet UIProgressView *progressView;
}

- (void)pasteboardInstallAction;
- (void)urlSchemeInstallWithURL:(NSString *)url;

@end

