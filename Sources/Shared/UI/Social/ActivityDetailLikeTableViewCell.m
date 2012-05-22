//
//  ActivityDetailLikeTableViewCell.m
//  eXo Platform
//
//  Created by Tran Hoai Son on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityDetailLikeTableViewCell.h"
#import "EGOImageView.h"
#import "MockSocial_Activity.h"
#import <QuartzCore/QuartzCore.h>
#import "SocialActivity.h"
#import "ActivityDetailViewController.h"
#import "LanguageHelper.h"


#define kSeparatorLineLeftMargin 20.0
#define kTopBottomMargin 10.0
#define kLeftRightMargin 10.0
#define kPadding 5.0
#define kNumberOfDisplayedAvatars 4
#define kThreePointAvatarTag 100

@interface ActivityDetailLikeTableViewCell () 

@property (nonatomic, retain) NSMutableArray *likerAvatarImageViews;
- (void)reloadAvatarViews;
- (UIImage *)imageOfThreePointsWithSize:(CGSize)imageSize;
- (EGOImageView *)newAvatarView;


@end

@implementation ActivityDetailLikeTableViewCell

@synthesize socialActivity = _socialActivity;
@synthesize lbMessage=_lbMessage;
@synthesize btnLike=_btnLike, delegate=_delegate;
@synthesize separatorLine = _separatorLine;
@synthesize likerAvatarImageViews = _likerAvatarImageViews;

- (void)dealloc
{
    [_lbMessage release];
    [_btnLike release];
    [_separatorLine release];
    [_socialActivity release];
    [_likerAvatarImageViews release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.likerAvatarImageViews = [NSMutableArray arrayWithCapacity:kNumberOfDisplayedAvatars];
        
        [self.contentView addSubview:self.lbMessage];
        
        [self.contentView addSubview:self.btnLike];
        
        _separatorLine = [[UIView alloc] init];
        [self addSubview:_separatorLine];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentBounds = self.contentView.bounds;
    
    /* ### Configure message label ### */
    CGSize messageSize = [_lbMessage.text sizeWithFont:_lbMessage.font];
    _lbMessage.frame = CGRectMake(kLeftRightMargin, kTopBottomMargin, messageSize.width, messageSize.height); // the message is on the top of the content view
    /* ##### */
    
    /* ### Configure liked button ### */
    float likeButtonWidth = self.btnLike.imageView.image.size.width;
    float likeButtonHeight = self.btnLike.imageView.image.size.height;
    _btnLike.frame = CGRectMake(contentBounds.size.width - kLeftRightMargin - likeButtonWidth, contentBounds.size.height - kTopBottomMargin - likeButtonHeight, likeButtonWidth, likeButtonHeight); // The like button is on the right bottom corner of the content view
    /* ##### */
    
    /* ### Configure avatar view ### */
    float avatarHeight = contentBounds.size.height - kTopBottomMargin * 2 - self.lbMessage.bounds.size.height - kPadding;
    int i = 0;
    for (EGOImageView *avatarView in self.likerAvatarImageViews) {
        // the avatar view is putted consequently on the left bottom corner of the content view
        avatarView.frame = CGRectMake(kLeftRightMargin + i * (avatarHeight + kPadding), contentBounds.size.height - kTopBottomMargin - avatarHeight, avatarHeight, avatarHeight);
        i++;
    }
    /* ##### */
    
        /* ### Configure three point view ### */
        EGOImageView *threePointView = (EGOImageView *)[self.contentView viewWithTag:kThreePointAvatarTag];
        if (!threePointView) {
            threePointView = [self newAvatarView];
            threePointView.image = [self imageOfThreePointsWithSize:CGSizeMake(avatarHeight, avatarHeight)];
            [threePointView setTag:kThreePointAvatarTag];
            [self.contentView addSubview:threePointView];
        }
    if (self.socialActivity.totalNumberOfLikes > kNumberOfDisplayedAvatars) {
        threePointView.frame = CGRectMake(kLeftRightMargin + i * (avatarHeight + kPadding), contentBounds.size.height - kTopBottomMargin - avatarHeight, avatarHeight, avatarHeight);
    } else {
        [threePointView setHidden:YES];
    }
    /* ##### */
    
    /* ### Configure separated line ### */
    self.separatorLine.frame = CGRectMake(kSeparatorLineLeftMargin, self.frame.size.height-6, self.frame.size.width - (2*kSeparatorLineLeftMargin), 1);
    self.separatorLine.backgroundColor = [UIColor colorWithRed:112./255 green:112./255 blue:112./255 alpha:1.];
    self.separatorLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    /* ##### */
}

#pragma mark - getters & setters
- (UILabel *)lbMessage {
    if (!_lbMessage) {
        _lbMessage = [[UILabel alloc] init];
        [_lbMessage setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];
        _lbMessage.backgroundColor = [UIColor clearColor];
        _lbMessage.textColor = [UIColor whiteColor];
    }
    return _lbMessage;
}

- (UIButton *)btnLike {
    if (!_btnLike) {
        _btnLike = [[UIButton alloc] init];
        [_btnLike setImage:[UIImage imageNamed:@"SocialActivityDetailLikeButton.png"] forState:UIControlStateNormal];
        [_btnLike addTarget:self action:@selector(btnLikeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnLike;
}

#pragma mark - Liker avatar management
- (EGOImageView *)newAvatarView {
    EGOImageView *imageView = [[[EGOImageView alloc] init] autorelease];
    //Add the CornerRadius
    [[imageView layer] setCornerRadius:3.0];
    [[imageView layer] setMasksToBounds:YES];
    
    //Add the border
    [[imageView layer] setBorderColor:[UIColor colorWithRed:45./255 green:45./255 blue:45./255 alpha:1.].CGColor];
    CGFloat borderWidth = 1.0;
    [[imageView layer] setBorderWidth:borderWidth];
    
    imageView.placeholderImage = [UIImage imageNamed:@"default-avatar"];
    return imageView;
}

- (void)reloadAvatarViews {
    int i = 0;
    for (SocialUserProfile *user in self.socialActivity.likedByIdentities) {
        if (i == kNumberOfDisplayedAvatars) break;
        EGOImageView *imageView = nil;
        if (i < _likerAvatarImageViews.count) {
           imageView  = [_likerAvatarImageViews objectAtIndex:i];
        } else {
            imageView = [self newAvatarView];
            [_likerAvatarImageViews addObject:imageView];
            [self.contentView addSubview:imageView]; // add the avatar view to the content view
            
        }
        [imageView setImageURLWithoutDownloading:[NSURL URLWithString:user.avatarUrl]];
        i++;
    }
}

// create image for the text "..."
- (UIImage *)imageOfThreePointsWithSize:(CGSize)imageSize {
    NSString *threePoints = @"...";
    UIFont *font = [UIFont boldSystemFontOfSize:20.0];
    CGRect rect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    // this method is available from iOS 4.0
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    
    CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
    [threePoints drawInRect:rect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Activity Cell methods 

- (void)setUserLikeThisActivity:(BOOL)userLikeThisActivity
{
    if(userLikeThisActivity) {
        [_btnLike setImage:[UIImage imageNamed:@"SocialActivityDetailDislikeButton.png"] forState:UIControlStateNormal];
    }else {
        [_btnLike setImage:[UIImage imageNamed:@"SocialActivityDetailLikeButton.png"] forState:UIControlStateNormal];
    }
    
}


- (void)setSocialActivity:(SocialActivity *)socialActivity
{
    [_socialActivity release];
    _socialActivity = [socialActivity retain];
    
    self.lbMessage.text = [NSString stringWithFormat:Localize(@"likeThisActivity"), _socialActivity.totalNumberOfLikes];
    [self setUserLikeThisActivity:_socialActivity.liked];
    [self reloadAvatarViews];
}


-(void)btnLikeAction:(UIButton *)sender
{
    if([_delegate respondsToSelector:@selector(likeDislikeActivity:)])
        [_delegate likeDislikeActivity:self.socialActivity.identityId];
    
}

@end
