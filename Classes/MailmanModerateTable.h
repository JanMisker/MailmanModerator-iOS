//
//  MailmanModerateTable.h
//  Mailman
//
//  Created by Jan Misker on 03-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaillistSettings.h"
#import "MailmanMessage.h"
#import "MailmanWebsite.h"

@interface MailmanModerateTable : UITableViewController <MailmanWebsiteDelegate, UIActionSheetDelegate> {
	UITableViewCell *msgCell;
	UIBarButtonItem *discardButton;
	UIBarButtonItem *approveButton;
	UIBarButtonItem *spaceButton;
	UIBarButtonItem *processButton;
	UIBarButtonItem *refreshButton;
	MaillistSettings *maillist;

	NSMutableArray *itemActions;
	UIImage *markOffImg;
	UIImage *markApproveImg;
	UIImage *markDiscardImg;
	NSDateFormatter *dateFormatter;
}

@property (nonatomic, assign) IBOutlet UITableViewCell *msgCell;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *discardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *approveButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *spaceButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *processButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) MaillistSettings *maillist;

- (IBAction)discardSelectedItems;
- (IBAction)approveSelectedItems;
- (IBAction)processItemActions;
- (IBAction)confirmProcessItemActions;
- (IBAction)refresh;

- (NSArray *)getItemIDsWithAction:(MailmanWebsiteAction)action;
- (void)updateProcessButton;

- (UITableViewCell *)tableView:(UITableView *)tableView mailmanMessageCellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView infoCellForRowAtIndexPath:(NSIndexPath *)indexPath;


@end
