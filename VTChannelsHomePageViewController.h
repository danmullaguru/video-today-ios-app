//
//  TSNewHomePageViewController.h
//  teluguscene
//
//  Created by dan mullaguru on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSDownloadManager.h"
#import "ChannelViewController.h"
#import "ChannelPageViewController.h"
#import "TSVideoViewController.h"
#import "TSChannelsVC.h"
#import "TSPreferencesViewController.h"
#import "LocalizationSystem.h"


@protocol VTChannelsHomePageViewControllerDelegate <NSObject>

-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId;
-(void) popVideo:(NSString *)videoId title:(NSString *)title;
-(void) loadAllVideosInExternalPlayerWithVideoSetArray:(NSArray*)videoSetArray  feedChannelInfo:(NSDictionary *)feed_OR_Channel_info StartingWithVideoIndex:(int)index;
-(void) doneWithPreferences;
-(void) showMoreVideosOfChannel:(NSString *)channelId startIndex:(int)startIndex;
-(void) channelPopulationErroredOut;
-(void)showChannelSearch;
-(void)showChannelPreferences;
@end



@interface VTChannelsHomePageViewController : UIViewController < UIScrollViewDelegate,ChannelViewControllerDelegate,TSChannelsVCDelegate,TSDownloadManagerDelegate,TSPreferencesViewControllerDelegate>

{
    BOOL reLayoutNeeded;
    NSMutableArray * newlyAddedChannels;


}

@property (nonatomic) dispatch_queue_t channelImagesDownloadQueue;

@property (nonatomic, retain) LocalizationSystem * ls;
@property (nonatomic, assign) id<VTChannelsHomePageViewControllerDelegate> delegate;
@property (nonatomic, retain) TSDownloadManager * downloadManager;
@property int currentChannelNum;
@property (nonatomic, retain) NSArray * activeSourcesArray;
@property int totalActiveChannels;
@property (nonatomic, retain) NSMutableDictionary *activeSourceIdChannelNumDictionary;
@property (nonatomic, retain) NSMutableDictionary *activeSourcesDownloadStatus;  
@property (nonatomic, retain) NSMutableArray * channelVCsArray;
//@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) TSVideoViewController *videoViewController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) IBOutlet UIScrollView *topScrollView;

@property (retain, nonatomic) IBOutlet UITableView *channelsTableView;

@property (retain, nonatomic) IBOutlet UITableView *channelsTableView2;

@property (retain, nonatomic) IBOutlet UILabel *channelsLbl;
@property (retain, nonatomic) IBOutlet UIButton *dragChannelsButton;
- (IBAction)dragChannels:(id)sender;
@property (retain, nonatomic) IBOutlet UIView *dragChannelsButtonParentView;

@property (retain, nonatomic) IBOutlet UIButton *dragVideosButton;
- (IBAction)dragVideos:(id)sender;
@property int videoToShowNum;

@property (retain, nonatomic) IBOutlet UIButton *channelSearchButton;

@property (retain, nonatomic) IBOutlet UIButton *channelsEditButton;

@property (retain, nonatomic) TSChannelsVC * channelListVC;

-(void) doReLayout;

//@property (retain, nonatomic) IBOutlet UIButton *preferencesButton;

@property (retain, nonatomic) IBOutlet UIWebView *webView;

@property (retain, nonatomic) IBOutlet UIView *playerView;
@property (retain, nonatomic) IBOutlet UIScrollView *channelsScrollView;


@property BOOL reLayoutNeeded;
@property (nonatomic, retain) NSMutableArray * newlyAddedChannels;

-(void) releaseAllChannels;
-(void) setVCtoCurrentLanguage;
-(void) loadActiveChannelsDictionary;

- (IBAction)showChannelSearch:(id)sender;

- (IBAction)showChannelPreferences:(id)sender;







@end
