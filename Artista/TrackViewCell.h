//
//  TrackViewCell.h
//  Artista
//
//  Created by Chloe Stars on 9/10/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackViewCell : UITableViewCell {
	IBOutlet UILabel *trackName;
	IBOutlet UILabel *duration;
	IBOutlet UILabel *listeningAndCount;
}

@property IBOutlet UILabel *trackName;
@property IBOutlet UILabel *duration;
@property IBOutlet UILabel *listeningAndCount;
@property (nonatomic, copy) NSString *reuseIdentifier;

+ (id) cellFromNib;

@end
