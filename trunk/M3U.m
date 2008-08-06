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

#import "M3U.h"
#import "Song.h"
#import "Common.h"
#import "jaStringMethods.h"

@implementation M3U

+(void)saveM3UTo:(NSString*)filePath playlist:(Playlist*)playlist {
  NSMutableString *exportString = [[NSMutableString alloc] init];
  NSArray *songs = [playlist getSongs];
  int songCount = [songs count];
  BOOL writeResult = FALSE;
  Song *currentSong;
  int i;
  // The following currently crashes the finder.
  // [exportString appendString:@"#EXTM3U\n"];
  for (i = 0; i < songCount; i++) {
    currentSong = [songs objectAtIndex:i];
    [exportString appendString:@"#EXTINF:"];
    [exportString appendString:[jaStringMethods intAsString:[currentSong getTime]]];
    [exportString appendString:@","];
    [exportString appendString:[currentSong getName]];
    [exportString appendString:@"\n"];
    [exportString appendString:[currentSong getLocation]];
    [exportString appendString:@"\n"];
  }
  // save string to file
  if ((![FILEMANAGER fileExistsAtPath:filePath]) || [FILEMANAGER isWritableFileAtPath:filePath]) {
    writeResult = [[jaStringMethods convertToUTF8:exportString] writeToFile:filePath atomically:YES];
    if (!writeResult) {
      [Common handleWriteError];
    }
  }
  else {
    [Common handleWriteError];
  }
}

@end
