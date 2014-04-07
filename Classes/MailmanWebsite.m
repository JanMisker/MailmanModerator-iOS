//
//  MailmanWebsiteController.m
//  Mailman
//
//  Created by Jan Misker on 03-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MailmanWebsite.h"
#import "RegexKitLite.h"
#import "TFHpple.h"

@implementation MailmanWebsite

@synthesize maillist, delegate;

- (id)initWithDelegate:(id<MailmanWebsiteDelegate>)_delegate maillist:(MaillistSettings *)_maillist {
	if (self = [super init]) {
		self.delegate = _delegate;
		self.maillist = _maillist;
	}
	return self;
}

+ (MailmanWebsite *)testConnection:(id<MailmanWebsiteDelegate>)delegate maillist:(MaillistSettings *)maillist {
	MailmanWebsite *handler = [[MailmanWebsite alloc] initWithDelegate:delegate maillist:maillist];
	[handler testConnection];
	[handler autorelease];
	return handler;
}
+ (MailmanWebsite *)loadModerateItems:(id<MailmanWebsiteDelegate>)delegate maillist:(MaillistSettings *)maillist {
	MailmanWebsite *handler = [[MailmanWebsite alloc] initWithDelegate:delegate maillist:maillist];
	[handler loadModerateItems];
	[handler autorelease];
	return handler;
}
+ (MailmanWebsite *)submit:(id<MailmanWebsiteDelegate>)delegate action:(MailmanWebsiteAction)action items:(NSArray *)items maillist:(MaillistSettings *)maillist {
	MailmanWebsite *handler = [[MailmanWebsite alloc] initWithDelegate:delegate maillist:maillist];
	[handler submit:(MailmanWebsiteAction)action items:(NSArray *)items];
	[handler autorelease];
	return handler;
}


- (void)testConnection {
	state = MailmanWebsiteStateTest;
	for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
	}
	[self requestUrl:[NSString stringWithFormat:@"%@?details=all", maillist.baseAdminURL]
				post:[NSDictionary dictionaryWithObjectsAndKeys:maillist.password, @"adminpw", @"all", @"details", nil]];
}
- (void)loadModerateItems {
	state = MailmanWebsiteStateLoadModerateItems;
	[self requestUrl:[NSString stringWithFormat:@"%@?details=all", maillist.baseAdminURL]
				post:[NSDictionary dictionaryWithObjectsAndKeys:maillist.password, @"adminpw", @"all", @"details", nil]];
}
- (void)submit:(MailmanWebsiteAction)action items:(NSArray *)items {
	state = MailmanWebsiteStateSubmit;
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1 + [items count]];
	[dict setObject:maillist.password forKey:@"adminpw"];
	for (NSString *msgId in items) {
		[dict setObject:[NSString stringWithFormat:@"%d", action] forKey:msgId];
	}
	[self requestUrl:maillist.baseAdminURL
				post:dict];
}

- (void)requestUrl:(NSString *)url post:(NSDictionary *)postDictionary {
	if (connection) {
		[connection cancel];
		[connection release];
	}
	NSMutableURLRequest *theRequest=[NSMutableURLRequest 
									 requestWithURL:[NSURL URLWithString:url]
									 cachePolicy:NSURLRequestReloadIgnoringCacheData
									 timeoutInterval:60.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	NSString *postData = @"";
	for (NSString *key in postDictionary) {
		NSString *value = [postDictionary objectForKey:key];
		value = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)value, NULL, CFSTR("+="), kCFStringEncodingUTF8);
		postData = [postData stringByAppendingFormat:@"%@=%@&", key, value];
	}
	[theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (connection) {
		receivedData = [[NSMutableData alloc] retain];
	} else {
		// inform the user that the download could not be made
		[delegate mailmanWebsite:self connectionFailed:@"Connection could not be made (10)"];
	}
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [receivedData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	}
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // do something with the data
	//NSLog(@"Cookies: %@", [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] description]);
	//NSString *responseHTML = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	//NSLog(@"html: %@", responseHTML);
	//NSArray *arr = [responseHTML componentsMatchedByRegex:[NSString stringWithFormat:@"(?i)%@\\?msgid=(\\d+)", maillist.baseAdminURL] 
	//											  capture:1];
	if (state == MailmanWebsiteStateTest) {
		TFHpple *doc = [[TFHpple alloc] initWithHTMLData:receivedData];
		NSArray *nodes = [doc search:@"//input[@name='adminpw']"];//[@name='admlogin']"];
		if ([nodes count]) {
			[delegate mailmanWebsite:self connectionFailed:@"Wrong password"];
		} else {
			nodes = [doc search:@"//a[contains(@href, '/listinfo')]"];
			if ([nodes count]) {
				[delegate mailmanWebsiteTestSucceeded:self];
			} else {
				[delegate mailmanWebsite:self connectionFailed:@"Unknown error, invalid base admin url?"];
			}
		}
	} else if (state == MailmanWebsiteStateLoadModerateItems) {
		NSMutableArray *result = [[NSMutableArray alloc] init];
		NSDateFormatter *dateParser = [[[NSDateFormatter alloc] init] autorelease];
		[dateParser setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
		[dateParser setDateFormat:@"E MMM dd HH:mm:ss yyyy"];
		/* /NSString *testPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"kik-elamys.html"];
		NSStringEncoding encoding;
		NSError *error = nil;
		//NSString *testString = [[NSString stringWithContentsOfFile:testPath usedEncoding:&encoding error:&error] lowercaseString];
		if (error) {
			NSLog(@"%@", [error localizedDescription]);
			NSLog(@"%@", [error localizedFailureReason]);
		}
		if (!testString) {
			encoding = NSASCIIStringEncoding;
			error = nil;
			testString = [[NSString stringWithContentsOfFile:testPath encoding:encoding error:&error] lowercaseString];
			if (error) {
				NSLog(@"%@", [error localizedDescription]);
				NSLog(@"%@", [error localizedFailureReason]);
			}
		}	*/		
		TFHpple *doc = [[TFHpple alloc] initWithHTMLData:receivedData];
		//TFHpple *doc = [[TFHpple alloc] initWithHTMLData:[testString dataUsingEncoding:encoding]];
		NSArray *inputs = [doc search:@"//form//table//table//input[@value='0']"];
		NSUInteger i, count = [inputs count];
		for (i = 0; i < count; i++) {
			TFHppleElement *inputEle = [inputs objectAtIndex:i];
			MailmanMessage *message = [[MailmanMessage alloc] init];
			message.idNumber = [inputEle objectForKey:@"name"];
			NSArray *ele = [doc search:[NSString stringWithFormat:
										@"//form//table[@width and position()=%d]/tr[position()<=4]/td[position()=2]/text()", i + 1]];
			if ([ele count] == 4) {
				message.sender = [[ele objectAtIndex:0] content];
				message.subject = [[ele objectAtIndex:1] content];
				message.reason = [[ele objectAtIndex:2] content];
				message.dateString = [[ele objectAtIndex:3] content];
				message.date = [dateParser dateFromString:message.dateString];
				//NSLog(@"%@ %@", message.dateString, message.date);
				[result addObject:message];
			}
		}
		//NSLog(@"result: %@", [result description]);
		maillist.moderateItems = result;
		[delegate mailmanWebsite:self moderateItems:result];
	} else if (state == MailmanWebsiteStateSubmit) {
		[self loadModerateItems];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//NSLog(@"Received error: %@ %@", [error localizedDescription], [error localizedFailureReason] );
	[delegate mailmanWebsite:self connectionFailed:[error localizedDescription]];
}


- (void)dealloc {
	[maillist release];
	[super dealloc];
}

@end
