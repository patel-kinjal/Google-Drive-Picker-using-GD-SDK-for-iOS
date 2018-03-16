//
//  AppDelegate.m
//  GDPicker
//
//  Created by Kinjal Patel on 11/07/17.
//  Copyright © 2017 Kinjal Patel. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import <Google/SignIn.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface AppDelegate ()

@property (nonatomic, strong) HomeViewController *homeVC;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (self.window == nil) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    self.homeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    self.window.rootViewController = self.homeVC;
    [self.window makeKeyAndVisible];
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    if (configureError) {
        NSLog(@"Error configuring Google services: %@", configureError.localizedDescription);
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
