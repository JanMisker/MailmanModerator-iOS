//
//  MaillistSettingsView.h
//  Mailman
//
//  Created by Jan Misker on 01-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaillistSettings.h"
#import "MailmanWebsite.h"

@class MaillistSettingsView;

@protocol MaillistSettingsViewDelegate

- (void)maillistSettingsView:(MaillistSettingsView *)view savedMaillist:(MaillistSettings *)maillist;
- (void)maillistSettingsViewCanceled:(MaillistSettingsView *)view;

@end

@interface MaillistSettingsView : UITableViewController <UITextFieldDelegate, UIWebViewDelegate, MailmanWebsiteDelegate, UIAlertViewDelegate> {
	UITableViewCell *emailAddressCell;
	UITableViewCell *baseAdminURLCell;
	UITableViewCell *passwordCell;
	UITableViewCell *testCell;
	
	UITextField *emailAddressTextField;
	UITextField *baseAdminURLTextField;
	UITextField *passwordTextField;
	UIActivityIndicatorView *testSpinner;
	
	MaillistSettings *maillist;
	id<MaillistSettingsViewDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *emailAddressCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *baseAdminURLCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *testCell;

@property (nonatomic, retain) IBOutlet UITextField *emailAddressTextField;
@property (nonatomic, retain) IBOutlet UITextField *baseAdminURLTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *testSpinner;

@property (nonatomic, retain) MaillistSettings *maillist;
@property (nonatomic, assign) id<MaillistSettingsViewDelegate> delegate;

- (IBAction)save;
- (IBAction)cancel;
- (IBAction)testConnection;
- (IBAction)updateBaseAdminURLField;

@end
