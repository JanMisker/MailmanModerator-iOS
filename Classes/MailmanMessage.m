//
//  MailmanMessage.m
//  Mailman
//
//  Created by Jan Misker on 03-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MailmanMessage.h"


@implementation MailmanMessage

@synthesize idNumber, sender, subject, date, dateString, reason;

- (void)dealloc {
	[idNumber release];
	[sender release];
	[subject release];
	[dateString release];
	[date release];
	[reason release];
	[super dealloc];
}

@end
