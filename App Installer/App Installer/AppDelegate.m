//
//  AppDelegate.m
//  App Installer
//
//  Created by Justin Proulx on 2017-06-23.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // delete garbage
    NSString *tempDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"temp"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:tempDir])
    {
        [fileManager removeItemAtPath:tempDir error:&error];
    }
    NSString *ipaDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"general.ipa"];
    if ([fileManager fileExistsAtPath:ipaDir])
    {
        [fileManager removeItemAtPath:ipaDir error:&error];
    }
    
    // if we launched from a shortcut, then return NO here so performActionForShortcut will take over
    BOOL launchedFromShortcut = launchOptions[UIApplicationLaunchOptionsShortcutItemKey];

    
    // Override point for customization after application launch.
    return !launchedFromShortcut;
}


- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    
    if ([shortcutItem.type isEqualToString:@"com.lbastudios.App-Installer.installFromClipboard"])
    {
        ViewController *mainViewController = self.window.rootViewController.childViewControllers.firstObject;
        [mainViewController pasteboardInstallAction];
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation {
    ViewController *mainViewController = self.window.rootViewController.childViewControllers.firstObject;
    [mainViewController urlSchemeInstallWithURL:[url.description stringByReplacingOccurrencesOfString:@"app-installer://" withString:@""]];
    
    return YES;
}


@end
