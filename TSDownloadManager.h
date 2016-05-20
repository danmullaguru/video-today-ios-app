//
//  TSDownloadManager.h
//  TSVideos
//
//  Created by dan mullaguru on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://blog.mugunthkumar.com)
//  More information about this template on the post http://mk.sg/89
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import <Foundation/Foundation.h>
#import "GDataYouTube.h"
#import "GDataServiceGoogleYouTube.h"


@protocol TSDownloadManagerDelegate <NSObject>
-(void) feedSaveCompleted: (NSDictionary *) FeedStatus;  
-(void) noInternetConnectionFound;
-(void) userNotFound:(NSString *)userId;
//{FeedSourceType“SingleSource/ALL”,FeedSourceId“sourceId”,FeedStatus“status”, FeedImportCount“download_count”}
-(void) fullDownloadStarted;
-(void) fullDownloadEnded;
-(void) individualSourceDownloadStarted;
-(void) individualSourceDownloadEnded;
@optional

@end


@interface TSDownloadManager : NSObject
{
    NSDictionary * allSourceDownloadStatus;//{@"sourceId",{@"Completed",@"1/1/2012 00:00:00"}}
    NSString * fullDownloadStatus;
    NSString * individualSourceDownloadStatus;
    NSDate * fullDownloadStartTime;
    NSDate * fullDownloadEndTime;
    int pendingFeed;
    int activeFeed;
    id <TSDownloadManagerDelegate> delegate;
    int currentQueue;
    dispatch_queue_t youtubeFeedDownloadQueue;
    dispatch_queue_t downloadDataSaveQueue;
    dispatch_queue_t dataCleanUpQueue;
    //GDataFeedYouTubeVideo * currentFeed;
}
@property (nonatomic, retain) NSDictionary * allSourceDownloadStatus;
@property (nonatomic, retain) NSString * fullDownloadStatus;//UnKnown,InProgress,Completed,Failed
@property (nonatomic, retain) NSString * individualSourceDownloadStatus;
@property (nonatomic, retain) NSDate * fullDownloadStartTime;
@property (nonatomic, retain) NSDate * fullDownloadEndTime;
@property (nonatomic) int pendingFeed;
@property (nonatomic) int activeFeed;
@property (nonatomic) int currentQueue;
@property (strong, nonatomic) id<TSDownloadManagerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) dispatch_queue_t youtubeFeedDownloadQueue;
@property (nonatomic) dispatch_queue_t downloadDataSaveQueue;
@property (nonatomic) dispatch_queue_t dataCleanUpQueue;
//@property (strong, nonatomic) GDataFeedYouTubeVideo * currentFeed;

+ (TSDownloadManager*) sharedInstance;
- (NSString *) startDownloadAllActiveSources;
- (NSString *) startDowloadForSource: (NSString *)sourceId;
- (void)downloadAllActiveSourcesToDB;
- (void)downloadSource:(NSString *)sourceId;
-(void) setPersistentStore:(NSPersistentStoreCoordinator *)pSC;
-(void) doCleanUpOldData;
- (GDataServiceGoogleYouTube *)youTubeService;


@end
