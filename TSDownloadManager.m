//
//  TSDownloadManager.m
//  TSVideos
//
//  Created by dan mullaguru on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://blog.mugunthkumar.com)
//  More information about this template on the post http://mk.sg/89	
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import "TSDownloadManager.h"
#import "Source.h"
#import "Content.h"
#import "GDataBaseElements.h"

#define MAX_QUEUES  6

@interface TSDownloadManager(){
@private
    
}


-(void)saveTheFeed:(GDataFeedYouTubeVideo *)aFeed inStore:(NSPersistentStoreCoordinator *)pSC;
//-(void)saveTheFeed:(GDataFeedYouTubeVideo *)aFeed inContext:(NSManagedObjectContext *)mo;
-(void) feedSaveCompletedLocal:(NSDictionary *)feedStatusInfo;

@end


@implementation TSDownloadManager

@synthesize fullDownloadStatus;
@synthesize individualSourceDownloadStatus;
@synthesize fullDownloadStartTime;
@synthesize fullDownloadEndTime;
@synthesize allSourceDownloadStatus;
@synthesize pendingFeed;
@synthesize activeFeed;
@synthesize currentQueue;
@synthesize delegate;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize youtubeFeedDownloadQueue;
@synthesize downloadDataSaveQueue;
@synthesize dataCleanUpQueue;
//@synthesize currentFeed;

#pragma mark -
#pragma mark Singleton Methods

+ (TSDownloadManager*)sharedInstance {

	static TSDownloadManager *_sharedInstance;
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
			});
		}

		return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {	

	return [self sharedInstance];
}


- (id)copyWithZone:(NSZone *)zone {
	return self;	
}

#if (!__has_feature(objc_arc))

- (id)retain {	

	return self;	
}

- (unsigned)retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release {
	//do nothing
}

- (id)autorelease {

	return self;	
}
#endif

#pragma mark -
#pragma mark Custom Methods

// Add your custom methods here///////////////////////////////////

- (NSString *) startDownloadAllActiveSources
{
    NSString * startStatus = @"started";
    return startStatus;
    
}


- (NSString *) startDowloadForSource: (NSString *)sourceId
{
    NSString * startStatus = @"started";
    return startStatus;
    
}


- (void)downloadAllActiveSourcesToDB
{
  
    NSManagedObjectContext * mo  = [[NSManagedObjectContext alloc]init];
    mo.persistentStoreCoordinator = self.persistentStoreCoordinator;
    [mo setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    
    NSArray *activeSourcesArray =  [Source fetchActiveSourcesOrderedBy:@"displayOrder" inManagedObjectContext:mo];
    
    
    
    GDataServiceGoogleYouTube *service = [self youTubeService];
    NSString *uploadsID = kGDataYouTubeUserFeedIDUploads;
    NSMutableString * sourceId; ;
    
    
    dispatch_queue_t feedDownloadQueue = self.youtubeFeedDownloadQueue;
    dispatch_retain(feedDownloadQueue);
    
    
    dispatch_async(feedDownloadQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), 
                      ^{[self.delegate fullDownloadStarted];});
        self.fullDownloadStatus = @"InProgress";
        //NSLog(@"FULL DOWNLOAD INPROGRESS");
    });
    
    
    
    for (Source *source in activeSourcesArray) 
    {
        sourceId = [NSMutableString stringWithString: source.sourceUserId];
        
        NSString * userFeedType = uploadsID;
        
        //Ignore newvideos source
        if([sourceId isEqualToString: @"newvideos"])
        {
          continue;  
        }
        

        
        NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForUserID:sourceId
                                                             userFeedID:userFeedType];
        //NSLog(@"Invoking Feed:%@", [feedURL path]);
        GDataQueryYouTube* query = [GDataQueryYouTube  youTubeQueryWithFeedURL:feedURL];
        NSMutableDictionary * sourceInfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"youtube",@"sourceSite",sourceId,@"sourceUserId", nil];
        
        int startIndex = 1;
        int batchSize = 50;//50 is max allowed by google
        int endIndex = 50;
        for(;startIndex <=endIndex; startIndex+=batchSize)
        {
            [query setStartIndex:startIndex];
            [query setMaxResults:batchSize];
            
            
            dispatch_async(feedDownloadQueue, 
                           ^{
                                //NSLog(@"--------------------------I am waiting for  youtubedownload in main queue:%d", 1);
                                dispatch_suspend(feedDownloadQueue);
                                //[self saveTheFeed:currentFeed inStore:self.persistentStoreCoordinator];
                                dispatch_sync(dispatch_get_main_queue(), 
                                              ^{
                                                      Source * contentSource =  [Source giveSourceIfExists:sourceInfo inManagedObjectContext:mo];
                                                      
                                                      if(!contentSource)
                                                      {
                                                          //NSLog(@"<<<<<<----------------------Source is deleted..Not invoking YouTube Call-------------------------->>>>>>>");
                                                          NSError * customError = [NSError errorWithDomain:@"ChannelDeleted" code:666 userInfo:nil];
                                                          [self request:nil finishedWithFeed:nil error:customError];
                                                           
                                                          
                                                      }
                                                      else 
                                                      {
                                                          //NSLog(@"Downloading from Youtube using GData:%@", sourceId);
                                                          [service fetchFeedWithQuery:query
                                                                         delegate:self
                                                                didFinishSelector:@selector(request:finishedWithFeed:error:)];
                                                      }
                                                  
                                              });
                           });
            
            
        }
        
        [sourceInfo release];

        
    } 
    
    
    
    dispatch_async(feedDownloadQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), 
                      ^{
                        
                          [self.delegate fullDownloadEnded];
                      });
        self.fullDownloadStatus = @"Completed";
        //NSLog(@"FULL DOWNLOAD COMPLETE...Invoking Clean up queue");
        dispatch_queue_t dataCleanUpQueueLocal = self.dataCleanUpQueue;
        dispatch_retain(dataCleanUpQueueLocal);
        dispatch_async(dataCleanUpQueueLocal, 
                       ^{
                           [Source cleanUpOldContentForAllSourcesInPersistenceStoreCoordinator:self.persistentStoreCoordinator];
                       });
    });

        /* 
         dispatch_queue_t dataCleanUpQueueLocal = self.dataCleanUpQueue;
         dispatch_retain(dataCleanUpQueueLocal);
    dispatch_async(dataCleanUpQueueLocal, 
                  ^{
         [Source cleanUpOldContentForAllSourcesInPersistenceStoreCoordinator:self.persistentStoreCoordinator];
                  });
         */
    [mo release];
    //mo = nil;
    sourceId = nil;
}

- (void)downloadSource:(NSString *)sourceId
{
    //Proceed only if source exists and is active.
    //Or say, Source not active or not existing..
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(isActive == %@) AND (sourceSite like[cd] %@) AND (sourceUserId like[cd] %@)",
                              [NSNumber numberWithBool: YES],@"youtube", sourceId];
    
    NSSortDescriptor *sourceSD = [[NSSortDescriptor alloc]initWithKey:@"displayOrder" ascending:YES];
    NSManagedObjectContext * mo  = [[NSManagedObjectContext alloc]init];
    mo.persistentStoreCoordinator = self.persistentStoreCoordinator;
    [mo setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    
    NSArray *activeSourcesArray = [Source fetchSourcesWithSearchPredicate:predicate sortedBy:sourceSD inManagedObjectContext:mo batchSize:50];
    
    
    Source *source = activeSourcesArray.lastObject;
     
    [sourceSD release];
    [mo release];
    
    if(source)
    {
        
        dispatch_queue_t feedDownloadQueue = self.youtubeFeedDownloadQueue;
        dispatch_retain(feedDownloadQueue);
        
        dispatch_async(feedDownloadQueue, ^{
            dispatch_sync(dispatch_get_main_queue(), 
                          ^{[self.delegate individualSourceDownloadStarted];});
            self.individualSourceDownloadStatus = @"InProgress";
            //NSLog(@"Individual Source DOWNLOAD INPROGRESS for Source: %@", sourceId);
        });
        
        
        GDataServiceGoogleYouTube *service = [self youTubeService];
        NSString *uploadsID = kGDataYouTubeUserFeedIDUploads;

        
        NSString * userFeedType = uploadsID;
        
       

        
        NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForUserID:sourceId
                                                             userFeedID:userFeedType];
        
        
           // NSLog(@"Invoking Feed:%@", [feedURL path]);
            GDataQueryYouTube* query = [GDataQueryYouTube  youTubeQueryWithFeedURL:feedURL];
            
            int startIndex = 1;
            int batchSize = 50;//50 is max allowed by google
            int endIndex = 50;
            for(;startIndex <=endIndex; startIndex+=batchSize)
            {
                [query setStartIndex:startIndex];
                [query setMaxResults:batchSize];
                
                dispatch_async(feedDownloadQueue, ^{
                    dispatch_suspend(feedDownloadQueue);
                    dispatch_sync(dispatch_get_main_queue(), 
                                  ^{
                                      [service fetchFeedWithQuery:query
                                                         delegate:self
                                                didFinishSelector:@selector(request:finishedWithFeed:error:)];
                                      
                                  });
                });

            }
        
        dispatch_async(feedDownloadQueue, ^{
            dispatch_sync(dispatch_get_main_queue(), 
                          ^{[self.delegate individualSourceDownloadEnded];});
            self.individualSourceDownloadStatus = @"Completed";
            //NSLog(@"Individual Source download complete for source:%@", sourceId);
        });

    }
            
}

#pragma mark - GData Youtube Data Feed returned


- (void)request:(GDataServiceTicket *)ticket
finishedWithFeed:(GDataFeedBase *)aFeed
          error:(NSError *)error {
              
    //NSLog(@"-Download from GData complete");

    //NSManagedObjectContext * moc = [self.managedObjectContext copy];
    
	if(!error)
    {
        dispatch_queue_t downloadSaveQueue = self.downloadDataSaveQueue;
        dispatch_async(downloadSaveQueue, ^{
            [self saveTheFeed:(GDataFeedYouTubeVideo *)aFeed inStore:self.persistentStoreCoordinator];
            //[self saveTheFeed:(GDataFeedYouTubeVideo *)aFeed inContext:moc];
        });
        
    }
    else
    {
        //NSLog(@"Downloaded GData has errors. ERROR DEscription:--->  %@",error.description);
        
        if([error.domain isEqualToString:@"NSURLErrorDomain"])
        {
            //NSLog(@"Error code:%d",error.code);
            if(error.code == -1009 || error.code == -1004 || error.code == -1001)
            {
                //NSLog(@"No Internet Connection");
                [self.delegate noInternetConnectionFound];
                 //NSLog(@"Not Resuming Feed Download Queue for Youtube Download...since there is no Internet");
            }
        }
       
        else 
            
        { 
            if ([error.domain isEqualToString:@"com.google.HTTPStatus"])
                {
                    //NSLog(@"Error code:%d",error.code);

                    
                    if(error.code == 404 || error.code == 400)
                    {
                        NSArray * pathComponents = [ticket.objectFetcher.mutableRequest.URL.path pathComponents];
                        NSString * sourceUserId = [pathComponents objectAtIndex:4];
                        
                        NSManagedObjectContext * mo  = [[NSManagedObjectContext alloc]init];
                        mo.persistentStoreCoordinator = self.persistentStoreCoordinator;
                        [mo setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
                        
                        [Source inActivateSourceIfExists:sourceUserId inManagedObjectContext:mo];
                        [mo release];
                        
                        [self.delegate userNotFound:sourceUserId];
                        //NSLog(@"Invalid Youtube User account");
                        
                    }
                    //NSLog(@"Error code:%d",error.code);
                    //User Account removed
                    else if(error.code == 403)
                    {
                        /*
                         NSLog(@"Youtube User account Suspended");
                         NSLog(@"--->Ticket:%@",ticket);
                         NSLog(@"--->Feed:%@",aFeed);
                         NSLog(@"--->Error:%@",error);
                         */
                        NSArray * pathComponents = [ticket.objectFetcher.mutableRequest.URL.path pathComponents];
                        NSString * sourceUserId = [pathComponents objectAtIndex:4];//@"thepakdramas";
                        //NSLog(@"Source Id: %@",sourceUserId);
                        
                        
                        NSManagedObjectContext * mo  = [[NSManagedObjectContext alloc]init];
                        mo.persistentStoreCoordinator = self.persistentStoreCoordinator;
                        [mo setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
                        
                        [Source inActivateSourceIfExists:sourceUserId inManagedObjectContext:mo];
                        [mo release];
                        
                        [self.delegate userNotFound:sourceUserId];
                    }

                }
            
            if (self.youtubeFeedDownloadQueue && [self.fullDownloadStatus isEqualToString:@"InProgress"])
                {
                    dispatch_queue_t feedDownloadQueue = self.youtubeFeedDownloadQueue;
                    @try{
                        //NSLog(@"RESUMING Next block in Feed Download Queue for Youtube Download...after handling invlaid user account issue");
                        dispatch_resume(feedDownloadQueue);
                    }
                    @catch (NSException * e) {
                        //NSLog(@"ERROR while Resuming Next block in Feed Download Queue for Youtube Download. ERROR:--->  :%@",[e description]);
                    }
                    @finally {
                        //its ok
                    }
                }
            else
            {
                //NSLog(@"Not resuming Download queue,after handling invalid user, as download status is:%@",self.fullDownloadStatus);
                
                if (self.youtubeFeedDownloadQueue && [self.individualSourceDownloadStatus isEqualToString:@"InProgress"])
                {
                    dispatch_queue_t feedDownloadQueue = self.youtubeFeedDownloadQueue;
                    //dispatch_retain(feedDownloadQueue);
                    @try{
                        //NSLog(@"RESUMING Next block in Feed Download Queue for Youtube Download...after handling invlaid user account issue, since individualSourceDownloadStatus is :%@",self.individualSourceDownloadStatus);
                        dispatch_resume(feedDownloadQueue);
                        
                        //dispatch_release(feedDownloadQueue);
                    }
                    @catch (NSException * e) {
                        //NSLog(@"ERROR while Resuming Next block in Feed Download Queue for Youtube Download. ERROR:--->  :%@",[e description]);
                    }
                    @finally {
                        //its ok
                    }
                }
            }
            
            
            
        }
       
    }


    
}

-(void) setPersistentStore:(NSPersistentStoreCoordinator *)pSC
{
    self.persistentStoreCoordinator = pSC;
    
}




-(void)saveTheFeed:(GDataFeedYouTubeVideo *)aFeed inStore:(NSPersistentStoreCoordinator *)pSC
//-(void)saveTheFeed:(GDataFeedYouTubeVideo *)aFeed inContext:(NSManagedObjectContext *)mo

{

    //NSLog(@"Saving the Feed in queue: com.teluguscene.downloaddatasave");
    
   
    NSManagedObjectContext * mo  = [[NSManagedObjectContext alloc]init];
    mo.persistentStoreCoordinator = pSC;
   [mo setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    
    //NSLog(@"MOC created..starting inserts");
    
    
    NSString * sourceId = nil;
    Source * contentSource;
    int thumbnailIndex = 1;
    BOOL recordInsertedInDB = NO;
    int newRecordsInserted = 0;
    int continuosDupe = 0;
    
   
    
    for (id feedEntry in [aFeed entries]) 
        {
        
            @try
            {
                if(! sourceId)
                {
                    NSArray * authors = [(GDataEntryYouTubeVideo *)feedEntry authors];
                    GDataAtomAuthor * author = [authors objectAtIndex:0];
                    //NSString *userId =author.name;//self.sourceUserId;
                    sourceId = [author.name lowercaseString];
                    
                    
                    NSMutableDictionary * sourceInfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"youtube",@"sourceSite",sourceId,@"sourceUserId", nil];
                    
                    //If Source is missing stop and do not continue......
                    
                    //contentSource = [Source insertSourceIfNew:sourceInfo inManagedObjectContext:mo];
                    
                    contentSource =  [Source giveSourceIfExists:sourceInfo inManagedObjectContext:mo];
                    
                    if(!contentSource)
                    {
                        //NSLog(@"<<<<<<----------------------Source is deleted..Lets stop inserting-------------------------->>>>>>>");
                        break;
                    }
                    
                    [sourceInfo release];
                    if([contentSource.thumbnailQuality isEqualToString:@"Low"])
                            {
                                thumbnailIndex = 2; 
                            }
                }
                
                GDataYouTubeMediaGroup * mediaGroup = [(GDataEntryYouTubeVideo *)feedEntry mediaGroup];
                
                
                NSArray *mediaContents = [mediaGroup mediaContents];
                NSNumber *flashFormatNum = [NSNumber numberWithInt:5];
                
                GDataMediaContent *flashContent;
                
                flashContent = [GDataUtilities firstObjectFromArray:mediaContents
                                                          withValue:flashFormatNum
                                                         forKeyPath:@
                                "youTubeFormatNumber"];
                
                //mediaContents = nil;
                
                
                
                if (flashContent != nil) 
                    {
                        //NSLog(@"Flash Content:%@",flashContent);
                        NSString *videoURL=[flashContent URLString];
                        //NSNumber * duration = [flashContent duration];
                        //NSLog(@"Duration:%@",duration);
                        NSArray *thumbnails = [mediaGroup mediaThumbnails];
                        NSString *contentType = @"video";
                        NSNumber *isLocked = [NSNumber numberWithBool:YES];
                        NSDate *uploadedDate = [[mediaGroup uploadedDate] date];
                        NSString *videoId = [mediaGroup videoID];
                        //NSData *videoThumbnail= nil;
                        //[NSData dataWithContentsOfURL:[NSURL URLWithString:[[thumbnails objectAtIndex:thumbnailIndex] URLString]]];
                        NSString * urlThumbnail = [[thumbnails objectAtIndex:1] URLString];
                        NSString * urlThumbnailSmall = [[thumbnails objectAtIndex:2] URLString];
                        NSString *vsContentId=[NSString stringWithFormat:@"vs_yt_%@",videoId];
                        NSString *contentTitle =[[(GDataEntryBase *) feedEntry title] stringValue];
                        NSString *displayName=@"youtube";
                        //NSString *sourceSite=@"youtube";
                        
                        
                        NSDictionary * contentInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                      contentType,@"contentType",
                                                      isLocked,@"isLocked",
                                                      uploadedDate,@"uploadedDate",
                                                      videoId,@"videoId",
                                                      urlThumbnail,@"urlThumbnail",
                                                      urlThumbnailSmall,@"urlThumbnailSmall",
                                                      //videoThumbnail,@"videoThumbnail",
                                                      videoURL,@"videoURL",
                                                      vsContentId,@"vsContentId",
                                                      contentTitle,@"contentTitle",
                                                      displayName,@"displayName",
                                                      contentSource, @"source",
                                                      //sourceId,@"sourceId",
                                                      //sourceSite,@"sourceSite",
                                                      //userId,@"sourceUserId",
                                                      nil];
                        //NSLog(@"Inserting%@",contentTitle);
                        recordInsertedInDB = [Content insertContentIfNew:contentInfo inManagedObjectContext:mo];
                        
                        [contentInfo release];
                        
                        if(recordInsertedInDB)
                            {
                                newRecordsInserted +=1;
                                continuosDupe = 0;
                            }
                        else
                            {
                                continuosDupe +=1;
                            }
                        
                        if(continuosDupe >=1)
                            {
                                //Lets leave now..seems to be same feed.
                                //NSLog(@"Looks i am hitting dupes in the feed. I will stop saving the feed now.");
                                break;
                                
                            }
                            
                    } 
                else
                {
                    //No Flash URL found..Skip saving record.
                    //NSLog(@"FLASH URL NOT FOUND FOR THE VIDEO:%@", [mediaGroup videoID]);
                }
                
                
            }
            @catch (NSException * e) {
                //NSLog(@"ERROR while saving record to DB:%@",[e description]);
            }
            @finally {
                //its ok
                
            }
        }//End For Loop
   
            aFeed = nil;
            
            NSError *error = nil;
            if (mo != nil &&  sourceId) {
                if(([mo hasChanges]) && (![mo save:&error])) {
                    
                    //NSLog(@"-ERROR while SAVING THE FEED %@, %@", error, [error userInfo]);
                    abort();
                } 
                else{
                    //NSLog(@"-Saved the Feed with no Issues for the SOURCE:  %@--------",sourceId);
                    if(contentSource)
                    {
                        NSDictionary * feedStatusInfo = [[NSDictionary alloc]initWithObjectsAndKeys:
                        sourceId,@"sourceId",
                        [NSNumber numberWithInt:newRecordsInserted],@"newRecordsInserted",
                        nil];
                        //NSLog(@"I will tell Hompage to reload the Channel with new data, if any");
                        
                        [self feedSaveCompletedLocal:[feedStatusInfo autorelease]];
                    }
                    else
                    {
                        //NSLog(@"????????????????-----I will not  tell Hompage to reload the Channel with new data, if any------???????????????");
                    }
                }
            }
    
    //NSLog(@"-Since the feed is saved or error handled, Now i will resume download queue: com.teluguscene.youtubedownload");
    
    if(self.youtubeFeedDownloadQueue  && [self.fullDownloadStatus isEqualToString:@"InProgress"])
    {
        dispatch_queue_t feedDownloadQueue = self.youtubeFeedDownloadQueue;
       //dispatch_retain(feedDownloadQueue);
        @try{
            //NSLog(@"RESUMING Next block in Feed Download Queue for Youtube Download...invoked after successful saving the feed");
            dispatch_resume(feedDownloadQueue);
            //dispatch_release(feedDownloadQueue);
        }
        @catch (NSException * e) {
            //NSLog(@"ERROR Resuming Next Feed Download Queue for Youtube Download...tried invoking after successful saving the feed:%@",[e description]);
        }
        @finally {
            //its ok
        }
    }
    else
    {
        //NSLog(@"Not resuming Download queue, after Saving Feed, as download status is:%@",self.fullDownloadStatus);
        
        if (self.youtubeFeedDownloadQueue && [self.individualSourceDownloadStatus isEqualToString:@"InProgress"])
        {
            dispatch_queue_t feedDownloadQueue = self.youtubeFeedDownloadQueue;
            //dispatch_retain(feedDownloadQueue);
            @try{
                //NSLog(@"RESUMING Next block in Feed Download Queue for Youtube Download...invoked after successful saving the fee, since individualSourceDownloadStatus is :%@",self.individualSourceDownloadStatus);
                dispatch_resume(feedDownloadQueue);
                
                //dispatch_release(feedDownloadQueue);
            }
            @catch (NSException * e) {
                //NSLog(@"ERROR while Resuming Next block in Feed Download Queue for Youtube Download. ERROR:--->  :%@",[e description]);
            }
            @finally {
                //its ok
            }
        }

    }
    

    
}



-(void)feedSaveCompletedLocal:(NSDictionary *)feedStatusInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate feedSaveCompleted:feedStatusInfo];
    });

    
}





#pragma mark - Clean up Data


-(void) doCleanUpOldData

{
    
}



#pragma mark - GData Youtube Service

- (GDataServiceGoogleYouTube *)youTubeService {
	static GDataServiceGoogleYouTube* _service = nil;
	
	if (!_service) {
		_service = [[GDataServiceGoogleYouTube alloc] init];
		
		[_service setUserAgent:@"AppWhirl-UserApp-1.0"];
		//[_service setShouldCacheDatedData:YES];
        [_service setShouldCacheResponseData:YES];
		[_service setServiceShouldFollowNextLinks:NO];
	}
	
	// fetch unauthenticated
	/*[_service setUserCredentialsWithUsername:@""
                                    password:@""];
     */
    
    [_service setYouTubeDeveloperKey:@"AI39si4Om1X17VLyiV9W36I0IiVLnY7tyWfbxSEJ1bNra2kQXeJpiO1PVRYtUdmqSmbKezAGLUfEgkDQP0Qpos5WxTQeM_Y26Q"];
    
	
	return _service;
}



@end
