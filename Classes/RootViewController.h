//
//  RootViewController.h
//  Mailman
//
//  Created by Jan Misker on 29-12-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "MaillistSettingsView.h"

@interface RootViewController : UITableViewController <MaillistSettingsViewDelegate, MailmanWebsiteDelegate> {
	NSMutableArray *maillists;
	UIBarButtonItem *addButton;
	UIBarButtonItem *refreshButton;
}

@property (nonatomic, retain) NSMutableArray *maillists;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;

- (IBAction)addMaillist;
- (IBAction)editMaillist:(MaillistSettings *)maillist;
- (IBAction)refresh;

- (void)loadMaillists;
- (void)storeMaillists;

@end
