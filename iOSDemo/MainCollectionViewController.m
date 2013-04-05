//
//  MainCollectionViewController.m
//  iOSDemo
//
//  Created by Rich Cameron on 2/8/13.
//  Copyright (c) 2013 rcameron. All rights reserved.
//

#import "MainCollectionViewController.h"

#import "CoreDataManager.h"
#import "WorkoutVideo.h"
#import "NSString+LetterCase.h"

#import "WorkoutCell.h"

#import "DetailViewController.h"

@interface MainCollectionViewController ()

@end

@implementation MainCollectionViewController
{
  NSArray *_workoutVideos;
  NSMutableDictionary *_urlsToImageData;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  
  if (!self)
    return nil;
  
  _workoutVideos = @[];
  
  _urlsToImageData = @{}.mutableCopy;
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self fetchRemoteWorkoutVideos];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"showDetail"]) {
    DetailViewController *detailController = [segue destinationViewController];
    
    NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
    WorkoutVideo *video = [_workoutVideos objectAtIndex:indexPath.item];
    
    NSData *imageData = [_urlsToImageData objectForKey:video.iosImageUrl];
    
    if (imageData)
      [detailController setImage:[UIImage imageWithData:imageData]];
    
    [detailController setTitle:video.workoutVideoTitle];
  }
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Interface
////////////////////////////////////////////////////////
- (void)updateInterface
{
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WorkoutVideo"];
  
  _workoutVideos = [[[CoreDataManager sharedManager] managedObjectContext] executeFetchRequest:request error:nil];
  
  [self.collectionView reloadData];
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Networking
////////////////////////////////////////////////////////
- (void)fetchRemoteWorkoutVideos
{
  NSManagedObjectContext *editContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
  [editContext setParentContext:[[CoreDataManager sharedManager] managedObjectContext]];
  
  NSString *urlString = @"http://wodstg.dailyburn.com/rest/v2/workout_videos.json";
  
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                           if (error)
                             return;
                           
                           NSArray *results = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:0
                                                                                error:nil];
                           
                           for (NSDictionary *dict in results) {
                             [editContext performBlockAndWait:^{
                               WorkoutVideo *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"WorkoutVideo"
                                                                                      inManagedObjectContext:editContext];
                               
                               [self updateWorkoutVideo:newVideo withDictionary:dict];
                               
                               [editContext save:nil];
                             }];
                             
                             NSLog(@"dict = %@", dict);
                           }
                           
                           [[[CoreDataManager sharedManager] managedObjectContext] performBlock:^{
                             [[CoreDataManager sharedManager] saveContext];
                             
                             [self updateInterface];
                           }];
                         }];
}

////////////////////////////////////////////////////////
- (void)updateWorkoutVideo:(WorkoutVideo *)workoutVideo withDictionary:(NSDictionary *)dictionary
{
  NSDictionary *subDict = [dictionary objectForKey:@"workout_video"];
  
  NSDictionary *attributes = [[workoutVideo entity] attributesByName];
  
  [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    id newValue = [subDict objectForKey:[key underscoreCase]];
    
    if (newValue)
      [workoutVideo setValue:newValue forKey:key];
  }];
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Collection View
////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

////////////////////////////////////////////////////////
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return [_workoutVideos count];
}

////////////////////////////////////////////////////////
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellReuse = @"reuseID";
  
  WorkoutCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuse forIndexPath:indexPath];
  
  WorkoutVideo *video = [_workoutVideos objectAtIndex:indexPath.item];
  
  NSData *imageData = [_urlsToImageData objectForKey:video.iosImageUrl];
  
  if (imageData) {
    [cell.imageView setImage:[UIImage imageWithData:imageData]];
    return cell;
  }
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:video.iosImageUrl]];
  
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                           if (error)
                             return;
                           
                           UIImage *image = [UIImage imageWithData:data];
                           
                           WorkoutCell *actualCell = (WorkoutCell *)[collectionView cellForItemAtIndexPath:indexPath];
                           
                           [actualCell.imageView setImage:image];
                           
                           [_urlsToImageData setObject:data forKey:video.iosImageUrl];
                         }];
  
  return cell;
}

@end
