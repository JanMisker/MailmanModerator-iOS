//
//  MaillistSettingsView.m
//  Mailman
//
//  Created by Jan Misker on 01-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MaillistSettingsView.h"


@implementation MaillistSettingsView

@synthesize emailAddressCell, baseAdminURLCell, testCell, passwordCell, 
emailAddressTextField, baseAdminURLTextField, passwordTextField, testSpinner, delegate, maillist;


- (IBAction)save {
	if (!maillist) {
		self.maillist = [[[MaillistSettings alloc] init] autorelease];
	}
	self.maillist.emailAddress = emailAddressTextField.text;
	self.maillist.baseAdminURL = baseAdminURLTextField.text;
	self.maillist.password = passwordTextField.text;
	self.maillist.moderateItems = nil;
	[self.delegate maillistSettingsView:self savedMaillist:self.maillist];
}

- (IBAction)cancel {
	[delegate maillistSettingsViewCanceled:self];
}

- (IBAction)testConnection {
	[self resignFirstResponder];
	[self updateBaseAdminURLField];
	MaillistSettings *maillistSettings = [[[MaillistSettings alloc] init] autorelease];
	maillistSettings.emailAddress = emailAddressTextField.text;
	maillistSettings.baseAdminURL = baseAdminURLTextField.text;
	maillistSettings.password = passwordTextField.text;
	[testSpinner startAnimating];
	[MailmanWebsite testConnection:self maillist:maillistSettings];
}

- (IBAction)updateBaseAdminURLField {
	if (emailAddressTextField.text && !baseAdminURLTextField.text) {
		NSArray *parts = [emailAddressTextField.text componentsSeparatedByString:@"@"];
		if ([parts count] == 2) {
			NSString *listname = [parts objectAtIndex:0];
			NSString *hostname = [parts objectAtIndex:1];
			NSString *url = [NSString stringWithFormat:@"http://%@/mailman/admindb/%@_%@", hostname, listname, hostname];
			baseAdminURLTextField.text = url;
		}
	}			
}

#pragma mark MailmanWebsiteDelegate

- (void)mailmanWebsiteTestSucceeded:(MailmanWebsite *)mailmanWebsite {
	[testSpinner stopAnimating];
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Connection test successful" 
													 message:@"Save settings" 
													delegate:self 
										   cancelButtonTitle:@"Cancel"	
										   otherButtonTitles:@"Save", nil] autorelease];
	[alert show];
}
- (void)mailmanWebsite:(MailmanWebsite *)mailmanWebsite moderateItems:(NSArray *)items {
}
- (void)mailmanWebsite:(MailmanWebsite *)mailmanWebsite connectionFailed:(NSString *)msg {
	[testSpinner stopAnimating];
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Connection test failed" 
													 message:msg 
													delegate:self 
										   cancelButtonTitle:@"Ok"	
										   otherButtonTitles:nil] autorelease];
	[alert show];
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

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																							target:self 
																							action:@selector(save)] 
											  autorelease];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																							target:self 
																							action:@selector(cancel)] 
											  autorelease];
}


- (void)viewWillAppear:(BOOL)animated {
	self.title = @"Create maillist";
	self.emailAddressTextField.text = maillist.emailAddress;
	self.passwordTextField.text = maillist.password;
	self.baseAdminURLTextField.text = maillist.baseAdminURL;
	self.navigationItem.rightBarButtonItem.enabled = self.passwordTextField.text && self.baseAdminURLTextField.text;
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.emailAddressTextField becomeFirstResponder];
}

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
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 3;
		case 1:
			return 1;
		default:
			return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				return emailAddressCell;
			case 1:
				return passwordCell;
			case 2:
				return baseAdminURLCell;
			default:
				break;
		}
	}
	if (indexPath.section == 1) {
		switch (indexPath.row) {
			case 0:
				return testCell;
		}
	}
	return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 39;
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

#pragma mark TextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[theTextField resignFirstResponder];
	if (theTextField == emailAddressTextField) {
		[passwordTextField becomeFirstResponder];
		[self updateBaseAdminURLField];
	}
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.navigationItem.rightBarButtonItem.enabled = self.passwordTextField.text && self.baseAdminURLTextField.text;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self save];
	}
}

- (void)dealloc {
	[maillist release];
    [super dealloc];
}


@end

