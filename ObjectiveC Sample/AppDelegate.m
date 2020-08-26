//
//  AppDelegate.m
//  ObjectiveC Sample
//
//  Created by Kalpesh Panchasara on 26/08/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    ViewController * test = [[ViewController alloc]init];
     UINavigationController *navig = [[UINavigationController alloc]initWithRootViewController:test];
    self.window = [[UIWindow alloc]init];
    self.window.frame = self.window.bounds;
    self.window.rootViewController = navig;
    [self.window makeKeyAndVisible];


    return YES;
}




@end
