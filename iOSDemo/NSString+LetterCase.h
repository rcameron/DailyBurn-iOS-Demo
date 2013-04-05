//
//  NSString+LetterCase.h
//  RemoteObjects
//
//  Created by Rich Cameron on 1/30/13.
//  Copyright (c) 2013 rcameron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LetterCase)

// Cases
- (NSString *)underscoreCase;
- (NSString *)camelCase;
- (NSString *)leadingLowerCase; // force first char to lowercase

// Plural
- (NSString *)plural;

// Singular
- (NSString *)singular;

@end
