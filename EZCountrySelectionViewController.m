//
//  EZCountrySelectionViewController.m
//  EZ Tube
//
//  Created by dan mullaguru on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EZCountrySelectionViewController.h"

@interface EZCountrySelectionViewController ()

-(void) loadDefaults;
-(void) loadFeedImagesDictionary;
-(void) loadSupportedCountries;
-(void) doneWithPreferencesLocal:(id)sender;
-(void) loadFlagViews;
-(void) setLocalizedChooseCountryText;
-(void) startChaningCountry;

@end

@implementation EZCountrySelectionViewController

@synthesize changeCountryAlert;
@synthesize internetAlert;
@synthesize chooseCountryLocalizedText;
@synthesize feedFlagsImagesDictionary;
@synthesize ls;
@synthesize countryCodes;
@synthesize country_keys;
@synthesize currentAppCountry;
@synthesize toAppCountry;
@synthesize tempAppCountry;
@synthesize delegate;
@synthesize row1View;
@synthesize row2View;
@synthesize row3View;
@synthesize row4View;
@synthesize row5View;
@synthesize currentCountryNameLbl;
@synthesize currentCountryFlagImageView;
@synthesize countryChangeProgressView;
@synthesize countriesView;
@synthesize countryInitializeButton;


#define degreesToRadians(x) (M_PI * x / 180.0);



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    ls = [LocalizationSystem sharedLocalSystem];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWithPreferencesLocal:)];
    
    

    
    [self loadFeedImagesDictionary];
    [self loadSupportedCountries];
    
    [self loadDefaults];
    [self loadFlagViews];
    [self setLocalizedChooseCountryText];
    
}

- (void)viewDidUnload
{

    [self setRow1View:nil];
    [self setRow2View:nil];
    [self setRow3View:nil];
    [self setRow4View:nil];
    [self setRow5View:nil];
    [self setCurrentCountryFlagImageView:nil];
    [self setCurrentCountryNameLbl:nil];
    [self setCountryChangeProgressView:nil];
    [self setCountriesView:nil];
    [self setCountryInitializeButton:nil];
    [self setChooseCountryLocalizedText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//return YES;
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {

    [row1View release];
    [row2View release];
    [row3View release];
    [row4View release];
    [row5View release];
    [currentCountryFlagImageView release];
    [currentCountryNameLbl release];
    [countryChangeProgressView release];
    [countriesView release];
    [countryInitializeButton release];
    [chooseCountryLocalizedText release];
    [super dealloc];
}

- (BOOL)connected 
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];  
    NetworkStatus networkStatus = [reachability currentReachabilityStatus]; 
    return !(networkStatus == NotReachable);
}


- (IBAction)initializeCountry:(id)sender {
    if([self connected])
    {
        [self.countryInitializeButton setEnabled:NO];
        [self.countriesView setAlpha:0.4];
        
        [[NSUserDefaults standardUserDefaults] setObject:toAppCountry forKey:@"currentAppCountry"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.countryChangeProgressView.progress = 0.1;
        [self.countryChangeProgressView setHidden:NO];
        
        [self.delegate setCountryTo:toAppCountry];   
    }
    else 
    {
        NSString * internetAlertTitle = ls.eZ_NO_INTERNET;
        NSString * internetAlertMsg = @"Internet Connection is required. Please connect internet and start the application.";
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:internetAlertTitle
                                                             message:internetAlertMsg
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"OK", nil] autorelease];
        self.internetAlert = alertView;
        [self.internetAlert show];
    }
}


-(void) doneWithPreferencesLocal:(id)sender {
    if(![self.toAppCountry isEqualToString:self.currentAppCountry])
    {
        
        if([self connected])
        {
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
            [self.countriesView setAlpha:0.4];
            
            [[NSUserDefaults standardUserDefaults] setObject:toAppCountry forKey:@"currentAppCountry"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.countryChangeProgressView.progress = 0.1;
            [self.countryChangeProgressView setHidden:NO];

            //[self.delegate setCountryTo:toAppCountry];
            
            aTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                      target:self 
                                                    selector:@selector(startChaningCountry) 
                                                    userInfo:nil 
                                                     repeats:NO];
        }
        else 
        {
            NSString * internetAlertTitle = @"No Internet";
            NSString * internetAlertMsg = @"Internet Connection is required. Please connect internet and start the application.";
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:internetAlertTitle
                                                                 message:internetAlertMsg
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:@"OK", nil] autorelease];
            self.internetAlert = alertView;
            [self.internetAlert show];
        }
    }
    else 
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    
}

-(void) startChaningCountry
{
    [self.delegate setCountryTo:toAppCountry];
}

-(void) loadDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!([defaults objectForKey:@"currentAppCountry"])) 
    {
        
        NSString * deviceSelectedCountryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
        //NSLog(@"Device Selected Country Code :%@",deviceSelectedCountryCode);
        
        //NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
        //NSString *country = [usLocale displayNameForKey: NSLocaleCountryCode value: countryCode];
        //NSLog(@"Country Code: %@, Country: %@", countryCode, country);
        
        NSArray * supportedCountries = [[NSArray alloc] initWithObjects: @"AR",@"AU",@"BR",@"CA",@"CZ",@"FR",@"DE",@"GB",@"HK",@"IN",@"IE",@"IL",@"IT",@"JP",@"MX",@"NL",@"NZ",@"PL",@"RU",@"ZA",@"KR",@"ES",@"SE",@"TW",@"US", nil];
        
        //@"All Countries",@"Argentina",@"Australia",@"Brazil",@"Canada",@"Czech Republic",@"France",@"Germany",@"Great Britain",@"Hong Kong",@"India",@"Ireland",@"Israel",@"Italy",@"Japan",@"Mexico",@"Netherlands",@"New Zealand",@"Poland",@"Russia",@"South Africa",@"South Korea",@"Spain",@"Sweden",@"Taiwan",@"United States", nil]; 
        

        
        if([supportedCountries indexOfObject:deviceSelectedCountryCode] == NSNotFound)
        {
            deviceSelectedCountryCode = @"ALL";   
        }
        
        NSString * langCode = [[defaults objectForKey:@"currentAppLanguage"] substringToIndex:2];
        
        //1.If language is Hindi,Urdu,Bengali,Kannada,Tamil,Telugu set country =IN
        if([langCode isEqualToString:@"hi"] || [langCode isEqualToString:@"ur"] || [langCode isEqualToString:@"bn"] || [langCode isEqualToString:@"kn"] || [langCode isEqualToString:@"ta"] || [langCode isEqualToString:@"te"])
        {
            deviceSelectedCountryCode = @"IN";
        }
        
        //2.If language is Chinese set country =HK
        if([langCode isEqualToString:@"zh"])
        {
            deviceSelectedCountryCode = @"HK";
        }
        
        //3.If language is Czech set country =CZ
        if([langCode isEqualToString:@"cs"])
        {
            deviceSelectedCountryCode = @"CZ";
        }
        
        //4.If language is Danish(da),Swedish(sv),Norsk(nn or nb),Finnish(fi) set country =SE
        if([langCode isEqualToString:@"da"] || [langCode isEqualToString:@"sv"] || [langCode isEqualToString:@"nn"] || [langCode isEqualToString:@"nb"] || [langCode isEqualToString:@"fi"])
        {
            deviceSelectedCountryCode = @"SE";
        }
        
        //5.If language is Dutch(nl) set country = Holland (NL)
        if([langCode isEqualToString:@"nl"])
        {
            deviceSelectedCountryCode = @"NL";
        }
        
        //6.If language is French(fr) and country is not france or canada, set country =France(FR)
        if([langCode isEqualToString:@"fr"] )
        {
            if(!([deviceSelectedCountryCode isEqualToString:@"FR"] || [deviceSelectedCountryCode isEqualToString:@"CA"]))
            {deviceSelectedCountryCode = @"FR";}
        }
        
        //7.If language is german(de) set country =Germany(DE)
        if([langCode isEqualToString:@"de"])
        {
            deviceSelectedCountryCode = @"DE";
        }
        
        //8.If language is Hebrew(he) set country =Israel(IL)
        if([langCode isEqualToString:@"he"])
        {
            deviceSelectedCountryCode = @"IL";
        }
        
        //9.If language is Italiano(it) set country =Italy(IT)
        if([langCode isEqualToString:@"it"])
        {
            deviceSelectedCountryCode = @"IT";
        }
        
        //10.If language is Japanese(ja) set country =Japan(JP)
        if([langCode isEqualToString:@"ja"])
        {
            deviceSelectedCountryCode = @"JP";
        }
        
        //11.If language is Korean(ko) set country =KOREA(KR)
        if([langCode isEqualToString:@"ko"] )
        {
            deviceSelectedCountryCode = @"KR";
        }
        
        //12.If language is Polish(pl) set country =POLAND(PL)
        if([langCode isEqualToString:@"pl"])
        {
            deviceSelectedCountryCode = @"PL";
        }
        
        //13.If language is Portugese(pt) set country =Brazil(BR)
        if([langCode isEqualToString:@"pt"])
        {
            deviceSelectedCountryCode = @"BR";
        }
        
        //14.If language is Russian(ru), Ukrainian(uk) set country =Russia(RU)
        if([langCode isEqualToString:@"ru"] || [langCode isEqualToString:@"uk"] )
        {
            deviceSelectedCountryCode = @"RU";
        }
        
        //1.If language is espanol(es), Catalan(ca) set country =Spain(ES)
        if([langCode isEqualToString:@"es"] || [langCode isEqualToString:@"ca"])
        {
            deviceSelectedCountryCode = @"ES";
        }
        
        
        [defaults setObject:deviceSelectedCountryCode forKey:@"currentAppCountry"];
        [defaults synchronize];
        
    }

    self.currentAppCountry = [defaults objectForKey:@"currentAppCountry"];
    self.toAppCountry = self.currentAppCountry;
    
    NSString * countryName = [self.country_keys objectAtIndex:[self.countryCodes indexOfObject:self.toAppCountry]];
    NSString * countryNameLocalized = AMLocalizedString(countryName, countryName);
    
    UIImage * countryFlag = [self.feedFlagsImagesDictionary objectForKey:countryName];
    self.currentCountryFlagImageView.image = countryFlag;
    self.currentCountryNameLbl.text = countryNameLocalized;

}


-(void) setLocalizedChooseCountryText
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * langCode = [[defaults objectForKey:@"currentAppLanguage"] substringToIndex:2];
    
    if(!([langCode isEqualToString:@"en"]))
    {
        [self.chooseCountryLocalizedText setHidden:NO];
        self.chooseCountryLocalizedText.text = ls.eZ_CHOOSE_COUNTRY;
    }
    else 
    {
        [self.chooseCountryLocalizedText setHidden:YES];
    }
    
    
}

-(void) loadFeedImagesDictionary
{
    //Load Country Flags Images
    
    NSArray * countryFlagImageKeys = [[NSArray alloc] initWithObjects: @"Argentina",@"Australia",@"Brazil",@"Canada",@"Czech Republic",@"France",@"Germany",@"Great Britain",@"Hong Kong",@"India",@"Ireland",@"Israel",@"Italy",@"Japan",@"Mexico",@"Netherlands",@"New Zealand",@"Poland",@"Russia",@"South Africa",@"South Korea",@"Spain",@"Sweden",@"Taiwan",@"United States",@"All Countries", nil];
    
    NSArray * countryFlagImages =  [[NSArray alloc] initWithObjects: 
                                                                     [UIImage imageNamed:@"argentina.png"],
                                                                     [UIImage imageNamed:@"australia.png"],
                                                                     [UIImage imageNamed:@"brazil.png"],
                                                                     [UIImage imageNamed:@"canada.png"],
                                                                     [UIImage imageNamed:@"czech.png"],
                                                                     [UIImage imageNamed:@"france.png"],
                                                                     [UIImage imageNamed:@"germany.png"],
                                                                     [UIImage imageNamed:@"britain.png"],
                                                                     [UIImage imageNamed:@"hongkong.png"],
                                                                     [UIImage imageNamed:@"india.png"],
                                                                     [UIImage imageNamed:@"ireland.png"],
                                                                     [UIImage imageNamed:@"israel.png"],
                                                                     [UIImage imageNamed:@"italy.png"],
                                                                     [UIImage imageNamed:@"japan.png"],
                                                                     [UIImage imageNamed:@"mexico.png"],
                                                                     [UIImage imageNamed:@"holland.png"],
                                                                     [UIImage imageNamed:@"newzealand.png"],
                                                                     [UIImage imageNamed:@"poland.png"],
                                                                     [UIImage imageNamed:@"russia.png"],
                                                                     [UIImage imageNamed:@"southafrica.png"],
                                                                     [UIImage imageNamed:@"southkorea.png"],
                                                                     [UIImage imageNamed:@"spain.png"],
                                                                     [UIImage imageNamed:@"sweden.png"],
                                                                     [UIImage imageNamed:@"taiwan.png"],
                                                                     [UIImage imageNamed:@"usa.png"],
                                                                     [UIImage imageNamed:@"globe.png"],
                                                                     nil];
    
    
    self.feedFlagsImagesDictionary = [[NSDictionary alloc]initWithObjects:countryFlagImages forKeys:countryFlagImageKeys];
    //NSLog(@"Loaded images dictionary:%@",self.feedFlagsImagesDictionary);
    
}

-(void) loadSupportedCountries
{
    
    self.countryCodes = [[NSArray alloc] initWithObjects: @"AR",@"AU",@"BR",@"CA",@"CZ",@"FR",@"DE",@"GB",@"HK",@"IN",@"IE",@"IL",@"IT",@"JP",@"MX",@"NL",@"NZ",@"PL",@"RU",@"ZA",@"KR",@"ES",@"SE",@"TW",@"US",@"ALL", nil];
    

    
    
    self.country_keys = [[NSArray alloc] initWithObjects: @"Argentina",@"Australia",@"Brazil",@"Canada",@"Czech Republic",@"France",@"Germany",@"Great Britain",@"Hong Kong",@"India",@"Ireland",@"Israel",@"Italy",@"Japan",@"Mexico",@"Netherlands",@"New Zealand",@"Poland",@"Russia",@"South Africa",@"South Korea",@"Spain",@"Sweden",@"Taiwan",@"United States",@"All Countries", nil]; 
    
}

-(void) loadFlagViews
{
    
    int rowNum = 0;
    int colNum = 0;
    int countryArrayIndex = 0;
    int xStart = 92;
    int xBuffer = 136;
    for (; rowNum<5; rowNum++) 
    {
        colNum = 0;
        
        for (; colNum<6; colNum++) 
        {
            
            //Skip last 4 columns, for first row
            if(rowNum == 0 && colNum>1)
                break;
            
            
            if(rowNum == 0)
                {
                    countryArrayIndex = (rowNum*6)+colNum;
                }
            else 
                {
                    countryArrayIndex = (rowNum*6)+colNum-4;
                }
            //NSLog(@"Index:%d",countryArrayIndex);
            

            
            NSString * cellCountryCode = [self.countryCodes objectAtIndex:countryArrayIndex];//@"";
            NSString * cellCountryNameEnglish = [self.country_keys objectAtIndex:countryArrayIndex];//@"";
            NSString * cellCountryNameLocalized = AMLocalizedString(cellCountryNameEnglish, cellCountryNameEnglish);//@"";
            UIImage  * cellCountryFlag = [self.feedFlagsImagesDictionary objectForKey:cellCountryNameEnglish ];//@"";
            
            //Create Video Cell, Set the attributes
            EZCountryCellView * countryCellView = [[EZCountryCellView alloc]init];
            
            countryCellView.countryCode = cellCountryCode;
            countryCellView.countryName = cellCountryNameEnglish;
            countryCellView.countryNameLbl.text = cellCountryNameLocalized;
            countryCellView.flagImageView.image = cellCountryFlag;
            countryCellView.delegate = self;
            //NSLog(@"current Country:%@, cellCountry:%@",currentAppCountry,cellCountryCode);
            
            if([toAppCountry isEqualToString:cellCountryCode])
            {
                [countryCellView.flagBorderImageView setHidden:NO];
                //CGFloat angle = degreesToRadians(345);

                //[countryCellView.flagImageView setTransform:CGAffineTransformMakeRotation(angle)];
            }
            else 
            {
                [countryCellView.flagBorderImageView setHidden:YES];
                //CGFloat angle = degreesToRadians(0);
                
                //[countryCellView.flagImageView setTransform:CGAffineTransformMakeRotation(angle)];
            }
            
            CGRect frame = countryCellView.frame;
            frame.origin.x = xStart+(xBuffer*colNum);
            frame.origin.y = 5;
            
            countryCellView.frame = frame;
       
            
            switch (rowNum) {
                case 0:
                    [ self.row1View addSubview:countryCellView];
                    break;
                    
                case 1:
                    [ self.row2View addSubview:countryCellView];
                    break;
                    
                case 2:
                    [ self.row3View addSubview:countryCellView];
                    break;
                    
                case 3:
                    [ self.row4View addSubview:countryCellView];
                    break;
                    
                case 4:
                    [ self.row5View addSubview:countryCellView];
                    break;
                    
                default:
                    break;
            }
            
            
        }
        
        
    }
    
}

#pragma mark - Table datasource delegate methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
 
 NSArray * sectionTitles = [NSArray arrayWithObject:@"Channels"];
 return sectionTitles;
 }
 */


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    int rows =0;
    
    /*
    if([tableView isEqual:countryListTable1])
    {
        rows = 13;
    }
    else if([tableView isEqual:countryListTable2])
    {
        rows = 13;
    }
     */
    return rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SupportedLanguage";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell forTableView:tableView atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    /*
    int actualRow = 0;
    
    if([tableView isEqual:countryListTable1])
    {
        actualRow = indexPath.row;
    }
    else if([tableView isEqual:countryListTable2])
    {
        actualRow = indexPath.row+13;
    }

    NSString * cellCountryCode = [self.countryCodes objectAtIndex:actualRow];//@"";
    NSString * cellCountryNameEnglish = [self.country_keys objectAtIndex:actualRow];//@"";
    NSString * cellCountryNameLocalized = AMLocalizedString(cellCountryNameEnglish, cellCountryNameEnglish);//@"";
    UIImage  * cellCountryFlag = [self.feedFlagsImagesDictionary objectForKey:cellCountryNameEnglish ];//@"";
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",cellCountryNameEnglish, cellCountryNameLocalized];
    
    
    if([currentAppCountry isEqualToString:cellCountryCode])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //cell.textLabel.font. = [UIColor whiteColor];
    }
    else 
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    


    cell.imageView.image = cellCountryFlag;
    
    //cell.detailTextLabel.text = [[supportedAppLanguages objectAtIndex:indexPath.row] valueForKey:@"langNameLocal"];//@"english";
    */
    
}

#pragma mark - TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    int actualRow = 0;
    
    if([tableView isEqual:countryListTable1])
    {
        actualRow = indexPath.row;
    }
    else if([tableView isEqual:countryListTable2])
    {
        actualRow = indexPath.row+13;
    }

    NSString * cellCountryCode = [self.countryCodes objectAtIndex:actualRow];//@"";
    //NSString * cellCountryNameEnglish = [self.country_keys objectAtIndex:actualRow];//@"";
    //NSString * cellCountryNameLocalized = AMLocalizedString(cellCountryNameEnglish, cellCountryNameEnglish);//@"";
    //NSString * countryImageName = [self.feedFlagsImagesDictionary objectForKey:cellCountryNameEnglish ];//@"";
    //UIImage  * cellCountryFlag = [UIImage imageNamed:countryImageName] ;
    
    currentAppCountry = cellCountryCode;
    
    [[NSUserDefaults standardUserDefaults] setObject:currentAppCountry forKey:@"currentAppCountry"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [countryListTable1 reloadData];
    [countryListTable2 reloadData];
     */
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 35.0f;
}

-(void) showChangeCountryAlert:(NSString *) newCountry
{
    tempAppCountry = toAppCountry;
    toAppCountry = newCountry;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //App language not set yet
        
    if(![newCountry isEqualToString:currentAppCountry] && [defaults objectForKey:@"appInitialized"])
        {
            int countryArrayIndex = [self.countryCodes indexOfObject:newCountry];
            NSString * cellCountryNameEnglish = [self.country_keys objectAtIndex:countryArrayIndex];//@"";
            NSString * cellCountryNameLocalized = AMLocalizedString(cellCountryNameEnglish, cellCountryNameEnglish);
            
            NSString * changeAlertMsg = [NSString stringWithFormat:@"All current Feeds and Channels will be deleted. New Feeds and Channels will be populated for the country selected: %@. Would you like to continue?", cellCountryNameLocalized];
            NSString * changeAlertTitle = cellCountryNameLocalized;
            
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:changeAlertTitle
                                                                 message:changeAlertMsg
                                                                delegate:self
                                                       cancelButtonTitle:ls.eZ_CANCEL
                                                       otherButtonTitles:ls.eZ_CONTINUE, nil] autorelease];
            self.changeCountryAlert = alertView;
            [self.changeCountryAlert show];
        }
    else 
    {
        //refresh the UI
        [self refreshTheUItoSelectedAppCountry];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
		
    if(alertView == self.changeCountryAlert)
    {
        switch (buttonIndex) {
            case 0:
            {
                // revert back the country
                toAppCountry =  tempAppCountry;
                //NSLog(@"Do Nothing");
                break;
            }
            default:
            {
              //NSLog(@"change to new country");
                //refresh the UI
                [self refreshTheUItoSelectedAppCountry];
                
            }
                break;
        }
    }

}

-(void) refreshTheUItoSelectedAppCountry
{
    for(NSObject * subView in self.row1View.subviews)
    {
        if([subView respondsToSelector:@selector(refreshToCountryCode:)])
        {
            EZCountryCellView * videoCell = (EZCountryCellView *)subView;
            [videoCell refreshToCountryCode:toAppCountry];
        }
    }
    
    for(NSObject * subView in self.row2View.subviews)
    {
        if([subView respondsToSelector:@selector(refreshToCountryCode:)])
        {
            EZCountryCellView * videoCell = (EZCountryCellView *)subView;
            [videoCell refreshToCountryCode:toAppCountry];
        }
    }
    
    for(NSObject * subView in self.row3View.subviews)
    {
        if([subView respondsToSelector:@selector(refreshToCountryCode:)])
        {
            EZCountryCellView * videoCell = (EZCountryCellView *)subView;
            [videoCell refreshToCountryCode:toAppCountry];
        }
    }
    
    for(NSObject * subView in self.row4View.subviews)
    {
        if([subView respondsToSelector:@selector(refreshToCountryCode:)])
        {
            EZCountryCellView * videoCell = (EZCountryCellView *)subView;
            [videoCell refreshToCountryCode:toAppCountry];
        }
    }
    
    for(NSObject * subView in self.row5View.subviews)
    {
        if([subView respondsToSelector:@selector(refreshToCountryCode:)])
        {
            EZCountryCellView * videoCell = (EZCountryCellView *)subView;
            [videoCell refreshToCountryCode:toAppCountry];
        }
    }
    
    NSString * countryName = [self.country_keys objectAtIndex:[self.countryCodes indexOfObject:self.toAppCountry]];
    NSString * countryNameLocalized = AMLocalizedString(countryName, countryName);
    
    UIImage * countryFlag = [self.feedFlagsImagesDictionary objectForKey:countryName];
    self.currentCountryFlagImageView.image = countryFlag;
    self.currentCountryNameLbl.text = countryNameLocalized;
    
}



@end
