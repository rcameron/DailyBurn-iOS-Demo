//
//  NSString+LetterCase.m
//  RemoteObjects
//
//  Created by Rich Cameron on 1/30/13.
//  Copyright (c) 2013 rcameron. All rights reserved.
//

#import "NSString+LetterCase.h"

@implementation NSString (LetterCase)

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Underscore
//
// Ex. [@"ManagedObject" underscoreCase] => @"managed_object"
////////////////////////////////////////////////////////
- (NSString *)underscoreCase
{
  NSMutableString *mutableText = [self mutableCopy];
  
  NSRange range = NSMakeRange(1, [mutableText length] - 1);
  
  do {
    range = [mutableText rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]
                                         options:0
                                           range:range];
    
    if (range.location != NSNotFound)
      [mutableText insertString:@"_" atIndex:range.location];
    
    range.location += 2;
    range.length = [mutableText length] - range.location;
    
  } while (range.location != NSNotFound && range.location < [mutableText length]);
  
  return [mutableText lowercaseString];
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Camel
//
// Ex. [@"workout_video_title" camelCase] => @"workoutVideoTitle"
////////////////////////////////////////////////////////
- (NSString *)camelCase
{
  NSMutableString *mutableText = [self mutableCopy];
  
  NSRange range = NSMakeRange(0, [mutableText length]);
  
  do {
    range = [mutableText rangeOfString:@"_"
                               options:0
                                 range:range];
    
    if (range.location != NSNotFound && range.location+1 < [mutableText length]) {
      NSRange replaceRange = NSMakeRange(range.location+1, 1);
      NSString *followingChar = [mutableText substringWithRange:replaceRange];
      [mutableText replaceCharactersInRange:replaceRange withString:[followingChar uppercaseString]];
    }
    
    range.location++;
    range.length = [mutableText length] - range.location;
    
  } while (range.location != NSNotFound && range.location < [mutableText length]);
  
  return [mutableText stringByReplacingOccurrencesOfString:@"_" withString:@""];
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Leading Lower
//
// Ex. [@"ManagedObject" leadingLowerCase] => @"managedObject"
////////////////////////////////////////////////////////
- (NSString *)leadingLowerCase
{
  if ([self length] == 0)
    return self;
  
  NSString *firstChar = [self substringToIndex:1];
  
  return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[firstChar lowercaseString]];
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Plural
//
// Ex. [@"ManagedObject" plural] => @"ManagedObjects"
////////////////////////////////////////////////////////
- (NSString *)plural
{
  if ([[self uppercaseString] hasSuffix:@"S"])
    return self;
  else
    return [NSString stringWithFormat:@"%@s", self];
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Singular
//
// Ex. [@"ManagedObjects" singular] => @"ManagedObject"
////////////////////////////////////////////////////////
- (NSString *)singular
{
  if ([[self uppercaseString] hasSuffix:@"S"])
    return [self substringToIndex:[self length]-1];
  else
    return self;
}

////////////////////////////////////////////////////////
@end
