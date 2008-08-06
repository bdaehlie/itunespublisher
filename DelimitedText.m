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

#import "DelimitedText.h"
#import "Song.h"
#import "jaStringMethods.h"
#import "Common.h"
#import "IPController.h"

@implementation DelimitedText

+(void)saveDTTo:(NSString*)filePath playlist:(Playlist*)playlist {
  NSMutableString *exportString = [[NSMutableString alloc] init];
  NSMutableArray *songs = [[NSMutableArray alloc] init]; // Mutable for removing dupes
  Song *currentSong;
  BOOL writeResult = FALSE;
  NSArray *fieldOrder = [[IPController getMain] getFieldOrder];
  int i, j, songCount, fieldOrderCount;
  int delimiter = [PREFERENCES integerForKey:prDTDelimiter];
  BOOL usePadding = [PREFERENCES boolForKey:prDTPadding];
  [songs addObjectsFromArray:[playlist getSongs]];
  if (![PREFERENCES boolForKey:priTunesOrdering]) {
    [songs sortUsingSelector:@selector(mainSort:)];
  }
  // Get rid of duplicate rows from output if prefs say so
  if ([PREFERENCES boolForKey:prDTRemoveDupes]) {
    [Common removeDuplicateSongsFromList:songs];
  }
  songCount = [songs count];
  fieldOrderCount = [fieldOrder count];
  for (i = 0; i < songCount; i++) {
    currentSong = [songs objectAtIndex:i];
    for (j = 0; j < fieldOrderCount; j++) {
      if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Name", TRANSERROR)]) {
        [exportString appendString:[currentSong getName]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Artist", TRANSERROR)]) {
        [exportString appendString:[currentSong getArtist]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Album", TRANSERROR)]) {
        [exportString appendString:[currentSong getAlbum]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Location", TRANSERROR)]) {
        [exportString appendString:[currentSong getLocation]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Genre", TRANSERROR)]) {
        [exportString appendString:[currentSong getGenre]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Kind", TRANSERROR)]) {
        [exportString appendString:[currentSong getKind]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Composer", TRANSERROR)]) {
        [exportString appendString:[currentSong getComposer]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Comments", TRANSERROR)]) {
        [exportString appendString:[currentSong getComments]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"SampleRate", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getSampleRate] toMString:exportString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Time", TRANSERROR)]) {
        [exportString appendString:[jaStringMethods getTimeAsString:[currentSong getTime]]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"BitRate", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getBitRate] toMString:exportString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Rating", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getRating] toMString:exportString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"PlayCount", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getPlaycount] toMString:exportString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"TrackNumber", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getTrackNumber] toMString:exportString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Year", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getYear] toMString:exportString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"BPM", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getBPM] toMString:exportString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Disc Number", TRANSERROR)]) {
        if ([currentSong getDiscNumber] < 1) {
          [exportString appendString:@"?"];
        }
        else {
          [jaStringMethods appendInt:[currentSong getDiscNumber] toMString:exportString printZero:NO];
        }
        [exportString appendString:@" of "];
        if ([currentSong getDiscCount] < 1) {
          [exportString appendString:@"?"];
        }
        else {
          [jaStringMethods appendInt:[currentSong getDiscCount] toMString:exportString printZero:NO];
        }
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Size", TRANSERROR)]) {
        [exportString appendString:[jaStringMethods kilobytesToMBString:([currentSong getSize] / 1024)]];
      }
      if (j < (fieldOrderCount - 1)) {
        if (usePadding) {
          [exportString appendString:@" "];
        }
        if (delimiter == dtStarChar) {
          [exportString appendString:@"*"];
        }
        else if (delimiter == dtBarChar) {
          [exportString appendString:@"|"];
        }
        else {
          [exportString appendString:@"\t"];
        }
        if (usePadding) {
          [exportString appendString:@" "];
        }
      }
    }
    [exportString appendString:@"\n"];
  }
  // save string to file
  if ((![FILEMANAGER fileExistsAtPath:filePath]) || [FILEMANAGER isWritableFileAtPath:filePath]) {
    if ([[PREFERENCES stringForKey:prDTEncoding] isEqualToString:@"Latin-1 (ISO 8859-1)"]) {
      writeResult = [[jaStringMethods convertToLatin1:exportString] writeToFile:filePath atomically:YES];
    }
    else if ([[PREFERENCES stringForKey:prDTEncoding] isEqualToString:@"ASCII"]) {
      writeResult = [[jaStringMethods convertToASCII:exportString] writeToFile:filePath atomically:YES];
    }
    else { // UTF-8
      writeResult = [[jaStringMethods convertToUTF8:exportString] writeToFile:filePath atomically:YES];
    }
    if (!writeResult) {
      [Common handleWriteError];
    }
  }
  else {
    [Common handleWriteError];
  }
}

@end
