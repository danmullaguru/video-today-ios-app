//
//  ChannelVideosViewController.h
//  EZ Tube
//
//  Created by dan mullaguru on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataYouTube.h"
#import "GDataServiceGoogleYouTube.h"
#import "GDataBaseElements.h"
#import "TSDownloadManager.h"
#import "EZChannelSearchVideoCellView.h"
#import "Source.h"
#import "EZUtility.h"

@protocol ChannelVideosViewControllerDelegate <NSObject>
-(void) channelVideosDownloadComplete;
-(void) addNewVideoSourceRecord:(NSMutableDictionary *)videoSource;
-(void) popVideo:(NSString *)videoId title:(NSString *)title;
-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId;
-(void) loadAllVideosInExternalPlayerWithVideoSetArray:(NSArray*)videoSetArray  feedChannelInfo:(NSDictionary *)feed_OR_Channel_info StartingWithVideoIndex:(int)index;
@end


@interface ChannelVideosViewController : UIViewController<EZChannelSearchVideoCellViewDelegate>
{
    id<ChannelVideosViewControllerDelegate>	delegate;
    dispatch_queue_t channelSearchVideoFeedDownloadQueue;
    int start_index;
    int max_results;
}


@property int start_index;
@property int max_results;

@property (nonatomic, assign) id<ChannelVideosViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) IBOutlet UILabel *channelIdLbl;
@property (retain, nonatomic) IBOutlet UILabel *channelTitleLbl;
@property (retain, nonatomic) IBOutlet UILabel *videoCountLbl;
@property (retain, nonatomic) IBOutlet UILabel *viewCountLbl;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *videoActivityIndicator;
@property (retain, nonatomic) IBOutlet UIButton *addChannelButton;
@property (retain, nonatomic) IBOutlet UILabel *addChannelMessageLbl;
@property (retain, nonatomic) IBOutlet UIScrollView *videosScrollView;
- (IBAction)addChannel:(id)sender;

@property (nonatomic, retain) NSString * channelId ;
@property (nonatomic, retain) NSString * channelTitle ;
@property (nonatomic, retain) NSString * channelVideoCount ;
@property (nonatomic, retain) NSString * channelViewsCount ;
@property (nonatomic, retain) NSMutableArray * channelVideoResultsArray ;
@property (nonatomic) dispatch_queue_t channelSearchVideoFeedDownloadQueue;

-(void) loadBasicChannelInfo:(NSDictionary *)channelInfo;
-(void) fetchMoreChannelInfo:(NSString *)channelIdSent;
-(void) downloadChannelMoreInfo;
-(void) downloadChannelVideos;
-(void) downloadChannelVideosFromIndex:(int)startIndex;
-(void) clearChannelHeaderInfo;
- (IBAction)showNext:(id)sender;
- (IBAction)showPrevious:(id)sender;
//-(void) loadLanguageUI;
-(void) setVCtoCurrentLanguage;


@property (retain, nonatomic) IBOutlet UIButton *prevButtonLbl;
@property (retain, nonatomic) IBOutlet UIButton *nextButtonLbl;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *videosDownloadIndicator;
@property (retain, nonatomic) IBOutlet UILabel *currentVideoStartEndLbl;
@property (retain, nonatomic) IBOutlet UILabel *channelLbl;

@property (retain, nonatomic) IBOutlet UILabel *titleLbl;

@property (retain, nonatomic) IBOutlet UILabel *viewsLbl;
@property (retain, nonatomic) IBOutlet UILabel *videosLbl;

@property (retain, nonatomic) IBOutlet UIImageView *channelIconImageView;
@property (nonatomic, retain) LocalizationSystem * ls;


@end
