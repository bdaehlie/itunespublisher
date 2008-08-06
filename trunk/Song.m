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

#import "Song.h"
#import "IPController.h"

@implementation Song

- (id)initWithDict:(NSDictionary*)songInfo {
  NSMutableString *locationString = [[NSMutableString alloc] init];
  [super init];
  name = [songInfo objectForKey:@"Name"];
  if (name == nil) {
    name = @"";
  }
  [name retain];
  artist = [songInfo objectForKey:@"Artist"];
  if (artist == nil) {
    artist = @"";
  }
  [artist retain];
  album = [songInfo objectForKey:@"Album"];
  if (album == nil) {
    album = @"";
  }
  [album retain];
  kind = [songInfo objectForKey:@"Kind"];
  if (kind == nil) {
    kind = @"";
  }
  [kind retain];
  genre = [songInfo objectForKey:@"Genre"];
  if (genre == nil) {
    genre = @"";
  }
  [genre retain];
	// Cleaning up location is a little more complicated
  if (([songInfo objectForKey:@"Location"] != nil) && ([songInfo objectForKey:@"Location"] != @"")) {
    [locationString appendString:[songInfo objectForKey:@"Location"]];
    [locationString stringByStandardizingPath];
    // cut off the "file://localhost/" and replace the "%20"s
    [locationString setString:[[locationString componentsSeparatedByString:@"%20"] componentsJoinedByString:@" "]];
    if ([locationString length] > 17) {
      [locationString setString:[locationString substringFromIndex:16]];
    }
  }
  else {
    [locationString setString:@""];
  }
  location = [[NSString alloc] initWithString:locationString];
  [locationString release];
  composer = [songInfo objectForKey:@"Composer"];
  if (composer == nil) {
    composer = @"";
  }
  [composer retain];
  comments = [songInfo objectForKey:@"Comments"];
  if (comments == nil) {
    comments = @"";
  }
  [comments retain];
	// plist integer values return NSNumber, convert to ints
  sampleRate = [[songInfo objectForKey:@"Sample Rate"] intValue];
  time = [[songInfo objectForKey:@"Total Time"] intValue] / 1000;
  bitRate = [[songInfo objectForKey:@"Bit Rate"] intValue];
  rating = [[songInfo objectForKey:@"Rating"] intValue] / 20;
  year = [[songInfo objectForKey:@"Year"] intValue];
  playcount = [[songInfo objectForKey:@"Play Count"] intValue];
  trackNumber = [[songInfo objectForKey:@"Track Number"] intValue];
  bpm = [[songInfo objectForKey:@"BPM"] intValue];
  discNumber = [[songInfo objectForKey:@"Disc Number"] intValue];
  discCount = [[songInfo objectForKey:@"Disc Count"] intValue];
  size = [[songInfo objectForKey:@"Size"] intValue];
  return self;
}

-(void)dealloc {
  if (artist != nil) {
    [artist release];
  }
  if (album != nil) {
    [album release];
  }
  if (name != nil) {
    [name release];
  }
  if (genre != nil) {
    [genre release];
  }
  if (location != nil) {
    [location release];
  }
  if (composer != nil) {
    [composer release];
  }
  if (comments != nil) {
    [comments release];
  }
  if (kind != nil) {
    [kind release];
  }
  [super dealloc];
}

/*
 Accessor Methods
*/

-(NSString*)getName {
  return name;
}

-(NSString*)getArtist {
  return artist;
}

-(NSString*)getAlbum {
  return album;
}

-(NSString*)getGenre {
  return genre;
}

-(NSString*)getLocation {
  return location;
}

-(int)getSampleRate {
  return sampleRate;
}

-(int)getTime {
  return time;
}

-(int)getBitRate {
  return bitRate;
}

-(int)getRating {
  return rating;
}

-(int)getPlaycount {
  return playcount;
}

-(int)getTrackNumber {
  return trackNumber;
}

-(int)getYear {
  return year;
}

-(NSString*)getComposer  {
  return composer;
}

-(NSString*)getComments {
  return comments;
}

-(int)getBPM {
  return bpm;
}

-(int)getDiscNumber {
  return discNumber;
}

-(int)getDiscCount {
  return discCount;
}

-(int)getSize {
  return size;
}

-(NSString*)getKind {
  return kind;
}

// returns true if the field given for this song and the argument match
-(BOOL)compareField:(NSString*)field withSong:(Song*)arg {
  if ([field isEqualToString:NSLocalizedString(@"Name", TRANSERROR)]) {
    if ([[arg getName] isEqualToString:name]) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Artist", TRANSERROR)]) {
    if ([[arg getArtist] isEqualToString:artist]) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Album", TRANSERROR)]) {
    if ([[arg getAlbum] isEqualToString:album]) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Location", TRANSERROR)]) {
    if ([[arg getLocation] isEqualToString:location]) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Genre", TRANSERROR)]) {
    if ([[arg getGenre] isEqualToString:genre]) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Kind", TRANSERROR)]) {
    if ([[arg getKind] isEqualToString:kind]) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Composer", TRANSERROR)]) {
    if ([[arg getComposer] isEqualToString:composer]) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Comments", TRANSERROR)]) {
    if ([[arg getComments] isEqualToString:comments]) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"SampleRate", TRANSERROR)]) {
    if ([arg getSampleRate] == sampleRate) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Time", TRANSERROR)]) {
    if ([arg getTime] == time) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"BitRate", TRANSERROR)]) {
    if ([arg getBitRate] == bitRate) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Rating", TRANSERROR)]) {
    if ([arg getRating] == rating) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"PlayCount", TRANSERROR)]) {
    if ([arg getPlaycount] == playcount) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"TrackNumber", TRANSERROR)]) {
    if ([arg getTrackNumber] == trackNumber) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Year", TRANSERROR)]) {
    if ([arg getYear] == year) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"BPM", TRANSERROR)]) {
    if ([arg getBPM] == bpm) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Disc Number", TRANSERROR)]) {
    if ([arg getDiscNumber] == discNumber) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Disc Count", TRANSERROR)]) {
    if ([arg getDiscCount] == discCount) {
      return TRUE;
    }
  }
  else if ([field isEqualToString:NSLocalizedString(@"Size", TRANSERROR)]) {
    if ([arg getSize] == size) {
      return TRUE;
    }
  }
  return FALSE;
}

/*
 Sorting Methods
*/

// This is special - it needs access to the sort order array, pulls weird trick with [IPController getMain]
- (int)mainSort:(Song*)arg {
  NSMutableArray *sortOrder = [[IPController getMain] getSortOrder];
  int i;
  int soc = [sortOrder count];
  for (i = 0; i < soc; i++) {
    if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Name", TRANSERROR)]) {
      if (![[arg getName] isEqualToString:name]) {
        return [self alphanumericSort:name and:[arg getName]];
      }
    }
    if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Kind", TRANSERROR)]) {
      if (![[arg getKind] isEqualToString:kind]) {
        return [self alphanumericSort:kind and:[arg getKind]];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Artist", TRANSERROR)]) {
      if (![[arg getArtist] isEqualToString:artist]) {
        return [self alphanumericSort:artist and:[arg getArtist]];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Album", TRANSERROR)]) {
      if (![[arg getAlbum] isEqualToString:album]) {
        return [self alphanumericSort:album and:[arg getAlbum]];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Location", TRANSERROR)]) {
      if (![[arg getLocation] isEqualToString:location]) {
        return [self alphanumericSort:location and:[arg getLocation]];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Genre", TRANSERROR)]) {
      if (![[arg getGenre] isEqualToString:genre]) {
        return [self alphanumericSort:genre and:[arg getGenre]];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"SampleRate", TRANSERROR)]) {
      if ([arg getSampleRate] != sampleRate) {
        return [self intSort:sampleRate and:[arg getSampleRate] reverse:NO];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Time", TRANSERROR)]) {
      if ([arg getTime] != time) {
        return [self intSort:time and:[arg getTime]  reverse:NO];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"BitRate", TRANSERROR)]) {
      if ([arg getBitRate] != bitRate) {
        return [self intSort:bitRate and:[arg getBitRate]  reverse:NO];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Rating", TRANSERROR)]) {
      if ([arg getRating] != rating) {
        return [self intSort:rating and:[arg getRating]  reverse:YES];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"PlayCount", TRANSERROR)]) {
      if ([arg getPlaycount] != playcount) {
        return [self intSort:playcount and:[arg getPlaycount]  reverse:YES];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"BPM", TRANSERROR)]) {
      if ([arg getBPM] != bpm) {
        return [self intSort:bpm and:[arg getBPM]  reverse:YES];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Disc Number", TRANSERROR)]) {
      if ([arg getDiscNumber] != discNumber) {
        return [self intSort:discNumber and:[arg getDiscNumber]  reverse:NO];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Disc Count", TRANSERROR)]) {
      if ([arg getDiscCount] != discCount) {
        return [self intSort:discCount and:[arg getDiscCount]  reverse:NO];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Size", TRANSERROR)]) {
      if ([arg getSize] != size) {
        return [self intSort:size and:[arg getSize]  reverse:NO];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"TrackNumber", TRANSERROR)]) {
      if ([arg getTrackNumber] != trackNumber) {
        return [self intSort:trackNumber and:[arg getTrackNumber]  reverse:NO];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Year", TRANSERROR)]) {
      if ([arg getYear] != year) {
        return [self intSort:year and:[arg getYear]  reverse:NO];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Composer", TRANSERROR)]) {
      if (![[arg getComposer] isEqualToString:composer]) {
        return [self alphanumericSort:composer and:[arg getComposer]];
      }
    }
    else if ([[sortOrder objectAtIndex:i] isEqualToString:NSLocalizedString(@"Comments", TRANSERROR)]) {
      if (![[arg getComments] isEqualToString:comments]) {
        return [self alphanumericSort:comments and:[arg getComments]];
      }
    }
  }
  return NSOrderedSame;
}

-(int)alphanumericSort:(NSString*)arg and:(NSString*)arg2 {
  if ([arg compare:arg2 options:NSCaseInsensitiveSearch] == NSOrderedAscending) {
    return NSOrderedAscending;
  }
  else if ([arg compare:arg2 options:NSCaseInsensitiveSearch] == NSOrderedDescending) {
    return NSOrderedDescending;
  }
  else {
    return NSOrderedSame;
  }
}

-(int)intSort:(int)arg and:(int)arg2 reverse:(BOOL)reverse {
  if (reverse) {
    if (arg > arg2) {
      return NSOrderedAscending;
    }
    else if (arg < arg2) {
      return NSOrderedDescending;
    }
    else {
      return NSOrderedSame;
    }
  }
  else {
    if (arg > arg2) {
      return NSOrderedDescending;
    }
    else if (arg < arg2) {
      return NSOrderedAscending;
    }
    else {
      return NSOrderedSame;
    }
  }
}

-(int)trackNumberSort:(Song*)s {
  if (trackNumber == 0) {
    return NSOrderedDescending;
  }
  else if ([s getTrackNumber] == 0) {
    return NSOrderedAscending;
  }
  else if (trackNumber < [s getTrackNumber]) {
    return NSOrderedAscending;
  }
  else if (trackNumber > [s getTrackNumber]) {
    return NSOrderedDescending;
  }
  else {
    return NSOrderedSame;
  }
}

@end
