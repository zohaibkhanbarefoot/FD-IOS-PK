//
//  cell_notification.m
//  EddystoneScannerSample
//
//  Created by user on 4/01/2017.
//
//

#import "cell_notification.h"

@implementation cell_notification

- (void)awakeFromNib{
    [super awakeFromNib];
    for (NSLayoutConstraint *cellConstraint in self.constraints) {
        [self removeConstraint:cellConstraint];
        id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
        id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
        NSLayoutConstraint *contentViewConstraint =
        [NSLayoutConstraint constraintWithItem:firstItem
                                     attribute:cellConstraint.firstAttribute
                                     relatedBy:cellConstraint.relation
                                        toItem:seccondItem
                                     attribute:cellConstraint.secondAttribute
                                    multiplier:cellConstraint.multiplier
                                      constant:cellConstraint.constant];
        [self.contentView addConstraint:contentViewConstraint];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) setText: (NSString *) text
{
    _lbl_title.text = text;
}
- (void) setText_message: (NSString *) text
{
    _lbl_message.text = text;
}


@end
