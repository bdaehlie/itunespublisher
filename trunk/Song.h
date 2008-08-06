/*
 This file is part of iTunes Publisher.
 
 iTunes Publisher is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 iTunes Publisher is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with iTunes Publisher; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 Copyright (c) 2001-2004 Josh Aas.
 */

#import <Foundation/Foundation.h>

@interface Song : NSObject {
  @private
	NSString *artist;
	NSString *album;
	NSString *name;
	NSString *genre;
	NSString *location;
  NSString *composer;
  NSString *comments;
  NSString *kind;
	int sampleRate;
	int time;
	int bitRate;
	int rating;
	int playcount;
	int trackNumber;
  int year;
  int bpm;
  int discNumber;
  int discCount;
  int size;
}

-(id)initWithDict:(NSDictionary*)songInfo;
-(void)dealloc;
-(NSString*)getName;
-(NSString*)getArtist;
-(NSString*)getAlbum;
-(NSString*)getGenre;
-(NSString*)getLocation;
-(NSString*)getKind;
-(int)getSampleRate;
-(int)getTime;
-(int)getBitRate;
-(int)getRating;
-(int)getPlaycount;
-(int)getTrackNumber;
-(int)getYear;
-(int)getBPM;
-(int)getDiscNumber;
-(int)getDiscCount;
-(int)getSize;
-(NSString*)getComposer;
-(NSString*)getComments;
-(BOOL)compareField:(NSString*)field withSong:(Song*)arg;
-(int)mainSort:(id)arg;
-(int)alphanumericSort:(NSString*)arg and:(NSString*)arg2;
-(int)intSort:(int)arg and:(int)arg2 reverse:(BOOL)reverse;
-(int)trackNumberSort:(Song*)s;

@end
