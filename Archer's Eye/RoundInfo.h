//
//  RoundInfo.h
//  Archer's Eye
//
//  Created by Alex de Vera on 3/7/15.
//  Copyright (c) 2015 Alex de Vera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoundInfo : NSObject
{
    NSDate         *_date;
    NSInteger       _numEnds;
    NSInteger       _numArrowsPerEnd;
    NSMutableArray *_endScores;
}

- (id)initWithDate:(NSDate *)date
        andNumEnds:(NSInteger)numEnds
   andArrowsPerEnd:(NSInteger)numArrowsPerEnd;

- (void)setScore:(NSInteger)score forEnd:(NSInteger)endID andArrow:(NSInteger)arrowID;
- (NSInteger)getScoreForEnd:(NSInteger)endID andArrow:(NSInteger)arrowID;
- (NSInteger)getScoreForEnd:(NSInteger)endID;
- (NSInteger)getTotalScoreUpToEnd:(NSInteger)endID;
- (NSInteger)getTotalArrows;
- (NSInteger)getTotalScore;

@property (strong)   NSDate         *date;
@property (strong)   NSMutableArray *endScores;
@property (readonly) NSInteger       numEnds;
@property (readonly) NSInteger       numArrowsPerEnd;

@end
