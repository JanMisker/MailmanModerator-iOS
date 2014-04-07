//
//  MaillistSettings.m
//  Mailman
//
//  Created by Jan Misker on 02-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MaillistSettings.h"

static NSString *const MaillistSettingsPassword = @"MaillistSettingsPassword";
static NSString *const MaillistSettingsEmailAddress = @"MaillistSettingsEmailAddress";
static NSString *const MaillistSettingsBaseAdminURL = @"MaillistSettingsBaseAdminURL";

@implementation MaillistSettings

@synthesize moderateItems;

- (id)init {
	if (self = [super init]) {
		dict = [[NSMutableDictionary dictionaryWithCapacity:3] retain];
	}
	return self;
}
- (id)initWithDictionary:(NSDictionary *)other {
	if (self = [super init]) {
		dict = [[NSMutableDictionary dictionaryWithDictionary:other] retain];
	}
	return self;
}

- (NSString *)password {
	return [dict objectForKey:MaillistSettingsPassword];
}
- (void)setPassword:(NSString *)password {
	[dict setValue:password forKey:MaillistSettingsPassword];
}

- (NSString *)emailAddress {
	return [dict objectForKey:MaillistSettingsEmailAddress];
}
- (void)setEmailAddress:(NSString *)emailAddress {
	[dict setValue:emailAddress forKey:MaillistSettingsEmailAddress];
}

- (NSString *)baseAdminURL {
	return [dict objectForKey:MaillistSettingsBaseAdminURL];
}
- (void)setBaseAdminURL:(NSString *)baseAdminURL {
	[dict setValue:baseAdminURL forKey:MaillistSettingsBaseAdminURL];
}

- (NSDictionary *)dictionaryRepresentation {
	return [NSDictionary dictionaryWithDictionary:dict];
}

- (void)dealloc {
	[dict release];
	[super dealloc];
}

@end
