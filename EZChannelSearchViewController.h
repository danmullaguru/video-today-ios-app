//
//  EZChannelSearchViewController.h
//  EZ Tube
//
//  Created by dan mullaguru on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataYouTube.h"
#import "GDataServiceGoogleYouTube.h"
#import "GDataBaseElements.h"
#import "TSDownloadManager.h"
#import "ChannelVideosViewController.h"
#import "TSVideoViewController.h"
#import "AudioToolbox/AudioToolbox.h"
#import "Source.h"

@protocol EZChannelSearchViewControllerDelegate <NSObject>

-(void) addNewVideoSourceRecord:(NSMutableDictionary *)videoSource informAboutFeeds:(BOOL)inform;
-(void) startFullDownloadOfChannels;
-(void) popVideo:(NSString *)videoId title:(NSString *)title;
-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId;
-(void) channelPopulationErroredOut;
-(void) loadAllVideosInExternalPlayerWithVideoSetArray:(NSArray*)videoSetArray  feedChannelInfo:(NSDictionary *)feed_OR_Channel_info StartingWithVideoIndex:(int)index;
@end



@interface EZChannelSearchViewController : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDataSource,UITableViewDelegate,ChannelVideosViewControllerDelegate,UIPopoverControllerDelegate,UITextFieldDelegate>
{
     id<EZChannelSearchViewControllerDelegate> delegate;
    NSTimer *aTimer;
    
    
}
 

@property (strong, nonatomic) id<EZChannelSearchViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSArray * pickerArraySearchType;
@property (nonatomic,retain) NSArray * pickerArraySearchPeriod;
@property (nonatomic,retain) NSArray * pickerArraySearchRegion;
@property (nonatomic,retain) NSArray * pickerArraySearchRegionFlags;
@property (nonatomic,retain) NSArray * pickerArraySearchChanneltype;
@property (nonatomic,retain) NSArray * pickerArraySearchChanneltypeIcons;

@property (nonatomic,retain) NSDictionary * bannedChannels;

@property (retain, nonatomic) IBOutlet UITableView *channelsTableView;

@property (retain, nonatomic) IBOutlet UIPickerView *pickerView;
@property (retain, nonatomic) IBOutlet UITextField *keywordField;
@property (retain, nonatomic) IBOutlet UIButton *findChannelsButton;

@property (retain, nonatomic) IBOutlet UIButton *prevButton;
@property (retain, nonatomic) IBOutlet UIButton *nextButton;

@property (retain, nonatomic) IBOutlet UILabel *currentSearchInfoLabel;
@property (retain, nonatomic) IBOutlet UILabel *showingResultsLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *channelFeedActivityIndicator;
@property (retain, nonatomic) IBOutlet UILabel *keywordSearchLbl;


@property (retain, nonatomic) ChannelVideosViewController * channelVideosVC;

@property (nonatomic, retain) NSString * currentYoutubeAPISearchType;
@property (nonatomic, retain) TSVideoViewController *videoViewController;

@property (nonatomic, retain) NSString * channelFeedID ;
@property (nonatomic, retain) NSString * channelFindType ;
@property (nonatomic, retain) NSString * channelSearchQueryString ;
@property (nonatomic, retain) NSString * selectedFeedType ;
@property (nonatomic, retain) NSString * selectedFeedPeriod ;
@property (nonatomic, retain) NSString * selectedFeedRegion ;
@property (nonatomic, retain) NSString * selectedFeedChannelType ;

- (IBAction)spinTheWheel:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *feedTypeButton;
@property (retain, nonatomic) IBOutlet UIButton *feedPeriodButton;
@property (retain, nonatomic) IBOutlet UIButton *feedCountryButton;
@property (retain, nonatomic) IBOutlet UIButton *feedCategoryButton;
@property (retain, nonatomic) IBOutlet UIButton *spinButton;

@property (retain, nonatomic) IBOutlet UIButton *searchButton;
@property (retain, nonatomic) IBOutlet UILabel *orLbl;

@property (nonatomic, retain) LocalizationSystem * ls;


- (IBAction)feedTypeButtonPressed:(id)sender;
- (IBAction)feedPeriodButtonPressed:(id)sender;

- (IBAction)feedCountryButtonPressed:(id)sender;
- (IBAction)feedCategoryButtonPressed:(id)sender;


-(void) setVCtoCurrentLanguage;

- (IBAction)searchChannels:(id)sender;
- (IBAction)showPrevious:(id)sender;
- (IBAction)showNext:(id)sender;
-(void)showVideosforChannelRowAtIndex:(int)rowNum;
-(void) clearCurrentChannelVideos;
-(void) loadDefaultChannelssForCountryLocale;
-(void) showChannelWithChannelId:(NSString *)channelId;
-(void) showChannelWithChannelId:(NSString *)channelId startIndex:(int)startIndex;

@end
