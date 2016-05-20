//
//  EZFeedsHomePageViewController.h
//  EZ Tube
//
//  Created by dan mullaguru on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataYouTube.h"
#import "GDataServiceGoogleYouTube.h"
#import "GDataBaseElements.h"
#import "TSDownloadManager.h"
#import "TSVideoViewController.h"
#import "EZFeedsViewController.h"
#import "EZFeedDisplayVideoCellView.h"
#import "Feed.h"
#import "EZFeedsTableCell.h"
#import "EZUtility.h"
#import "LocalizationSystem.h"
#import "Content.h"


@protocol VTFeedsHomePageViewControllerDelegate <NSObject>

-(void) popVideo:(NSString *)videoId title:(NSString *)title;
-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId;
-(void) doneWithPreferences;
-(void) loadAllVideosInExternalPlayerWithVideoSetArray:(NSArray*)videoSetArray  feedChannelInfo:(NSDictionary *)feed_OR_Channel_info StartingWithVideoIndex:(int)index;
-(void)showFeedSearch;
-(void)showFeedPreferences;
@end

@interface VTFeedsHomePageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,EZFeedsViewControllerDelegate,EZFeedDisplayVideoCellViewDelegate,UIPopoverControllerDelegate,UIScrollViewDelegate>
{
    BOOL reLayoutNeeded;
    int start_index;
    int max_results;
    NSString * feedType ;
    NSString * feedURL ;
     UINib *cellLoader;
    BOOL pageControlUsed;
}

@property int start_index;
@property int max_results;
@property int currentSelectedFeedActualRow;
//@property int currentPage;
@property (nonatomic, retain) NSString * feedType ;
@property (nonatomic, retain) NSString * feedURL ;

@property (nonatomic, retain) LocalizationSystem * ls;

@property (nonatomic, assign) id<VTFeedsHomePageViewControllerDelegate> delegate;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray * feedVideoResultsArray ;
@property (nonatomic, retain) NSDictionary * feedFlagsImagesDictionary;
@property (nonatomic, retain) NSDictionary * feedCategoriesImagesDictionary;

@property (retain, nonatomic) IBOutlet UITableView *feedsTableView;

@property (retain, nonatomic) IBOutlet UIScrollView *videosScrollView;
@property (nonatomic, retain) TSVideoViewController *videoViewController;
@property (nonatomic) dispatch_queue_t videoFeedDownloadQueue;
@property (retain, nonatomic) IBOutlet UILabel *selectedFeedLbl;
@property BOOL reLayoutNeeded;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *VideosDownloadIndicator;
@property (retain, nonatomic) IBOutlet UIButton *prevButton;
@property (retain, nonatomic) IBOutlet UIButton *nextButton;
@property (retain, nonatomic) IBOutlet UILabel *videoStartEndLbl;
@property (retain, nonatomic) IBOutlet UIScrollView *feedsScrollView;
@property int videoToShowNum;

-(void) doReLayout;
-(void) showVideosForRow:(int)rowNum;
- (IBAction)showPrevious:(id)sender;
- (IBAction)showNext:(id)sender;
-(void) setVCtoCurrentLanguage;

@property (retain, nonatomic) IBOutlet UIButton *upButton;
- (IBAction)upButtonPressed:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *downButton;

- (IBAction)downButtonPressed:(id)sender;



@property (retain, nonatomic) IBOutlet UIImageView *currentFeedCountryImage;

@property (retain, nonatomic) IBOutlet UIImageView *currentFeedCategoryImage;


@property (retain, nonatomic) IBOutlet UIView *feedHeaderView;


@property (retain, nonatomic) IBOutlet UIPageControl *feedsPageControl;
@property (retain, nonatomic) IBOutlet UILabel *feedsLbl;

-(void) initializeViewsIfNotYet;
- (IBAction)changePage:(id)sender;
- (IBAction)showFeedSearch:(id)sender;
- (IBAction)showFeedPreferences:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *feedSearchButton;

@property (retain, nonatomic) IBOutlet UIButton *feedManageButton;



@end
