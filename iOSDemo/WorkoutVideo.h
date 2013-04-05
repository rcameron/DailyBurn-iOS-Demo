//
//  WorkoutVideo.h
//  iOSDemo
//
//  Created by Rich Cameron on 2/8/13.
//  Copyright (c) 2013 rcameron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WorkoutVideo : NSManagedObject

@property (nonatomic, retain) NSString * workoutVideoTitle;
@property (nonatomic, retain) NSString * iosImageUrl;

@end
