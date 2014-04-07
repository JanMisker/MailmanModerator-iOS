//
//  MaillistSettings.h
//  Mailman
//
//  Created by Jan Misker on 02-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MaillistSettings : NSObject {
	NSMutableDictionary *dict;
	NSArray *moderateItems;
}

@property (nonatomic, retain) NSString *emailAddress;
@property (nonatomic, retain) NSString *baseAdminURL;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;
@property (nonatomic, retain) NSArray *moderateItems;

- (id)initWithDictionary:(NSDictionary *)other;

@end
