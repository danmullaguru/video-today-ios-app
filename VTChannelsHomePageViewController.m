//
//  TSNewHomePageViewController.m
//  teluguscene
//
//  Created by dan mullaguru on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VTChannelsHomePageViewController.h"
#import "TSChannelsVC.h"


@interface VTChannelsHomePageViewController ()

-(void) ifVideoEmptyLoadFirstVideoFromCurrentChannel;
-(void)populateChannelsTable;
//-(void) loadActiveChannelsDictionary;
-(void) loadNewlyAddedSources;
-(void) setUpPrevCurrentNextChannelsForChannelNum:(int)channelNum pageNum:(int)pageNum ForOrientation:(UIInterfaceOrientation)InterfaceOrientation;
-(void) setUpChannelNum:(int)channelNum pageNum:(int)pageNum ForOrientation:(UIInterfaceOrientation)InterfaceOrientation;

-(void) releaseOtherChannelsforCurrentChannel;
-(void) releaseAllChannelsExceptCurrentChannel;
-(void) releaseAllChannels;

- (void)scrollToChannelNum:(int)channelNum;
-(void) channelDownloadCompleted:(int)channelNum withNewRecords:(int)newRecordsInserted;
-(void) channelDownloadStarted:(int)channelNum;
//@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)saveContext;
-(void) updateNewRecordCount:(int)recordCount processDate:(NSDate *)processedDate forChannelNum:(int)channelNum;
-(void) loadSettingsForOrientation:(UIInterfaceOrientation)InterfaceOrientation;
-(void) setTopSCrollViewContentSize;
-(void) setChannelsScrollViewContentSize;
-(void) reFrameAndPositionChannelsForInterfaceOrientation:(UIInterfaceOrientation)io;

-(void) handlePinchVideos:(UIPinchGestureRecognizer *)gr;
-(void) handlePinchChannels:(UIPinchGestureRecognizer *)gr;

-(void)moveChannelListScrollViewToChannel:(int)channelNum;


@end


@implementation VTChannelsHomePageViewController


UIInterfaceOrientation currentOrientationName;

@synthesize channelImagesDownloadQueue;
@synthesize ls;
@synthesize delegate;
@synthesize downloadManager;
@synthesize currentChannelNum;
@synthesize totalActiveChannels;
@synthesize activeSourcesArray;
@synthesize activeSourceIdChannelNumDictionary;
@synthesize channelVCsArray;

@synthesize videoViewController;
//@synthesize activityIndicator;
@synthesize managedObjectContext;
@synthesize topScrollView;
@synthesize channelsTableView;
@synthesize channelsTableView2;
@synthesize channelsLbl;
@synthesize dragChannelsButton;
//@synthesize preferencesButton;

@synthesize webView;
@synthesize playerView;
@synthesize channelsScrollView;
@synthesize reLayoutNeeded;
@synthesize newlyAddedChannels;
@synthesize activeSourcesDownloadStatus;
@synthesize dragChannelsButtonParentView;
@synthesize dragVideosButton;
@synthesize videoToShowNum;
@synthesize channelSearchButton;
@synthesize channelsEditButton;

@synthesize channelListVC;

//int VT_PAGE_HEIGHT = PAGE_HEIGHT;
//int VT_PAGE_WIDTH = PAGE_WIDTH;
int VT_VIDEO_COUNT_PER_PAGE  = VIDEO_COUNT_PER_PAGE;
//int VT_CHANNEL_PAGE_TOP_OFFSET = CHANNEL_PAGE_TOP_OFFSET;
int VT_VIDEO_ROWS_PER_PAGE = VIDEO_ROWS_PER_PAGE;
int VT_VIDEO_COLUMNS_PER_PAGE = VIDEO_COLUMNS_PER_PAGE;
int VT_VIDEO_VIEW_WIDTH  = VIDEO_VIEW_WIDTH;
int VT_VIDEO_VIEW_HEIGHT = VIDEO_VIEW_HEIGHT;
int VT_VIDEO_PAGE_TOP_OFFSET = VIDEO_PAGE_TOP_OFFSET;
int VT_VIDEO_PAGE_LEFT_OFFSET = VIDEO_PAGE_LEFT_OFFSET;
int VT_VIDEO_VERTICAL_MARGIN = VIDEO_VERTICAL_MARGIN;
int VT_VIDEO_HORIZONTAL_MARGIN = VIDEO_HORIZONTAL_MARGIN;
//int VT_CHANNEL_HEADER_HEIGHT = CHANNEL_HEADER_HEIGHT;

CFTimeInterval _ticks;

UIPopoverController * popOver;


/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/



#pragma mark - View lifecycle

- (void)viewDidLoad
{
   /* 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(youtubeFullScreenEnteredUIMoviePlayer:)
                                                 name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(youtubeFullScreenExitedUIMoviePlayer:)
                                                 name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    */
    
    
    //NSLog(@"viewDidLoad--TSNewHomepage");
    
    [super viewDidLoad];
    
    
    self.channelImagesDownloadQueue = dispatch_queue_create("com.eztube.channelImagesDownload", NULL);;
     ls = [LocalizationSystem sharedLocalSystem];
    
    
    // Do any additional setup after loading the view from its nib.
    self.newlyAddedChannels = [[NSMutableArray alloc]init];
    self.activeSourcesDownloadStatus = [[NSMutableDictionary alloc]init];
    self.activeSourceIdChannelNumDictionary = [[NSMutableDictionary alloc]init];
        
    
    self.topScrollView.scrollsToTop = NO;
    [self loadSettingsForOrientation:self.interfaceOrientation];
   
     //Initial Load
    [self loadActiveChannelsDictionary];
    [self setTopSCrollViewContentSize];
    //[self setChannelsScrollViewContentSize];

    
    currentChannelNum = 0;
    self.videoToShowNum = -1;
    
    [self setUpPrevCurrentNextChannelsForChannelNum:currentChannelNum pageNum:0 ForOrientation:self.interfaceOrientation];
   
    //populate Channels Table
    [self populateChannelsTable];
    [self setChannelsScrollViewContentSize];
    
    self.reLayoutNeeded = NO;
    
    [self setVCtoCurrentLanguage];
    
        //VideoPlayer added in app delegate
        //self.videoViewController = [[TSVideoViewController alloc] initWithNibName:@"TSVideoViewController" bundle:nil];
    //[self.playerView addSubview:self.videoViewController.view];
    
    
    //Add pinch gesture for videos Scroll View
    UIPinchGestureRecognizer* pinchVideos = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchVideos:)];
    [self.topScrollView addGestureRecognizer: pinchVideos];
    [pinchVideos release];
    
    
    //Add pinch gesture for feeds Scroll View
    UIPinchGestureRecognizer* pinchChannels = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchChannels:)];
    [self.channelsScrollView addGestureRecognizer: pinchChannels];
    [pinchChannels release];


    
}


-(void)viewDidAppear:(BOOL)animated
{
    //[self ifVideoEmptyLoadFirstVideoFromCurrentChannel];
    for(int i =0; i < totalActiveChannels; i++)
    {
        if ((NSNull *)[channelVCsArray objectAtIndex:i] != [NSNull null])
        {
            
            [((ChannelViewController *)[channelVCsArray objectAtIndex:i]) viewDidAppear:YES];
            
        }
        
    }
}

-(void) ifVideoEmptyLoadFirstVideoFromCurrentChannel
{
    
    //Is VideoId exists for VideoController?
    //if not,does feed exist in array "feedVideoResultsArray"?
    // then , loadVideo of the VideoController with the first row of the feed videos returned.
    if([self.videoViewController.videoId isEqualToString:@""])
    {
        
      if(channelVCsArray.count > 0)
      {
            if ((NSNull *)[channelVCsArray objectAtIndex:self.currentChannelNum] != [NSNull null])
            {
                
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                if(((ChannelViewController *)[channelVCsArray objectAtIndex:self.currentChannelNum]).fetchedResultsController.fetchedObjects.count >0)
                {
                      Content *contentRecord = [((ChannelViewController *)[channelVCsArray objectAtIndex:self.currentChannelNum]).fetchedResultsController objectAtIndexPath:indexPath];
                        if(contentRecord)
                        {
                            [self loadVideoInPage:contentRecord.videoId title:contentRecord.contentTitle channelId:@"" videoSeqNum:1 ];
                            self.videoToShowNum = -1;
                        }  
                }
                
            }
      }

    }
    
}


#pragma mark - Handle VideosScrollView Gestures

-(void) handlePinchVideos:(UIPinchGestureRecognizer *)gr {
    //NSLog(@"handlePinch");
    //NSLog(@"pinch Scale:%f, pinch Velocity:%f",gr.scale,gr.velocity);
    //NSLog(@"pinchState:%@",gr.state);
    if([gr state] == UIGestureRecognizerStateEnded) 
    {
        //NSLog(@"pinch Scale:%f, pinch Velocity:%f",gr.scale,gr.velocity);
        if(gr.scale > 1)
        {
            if(! self.dragVideosButton.isSelected)
            {
                [self dragVideos:nil];
            }
        }
        else 
        {
            if(self.dragVideosButton.isSelected)
            {
                [self dragVideos:nil];
            }
        }
	}
    
}


#pragma mark - Handle VideosScrollView Gestures

-(void) handlePinchChannels:(UIPinchGestureRecognizer *)gr {
    //NSLog(@"handlePinch");
    //NSLog(@"pinch Scale:%f, pinch Velocity:%f",gr.scale,gr.velocity);
    //NSLog(@"pinchState:%@",gr.state);
    if([gr state] == UIGestureRecognizerStateEnded) 
    {
        //NSLog(@"pinch Scale:%f, pinch Velocity:%f",gr.scale,gr.velocity);
        if(gr.scale > 1)
        {
            if(! self.dragChannelsButton.isSelected)
            {
                [self dragChannels:nil];
            }
        }
        else 
        {
            if(self.dragChannelsButton.isSelected)
            {
                [self dragChannels:nil];
            }
        }
	}
    
}


-(void) setVCtoCurrentLanguage
{
    
    channelsLbl.text = ls.eZ_CHANNELS;
    
    //channel search in local language
    
    UIImage *top_search_default_img = [[UIImage alloc] initWithContentsOfFile:ls.top_search_default_path ];
    if(!top_search_default_img)
    {
        top_search_default_img = [[UIImage alloc] initWithContentsOfFile:ls.top_share_mainBundle_path];
    }
    
    UIImage *top_search_active_img = [[UIImage alloc] initWithContentsOfFile:ls.top_search_active_path ];
    if(!top_search_active_img)
    {
        top_search_active_img = [[UIImage alloc] initWithContentsOfFile:ls.top_search_active_mainBundle_path];
    }
    
    [self.channelSearchButton setImage:top_search_default_img forState:UIControlStateNormal];
    [self.channelSearchButton setImage:top_search_active_img forState:UIControlStateHighlighted];
    [self.channelSearchButton setImage:top_search_active_img forState:UIControlStateSelected];
    
    [top_search_default_img release];
    [top_search_active_img release];
    
    //manage,channels in local language
    UIImage *top_manage_img = [[UIImage alloc] initWithContentsOfFile:ls.top_manage_path ];
    if(!top_manage_img)
    {
        top_manage_img = [[UIImage alloc] initWithContentsOfFile:ls.top_manage_mainBundle_path];
    }
    

    [channelsEditButton setImage:top_manage_img forState:UIControlStateNormal];
    
    [top_manage_img release];
    

    

        if (currentChannelNum<2 && channelVCsArray.count >0) 
        {
            if ((NSNull *)[channelVCsArray objectAtIndex:0] != [NSNull null])
            {
                [((ChannelViewController *)[channelVCsArray objectAtIndex:0]) setVCtoCurrentLanguage];
            }
        }
    
    [channelListVC refreshTableDataAndSetCurrentChannel:self.currentChannelNum];

  
}

-(void) initializeChannelArrays
{
    
    
    
    
}

- (void)viewDidUnload
{
   
    //[self setPreferencesButton:nil];
    //[self setActivityIndicator:nil];
    [self setTopScrollView:nil];

    [self setChannelsTableView:nil];
    [self setChannelsLbl:nil];
    [self setWebView:nil];
    [self setPlayerView:nil];
    [self setChannelsTableView2:nil];
    [self setChannelsScrollView:nil];
    [self setDragChannelsButton:nil];
    [self setDragVideosButton:nil];
    [self setDragChannelsButtonParentView:nil];
    [self setChannelSearchButton:nil];
    [self setChannelsEditButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




-(void)viewWillAppear:(BOOL)animated 
{
    //NSLog(@"Channels view Will Appear");
    [super viewWillAppear:animated];
        
    [self loadSettingsForOrientation:self.interfaceOrientation];
    
    [self.playerView addSubview:self.videoViewController.view];


    

    
    //Add Observer
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(youtubeFullScreenEnteredUIMoviePlayer:)
                                                 name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(youtubeFullScreenExitedUIMoviePlayer:)
                                                 name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
     */
}


-(void)viewWillDisappear:(BOOL)animated
{
    //NSLog(@"Channels view Will DisAppear");
    /*
     [self releaseAllChannels];
    self.currentChannelNum = -1;
    [self scrollToChannelNum:0];
     */
    
    //Remove Observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
     //NSLog(@"Homepage Recieved Memory Warning");
    [self releaseAllChannelsExceptCurrentChannel];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    
    

    [topScrollView release];

    

    [channelsTableView release];
    [channelsLbl release];
    [webView release];
    [playerView release];
    [channelsTableView2 release];
    [channelsScrollView release];
    [dragChannelsButton release];
    [dragVideosButton release];
    [dragChannelsButtonParentView release];
    
    [channelSearchButton release];
    [channelsEditButton release];
    
    [super dealloc];
}

#pragma mark - Orientation Changes
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	//return YES;
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (BOOL)shouldAutorotate {
    return [self shouldAutorotateToInterfaceOrientation:self.interfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    UIInterfaceOrientation io = UIInterfaceOrientationPortrait;
    if(UIInterfaceOrientationIsPortrait(fromInterfaceOrientation))
    {
        io = UIInterfaceOrientationLandscapeLeft;
    }
    
    [self setTopSCrollViewContentSize];
    [self reFrameAndPositionChannelsForInterfaceOrientation:io];
    
    
    //NSLog(@"didRotateToInterfaceOrientation--TSNewHomepage");
    
    //Set up Current Channel, prev, Next 
    //NSLog(@"Current Channel Nul:%d",self.currentChannelNum);
    //[self setUpPrevCurrentNextChannelsForChannelNum:self.currentChannelNum ForOrientation:io];
    
    //ScrollToCurrentChannel
    [self scrollToChannelNum:currentChannelNum];
    
}

#pragma mark - populate Channels Table
-(void)populateChannelsTable
{
    channelListVC = [[TSChannelsVC alloc]init];
    channelListVC.managedObjectContext = self.managedObjectContext;
    channelListVC.title = @"Channels";
    channelListVC.delegate = self;
    channelListVC.tableView = channelsTableView;
    channelListVC.tableView2 = channelsTableView2;
    
    
    channelsTableView.delegate = channelListVC;
    channelsTableView.dataSource = channelListVC;
    
    channelsTableView2.delegate = channelListVC;
    channelsTableView2.dataSource = channelListVC;
    
    //CGRect frame  = CGRectMake(0, 0, 259, 642);
    //channelListVC.view.frame = frame;

    
    
}

#pragma mark - Load Active Channels in to Dictionary

-(void) loadActiveChannelsDictionary
{
    [self setChannelVCsArray:nil];
    //populate allSourcesDictionaryofArrays
    
    self.activeSourcesArray = [Source fetchActiveSourcesOrderedBy:@"displayOrder" inManagedObjectContext:self.managedObjectContext];
    self.totalActiveChannels = self.activeSourcesArray.count;
    
    
    //populate channelVCsArray with null objects
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    
    int i =0;
    for (Source *source in self.activeSourcesArray) 
    {
        [activeSourceIdChannelNumDictionary setObject:[NSNumber numberWithInt:i++] forKey:source.sourceUserId];
            if (![activeSourcesDownloadStatus objectForKey:source.sourceUserId]) 
            {
                    [activeSourcesDownloadStatus setObject:@"downloaded" forKey:source.sourceUserId];  
            }
        
        [controllers addObject:[NSNull null]];
    } 
    self.channelVCsArray = controllers;
    //NSLog(@"SourceIdChannelNumDictionary: %@",activeSourceIdChannelNumDictionary);
    [controllers release];
    
}

- (IBAction)showChannelSearch:(id)sender {
    [self.delegate showChannelSearch];
}

- (IBAction)showChannelPreferences:(id)sender {
    [self.delegate showChannelPreferences];
}







#pragma mark load any newly added source in preferences screen

-(void) loadNewlyAddedSources
{
    //NSLog(@"Loading Newly added Sources");
    for (NSString * sourceId in self.newlyAddedChannels) {
        //NSLog(@"Loading Newly added Source: %@",sourceId);
        [self.downloadManager downloadSource:sourceId];
        [activeSourcesDownloadStatus setObject:@"downloading" forKey:sourceId];
        int channelNum = [[activeSourceIdChannelNumDictionary objectForKey:sourceId]intValue];
        [self channelDownloadStarted:channelNum];
    }
    [self.newlyAddedChannels removeAllObjects];
    //NSLog(@"Loading Newly added Sources complete");
    
}





#pragma mark - setUp Channels and Release unused chanels

-(void) setUpPrevCurrentNextChannelsForChannelNum:(int)channelNum pageNum:(int)pageNum ForOrientation:(UIInterfaceOrientation)InterfaceOrientation
{
    //NSLog(@"---Start------Loading and Releasing Channels for Current Channel:%d",self.currentChannelNum);
    
    if(self.totalActiveChannels < 1)
        return;
    
    
    //setup current channel, Scroll to location
    [self setUpChannelNum:channelNum pageNum:pageNum ForOrientation:(UIInterfaceOrientation)InterfaceOrientation];
    //[self scrollToChannelNum:channelNum];
    
    [channelListVC selectRow:channelNum];
    [self moveChannelListScrollViewToChannel:channelNum];
    
    
    //setup Next Channel, if existing
    if(channelNum < self.totalActiveChannels-1)
    {
        [self setUpChannelNum:channelNum+1 pageNum:0 ForOrientation:(UIInterfaceOrientation)InterfaceOrientation];
        
    }
    
    //Setup Prev Channel, if existing
    if(channelNum > 0)
    {
        [self setUpChannelNum:channelNum-1 pageNum:0 ForOrientation:(UIInterfaceOrientation)InterfaceOrientation];
        
    }
    
    //NSLog(@"Strat:----Releasing Unused Channels");
    [self releaseOtherChannelsforCurrentChannel];
    //NSLog(@"----End-----Loading and Releasing Channels for Current Channel:%d",self.currentChannelNum);
    
}

-(void) setUpChannelNum:(int)channelNum pageNum:(int)pageNum ForOrientation:(UIInterfaceOrientation)InterfaceOrientation
{
    //Find out channel source object from array
    
    //Find out location (X,Y) for the channelVC
    //Buffer HEADER_HEIGHT + FOOTER_HEIGHT
    
    //initialize channelVC with source object and add Sub View
    
    if (!InterfaceOrientation)
    {
        InterfaceOrientation = self.interfaceOrientation;
    }
    
    if (channelNum < 0)
        return;
    if (channelNum >= self.totalActiveChannels)
        return;
    
    // replace the placeholder if necessary
    ChannelViewController *controller = [channelVCsArray objectAtIndex:channelNum];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[ChannelViewController alloc] initWithChannelNumber:channelNum currentChannelNumber:self.currentChannelNum  frameWidth:(int)self.topScrollView.frame.size.width withManagedObject:self.managedObjectContext andSource:[activeSourcesArray objectAtIndex:channelNum]];
        controller.delegate = self;
        controller.channelImagesDownloadQueue = self.channelImagesDownloadQueue;
        //[controller loadSettingsForOrientation:InterfaceOrientation];
        [channelVCsArray replaceObjectAtIndex:channelNum withObject:controller];
        [controller release];
    }
    //If channelVC already exists, but it is not a current channel, release previous and current pages of the channelVC
    
    
    else 
    {
        controller.currentChannelNumber = self.currentChannelNum;
        //NSLog(@"Current Channel Num:%d",currentChannelNum);
        //NSLog(@"This Particular Channel Num:%d",controller.channelNumber);
        if (controller.channelNumber != currentChannelNum)
        {
            // release previous and current pages of the channelVC
            //NSLog(@"I will release previous and next pages for this channel:%d",controller.channelNumber);
            //[controller releasePreviousAndNextPagesforCurrentPage];
        }
        else
        {
            //Load Previous and Next Pages for currentChannel
            //NSLog(@"I will load previous and next pages for current channel:%d",controller.channelNumber);
            [controller setUpPrevCurrentNextPagesForPageNum:controller.currentChannelPageNumber];
        }
    }
     
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.topScrollView.frame;
        frame.origin.x = 0;
        frame.origin.y = (self.topScrollView.frame.size.height) * channelNum;

        controller.view.frame = frame;
        
        
        
        
        //NSLog(@"Setting up Channel:%d at frame:x:%f,y:%f,width:%f,height:%f",channelNum,frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);

        NSString * channelId = ((Source *)[activeSourcesArray objectAtIndex:channelNum]).sourceUserId;
        //channelDownloadStatus
        //[activeSourcesDownloadStatus setObject:@"downloading" forKey:source.sourceUserId];
        NSString * downloadStatus = [activeSourcesDownloadStatus objectForKey:channelId];
        if([downloadStatus isEqualToString:@"downloading"])
        {
            //NSLog(@"Setting up new channel:%@, channelNum:%d, downloadStatus:%@",channelId,channelNum,downloadStatus);
            [controller channelDownloadStarted];
        }
        
        //[controller setUpPrevCurrentNextPagesForPageNum:0];
        [controller setChannelSCrollViewContentSize];
        
        [self.topScrollView addSubview:controller.view];
        //[self.topScrollView bringSubviewToFront:controller.view];
        
        [controller setUpPrevCurrentNextPagesForPageNum:pageNum];
    }

    
    
}





-(void) releaseAllChannelsExceptCurrentChannel
{
    //Releases all channels except current channel
    for(int i =0; i < totalActiveChannels; i++)
    {
        if (i == currentChannelNum) {
            if ((NSNull *)[channelVCsArray objectAtIndex:i] != [NSNull null])
            {
                ((ChannelViewController *)[channelVCsArray objectAtIndex:i]).currentChannelNumber = currentChannelNum;
            }
            continue;
        }
        else if ((NSNull *)[channelVCsArray objectAtIndex:i] != [NSNull null])
        {
            //NSLog(@"Releasing Channel:%d Start",i);
            //[((ChannelViewController *)[channelVCsArray objectAtIndex:i]).view removeFromSuperview];
            //[[channelVCsArray objectAtIndex:i]release ];
            [channelVCsArray replaceObjectAtIndex:i withObject:[NSNull null]];
            //NSLog(@"Releasing Channel:%d End",i);
        }
        
    }
    
}

-(void) releaseOtherChannelsforCurrentChannel
{
    //Releases all channels except current, next and previous
    for(int i =0; i < totalActiveChannels; i++)
    {
        if (i == currentChannelNum || i == currentChannelNum-1 || i == currentChannelNum+1) {
            if ((NSNull *)[channelVCsArray objectAtIndex:i] != [NSNull null])
            {
                ((ChannelViewController *)[channelVCsArray objectAtIndex:i]).currentChannelNumber = currentChannelNum;
            }
            continue;
        }
        else if ((NSNull *)[channelVCsArray objectAtIndex:i] != [NSNull null])
        {
            //NSLog(@"Releasing Channel:%d Start",i);
            //[((ChannelViewController *)[channelVCsArray objectAtIndex:i]).view removeFromSuperview];
            //[[channelVCsArray objectAtIndex:i]release ];
            [channelVCsArray replaceObjectAtIndex:i withObject:[NSNull null]];
            //NSLog(@"Releasing Channel:%d End",i);
        }
        
    }
    
}



-(void) releaseAllChannels
{
   
    
    //Releases all channels...Rarely required to call this
    for(int i =0; i < totalActiveChannels; i++)
    {
        if ((NSNull *)[channelVCsArray objectAtIndex:i] != [NSNull null])
        {
            //NSLog(@"Releasing Channel:%d Start",i);
            //[((ChannelViewController *)[channelVCsArray objectAtIndex:i]).view removeFromSuperview];
            ((ChannelViewController *)[channelVCsArray objectAtIndex:i]).channelScrollView.delegate = nil;
            [channelVCsArray replaceObjectAtIndex:i withObject:[NSNull null]];
            //NSLog(@"Releasing Channel:%d End",i);
        }
        
    }
    
    
    
}






#pragma mark - topScrollView delegate methods -- Sets up Channel when scrolled vertically

- (void)scrollViewDidScroll:(UIScrollView *)sender
{

}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   // pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // pageControlUsed = NO;
    //CGFloat pageHeight = 879;//topScrollView.frame.size.height;
    //int offset = topScrollView.contentOffset.y;
    [self clearNewVideos:self.currentChannelNum];
    
    int pageHeight = self.topScrollView.frame.size.height;
    int channelNum = floor((topScrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    currentChannelNum = channelNum;
    [self setUpPrevCurrentNextChannelsForChannelNum:channelNum pageNum:0 ForOrientation:self.interfaceOrientation];
}

#pragma mark - Show Specific Channel -- on selecting left side

-(void) showChannelVideos:(int)channelNum
{
    [self clearNewVideos:self.currentChannelNum];
    //NSLog(@"Going to show channel:%d",channelNum);
    currentChannelNum = channelNum;
    [self setUpPrevCurrentNextChannelsForChannelNum:channelNum pageNum:0 ForOrientation:self.interfaceOrientation];
    //self.topScrollView.decelerationRate = 0.50;
    [self scrollToChannelNum:channelNum];
    [popOver dismissPopoverAnimated:YES];
}


#pragma mark - Scroll to channel after Layout

- (void)scrollToChannelNum:(int)channelNum
{
    CGRect frame = self.topScrollView.frame;
    frame.origin.x = 0;
    frame.origin.y = frame.size.height * channelNum;
    //frame.size.width = VT_PAGE_WIDTH;
    //frame.size.height = VT_PAGE_HEIGHT;
    [self.topScrollView scrollRectToVisible:frame animated:YES];
    //NSLog(@"Scrolled to frame:x:%f,y:%f,width:%f,height:%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
}


-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelIdSent
{
    
    [self.delegate popVideo:videoId title:title channelId:channelIdSent];
    //[self loadVideo:videoId title:title channelId:channelIdSent];
    
}


-(void) popVideo:(NSString *)videoId title:(NSString *)title
{
    [self.delegate popVideo:videoId title:title];
    //[self loadVideo:videoId title:title channelId:@""];
    
}

-(void) loadAllVideosInExternalPlayerWithVideoSetArray:(NSArray*)videoSetArray  feedChannelInfo:(NSDictionary *)feed_OR_Channel_info StartingWithVideoIndex:(int)index
{
    [self.delegate loadAllVideosInExternalPlayerWithVideoSetArray:videoSetArray feedChannelInfo:feed_OR_Channel_info StartingWithVideoIndex:index];
}


-(void)loadVideoInPage:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelIdSent videoSeqNum:(int)videoSeqNum
{

    self.videoToShowNum = videoSeqNum;
    
    if(self.dragVideosButton.isSelected)
    {
        [self dragVideos:nil];
    }
    
    if(self.dragChannelsButton.isSelected)
    {
        [self dragChannels:nil];
    }
    
    
    //self.videoViewController.delegate = self.delegate;
    
    //[self.playerView addSubview:self.videoViewController.view];
    
    
    self.videoViewController.videoId = videoId;
    self.videoViewController.videoTitle = title;
    self.videoViewController.channelId = channelIdSent;
    //NSLog(@"Loading Video");
    [self.videoViewController loadVideo];
    
    self.videoToShowNum = -1;
    
}

-(void)loadVideoInPage:(NSString *)videoId title:(NSString *)title videoSeqNum:(int)videoSeqNum
{
    self.videoToShowNum = videoSeqNum;
    
    if(self.dragVideosButton.isSelected)
    {
        [self dragVideos:nil];
    }
    
    if(self.dragChannelsButton.isSelected)
    {
        [self dragChannels:nil];
    }
    
    
    //self.videoViewController.delegate = self.delegate;
    
    //[self.playerView addSubview:self.videoViewController.view];
    
    
    self.videoViewController.videoId = videoId;
    self.videoViewController.videoTitle = title;
    self.videoViewController.channelId = @"";
   
    [self.videoViewController loadVideo];
    
    self.videoToShowNum = -1;
    
}

-(void) showMoreVideosOfChannel:(NSString *)channelId startIndex:(int)startIndex
{
     [self.delegate showMoreVideosOfChannel:channelId startIndex:startIndex];
}


#pragma mark - Channel Preferences Screen  Delegate methods

-(void) doneWithPreferences
{
    //NSLog(@"Done with preferences");
    
    [self doReLayout];
    
    [self.delegate doneWithPreferences];

    
    
}


-(void) needsReLayout
{
    self.reLayoutNeeded = YES;
    //NSLog(@"needsReLayout preferences");


}
 

-(void) doReLayout
{
     //NSLog(@"start doReLayout");
    //[self loadSettingsForOrientation:self.interfaceOrientation];
    
    if (self.reLayoutNeeded) 
    {
        
        //NSLog(@"Reloading Channels View as relayout is needed");
        
        [self setTopSCrollViewContentSize];
        
        //NSLog(@"setTopSCrollViewContentSize is complete");
        
        currentChannelNum = 0;
        [self scrollToChannelNum:currentChannelNum];
        
        //NSLog(@"scrollToChannelNum is complete");
        
        [self setUpPrevCurrentNextChannelsForChannelNum:currentChannelNum pageNum:0 ForOrientation:self.interfaceOrientation];
        
        //NSLog(@"setUpPrevCurrentNextChannelsForChannelNum is complete");
        //Refresh Channels Menu
        
        
        [channelListVC refreshTableDataAndSetCurrentChannel:self.currentChannelNum];
        [self setChannelsScrollViewContentSize];
        
        //NSLog(@"refreshTableData is complete");
        
        self.reLayoutNeeded = NO;
    }

}

-(void)addedNewSource:(NSString *) sourceId
{
   
    //NSLog(@"addedNewSource");
    
    //Invoke Download imediately
    //NSLog(@"Loading Newly added Source: %@",sourceId);
    [self.downloadManager downloadSource:sourceId];
    [activeSourcesDownloadStatus setObject:@"downloading" forKey:sourceId];

    
    //releaseAllChannels
    [self releaseAllChannels];
    
    //Set Needs Relayout
    self.reLayoutNeeded = YES;
    
    //Since data is corrupted, refresh all arrays
    [self loadActiveChannelsDictionary];
   

}

-(void) startFullDownloadOfChannels
{
    [channelListVC refreshTableDataAndSetCurrentChannel:self.currentChannelNum];
    
    //releaseAllChannels
    [self releaseAllChannels];
    
    //Set Needs Relayout
    self.reLayoutNeeded = YES;
    
    //Since data is corrupted, refresh all arrays
    [self loadActiveChannelsDictionary];
    
    
    [self doReLayout];
    
    [self.downloadManager downloadAllActiveSourcesToDB];
    
}

-(void) channelPopulationErroredOut
{
    [self.delegate channelPopulationErroredOut];
    
}

-(void)removedSource:(NSString *) sourceId
{

    //NSLog(@"removedSource");
    
    //Since data is corrupted, refresh all arrays
     [self loadActiveChannelsDictionary];
   

}


-(void) sourceEdited
{
    
    //NSLog(@"sourceEdited");
    
    //Since data is corrupted, refresh all arrays
     [self loadActiveChannelsDictionary];
    
}


-(void) sourceMovedOrder
{
    //NSLog(@"sourceMovedOrder");
    
    //Since data is corrupted, refresh all arrays
     [self loadActiveChannelsDictionary];
}





#pragma mark - Download Manager Delegate methods

#pragma mark - Feed Saved in DownloadManager

-(void) feedSaveCompleted: (NSDictionary *) feedStatus
{
     @try{
         
            [feedStatus retain];
            
            //NSLog(@"UPDATING TABLE: FEEDSTATUS recieved: %@",[feedStatus description]);
            int newRecordsInserted = [[feedStatus objectForKey:@"newRecordsInserted"] intValue];
            NSString * sourceId = [feedStatus objectForKey:@"sourceId"];
            
            
            
            //[self.newlyAddedChannels removeObject:sourceId];
            
            //Update array-activeSourcesDownloadStatus- and set the downloadstatus = downloaded for the specific channel
            [activeSourcesDownloadStatus setObject:@"downloaded" forKey:sourceId];
         
            //NSLog(@"first channel:%@",((Source *)[activeSourcesArray objectAtIndex:0]).sourceUserId);
            [activeSourcesDownloadStatus setObject:@"downloaded" forKey:((Source *)[activeSourcesArray objectAtIndex:0]).sourceUserId];
         
            int channelNum = [[activeSourceIdChannelNumDictionary objectForKey:sourceId]intValue];
            //NSLog(@"FeedCompleted for channel:%@, channelNum:%d, channelNumObject:%@",sourceId,channelNum,[activeSourceIdChannelNumDictionary objectForKey:sourceId] );
            
            
                
           
            if(newRecordsInserted >0)
            {
                //Update the activeChannels fetchedObject for the channel, increment the newrecords count. save the record.
                [self updateNewRecordCount:newRecordsInserted processDate:[NSDate date] forChannelNum:channelNum];
            }
            else
            {
                [self updateNewRecordCount:-1 processDate:[NSDate date] forChannelNum:channelNum];
            }
            
            [self channelDownloadCompleted:channelNum withNewRecords:newRecordsInserted];
            [feedStatus release];
     }
    @catch (NSException * e) {
        //NSLog(@"ERROR while feedSaveCompleted:%@",[e description]);
    }
    @finally {
        //its ok
        
    }
}


#pragma mark Increment Channel's New Videos count
-(void) updateNewRecordCount:(int)recordCount processDate:(NSDate *)processedDate forChannelNum:(int)channelNum

{
    Source * source =  [self.activeSourcesArray objectAtIndex:channelNum];
    if(recordCount >=0)
        source.newVideos = [NSNumber numberWithInt:recordCount+[source.newVideos intValue]];
    if (processedDate) {
        source.lastProcessedDate = processedDate;
    }
    [self saveContext];
    
    
    [self.channelListVC refreshTableDataAndSetCurrentChannel:self.currentChannelNum];
    [self.channelsTableView reloadData];
    [self.channelsTableView2 reloadData];
    
}

#pragma mark  NO Internet
-(void) noInternetConnectionFound
{
    // Set the download status to "1" for all active channels, by populating the dictionary activeSourcesDownloadStatus
    
     //For all channels in -channelVCsArray-, call download ended method-channelDownloadCompleted:foundNewRecords-"0"-
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:EZ_NO_INTERNET message:EZ_NO_INTERNET_DETAILED delegate:self cancelButtonTitle:EZ_CANCEL otherButtonTitles: nil];
    [alert show];
    [alert release];
    
    
    int index = 0;
    for (Source *source in self.activeSourcesArray) {
        [activeSourcesDownloadStatus setObject:@"downloaded" forKey:source.sourceUserId];
        //NSString * channelId = source.sourceUserId;
        //NSLog(@"channelNum:%d, channelId:%@",index,channelId);
        [self channelDownloadCompleted:index withNewRecords:0];
        index++;
    }
}

#pragma mark Invalid User
-(void) userNotFound:(NSString *)userId
{
    //NSLog(@"Removing source:%@",userId);
    [self removedSource:userId];
    [self needsReLayout];
    [self doReLayout];
    
    //UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Invalid Youtube Userid" message:@"Please delete the newly added Channel" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    //[alert show];
    //[alert release];
}

#pragma mark full download started
-(void) fullDownloadStarted
{
    // Set the download status to "downloading" for all active channels, by populating the dictionary activeSourcesDownloadStatus
    int index = 0;
    for (Source *source in self.activeSourcesArray) {
        [activeSourcesDownloadStatus setObject:@"downloading" forKey:source.sourceUserId];
        //NSString * channelId = source.sourceUserId;
        //NSLog(@"channelNum:%d, channelId:%@",index,channelId);
         [self channelDownloadStarted:index];
        index++;
    } 

//For all channels in -channelVCsArray-, call download started method-channelDownloadStarted-
}

#pragma mark full download ended
-(void) fullDownloadEnded
{
//Not much to do.. Make it optional in delegate.
}

#pragma mark individual source download started

-(void) individualSourceDownloadStarted
{
    //If channel exists in -channelVCsArray-, call download started method-channelDownloadStarted-
}

#pragma mark individual source download ended

-(void) individualSourceDownloadEnded
{
    //If channel exists in -channelVCsArray-, call download ended method-channelDownloadCompleted:foundNewRecords-
}










#pragma mark - Utility functions -


#pragma mark Channel Download Started
-(void) channelDownloadStarted:(int)channelNum
{
    
     //NSLog(@"downloading channel where channelNum:%d",channelNum);
    if ((NSNull *)[channelVCsArray objectAtIndex:channelNum] != [NSNull null])
    {
        [((ChannelViewController *)[channelVCsArray objectAtIndex:channelNum]) channelDownloadStarted];
    } 
    
}

#pragma mark Channel Download Completed
-(void) channelDownloadCompleted:(int)channelNum withNewRecords:(int)newRecordsInserted
{
    @try{
                //NSLog(@"download channel complete, where channelNum:%d",channelNum);
                //if channel is created and exits in channelVCsArray, call channelVC method channelDownloadCompleted:(int)foundNewRecords
                //int channelNum = [[activeSourcesChannelNumDictionary objectForKey:sourceId] intValue];
                if ((NSNull *)[channelVCsArray objectAtIndex:channelNum] != [NSNull null])
                {
                    [((ChannelViewController *)[channelVCsArray objectAtIndex:channelNum]) channelDownloadCompleted:newRecordsInserted];
                }
                
                /*
                 TSChannelsVC * masterViewController = (TSChannelsVC *)((UINavigationController *)self.splitController.masterViewController).topViewController;
                 if(masterViewController)
                 {
                 [masterViewController changeNewRecordCount:newRecordsInserted forChannelNum:channelNum];
                 }
                 */
                
                //If New Videos is in memory, and is empty, load it now
                if ((NSNull *)[channelVCsArray objectAtIndex:0] != [NSNull null])
                {
                    ChannelViewController * latestVideosChanel = (ChannelViewController *)[channelVCsArray objectAtIndex:0];
                    if (latestVideosChanel.videoCountForChannel == 0) {
                        [latestVideosChanel refreshChannel:nil];
                    }
                    else
                    {
                        [latestVideosChanel channelDownloadCompleted:newRecordsInserted];
                    }
                    
                }
    }
    @catch (NSException * e) {
        //NSLog(@"ERROR while refreshing channel after download:%@",[e description]);
    }
    @finally {
        //its ok
        
    }
    
}



#pragma mark Clear Channel's New videos count
-(void) clearNewVideos:(int)channelNum
{
    //ClearNewVideos...Delegate method of ChannelViewController, to clear newVideo count once channel did appear.
    //NSLog(@"Clearing new video count for channel:%d",channelNum);
    Source * source =  [self.activeSourcesArray objectAtIndex:channelNum];
    
    source.newVideos = [NSNumber numberWithInt:0];
    source.lastProcessedDate = [NSDate date];
    [self saveContext];
    
    [self.channelListVC refreshTableDataAndSetCurrentChannel:self.currentChannelNum];
    [self.channelsTableView reloadData];
    [self.channelsTableView2 reloadData];
    
    /*
    if (channelListVC) 
    {
        [channelListVC refreshTableDataAndSetCurrentChannel:self.currentChannelNum];
    }
    */
    
}

#pragma mark Change vertical Scroll View Content Size
-(void) setTopSCrollViewContentSize
{

    int height = (self.topScrollView.frame.size.height)*self.totalActiveChannels;
    self.topScrollView.contentSize =  CGSizeMake(self.topScrollView.frame.size.width,height);

    //NSLog(@"-------->Top Scroll View content Size change to :%f,%d",self.topScrollView.frame.size.width,height);
    
    
}

#pragma mark Channel Scroll View Content Size
-(void) setChannelsScrollViewContentSize
{
    int channelRows = [self.channelListVC.fetchedResultsController.fetchedObjects count];
    int channelRowHeight = 101;
    int height = (channelRows * channelRowHeight)+2;
    
    int minHeight = self.channelsScrollView.frame.size.height;
    if(height < minHeight)
        height = minHeight;
    
    self.channelsScrollView.contentSize =  CGSizeMake(self.channelsScrollView.frame.size.width,height);
    
    //CGRect frame1 = CGRectMake(0, 1, 320, height);
    //CGRect frame2 = CGRectMake(321, 1, 319, height);
    
    CGRect frame1 = self.channelsTableView.frame;//CGRectMake(0, 1, 320, height);
    frame1.size.height = height;
    CGRect frame2 =  self.channelsTableView2.frame;//CGRectMake(321, 1, 319, height);
    frame2.size.height = height;
    
    
    self.channelsTableView.frame = frame1;//CGSizeMake(self.channelsTableView.frame.size.width,height);
    self.channelsTableView2.frame = frame2;//CGSizeMake(self.channelsTableView2.frame.size.width,height);
    
    //NSLog(@"-------->Top Scroll View content Size change to :%f,%d",self.topScrollView.frame.size.width,height);
    
    
}



#pragma mark reLayout Channels for Orientation Change

-(void) reFrameAndPositionChannelsForInterfaceOrientation:(UIInterfaceOrientation)io
{
    
    for(int i =0; i < totalActiveChannels; i++)
    {
        if (i == currentChannelNum || i == currentChannelNum-1 || i == currentChannelNum+1) {
            if ((NSNull *)[channelVCsArray objectAtIndex:i] != [NSNull null])
            {
                ChannelViewController * channel = ((ChannelViewController *)[channelVCsArray objectAtIndex:i]);
                //Reframe channel
                CGRect frame = self.topScrollView.frame;
                frame.origin.x = 0;
                frame.origin.y = i*self.topScrollView.frame.size.height;
                //frame.size.width = VT_PAGE_WIDTH;
                //frame.size.height = VT_PAGE_HEIGHT;
                channel.view.frame = frame;
                
                //NSLog(@"Moving the Channel frame to x:%f,y:%f,width:%f,height:%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
                
                [channel reFramePagesAndreLayoutVideosForInterfaceOrientation:io];
                [channel.view setNeedsLayout];
                [channel.view setNeedsDisplay];
                [channel.view layoutSubviews];
            }
            //continue;
        }
       /*
        else if ((NSNull *)[channelVCsArray objectAtIndex:i] != [NSNull null])
        {
            [channelVCsArray replaceObjectAtIndex:i withObject:[NSNull null]];
        }
        */
        
    }
    
    [self.topScrollView setNeedsLayout];
    [self.topScrollView setNeedsDisplay];
    [self.topScrollView layoutSubviews];
    //[self scrollToChannelNum:currentChannelNum];
    
}



#pragma mark Reload specific Channel

-(void) downloadChannel: (NSString *)sourceId
{
    
    [self.downloadManager downloadSource:sourceId];
    
}

#pragma mark Load Settings For Orientation

-(void) loadSettingsForOrientation:(UIInterfaceOrientation)InterfaceOrientation
{
    //BOOL isLandscapeOrientation = UIInterfaceOrientationIsLandscape(InterfaceOrientation);
    
    InterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
    
    if ( InterfaceOrientation == UIInterfaceOrientationPortrait || 
        InterfaceOrientation ==    UIInterfaceOrientationPortraitUpsideDown )
    {
        //NSLog(@"Loading settings for Orientation Portrait--Home Page");
        // VT_PAGE_HEIGHT = PAGE_HEIGHT;
        // VT_PAGE_WIDTH = PAGE_WIDTH;
        // VT_CHANNEL_PAGE_TOP_OFFSET = CHANNEL_PAGE_TOP_OFFSET;
        VT_VIDEO_ROWS_PER_PAGE = VIDEO_ROWS_PER_PAGE;
        VT_VIDEO_COLUMNS_PER_PAGE = VIDEO_COLUMNS_PER_PAGE;
        VT_VIDEO_COUNT_PER_PAGE  = VIDEO_COUNT_PER_PAGE;
        VT_VIDEO_VIEW_WIDTH  = VIDEO_VIEW_WIDTH;
        VT_VIDEO_VIEW_HEIGHT = VIDEO_VIEW_HEIGHT;
        VT_VIDEO_PAGE_TOP_OFFSET = VIDEO_PAGE_TOP_OFFSET;
        VT_VIDEO_PAGE_LEFT_OFFSET = VIDEO_PAGE_LEFT_OFFSET;
        VT_VIDEO_VERTICAL_MARGIN = VIDEO_VERTICAL_MARGIN;
        VT_VIDEO_HORIZONTAL_MARGIN = VIDEO_HORIZONTAL_MARGIN;
        //VT_CHANNEL_HEADER_HEIGHT = CHANNEL_HEADER_HEIGHT;
    }
    
    else
    {
        //NSLog(@"Loading settings for Orientation Landscape--Home Page");
        //VT_PAGE_HEIGHT = L_PAGE_HEIGHT;
        //VT_PAGE_WIDTH = L_PAGE_WIDTH;
        //VT_CHANNEL_PAGE_TOP_OFFSET = L_CHANNEL_PAGE_TOP_OFFSET;
        VT_VIDEO_ROWS_PER_PAGE = L_VIDEO_ROWS_PER_PAGE;
        VT_VIDEO_COLUMNS_PER_PAGE = L_VIDEO_COLUMNS_PER_PAGE;
        VT_VIDEO_COUNT_PER_PAGE  = L_VIDEO_COUNT_PER_PAGE;
        VT_VIDEO_VIEW_WIDTH  = L_VIDEO_VIEW_WIDTH;
        VT_VIDEO_VIEW_HEIGHT = L_VIDEO_VIEW_HEIGHT;
        VT_VIDEO_PAGE_TOP_OFFSET = L_VIDEO_PAGE_TOP_OFFSET;
        VT_VIDEO_PAGE_LEFT_OFFSET = L_VIDEO_PAGE_LEFT_OFFSET;
        VT_VIDEO_VERTICAL_MARGIN = L_VIDEO_VERTICAL_MARGIN;
        VT_VIDEO_HORIZONTAL_MARGIN = L_VIDEO_HORIZONTAL_MARGIN;
        //VT_CHANNEL_HEADER_HEIGHT = L_CHANNEL_HEADER_HEIGHT;
        
    }
}


#pragma mark  save changes in managedObjectContext 

- (void)saveContext {
    
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
} 


- (IBAction)dragChannels:(id)sender {
    
    if(!dragChannelsButton.isSelected)
    {
        CGRect frame = self.channelsScrollView.frame;
        int x = frame.origin.x;
        //int y = frame.origin.y;
        int width = frame.size.width;
        //int height = frame.size.height;
        
        

        [UIView beginAnimations:@"Zoom" context:NULL];
        [UIView setAnimationDuration:0.5];
        
        
        self.dragChannelsButtonParentView.frame =  CGRectMake(x, 0, width, 24);
        self.channelsScrollView.frame           =  CGRectMake(x, 24, width, 618);
        [dragChannelsButton setSelected:YES];
        
        [UIView commitAnimations];
    }
    else 
    {
        CGRect frame = self.channelsScrollView.frame;
        int x = frame.origin.x;
        //int y = frame.origin.y;
        int width = frame.size.width;
        //int height = frame.size.height;
        
        
        [UIView beginAnimations:@"Zoom" context:NULL];
        [UIView setAnimationDuration:0.5];
        
        self.dragChannelsButtonParentView.frame = CGRectMake(x, 426, width, 24);
        self.channelsScrollView.frame           = CGRectMake(x, 450, width, 192);
        [dragChannelsButton setSelected:NO];
        [UIView commitAnimations];
        
    }
    [self setChannelsScrollViewContentSize];
    [self moveChannelListScrollViewToChannel:self.currentChannelNum];
}

- (IBAction)dragVideos:(id)sender {
    
    int pageNumToShow = 0;
    

    
    if(dragChannelsButton.isSelected)
    {
        [self dragChannels:nil];
    }
    
    [self.dragVideosButton setHidden:YES];
    
    [UIView beginAnimations:@"Zoom" context:NULL];
    [UIView setAnimationDuration:0.5];
    
    
    if(!dragVideosButton.isSelected)
    {
        //CGRect frame = self.topScrollView.frame;
        //int x = frame.origin.x;
        //int y = frame.origin.y;
        //int width = frame.size.width;
        //int height = frame.size.height;
        
        //CGRect newFrame = CGRectMake(20, 0, 1004, 642);
        
        if(self.videoToShowNum == -1)
        {
            int currentPage =0;
            if ((NSNull *)[channelVCsArray objectAtIndex:self.currentChannelNum] != [NSNull null])
            {
                currentPage = ((ChannelViewController *)[channelVCsArray objectAtIndex:self.currentChannelNum]).currentChannelPageNumber;
            }
            //NSLog(@"Current Page Num:%d",currentPage);
            //find videoToSHowNum
            self.videoToShowNum = (currentPage * 8) + 1;
            
        }
        
        pageNumToShow = ceil(self.videoToShowNum/12.0)-1 ;
        
        [self releaseAllChannels];
        

 
        
        self.dragVideosButton.frame = CGRectMake(5, 5, 30, 25);
        self.topScrollView.frame = CGRectMake(0, 0, 1024, 642);
        
        [dragVideosButton setSelected:YES];
        
        
    }
    else 
    {
        //CGRect frame = self.topScrollView.frame;
        //int x = frame.origin.x;
        //int y = frame.origin.y;
        //int width = frame.size.width;
        //int height = frame.size.height;
        if(self.videoToShowNum == -1)
        {
            int currentPage =0;
            if ((NSNull *)[channelVCsArray objectAtIndex:self.currentChannelNum] != [NSNull null])
            {
                currentPage = ((ChannelViewController *)[channelVCsArray objectAtIndex:self.currentChannelNum]).currentChannelPageNumber;
            }
            //NSLog(@"Current Page Num:%d",currentPage);
            //find videoToSHowNum
            self.videoToShowNum = (currentPage * 12) + 1;
            
        }
        
        pageNumToShow = ceil(self.videoToShowNum/8.0) - 1;
        
        [self releaseAllChannels];
        
        CGRect newFrame = CGRectMake(640, 0, 384, 642);

        
        self.topScrollView.frame = newFrame;
        self.dragVideosButton.frame = CGRectMake(645, 5, 30, 25);
        
        [dragVideosButton setSelected:NO];
        
        
    }
    
    self.videoToShowNum = -1;
    
    //NSLog(@"Drag Videos: Setting up Channel:%d , Page:%d",self.currentChannelNum,pageNumToShow);
    

     [UIView commitAnimations];
    
    [self.dragVideosButton setHidden:NO];
    
    //[self setUpChannelNum:self.currentChannelNum pageNum:pageNumToShow ForOrientation:UIInterfaceOrientationLandscapeLeft];
    [self setUpPrevCurrentNextChannelsForChannelNum:self.currentChannelNum pageNum:pageNumToShow ForOrientation:UIInterfaceOrientationLandscapeLeft];
   
    
}


-(void)moveChannelListScrollViewToChannel:(int)channelNum
{
    
    int rowNum = channelNum;//floor(channelNum / 2.0) + 1;
    int scrollIdealPosition = 101;
    int rowPosition = (rowNum-1)*101;
    CGPoint scrollPosition = self.channelsScrollView.contentOffset;
    
    int scrollToPosition = rowPosition - scrollIdealPosition;
    CGRect scrollFrame = self.channelsScrollView.frame;
        
    if(scrollToPosition > 0)
    {

        scrollFrame.origin.y = scrollToPosition;
        [self.channelsScrollView scrollRectToVisible:scrollFrame animated:YES];
    }
    else if(scrollPosition.y >0)
    {
        scrollFrame.origin.y = 0;
        [self.channelsScrollView scrollRectToVisible:scrollFrame animated:YES];
    }
}


@end
