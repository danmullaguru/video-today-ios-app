//
//  ChannelVideosViewController.m
//  EZ Tube
//
//  Created by dan mullaguru on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChannelVideosViewController.h"

@interface ChannelVideosViewController()

-(void) refreshVideoResults;
-(void) videoFeedCompleteLocal;
-(void) launchYoutubeAPIVideoFeedForUserId:(NSString *)userId;
-(void) launchYoutubeAPIMoreChannelInfoFeedForUserId:(NSString *)userId;
-(void) showHideAddChannelButton;
-(void) videoFeedActive;
-(void) videoFeedComplete;

@end

@implementation ChannelVideosViewController

@synthesize ls;
@synthesize prevButtonLbl;
@synthesize nextButtonLbl;
@synthesize videosDownloadIndicator;
@synthesize currentVideoStartEndLbl;
@synthesize channelLbl;
@synthesize titleLbl;
@synthesize viewsLbl;
@synthesize videosLbl;
@synthesize channelIconImageView;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize start_index;
@synthesize max_results;

@synthesize channelIdLbl;
@synthesize channelTitleLbl;
@synthesize videoCountLbl;
@synthesize viewCountLbl;
@synthesize videoActivityIndicator;
@synthesize addChannelButton;
@synthesize addChannelMessageLbl;
@synthesize videosScrollView;

@synthesize channelId;
@synthesize channelTitle;
@synthesize channelVideoCount;
@synthesize channelViewsCount;
@synthesize channelVideoResultsArray;
@synthesize delegate;
@synthesize channelSearchVideoFeedDownloadQueue;

GDataServiceGoogleYouTube *youTubeService;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    ls = [LocalizationSystem sharedLocalSystem];
    
    
    // Do any additional setup after loading the view from its nib.
    channelVideoResultsArray = [[NSMutableArray alloc]init];
    youTubeService = [[TSDownloadManager sharedInstance] youTubeService];
    
    dispatch_queue_t videoDownloadQueue = dispatch_queue_create("com.eztube.channelVideoFeed", NULL);
    self.channelSearchVideoFeedDownloadQueue = videoDownloadQueue;

    //Set background image
    UIImage * scrollBGImg = [UIImage imageNamed:@"channelbackground.png"];
    self.videosScrollView.backgroundColor = [UIColor colorWithPatternImage:scrollBGImg];
    
    //[self loadLanguageUI];
    [self setVCtoCurrentLanguage];
  
}


/*
-(void) loadLanguageUI
{


}
 */

-(void)viewDidAppear:(BOOL)animated
{
    [self downloadPendingImages];
}

-(void) downloadPendingImages
{
    
    //Loop through all subviews of VideosScrollView
    if (self.view.window)
    {
        for(NSObject * subView in self.videosScrollView.subviews)
        {
            if([subView respondsToSelector:@selector(loadImageView)])
            {
                EZChannelSearchVideoCellView * videoCell = (EZChannelSearchVideoCellView *)subView;
                [videoCell loadImageView];
            }
        }
    }
    
    
}



#pragma mark - setCurrent Language to UI
-(void) setVCtoCurrentLanguage
{
    channelLbl.text = ls.eZ_CHANNEL;
    titleLbl.text = ls.eZ_TITLE;
    videosLbl.text = ls.eZ_VIDEOS;
    viewsLbl.text = ls.eZ_VIEWS;
    addChannelMessageLbl.text = ls.eZ_ADDED_TO_EZCHANNELS;
    
    //Search button
    
    UIImage *addChannelbutton_img = [[UIImage alloc] initWithContentsOfFile:ls.add_to_ez_channels_path];
    if(!addChannelbutton_img)
    {
        addChannelbutton_img = [[UIImage alloc] initWithContentsOfFile:ls.add_to_ez_channels_mainBundle_path];
    }
    [addChannelButton setImage:addChannelbutton_img forState:UIControlStateNormal];
    [addChannelbutton_img release];
    
}

- (void)viewDidUnload
{
    [self setChannelIdLbl:nil];
    [self setChannelTitleLbl:nil];
    [self setVideoCountLbl:nil];
    [self setViewCountLbl:nil];
    [self setVideoActivityIndicator:nil];
    [self setAddChannelButton:nil];
    [self setAddChannelMessageLbl:nil];
    [self setVideosScrollView:nil];
    [self setPrevButtonLbl:nil];
    [self setNextButtonLbl:nil];
    [self setVideosDownloadIndicator:nil];
    [self setCurrentVideoStartEndLbl:nil];
    [self setChannelLbl:nil];
    [self setTitleLbl:nil];
    [self setViewsLbl:nil];
    [self setVideosLbl:nil];
    [self setChannelIconImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	//return YES;
    
     return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void) loadBasicChannelInfo:(NSDictionary *)channelInfo
{
   
    [self.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 750, 518) animated:YES];
    [self.channelVideoResultsArray removeAllObjects];
    
    channelId = [channelInfo objectForKey:@"channelName"];
    channelTitle = [channelInfo objectForKey:@"channelTitle"];
    channelVideoCount = [channelInfo objectForKey:@"videoCount"];
    channelViewsCount = [channelInfo objectForKey:@"totalUploadViewCount"];
    
    UIImage * thumbImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[channelInfo objectForKey:@"thumbURL"]]]];
    
    if(! thumbImg)
    {
        [self fetchMoreChannelInfo:channelId];
    }
    channelIconImageView.image = thumbImg;
  
    
    
    channelIdLbl.text = channelId;
    channelTitleLbl.text = channelTitle;
    videoCountLbl.text = channelVideoCount;
    viewCountLbl.text = channelViewsCount;
   
}

-(void) fetchMoreChannelInfo:(NSString *)channelIdSent
{
    [self launchYoutubeAPIMoreChannelInfoFeedForUserId:channelIdSent];
    
    
}

-(void) clearChannelHeaderInfo
{
    channelIdLbl.text = @"";
    channelTitleLbl.text = @"";
    videoCountLbl.text = @"";
    viewCountLbl.text = @"";
    currentVideoStartEndLbl.text = @"";
    [channelIconImageView setHidden:YES];
    [prevButtonLbl setEnabled:NO];
    [nextButtonLbl setEnabled:NO];
    
    [self.addChannelButton setEnabled:NO];
    
    
}

-(void) downloadChannelMoreInfo
{
    
}

-(void) downloadChannelVideos
{
    //Set start_index, max_results
    self.start_index = 1;
    self.max_results = 50;
    
    [self launchYoutubeAPIVideoFeedForUserId:channelId];
    
    //ShowHideAddChannelButton
    [self showHideAddChannelButton];
    [self videoFeedActive];
    
}

-(void) downloadChannelVideosFromIndex:(int)startIndex
{
    //Set start_index, max_results
    self.start_index = startIndex;
    self.max_results = 50;
    
    [self launchYoutubeAPIVideoFeedForUserId:channelId];
    
    //ShowHideAddChannelButton
    [self showHideAddChannelButton];
    [self videoFeedActive];
    
}

#pragma mark - Launch Video Uploads Feed 

-(void) launchYoutubeAPIVideoFeedForUserId:(NSString *)userId
{
    [self.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 750, 518) animated:YES];
    
    NSString *uploadsID = kGDataYouTubeUserFeedIDUploads;
    
    NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForUserID:userId
                                                         userFeedID:uploadsID];
    //NSLog(@"Invoking Feed:%@", [feedURL path]);
    GDataQueryYouTube* query = [GDataQueryYouTube  youTubeQueryWithFeedURL:feedURL];
    [query setStartIndex:start_index];
    [query setMaxResults:max_results];
    
    //NSLog(@"Invoking Feed:%@", feedURL);
     self.currentVideoStartEndLbl.text = [NSString stringWithFormat:@"(%d-%d)",start_index,start_index+max_results-1];
    
    [youTubeService fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(request:finishedWithFeed:error:)];
    
    
}


-(void) launchYoutubeAPIMoreChannelInfoFeedForUserId:(NSString *)userId
{

    

    
    NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForUserID:userId
                                                         userFeedID:nil];
    //NSLog(@"Invoking Feed feedURL path:%@", [feedURL path]);
    GDataQueryYouTube* query = [GDataQueryYouTube  youTubeQueryWithFeedURL:feedURL];

    
    //NSLog(@"Invoking Feed feedURL:%@", feedURL);
    self.currentVideoStartEndLbl.text = [NSString stringWithFormat:@"(%d-%d)",start_index,start_index+max_results-1];
    
    [youTubeService fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(request:finishedWithMoreChannelInfoFeed:error:)];
    
    
}

#pragma mark - Feed returned

- (void)request:(GDataServiceTicket *)ticket
finishedWithMoreChannelInfoFeed:(GDataFeedBase *)aFeed
          error:(NSError *)error 
{

    
	if(!error)
    {


                GDataEntryYouTubeUserProfile * youTubeUser = (GDataEntryYouTubeUserProfile *)aFeed;
                GDataMediaThumbnail * thumbNailMedia = youTubeUser.thumbnail;
                NSString * urlString = thumbNailMedia.URLString;
                //NSLog(@"URL String :%@",urlString);
                NSURL * url = [NSURL URLWithString:urlString];
                UIImage * thumbImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                channelIconImageView.image = thumbImg;
                //[thumbImg release];
        
                GDataYouTubeStatistics * statistics = youTubeUser.statistics;
                self.viewCountLbl.text = [statistics.totalUploadViews stringValue];
                //self.videoCountLbl.text = [statistics. stringValue];
        
    
        
    }//End if error
    else
    {
        //Ignore error

        
    }
    

}





- (void)request:(GDataServiceTicket *)ticket
finishedWithFeed:(GDataFeedBase *)aFeed
          error:(NSError *)error 
{
    
    //NSLog(@"-Download from GData complete");
    
    //NSManagedObjectContext * moc = [self.managedObjectContext copy];
    
	//if(!error && self.view.window)
    if(!error)
    {
             
            //Clear old results
            [channelVideoResultsArray removeAllObjects];
            //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //[dateFormatter setDateStyle:NSDateFormatterShortStyle];

        
            for (id feedEntry in [aFeed entries]) 
            {
                
                // NSArray * authors = [(GDataEntryYouTubeVideo *)feedEntry authors];
                //GDataAtomAuthor * author = [authors objectAtIndex:0];
                //NSString *userId =author.name;//self.sourceUserId;
                // NSString *sourceId = [author.name lowercaseString];
                
                
                
                
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
                    NSString *videoURL=[flashContent URLString];
                    NSArray *thumbnails = [mediaGroup mediaThumbnails];
                    NSDate *uploadedDate = [[mediaGroup uploadedDate] date];
                    //NSString * dateString = [dateFormatter stringFromDate:uploadedDate];
                    NSString * dateString = [ls giveFriendlyDate:uploadedDate];
                    NSString *videoId = [mediaGroup videoID];
                    //NSURL *thumbNailURL = [NSURL URLWithString:[[thumbnails objectAtIndex:1] URLString]];
                    NSString *thumbnailString = [[thumbnails objectAtIndex:1] URLString];
                    //NSData *videoThumbnail=[NSData dataWithContentsOfURL:[NSURL URLWithString:[[thumbnails objectAtIndex:1] URLString]]];
                    NSString *contentTitle =[[(GDataEntryBase *) feedEntry title] stringValue];
                    
                    NSDictionary * row = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          videoId,@"videoId",
                                          contentTitle,@"videoTitle",
                                          videoURL,@"videoURL",
                                          dateString,@"videoUploadDate",
                                          thumbnailString,@"videoThumbnailString",
                                          nil];
                    [channelVideoResultsArray addObject:row];
                    [row release];
                    
                    //NSLog(@"Video:%@   Date:%@",contentTitle,uploadedDate);
                    
                }
            }//End For Loop
            
        //[dateFormatter release];
        
    }//End if error
    else
    {
        //Log error
        //NSLog(@"Downloaded GData has errors. ERROR DEscription:--->  %@",error.description);
        
    }
    
    
    [self refreshVideoResults];
    [self videoFeedCompleteLocal];
    
}

-(void) refreshVideoResults
{
    
    
    CGRect frame = self.videosScrollView.frame;
    int height = frame.size.height;
    

    
    
    int i = 1;
    int x = 0;
    int xStart = 6;
    int xBuffer = 6;
    int yStart = 6;
    int yBuffer = 6;
    
    float videoCount = channelVideoResultsArray.count;
    int rowCount = ceil(videoCount / 3.0);
    int scrollWidth = rowCount* (180+xBuffer)+xBuffer;
    if(scrollWidth < 646)
        scrollWidth = 646;
    self.videosScrollView.contentSize =  CGSizeMake(scrollWidth, height);
    
    
    
    int videoNum = 0;
    
    
    
    
    for (NSDictionary * videoRow in channelVideoResultsArray)
    {
       
        
        //Create Video Cell, Set the attributes
        EZChannelSearchVideoCellView * channelVideoCellView = [[EZChannelSearchVideoCellView alloc]init];
        
        channelVideoCellView.videoIndex = videoNum;
        channelVideoCellView.videoId = [videoRow objectForKey:@"videoId"];
        channelVideoCellView.videoThumbNailURLString = [videoRow objectForKey:@"videoThumbnailString"];
        channelVideoCellView.videoURL = [videoRow objectForKey:@"videoURL"];
        channelVideoCellView.videoTitle = [videoRow objectForKey:@"videoTitle"];
        channelVideoCellView.channelId = @"newvideos";
        //[channelVideoCellView.channelId retain];
         videoNum++;
        channelVideoCellView.videoTitleLbl.text = [NSString stringWithFormat:@"%d. %@",videoNum+start_index-1,[videoRow objectForKey:@"videoTitle"]];
        channelVideoCellView.videoUploadDateLbl.text = [videoRow objectForKey:@"videoUploadDate"];
        
        channelVideoCellView.channelSearchVideoFeedDownloadQueue = channelSearchVideoFeedDownloadQueue;
        channelVideoCellView.delegate = self;
        
        //Add Video Cell view as SubView
        CGRect frame = channelVideoCellView.frame;
        frame.origin.x = xStart+x;
        frame.origin.y = yStart+(i-1)*(135+yBuffer);
        
        channelVideoCellView.frame = frame;
                
        [ self.videosScrollView addSubview:channelVideoCellView];
        [channelVideoCellView loadImageView];
        
        //Load Video Cell Images
        
        if(i == 1)
            i = 2;
        else if(i ==2)
            i = 3;
        else if(i ==3)
        {
            i = 1;
            x = x+180+xBuffer;
        }
    }
   
    
}


-(void) videoFeedCompleteLocal
{

    
    [self.delegate channelVideosDownloadComplete];
    [self videoFeedComplete];
    
}

#pragma mark - Play Video on Touch

-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelIdSent;
{
    
    [self.delegate popVideo:videoId title:title channelId:channelIdSent];
    
}

-(void) popVideo:(NSString *)videoId title:(NSString *)title;
{
    [self.delegate popVideo:videoId title:title];
    
}

-(void) loadAllVideosInExternalPlayerStartingWithVideoIndex:(int)index
{
    NSMutableArray * videoSetArray = [[NSMutableArray alloc] init];
    //make the videoSetArray
    
    for (NSDictionary * videoRow in channelVideoResultsArray)
    {
       
        //NSString * thumbUrl = [[[videoRow objectForKey:@"videoThumbnailString"] copy] retain];
        // NSLog(@">>>:%@",thumbUrl);

        NSDictionary * videoInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [videoRow objectForKey:@"videoId"], @"videoId",
                                    [videoRow objectForKey:@"videoTitle"], @"videoTitle",
                                    self.channelId, @"videoChannelId",
                                    [videoRow objectForKey:@"videoThumbnailString"], @"videoImgURL",
                                    [videoRow objectForKey:@"videoUploadDate"], @"videoUploadDate",
                                    nil ];
        [videoSetArray addObject:videoInfo];
        [videoInfo autorelease];
    }
    
    NSDictionary * feed_OR_Channel_info = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           @"CHANNEL",@"feed_Channel_Type",
                                           self.channelId,@"feed_Channel_Title",
                                           channelIconImageView.image,@"feed_Channel_FlagImg",
                                           channelIconImageView.image,@"feed_Channel_Category_Channel_img",
                                           nil ];
    
    //NSLog(@"videoSetArray:%@",videoSetArray);
    [self.delegate loadAllVideosInExternalPlayerWithVideoSetArray:videoSetArray feedChannelInfo:feed_OR_Channel_info StartingWithVideoIndex:index];
}





#pragma mark - showHideAddChannelButton

-(void) showHideAddChannelButton
{
    BOOL isChannelAdded = NO;
    
    isChannelAdded = [Source doesChannelExistForSite:@"youtube" channelId:channelId inManagedObjectContext:self.managedObjectContext];
    
    if(isChannelAdded)
    {
        [addChannelButton setHidden:YES];
        [addChannelMessageLbl setHidden:NO];
    }
    else
    {
        [addChannelButton setHidden:NO];
        [addChannelMessageLbl setHidden:YES];
        
    }
    
}


- (IBAction)addChannel:(id)sender {
    // NSData *videoThumbnail=[NSData dataWithContentsOfURL:[NSURL URLWithString:[[thumbnails objectAtIndex:thumbnailIndex] URLString]]];
    NSData *imageData = UIImagePNGRepresentation(channelIconImageView.image);

    
    NSMutableDictionary * videoSource = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                         @"youtube", @"sourceSite",
                                         channelId, @"sourceUserId",
                                         channelId, @"displayName",
                                         [NSNumber numberWithInt:200], @"maxVideos",
                                         @"High",@"thumbnailQuality",
                                         imageData,@"channelThumbnail",
                                         nil];               
    
    
    [self.delegate addNewVideoSourceRecord:[videoSource autorelease]];
    
    [self showHideAddChannelButton];

}


- (IBAction)showNext:(id)sender {
    
    [self videoFeedActive];
    
    if(start_index < (600 - max_results))
        start_index = start_index+max_results;
    

        [self launchYoutubeAPIVideoFeedForUserId:channelId];
    
}

- (IBAction)showPrevious:(id)sender {
    
    [self videoFeedActive];
    
    if(start_index > max_results)
        start_index = start_index-max_results;
    else 
    {
        start_index = 1;
    }
    
        [self launchYoutubeAPIVideoFeedForUserId:channelId];
    
    
}


-(void) videoFeedActive
{
    

    
    //Disable Buttons
    [prevButtonLbl setEnabled:NO];
    [nextButtonLbl setEnabled:NO];
    [addChannelButton setEnabled:NO];
    
    //StartActivityIndicator
    [videosDownloadIndicator startAnimating];
    [channelIconImageView setHidden:YES];
    
    
}


-(void) videoFeedComplete
{
    
    
    //Enable Buttons
    [prevButtonLbl setEnabled:YES];
    [nextButtonLbl setEnabled:YES];
    [addChannelButton setEnabled:YES];
    
    
    //StopActivityIndicator
    [videosDownloadIndicator stopAnimating];
    [channelIconImageView setHidden:NO];
    
    
}




- (void)dealloc {
    [channelIdLbl release];
    [channelTitleLbl release];
    [videoCountLbl release];
    [viewCountLbl release];
    [videoActivityIndicator release];
    [addChannelButton release];
    [addChannelMessageLbl release];
    [videosScrollView release];
    [prevButtonLbl release];
    [nextButtonLbl release];
    [videosDownloadIndicator release];
    [currentVideoStartEndLbl release];
    [channelLbl release];
    [titleLbl release];
    [viewsLbl release];
    [videosLbl release];
    [channelIconImageView release];
    [super dealloc];
}

@end
