//
//  EZChannelSearchVideoCellView.m
//  EZ Tube
//
//  Created by dan mullaguru on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EZChannelSearchVideoCellView.h"

@implementation EZChannelSearchVideoCellView
@synthesize videoImageView;
@synthesize videoTitleLbl;
@synthesize videoUploadDateLbl;
@synthesize videoDownloadIndicator;
@synthesize videoIndex;
@synthesize videoId;
@synthesize videoTitle;
@synthesize channelId;
@synthesize videoURL;
@synthesize videoThumbNailURLString;
@synthesize channelSearchVideoFeedDownloadQueue;
@synthesize imageDownloaded;
@synthesize delegate;

/*
 - (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
*/

- (id)initWithFrame:(CGRect)frame {
    
    //self = [super initWithFrame:frame]; // not needed - thanks ddickison
	if (self) {
        NSArray *nib = [[NSBundle mainBundle] 
						loadNibNamed:@"EZChannelSearchVideoCellView"
						owner:self
						options:nil];
		
		[self release];	// release object before reassignment to avoid leak - thanks ddickison
		self = [nib objectAtIndex:0];
        self.imageDownloaded = NO;
		
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


 

-(void) loadImageView
{ 
    if(!(self.imageDownloaded))
    {
        
        [videoDownloadIndicator startAnimating];
        
        //dispatch_queue_t videoDownloadQueue = dispatch_queue_create("com.eztube.testVideoFeed", NULL);
        
        dispatch_async(channelSearchVideoFeedDownloadQueue, ^{
            if (self.window) 
            {
                UIImage *videoThumbNailImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:videoThumbNailURLString]]];
                dispatch_sync(dispatch_get_main_queue(), 
                              ^{  self.videoImageView.image = videoThumbNailImage;
                                  [self.videoDownloadIndicator stopAnimating];
                                  self.imageDownloaded = YES;
                              });
                //NSLog(@"Downloaded");
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), 
                              ^{ 
                                  //NSLog(@"Not downloaded");
                                  [self.videoDownloadIndicator stopAnimating];
                                  self.imageDownloaded = NO;
                              } );
            } 
            
        });
        
    }
    
    
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"Video View touched..Calling Super View");
    
    /*
     
    UITouch *touch = [touches anyObject];
    NSLog(@"--------------------------TouchView of class:%@",[touch class]);
    NSLog(@"--------------------------TouchView of class:%@",[[touch view] class]);
    NSLog(@"--------------------------touches description:%@",touches.debugDescription);
    NSLog(@"--------------------------event description:%@",event.debugDescription);
    
    */


    [super touchesBegan:touches withEvent:event];
    //[self.delegate popVideo:videoId title:videoTitleLbl.text];
    //[self.delegate popVideo:videoId title:videoTitle channelId:channelId];
    [self.delegate loadAllVideosInExternalPlayerStartingWithVideoIndex:self.videoIndex];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"Video View touchesEnded");
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"Video View touchesCancelled");
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"Video View touchesMoved");
}

- (void)dealloc {
    [videoImageView release];
    [videoTitleLbl release];
    [videoUploadDateLbl release];
    [videoDownloadIndicator release];
    [super dealloc];
}
@end
