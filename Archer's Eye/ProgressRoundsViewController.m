//
//  ProgressRoundsViewController.m
//  Archer's Eye
//
//  Created by Alex de Vera on 4/4/15.
//  Copyright (c) 2015 Alex de Vera. All rights reserved.
//

#import "ProgressRoundsViewController.h"
#import "RoundDescCell.h"

@interface ProgressRoundsViewController ()

@end



@implementation ProgressRoundsViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate    = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.archersEyeInfo =  self.appDelegate.archersEyeInfo;
    self.favRounds      = [self.archersEyeInfo matrixOfFavoritePastRounds];
    self.favRoundID     = -1;
    
//    [self.archersEyeInfo jsonData];
}



//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if( [self.favRounds count] > 0 )
        [self.archersEyeInfo showHintPopupIfNecessary:eHint_Graphs_Progress];
    
    // Select the first item if it exists
    if( [self.favRounds count] > 0 )
    {
        if( [self.favRounds[0] count] > 0 )
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    }
}



//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self initPlot];
}



//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
























#pragma mark - Table view data source

//------------------------------------------------------------------------------
// Number of sections.
//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



//------------------------------------------------------------------------------
// Title for a section.
//------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return @"Favorite Rounds";
}



//------------------------------------------------------------------------------
// Number of rows in a section.
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favRounds count];
}



//------------------------------------------------------------------------------
// Build the rows.
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray  *favRound   = self.favRounds[indexPath.row];
    RoundDescCell   *cell       = [tableView dequeueReusableCellWithIdentifier:@"RoundDescCell"];
    RoundInfo       *info       = favRound[0];
    
    cell.name.text      = info.name;
    cell.dist.text      = [NSString stringWithFormat:@"%ld yds", (long)info.distance];
    cell.desc.text      = [NSString stringWithFormat:@"%ldx%ld", (long)info.numEnds,  (long)info.numArrowsPerEnd];
    cell.score.text     = [NSString stringWithFormat:@"%ld pts", (long)info.numEnds * (long)info.numArrowsPerEnd * [info getMaxArrowRealScore]];
    cell.bowName.text   = info.bow.name;
    cell.bowType.text   = [BowInfo typeAsString:info.bow.type];
    cell.bowWeight.text = [NSString stringWithFormat:@"%ld lbs", (long)info.bow.drawWeight];
    
    // Set the colors for each round
    cell.name.textColor     = [RoundInfo typeAsFontColor:info.type];
//    cell.bowName.textColor  = [RoundInfo typeAsFontColor:info.type];
    
    return cell;
}



//------------------------------------------------------------------------------
// Did select a row.
//------------------------------------------------------------------------------
-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _favRoundID = indexPath.row;
    
    [self initPlot];
}



//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}



//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
























#pragma mark - Chart behavior

//------------------------------------------------------------------------------
// Create a new plot.
//------------------------------------------------------------------------------
- (void)initPlot
{
    if( _favRoundID >= 0  &&  _favRoundID < [_favRounds count] )
    {
        // Make sure to remove a previous graph if it exists
        if( self.hostView != nil )
        {
            [self.hostView removeFromSuperview];
             self.hostView = nil;
        }
        
        [self configureHost];
        [self configureGraph];
        [self configureChart];
        [self configureLegend];
    }
}



//------------------------------------------------------------------------------
// Configure the holding area.
//------------------------------------------------------------------------------
- (void)configureHost
{
    // 1 - Set up view frame
    CGRect parentRect = self.graphView.bounds;
    float  percentage = 0.95f;
    
    parentRect.size.width  *= percentage;
    parentRect.size.height *= percentage;
    parentRect.origin.x     = self.graphView.bounds.size.width  * (1-percentage)/2;
    parentRect.origin.y     = self.graphView.bounds.size.height * (1-percentage)/2;
    
    // 2 - Create host view
    self.hostView                   = [(CPTGraphHostingView *)[CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = NO;
    [self.graphView addSubview:self.hostView];
}



//------------------------------------------------------------------------------
// Configure some general values.
//------------------------------------------------------------------------------
- (void)configureGraph
{
    // 1 - Create and initialize graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph   = graph;
    graph.paddingLeft           = 0.0f;
    graph.paddingTop            = 0.0f;
    graph.paddingRight          = 0.0f;
    graph.paddingBottom         = 0.0f;
    
    // 2 - Set up text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color     = [CPTColor grayColor];
    textStyle.fontName  = @"Helvetica-Bold";
    textStyle.fontSize  = 16.0f;
    
    // 3 - Configure title
    NSString *title = @"";
    graph.title                     = title;
    graph.titleTextStyle            = textStyle;
    graph.titlePlotAreaFrameAnchor  = CPTRectAnchorTop;
    graph.titleDisplacement         = CGPointMake(0.0f, -12.0f);
    
    // 4 - Set theme
    self.selectedTheme = [CPTTheme themeNamed:kCPTPlainBlackTheme];
    [graph applyTheme:self.selectedTheme];
}



//------------------------------------------------------------------------------
// Configure the scatter plot.
//------------------------------------------------------------------------------
- (void)configureChart
{
    // 1 - Get reference to graph
    CPTGraph        *graph      = self.hostView.hostedGraph;
    CPTXYPlotSpace  *plotSpace  = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    // 2 - Create chart
    CPTScatterPlot *scatterPlot = [[CPTScatterPlot alloc] init];
    RoundInfo      *round       = self.favRounds[self.favRoundID][0];
    UIColor        *color       = [RoundInfo typeAsColor:round.type];
    CGFloat        red          = 1.0f;
    CGFloat        blue         = 1.0f;
    CGFloat        green        = 1.0f;
    CGFloat        alpha        = 1.0f;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    self.lineColor = [CPTColor colorWithComponentRed:red green:green blue:blue alpha:1.0f];
    self.fillColor = [CPTColor colorWithComponentRed:red green:green blue:blue alpha:0.3f];
    
    scatterPlot.dataSource      = self;
    scatterPlot.delegate        = self;
    scatterPlot.identifier      = @"DATA";
    scatterPlot.areaFill        = [CPTFill fillWithColor:self.fillColor];
    scatterPlot.areaBaseValue   = @0.0;
    [graph addPlot:scatterPlot toPlotSpace:plotSpace];
    
    // 3 - Set up plot space
    NSInteger totalArrows    = [self.favRounds[self.favRoundID][0] getTotalArrows];
    NSInteger maxArrowScore  = [self.favRounds[self.favRoundID][0] getMaxArrowRealScore];
    NSNumber *xStart         = [NSNumber numberWithFloat:-((float)[self.favRounds[_favRoundID] count]) * 0.2f];
    NSNumber *xLength        = [NSNumber numberWithFloat:((float)[self.favRounds[_favRoundID] count]) * 1.2f];
    NSNumber *yStart         = [NSNumber numberWithFloat:-(totalArrows * maxArrowScore) * 0.2f];
    NSNumber *yLength        = [NSNumber numberWithFloat:(totalArrows * maxArrowScore) * 1.3f];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:xStart length:xLength];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:yStart length:yLength];

    // 4 - Create styles and symbols
    CPTMutableLineStyle *lineStyle  = [scatterPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth             = 2.5;
    lineStyle.lineColor             = self.lineColor;
    scatterPlot.dataLineStyle       = lineStyle;
    
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor            = self.lineColor;
    
    CPTPlotSymbol *symbol   = [CPTPlotSymbol ellipsePlotSymbol];
    symbol.fill             = [CPTFill fillWithColor:self.lineColor];
    symbol.lineStyle        = symbolLineStyle;
    symbol.size             = CGSizeMake(6.0f, 6.0f);
    scatterPlot.plotSymbol  = symbol;
}



//------------------------------------------------------------------------------
// Configure the legend.
//------------------------------------------------------------------------------
- (void)configureLegend
{
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color                = [CPTColor greenColor];
    axisTitleStyle.fontName             = @"Helvetica-Bold";
    axisTitleStyle.fontSize             = 14.0f;
    CPTMutableLineStyle *axisLineStyle  = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth             = 2.0f;
    axisLineStyle.lineColor             = [CPTColor grayColor];
    CPTMutableTextStyle *axisTextStyle  = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color                 = [CPTColor whiteColor];
    axisTextStyle.fontName              = @"Helvetica-Bold";
    axisTextStyle.fontSize              = 11.0f;
    CPTMutableLineStyle *tickLineStyle  = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor             = [CPTColor lightGrayColor];
    tickLineStyle.lineWidth             = 2.0f;
    CPTMutableLineStyle *gridLineStyle  = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor             = [CPTColor darkGrayColor];
    gridLineStyle.lineWidth             = 1.0f;
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.hostView.hostedGraph.axisSet;
    
    // 3 - Configure x-axis
    CPTAxis *x           = axisSet.xAxis;
    x.title              = @"Sessions";
    x.titleTextStyle     = axisTitleStyle;
    x.titleOffset        = 19.0f;
    x.axisLineStyle      = axisLineStyle;
    x.labelingPolicy     = CPTAxisLabelingPolicyNone;
    x.labelTextStyle     = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength    = 4.0f;
    x.tickDirection      = CPTSignNegative;
    NSMutableSet *xLabels    = [NSMutableSet setWithCapacity:[self.favRounds[self.favRoundID] count]];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:[self.favRounds[self.favRoundID] count]];
    NSInteger j = 0;
    for( NSInteger i = 0; i < [self.favRounds[self.favRoundID] count]; ++i )
    {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%ld", i] textStyle:x.labelTextStyle];
        NSNumber *location = [NSNumber numberWithInteger:j++];
        label.tickLocation = location;
        label.offset = x.majorTickLength;
        if (label)
        {
            [xLabels addObject:label];
            [xLocations addObject:location];
        }
    }
    x.axisLabels         = xLabels;
    x.majorTickLocations = xLocations;
    
    // 4 - Configure y-axis
    CPTAxis *y           = axisSet.yAxis;
    y.title              = @"Points";
    y.titleTextStyle     = axisTitleStyle;
    y.titleOffset        = -42.0f;
    y.axisLineStyle      = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy     = CPTAxisLabelingPolicyNone;
    y.labelTextStyle     = axisTextStyle;
    y.labelOffset        = 20.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength    = 4.0f;
    y.minorTickLength    = 2.0f;
    y.tickDirection      = CPTSignPositive;
    eRoundType    roundType       = [(RoundInfo *)self.favRounds[_favRoundID][0] type];
    NSInteger     majorIncrement  = (roundType == eRoundType_FITA) ? 100 : 50;
    NSInteger     minorIncrement  = (roundType == eRoundType_FITA) ? 50  : 25;
    CGFloat       yMax            = [self.favRounds[self.favRoundID][0] getTotalArrows] * [self.favRounds[self.favRoundID][0] getMaxArrowRealScore];
    NSMutableSet *yLabels         = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement)
    {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0)
        {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)j] textStyle:y.labelTextStyle];
            NSNumber *location  = [NSNumber numberWithInteger:j];
            label.tickLocation  = location;
            label.offset        = -y.majorTickLength - y.labelOffset;
            if (label)
            {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:location];
        }
        else
        {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels         = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations; 
}






















#pragma mark - CPTPlotDataSource methods

//------------------------------------------------------------------------------
// ScatterPlot - number of sections.
//------------------------------------------------------------------------------
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.favRounds[_favRoundID] count];
}



//------------------------------------------------------------------------------
// ScatterPlot - xy values
//------------------------------------------------------------------------------
- (NSNumber *)numberForPlot:(CPTPlot *)plot
                      field:(NSUInteger)fieldEnum
                recordIndex:(NSUInteger)idx
{
    NSNumber *num = @(0);
    
    // This method is actually called twice per point in the plot, one for the X and one for the Y value
    if( fieldEnum == CPTScatterPlotFieldX )
        num = @(idx);
    else
        num = @([self.favRounds[_favRoundID][idx] getRealTotalScore]);
    
    return num;
}



//------------------------------------------------------------------------------
// ScatterPlot - data label for each section.
//------------------------------------------------------------------------------
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot
                   recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *labelText = nil;
    
    if( !labelText )
    {
        labelText           = [[CPTMutableTextStyle alloc] init];
        labelText.fontName  = @"Helvetica-Bold";
        labelText.color     = [CPTColor greenColor];
    }
    
    NSString *labelValue = [NSString stringWithFormat:@"%ld", (long)[self.favRounds[self.favRoundID][index] getRealTotalScore]];
    
    return [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
}

@end
