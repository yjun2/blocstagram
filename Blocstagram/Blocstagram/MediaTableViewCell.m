//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Yong Jun on 5/5/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "User.h"
#import "Comment.h"

@interface MediaTableViewCell()

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;

@end

static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *linkColor;
static UIColor *firstComment;
static NSParagraphStyle *paragraphStyle;
static NSParagraphStyle *paragraphRightAlignedStyle;

@implementation MediaTableViewCell

+ (void) load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
    commentLabelGray = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1];
    firstComment = [UIColor colorWithRed:0.255 green:0.128 blue:0.0 alpha:1];
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1];
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent= -20;
    mutableParagraphStyle.paragraphSpacing = 5;
    
    NSMutableParagraphStyle *mutableParagraphRightAlignedStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphRightAlignedStyle.headIndent = 20.0;
    mutableParagraphRightAlignedStyle.firstLineHeadIndent = 20.0;
    mutableParagraphRightAlignedStyle.tailIndent= -20;
    mutableParagraphRightAlignedStyle.paragraphSpacing = 5;
    mutableParagraphRightAlignedStyle.alignment = NSTextAlignmentRight;
    
    paragraphStyle = mutableParagraphStyle;
    paragraphRightAlignedStyle = mutableParagraphRightAlignedStyle;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.mediaImageView = [[UIImageView alloc] init];
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel]) {
            [self.contentView addSubview:view];
        }
    }
    
    return self;
}

- (NSAttributedString *) usernameAndCaptionString {
    CGFloat usernameFontSize = 15;
    
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    NSMutableAttributedString *mutableUsernameCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName: [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName: paragraphStyle}];
    
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    // assignement #2 - Increase the kerning of the image caption
    CGFloat spacing = 5;
    NSRange captionRange = [baseString rangeOfString:self.mediaItem.caption];
    [mutableUsernameCaptionString addAttribute:NSKernAttributeName value:@(spacing) range:captionRange];
    
    return mutableUsernameCaptionString;
}

- (NSAttributedString *) commentString {
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    NSUInteger index = 0;
    for (Comment *comment in self.mediaItem.comments) {
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        
        NSMutableAttributedString *oneCommentString = nil;
        
        // assignment #1 - Change the color of the first comment to orange
        if (index == 0) { // change the first comment color to orange
            oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSForegroundColorAttributeName : firstComment, NSParagraphStyleAttributeName : paragraphStyle}];
        } else {
            // assignment #3 - Right align every other comment
            if (index % 2 == 0) {
                oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
            } else {
                oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphRightAlignedStyle}];
            }
            
        }
        
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
        [commentString appendAttributedString:oneCommentString];
        
        index++;
    }
    
    return commentString;
}

- (CGSize) sizeOfString:(NSAttributedString *)string {
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 40, 0.0);
    CGRect sizeRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    sizeRect.size.height += 20;
    sizeRect = CGRectIntegral(sizeRect);
    return sizeRect.size;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageHeight = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
    self.mediaImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), imageHeight);
    
    CGSize sizeOfUsernameAndCaptionLabel = [self sizeOfString:self.usernameAndCaptionLabel.attributedText];
    self.usernameAndCaptionLabel.frame = CGRectMake(0, CGRectGetMaxY(self.mediaImageView.frame), CGRectGetWidth(self.contentView.bounds), sizeOfUsernameAndCaptionLabel.height);
    
    CGSize sizeOfCommentLabel = [self sizeOfString:self.commentLabel.attributedText];
    self.commentLabel.frame = CGRectMake(0, CGRectGetMaxY(self.usernameAndCaptionLabel.frame), CGRectGetWidth(self.bounds), sizeOfCommentLabel.height);
    
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
    
}


- (void)setMediaItem:(Media *)mediaItem {
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    
}

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    layoutCell.frame = CGRectMake(0, 0, width, CGFLOAT_MAX);
    layoutCell.mediaItem = mediaItem;
    [layoutCell layoutSubviews];
    return CGRectGetMaxY(layoutCell.commentLabel.frame);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
