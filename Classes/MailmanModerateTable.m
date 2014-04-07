//
//  MailmanModerateTable.m
//  Mailman
//
//  Created by Jan Misker on 03-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MailmanModerateTable.h"


@implementation MailmanModerateTable

@synthesize discardButton, approveButton, spaceButton, refreshButton, processButton, maillist, msgCell;


- (IBAction)discardSelectedItems {
	[MailmanWebsite submit:self 
					action:MailmanWebsiteActionDiscard 
					 items:[self getItemIDsWithAction:MailmanWebsiteActionDiscard] 
				  maillist:maillist];
}

- (IBAction)approveSelectedItems {
	[MailmanWebsite submit:self 
					action:MailmanWebsiteActionApprove 
					 items:[self getItemIDsWithAction:MailmanWebsiteActionApprove] 
				  maillist:maillist];
}

- (IBAction)processItemActions {
	[self approveSelectedItems];
	[self discardSelectedItems];
}

- (IBAction)confirmProcessItemActions {
	UIActionSheet *confirmSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm processing messages"
															  delegate:self 
													 cancelButtonTitle:@"Cancel" 
												destructiveButtonTitle:@"Process" 
													 otherButtonTitles:nil];
	[confirmSheet setActionSheetStyle:UIActionSheetStyleDefault];
	[confirmSheet showFromToolbar:self.navigationController.toolbar];
	[confirmSheet autorelease];
}

- (IBAction)refresh {
	[MailmanWebsite loadModerateItems:self maillist:maillist];
}

- (NSArray *)getItemIDsWithAction:(MailmanWebsiteAction)action {
	NSMutableArray *items = [NSMutableArray array];
	NSUInteger i, count = [itemActions count];
	for (i = 0; i < count; i++) {
		MailmanWebsiteAction _action = [[itemActions objectAtIndex:i] intValue];
		if (_action == action) {
			[items addObject:[[maillist.moderateItems objectAtIndex:i] idNumber]];
		}
	}
	return items;
}

- (void)updateProcessButton {
	int count = 0;
	for (NSNumber *num in itemActions) {
		int i = [num intValue];
		if (i != MailmanWebsiteActionDefer)
			++count;
	}
	processButton.enabled = count != 0;
	processButton.title = [NSString stringWithFormat:@"Process (%d)", count];
}


#pragma mark MailmanWebsiteDelegate

- (void)mailmanWebsite:(MailmanWebsite *)mailmanWebsite moderateItems:(NSArray *)items {
	[itemActions release];
	itemActions = [[NSMutableArray alloc] initWithCapacity:[maillist.moderateItems count]];
	for (int i = 0; i < [maillist.moderateItems count]; ++i) {
		[itemActions insertObject:[NSNumber numberWithInt:MailmanWebsiteActionDefer] atIndex:i];
	}
	[self.tableView reloadData];
	[self updateProcessButton];
}

- (void)mailmanWebsite:(MailmanWebsite *)mailmanWebsite connectionFailed:(NSString *)msg {
	[[[[UIAlertView alloc] initWithTitle:@"Connection failure" 
								 message:msg 
								delegate:nil 
					   cancelButtonTitle:@"OK" 
					   otherButtonTitles:nil] 
	  autorelease] 
	 show];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [actionSheet cancelButtonIndex]) {
		[self processItemActions];
	}
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight = 60;
	itemActions = [[NSMutableArray alloc] initWithCapacity:[maillist.moderateItems count]];
	for (int i = 0; i < [maillist.moderateItems count]; ++i) {
		[itemActions insertObject:[NSNumber numberWithInt:MailmanWebsiteActionDefer] atIndex:i];
	}
	self.navigationController.toolbarHidden = NO;
	self.toolbarItems = [NSArray arrayWithObjects:self.spaceButton, self.processButton, self.spaceButton, nil];
	self.title = maillist.emailAddress;
	self.navigationItem.rightBarButtonItem = self.refreshButton;
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"mark-off" ofType:@"png"];
	markOffImg = [[UIImage imageWithContentsOfFile:path] retain];
	path = [[NSBundle mainBundle] pathForResource:@"mark-red" ofType:@"png"];
	markDiscardImg = [[UIImage imageWithContentsOfFile:path] retain];
	path = [[NSBundle mainBundle] pathForResource:@"mark-green" ofType:@"png"];
	markApproveImg = [[UIImage imageWithContentsOfFile:path] retain];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [maillist.moderateItems count] + 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [maillist.moderateItems count]) {
		return [self tableView:tableView infoCellForRowAtIndexPath:indexPath];
	} else {
		return [self tableView:tableView mailmanMessageCellForRowAtIndexPath:indexPath];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView mailmanMessageCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MessageCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil];
        cell = msgCell;
        self.msgCell = nil;
    }
	MailmanMessage *msg = [maillist.moderateItems objectAtIndex:indexPath.row];
	UIImageView *icon = (UIImageView *)[cell viewWithTag:1];
	UILabel *senderLabel = (UILabel *)[cell viewWithTag:2];
	UILabel *dateLabel = (UILabel *)[cell viewWithTag:3];
	UILabel *subjectLabel = (UILabel *)[cell viewWithTag:4];

	senderLabel.text = msg.sender;
	subjectLabel.text = msg.subject;
	dateLabel.text = [dateFormatter stringFromDate:msg.date];

	MailmanWebsiteAction action = [[itemActions objectAtIndex:indexPath.row] intValue];
	switch (action) {
		case MailmanWebsiteActionApprove:
			icon.image = markApproveImg;
			break;
		case MailmanWebsiteActionDiscard:
			icon.image = markDiscardImg;
			break;
		default:
			icon.image = markOffImg;
			break;
	}
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView infoCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InfoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	cell.textLabel.textAlignment = UITextAlignmentCenter;

	if ([maillist.moderateItems count] == 0) {
		cell.textLabel.text = @"No messages to moderate";
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.numberOfLines = 1;
		cell.textLabel.font = [UIFont systemFontOfSize:16.0];
	} else {
		//cell.textLabel.text = nil;
		cell.textLabel.text = @"Tap a message to switch moderation action\ngreen = approve, red = discard, empty = defer";
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
		cell.textLabel.numberOfLines = 3;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	if (indexPath.row >= [itemActions count])
		return;
	MailmanWebsiteAction action = [[itemActions objectAtIndex:indexPath.row] intValue];
	switch (action) {
		case MailmanWebsiteActionDefer:
			action = MailmanWebsiteActionApprove;
			break;
		case MailmanWebsiteActionApprove:
			action = MailmanWebsiteActionDiscard;
			break;
		default:
			action = MailmanWebsiteActionDefer;
			break;
	}
	[itemActions replaceObjectAtIndex:indexPath.row 
						   withObject:[NSNumber numberWithInt:action]];
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
	[self updateProcessButton];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[itemActions release];
	[discardButton release];
	[approveButton release];
	[refreshButton release];
	[spaceButton release];
	[markOffImg release];
	[markApproveImg release];
	[markDiscardImg release];
	[dateFormatter release];
    [super dealloc];
}


@end

