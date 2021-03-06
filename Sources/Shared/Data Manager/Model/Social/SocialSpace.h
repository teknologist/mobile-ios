//
// Copyright (C) 2003-2015 eXo Platform SAS.
//
// This is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation; either version 3 of
// the License, or (at your option) any later version.
//
// This software is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this software; if not, write to the Free
// Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
// 02110-1301 USA, or see the FSF site: http://www.fsf.org.
//


#import <Foundation/Foundation.h>

@interface SocialSpace : NSObject {
    NSString * _avatarUrl;
    NSString * _groupId;
    NSString * _spaceUrl;
    NSString * _name;
    NSString * _displayName;
    NSString * _url;
    NSString * _spaceId;

}

@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * spaceUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * spaceId;

@end
