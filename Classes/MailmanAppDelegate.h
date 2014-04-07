//
//  MailmanAppDelegate.h
//  Mailman
//
//  Created by Jan Misker on 29-12-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@interface MailmanAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

