//
//  RootViewController.m
//  Mailman
//
//  Created by Jan Misker on 29-12-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "RootViewController.h"
#import "MailmanModerateTable.h"

NSString *kMaillists = @"kMaillists";

@implementation RootViewController

@synthesize maillists, addButton, refreshButton;

- (IBAction)addMaillist {
	//NSLog(@"- (IBAction)addMaillist;");
	MaillistSettingsView *settingsController = [[MaillistSettingsView alloc] initWithNibName:@"MaillistSettingsView" bundle:nil];
	settingsController.delegate = self;
	[self.navigationController pushViewController:settingsController animated:YES];
}
- (IBAction)editMaillist:(MaillistSettings *)maillist {
	MaillistSettingsView *settingsController = [[MaillistSettingsView alloc] initWithNibName:@"MaillistSettingsView" bundle:nil];
	settingsController.delegate = self;
	settingsController.maillist = maillist;
	[self.navigationController pushViewController:settingsController animated:YES];
}
- (IBAction)refresh {
	//NSLog(@"refresh");
	for (MaillistSettings *maillist in maillists) {
		[MailmanWebsite loadModerateItems:self maillist:maillist];
	}
}

- (void)loadMaillists {
	id arr = [[NSUserDefaults standardUserDefaults] objectForKey:kMaillists];
	if (arr == nil) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:kMaillists];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	NSArray *maillistsAsDictionaries = [[NSUserDefaults standardUserDefaults] arrayForKey:kMaillists];
	self.maillists = [NSMutableArray arrayWithCapacity:[maillistsAsDictionaries count]];
	for (NSDictionary *dict in maillistsAsDictionaries) {
		[self.maillists addObject:[[[MaillistSettings alloc] initWithDictionary:dict] autorelease]];
	}
}
- (void)storeMaillists {
	NSMutableArray *maillistsAsDictionaries = [NSMutableArray arrayWithCapacity:[maillists count]];
	for (MaillistSettings *item in maillists) {
		[maillistsAsDictionaries addObject:[item dictionaryRepresentation]];
	}
	[[NSUserDefaults standardUserDefaults] setObject:maillistsAsDictionaries forKey:kMaillists];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark MailmanWebsiteDelegate
		
- (void)mailmanWebsiteTestSucceeded:(MailmanWebsite *)mailmanWebsite {
}
- (void)mailmanWebsite:(MailmanWebsite *)mailmanWebsite moderateItems:(NSArray *)items {
	[self.tableView reloadData];
}
- (void)mailmanWebsite:(MailmanWebsite *)mailmanWebsite connectionFailed:(NSString *)msg {
}

		 
#pragma mark MaillistSettingsViewDelegate

- (void)maillistSettingsView:(MaillistSettingsView *)view savedMaillist:(MaillistSettings *)maillist {
	//NSLog(@"%@", [maillists class]);
	//NSLog(@"%@", maillist);
	[self.navigationController popViewControllerAnimated:YES];
	int idx = [maillists indexOfObject:maillist];
	if (idx == NSNotFound) {
		[maillists addObject:maillist];
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[maillists count] - 1 inSection:0]] 
							  withRowAnimation:UITableViewRowAnimationBottom];
	} else {
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:idx inSection:0]]
							  withRowAnimation:UITableViewRowAnimationFade];
	}
	[self storeMaillists];
	[view release];
}
- (void)maillistSettingsViewCanceled:(MaillistSettingsView *)view {
	[self.navigationController popViewControllerAnimated:YES];
	[view release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	//NSLog(@"%@", [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] description]);
	[self loadMaillists];
	[self refresh];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	self.navigationItem.rightBarButtonItem = self.refreshButton;
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.title = @"Maillists";
}


- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
    [super viewWillAppear:animated];
}

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
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.tableView.editing)
		return [maillists count] + 1;
    return [maillists count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	if (self.tableView.editing && indexPath.row == [maillists count]) {
		cell.textLabel.text = @"Create new maillist";
		cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		return cell;
	}
	MaillistSettings *settings = [maillists objectAtIndex:indexPath.row];
	cell.textLabel.text = settings.emailAddress;
	if (settings.moderateItems) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d messages to moderate", [settings.moderateItems count]];
	} else {
		cell.detailTextLabel.text = @"No messages to moderate";
	}
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	if (tableView.editing) {
		if (indexPath.row == [maillists count]) {
			[self addMaillist];
		} else {
			[self editMaillist:[maillists objectAtIndex:indexPath.row]];
		}
	} else {
		[self tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
	if (tableView.editing) {
		if (indexPath.row == [maillists count]) {
			[self addMaillist];
		} else {
			[self editMaillist:[maillists objectAtIndex:indexPath.row]];
		}
	} else {
		//show the maillist messages
		MaillistSettings *maillist = [maillists objectAtIndex:indexPath.row];
		if (maillist) {
			MailmanModerateTable *moderator = [[[MailmanModerateTable alloc] initWithNibName:@"MailmanModerateTable" bundle:nil] autorelease];
			moderator.maillist = maillist;
			[self.navigationController pushViewController:moderator animated:YES];
		}
	}
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [maillists count]) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
		[maillists removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self storeMaillists];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		[self addMaillist];
    }   
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:YES];
	[self.tableView reloadData];
	if (editing) {
		[self.navigationItem setRightBarButtonItem:self.addButton animated:YES];
	} else {
		[self.navigationItem setRightBarButtonItem:self.refreshButton animated:YES];
	}
}

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
    [super dealloc];
}


@end

