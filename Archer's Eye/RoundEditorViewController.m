//
//  LiveRoundViewController.m
//  Archer's Eye
//
//  Created by Alex de Vera on 3/8/15.
//  Copyright (c) 2015 Alex de Vera. All rights reserved.
//

#import "RoundEditorViewController.h"

@interface RoundEditorViewController ()

@end



@implementation RoundEditorViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.appDelegate    = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.archersEyeInfo = self.appDelegate.archersEyeInfo;
    self.currRound      = (self.archersEyeInfo.currRound != nil) ? self.archersEyeInfo.currRound : self.archersEyeInfo.liveRound;
    _doneButton.enabled = NO;
    
    CGPoint currEmpty = [_currRound getCurrEndAndArrow];
    _currEndID   = currEmpty.y;
    _currArrowID = currEmpty.x;
    
    // We are always going to use our own back button.  Rename it accordingly.
    if( self.editorType == eRoundEditorType_Live )
        _exitButton.title = @"Back";
    else if( self.editorType == eRoundEditorType_Past )
        _exitButton.title = @"Cancel";
    
    // Fix the erase/done button enabled states
    if( _currEndID >= [_currRound numEnds] )
    {
        _doneButton.enabled = YES;
    }

    // Enable the appropriate controls
    if( _currRound.type == eRoundType_FITA )
    {
        _controlsFITA.hidden    = NO;
        _controlsNFAA.hidden    = YES;
    }
    else if( _currRound.type == eRoundType_NFAA )
    {
        _controlsFITA.hidden    = YES;
        _controlsNFAA.hidden    = NO;
    }
}



//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}



//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"gotoRoundDate"] )
    {
        UINavigationController  *nav       = (UINavigationController  *)segue.destinationViewController;
        RoundDateViewController *roundDate = (RoundDateViewController *)nav.topViewController;
        
        roundDate.delegate = self;
        roundDate.currDate = self.currRound.date;
    }
    else if( [segue.identifier isEqualToString:@"gotoBowInfo"] )
    {
        if( self.editorType == eRoundEditorType_Live )
            [self.archersEyeInfo selectBowFromLiveRound];
        else if( self.editorType == eRoundEditorType_Past )
            [self.archersEyeInfo selectBowFromPastRound];
    }
}



//------------------------------------------------------------------------------
// Protocol: RoundDateViewControllerDelegate
//------------------------------------------------------------------------------
- (void)setDateForCurrentRound:(NSDate *)date
{
    self.currRound.date = date;
}





















#pragma mark - Table view data source

//------------------------------------------------------------------------------
// Number of rows in a section.
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _currRound.numEnds + 1;
}



//------------------------------------------------------------------------------
// Build the rows.
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = nil;
    NSInteger        row           = indexPath.row;

    // End cells
    if( row < _currRound.numEnds )
    {
        EndCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EndCell"];
        
        cell.endNumLabel.text = [NSString stringWithFormat:@"%ld:", (long)row + 1];
        tableViewCell         = cell;
        
        // Initialize the arrow scores
        for( NSInteger i = 0; i < _currRound.numArrowsPerEnd; ++i )
        {
            [self setVisualScore:[_currRound getScoreForEnd:row andArrow:i] forButton:cell.arrowButtons[i]];
            
            [cell.arrowButtons[i] setTag:(row * _currRound.numArrowsPerEnd) + i];
        }
        
        cell.endXLabel.text     = [NSString stringWithFormat:@"%ld", (long)[_currRound getNumberOfArrowsWithScore:11 forEnd:row]];
        cell.endScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)[_currRound getRealScoreForEnd:row]];
        
        if( row == _currEndID )
        {
            [cell.arrowButtons[_currArrowID] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [cell.arrowButtons[_currArrowID] setBackgroundColor:[UIColor greenColor]];
        }

        // Hide any slots we're not using
        if( _currRound.numArrowsPerEnd < 1 )    cell.arrow0Button.hidden = YES;
        if( _currRound.numArrowsPerEnd < 2 )    cell.arrow1Button.hidden = YES;
        if( _currRound.numArrowsPerEnd < 3 )    cell.arrow2Button.hidden = YES;
        if( _currRound.numArrowsPerEnd < 4 )    cell.arrow3Button.hidden = YES;
        if( _currRound.numArrowsPerEnd < 5 )    cell.arrow4Button.hidden = YES;
        if( _currRound.numArrowsPerEnd < 6 )    cell.arrow5Button.hidden = YES;
    }
    // Total cells
    else
    {
        TotalsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TotalsCell"];
        
        cell.totalXsLabel.text    = [NSString stringWithFormat:@"%ld", (long)[_currRound getNumberOfArrowsWithScore:11]];
        cell.totalScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)[_currRound getRealTotalScore]];
        tableViewCell             = cell;
        self.totalsCell           = cell;
    }
    
    return tableViewCell;
}



//------------------------------------------------------------------------------
-               (CGFloat)tableView:(UITableView *)tableView
  estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPathXF
{
    return 38;
}



//------------------------------------------------------------------------------
-       (CGFloat)tableView:(UITableView *)tableView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}






















#pragma mark - Data handling methods


//------------------------------------------------------------------------------
// Returns the current end.
//------------------------------------------------------------------------------
- (EndCell *)getCurrEndCell
{
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currEndID inSection:0]];
    
    if( ![cell isKindOfClass:[EndCell class]] )
        cell = nil;
    
    return (EndCell *)cell;
}



//------------------------------------------------------------------------------
// Returns the current arrow label for the current end.
//------------------------------------------------------------------------------
- (UIButton *)getCurrArrowButton
{
    UIButton *button = nil;
    EndCell  *cell  = [self getCurrEndCell];
    
    button = cell.arrowButtons[_currArrowID];
    
    return button;
}



//------------------------------------------------------------------------------
// Sets the current arrow and end
//------------------------------------------------------------------------------
- (void)setCurrEndID:(NSInteger)currEndID andCurrArrowID:(NSInteger)currArrowID
{
    // Get the score of the currently selected slot
    NSInteger    score  = [_currRound getScoreForEnd:_currEndID andArrow:_currArrowID];
    EndCell     *cell   = [self getCurrEndCell];
    UIButton    *button = cell.arrowButtons[_currArrowID];
    
    // Visually reset the old slot
    [self setVisualScore:score forButton:button];
    
    // Highlight the new slot
    _currEndID   = currEndID;
    _currArrowID = currArrowID;
    [[self getCurrArrowButton] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[self getCurrArrowButton] setBackgroundColor:[UIColor greenColor]];
}



//------------------------------------------------------------------------------
// Increments to the next arrow.
//------------------------------------------------------------------------------
- (void)incArrowID
{
    NSInteger numEnds         = _currRound.numEnds;
    NSInteger numArrowsPerEnd = _currRound.numArrowsPerEnd;

    if( _currEndID < numEnds )
    {
        if( _currArrowID + 1 >= numArrowsPerEnd )
        {
            if( _currEndID + 1 <= numEnds )
            {
                _currArrowID  = 0;
                _currEndID   += 1;
                
                if( _currEndID >= numEnds )
                    _doneButton.enabled = YES;
            }
        }
        else
            _currArrowID += 1;
    }

    [[self getCurrArrowButton] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[self getCurrArrowButton] setBackgroundColor:[UIColor greenColor]];
}



//------------------------------------------------------------------------------
// Decrements to the previous arrow.
//------------------------------------------------------------------------------
- (void)decArrowID
{
//    NSInteger numEnds         = _currRound.numEnds;
    NSInteger numArrowsPerEnd = _currRound.numArrowsPerEnd;
    
    [[self getCurrArrowButton] setBackgroundColor:_buttonErase.currentTitleColor];
    [[self getCurrArrowButton] setBackgroundColor:_buttonErase.backgroundColor];
    
    if( _currArrowID - 1 < 0 )
    {
        _currArrowID  = numArrowsPerEnd - 1;
        _currEndID   -= 1;
        
        // Fix going beyond the beginning
        if( _currEndID < 0 )
        {
            _currArrowID = 0;
            _currEndID   = 0;
        }
    }
    else
        _currArrowID -= 1;
    
    _doneButton.enabled = NO;
    
    [[self getCurrArrowButton] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[self getCurrArrowButton] setBackgroundColor:[UIColor greenColor]];
}



//------------------------------------------------------------------------------
// Sets the score for the current arrow.
//------------------------------------------------------------------------------
- (void)setScoreForCurrArrow:(NSInteger)score
{
    if( _currEndID < _currRound.numEnds )
    {
        EndCell  *cell   = [self getCurrEndCell];
        UIButton *button = cell.arrowButtons[_currArrowID];

        // Set the score in the data
        [_currRound setScore:score forEnd:_currEndID andArrow:_currArrowID];
        
        // Visually set the score
        [self setVisualScore:score forButton:button];
        [self updateTotalScores];
        [self makeEndVisible];
        [self incArrowID];
    }
}



//------------------------------------------------------------------------------
// Changes the color of the current arrow according to the score.
//------------------------------------------------------------------------------
- (void)setVisualScore:(NSInteger)score forButton:(UIButton *)cellButton
{
    UIButton *buttonTemplate;

    if( score >= 11 )
       [cellButton setTitle:@"X" forState:UIControlStateNormal];
    else if( score >= 0 )
        [cellButton setTitle:[NSString stringWithFormat:@"%ld", (long)score] forState:UIControlStateNormal];
    else
        [cellButton setTitle:@"?" forState:UIControlStateNormal];
    
    if( _currRound.type == eRoundType_FITA )
    {
        if( score >= 9 )
            buttonTemplate = _buttonFITAYellow;
        else if( score >= 7 )
            buttonTemplate = _buttonFITARed;
        else if( score >= 5 )
            buttonTemplate = _buttonFITABlue;
        else if( score >= 3 )
            buttonTemplate = _buttonFITABlack;
        else if( score >= 1 )
            buttonTemplate = _buttonFITAWhite;
        else if( score == 0 )
            buttonTemplate = _buttonFITAMiss;
        else
            buttonTemplate = _buttonErase;
    }
    else if( _currRound.type == eRoundType_NFAA )
    {
        if( score >= 5 )
            buttonTemplate = _buttonNFAAWhite;
        else if( score >= 1 )
            buttonTemplate = _buttonNFAABlue;
        else if( score == 0 )
            buttonTemplate = _buttonNFAAMiss;
        else
            buttonTemplate = _buttonErase;
    }
    [cellButton setTitleColor:buttonTemplate.currentTitleColor forState:UIControlStateNormal];
    [cellButton setBackgroundColor:buttonTemplate.backgroundColor];
}



//------------------------------------------------------------------------------
// Nulls out the current arrow.
//------------------------------------------------------------------------------
- (void)eraseScoreForCurrArrow
{
//    EndCell *prevCell  = [self getCurrEndCell];

    if( [_currRound getScoreForEnd:_currEndID andArrow:_currArrowID] == -1 )
        [self decArrowID];

    EndCell  *cell   = [self getCurrEndCell];
    UIButton *button = cell.arrowButtons[_currArrowID];
    
    // Set the score in the data
    [_currRound setScore:-1 forEnd:_currEndID andArrow:_currArrowID];
    
    // Visually set the score
    [self setVisualScore:-1 forButton:button];
    [[self getCurrArrowButton] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[self getCurrArrowButton] setBackgroundColor:[UIColor greenColor]];
    
    [self updateTotalScores];
    
    [self makeEndVisible];
}



//------------------------------------------------------------------------------
// Updates the score totals for the current end.
//------------------------------------------------------------------------------
- (void)updateTotalScores
{
    EndCell     *cell                = [self getCurrEndCell];
    NSInteger    xScore              = [_currRound getNumberOfArrowsWithScore:11 forEnd:_currEndID];
    NSInteger    endScore            = [_currRound getRealScoreForEnd:_currEndID];
    NSInteger    totalXScore         = [_currRound getNumberOfArrowsWithScore:11];
    NSInteger    totalScore          = [_currRound getRealTotalScore];
    
    cell.endXLabel.text              = [NSString stringWithFormat:@"%ld", (long)xScore];
    cell.endScoreLabel.text          = [NSString stringWithFormat:@"%ld", (long)endScore];
    
    _totalsCell.totalXsLabel.text    = [NSString stringWithFormat:@"%ld", (long)totalXScore];
    _totalsCell.totalScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)totalScore];
}



//------------------------------------------------------------------------------
// Scroll to the row to make it visible if necessary.
//------------------------------------------------------------------------------
- (void)makeEndVisible
{
    // Make sure the currently selected arrow is in view
    if( _currEndID < _currRound.numEnds )
    {
        NSArray  *visibleRows = [self.tableView indexPathsForVisibleRows];
        BOOL      visible     = NO;
        NSInteger i           = 0;
        
        // Check if the current end is visible
        for( NSIndexPath *indexPath in visibleRows )
        {
            if( i > 0  &&  i < [visibleRows count] - 2 )
            {
                if( indexPath.section == 0  &&  indexPath.row == _currEndID )
                {
                    visible = YES;
                    break;
                }
            }
            ++i;
        }
        
        // Make it visible if it's not on the screen
        if( !visible )
        {
            NSIndexPath *path = [NSIndexPath indexPathForRow:_currEndID inSection:0];
            [_tableView scrollToRowAtIndexPath:path
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:YES];
        }
    }
}
















#pragma mark - Scoring buttons

//------------------------------------------------------------------------------
- (IBAction)scoreXButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:11];
}



//------------------------------------------------------------------------------
- (IBAction)score10ButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:10];
}



//------------------------------------------------------------------------------
- (IBAction)score9ButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:9];
}



//------------------------------------------------------------------------------
- (IBAction)score8ButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:8];
}



//------------------------------------------------------------------------------
- (IBAction)score7ButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:7];
}



//------------------------------------------------------------------------------
- (IBAction)score6ButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:6];
}



//------------------------------------------------------------------------------
- (IBAction)score5ButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:5];
}



//------------------------------------------------------------------------------
- (IBAction)score4ButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:4];
}



//------------------------------------------------------------------------------
- (IBAction)score3ButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:3];
}



//------------------------------------------------------------------------------
- (IBAction)score2ButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:2];
}



//------------------------------------------------------------------------------
- (IBAction)score1ButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:1];
}



//------------------------------------------------------------------------------
- (IBAction)score0ButtonPressed:(id)sender
{
    [self setScoreForCurrArrow:0];
}



//------------------------------------------------------------------------------
// Button in a EndCell was pressed.  Set our cursor to that arrow.
//------------------------------------------------------------------------------
- (IBAction)arrowButtonPressed:(id)sender
{
    NSInteger buttonTag = [sender tag];
    NSInteger endID     = buttonTag / self.currRound.numArrowsPerEnd;
    NSInteger arrowID   = buttonTag % self.currRound.numArrowsPerEnd;
    
    [self setCurrEndID:endID andCurrArrowID:arrowID];
}



//------------------------------------------------------------------------------
- (IBAction)eraseButtonPressed:(id)sender
{
    [self eraseScoreForCurrArrow];
}



//------------------------------------------------------------------------------
- (IBAction)exitButtonPressed:(id)sender
{
    NSString *unwindSegueName;
    
    if( self.editorType == eRoundEditorType_Live )
    {
        unwindSegueName = @"unwindToLiveRound";
    }
    else if( self.editorType == eRoundEditorType_Past )
    {
        [self.archersEyeInfo endCurrRoundAndDiscard];
        unwindSegueName = @"unwindToPastRounds";
    }
    
    // Programmatically run the unwind segue because we have to wait for the
    // AlertView.
    [self performSegueWithIdentifier:unwindSegueName sender:self];
}



//------------------------------------------------------------------------------
- (IBAction)saveButtonPressed:(id)sender
{
    UIAlertView *confirmDone = [[UIAlertView alloc] initWithTitle:@""
                                                          message:@"Save now?"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Save", nil];
    
    [confirmDone show];
}























#pragma UIAlertView delegate methods

//------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 1 )
    {
        NSString *unwindSegueName;
        
        if( self.editorType == eRoundEditorType_Live )
        {
            [self.archersEyeInfo endLiveRoundAndSave];
            unwindSegueName = @"unwindToLiveRound";
        }
        else if( self.editorType == eRoundEditorType_Past )
        {
            [self.archersEyeInfo endCurrRoundAndSave];
            unwindSegueName = @"unwindToPastRounds";
        }
        
        // Send data to our delegate
        if( self.delegate != nil )
        {
            if( [self.delegate respondsToSelector:@selector(currItemChanged)] )
                [self.delegate currItemChanged];
        }
        
        // Programmatically run the unwind segue because we have to wait for the
        // AlertView.
        [self performSegueWithIdentifier:unwindSegueName sender:self];
    }
}

@end
