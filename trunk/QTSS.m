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

#import "QTSS.h"
#import "Song.h"
#import "Common.h"
#import "jaStringMethods.h"

@implementation QTSS

+(void)saveQTSSTo:(NSString*)filePath playlist:(Playlist*)playlist {
  NSMutableString *exportString = [[NSMutableString alloc] init];
  NSArray *songs = [playlist getSongs];
  BOOL writeResult = FALSE;
  int songCount = [songs count];
  Song *currentSong;
  int playNumber, i;
  [exportString appendString:@"*PLAY-LIST*\n#\n# Created by iTunes Publisher\n#\n\"*PLAY-LIST*\" 10\n"];
  for (i = 0; i < songCount; i++) {
    currentSong = [songs objectAtIndex:i];
    playNumber = [currentSong getRating];
    // no rating defaults to 5 in QTSS
    if (playNumber == 0) {
      playNumber = 5;
    }
    [exportString appendString:@"\""];
    [exportString appendString:[currentSong getLocation]];
    [exportString appendString:@"\" "];
    [exportString appendString:[jaStringMethods intAsString:playNumber]];
    [exportString appendString:@"\n"];
  }
  [exportString appendString:@"\n"];
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
