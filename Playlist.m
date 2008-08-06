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

#import "Playlist.h"

@implementation Playlist

// pass a playlist dictionary
-(id)initWithDict:(NSDictionary*)playlistDict andTracks:(NSDictionary*)trackDict {
	int i, j, count;
  BOOL exists;
	NSArray *songList;
	NSString *currentSongID;
	NSDictionary *currentSongInfo;
	Song *currentSong;
  Song *secondCurrentSong;
  // init superclass
	[super init];
  // init songs and playlist data
	songs = [[NSMutableArray alloc] init];
	name = [[playlistDict objectForKey:@"Name"] retain];
	songList = [playlistDict objectForKey:@"Playlist Items"];
  count = [songList count];
	for (i = 0; i < count; i++) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    currentSongID = [[[songList objectAtIndex:i] objectForKey:@"Track ID"] stringValue];
    currentSongInfo = [trackDict objectForKey:currentSongID];
    currentSong = [[Song alloc] initWithDict:currentSongInfo];
    [songs addObject:currentSong];
    [currentSong release];
    [pool release];
	}
  // init album list
  albums = [[NSMutableArray alloc] init];
  // loop through each song, don't bother with songs that don't have an album
  count = [songs count];
  for (i = 0; i < count; i++) {
    if (![[[songs objectAtIndex:i] getAlbum] isEqualToString:@""]) {
      // see if the song's album exists in the album array
      exists = FALSE;
      currentSong = [songs objectAtIndex:i];
      for (j = 0; j < [albums count]; j++) {
        // see if the song is in the same album as the first song in the album
        secondCurrentSong = [[albums objectAtIndex:j] objectAtIndex:0];
        if ([[currentSong getAlbum] isEqualToString:[secondCurrentSong getAlbum]]) {
          exists = TRUE;
          break;
        }
      }
      if (exists) {
        // add it to the album
        [[albums objectAtIndex:j] addObject:currentSong];
      }
      else {
        // make a new album
        [albums addObject:[NSMutableArray arrayWithObject:currentSong]];
      }
    }
  }
  // go through each album and put the songs in order
  count = [albums count];
  for (i = 0; i < count; i++) {
    // sort tempArray by track number
    [[albums objectAtIndex:i] sortUsingSelector:@selector(trackNumberSort:)];
  }
	return self;
}

-(void)dealloc {
	[name release];
	[songs release];
  [albums release];
	[super dealloc];
}

-(NSString*)getName {
	return name;
}

-(NSArray*)getSongs {
	return [NSArray arrayWithArray:songs];
}

-(NSArray*)getAlbums {
  return [NSArray arrayWithArray:albums];
}

@end
