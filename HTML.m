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

#import "HTML.h"
#import "Song.h"
#import "jaStringMethods.h"
#import "Common.h"
#import "IPController.h"

@implementation HTML

+(NSString*)getTotalTimeForSongsAsString:(NSArray*)songs {
  int i, totalTime = 0;
  int totalSongs = [songs count];
  for (i = 0; i < totalSongs; i++) {
    totalTime += [[songs objectAtIndex:i] getTime];
  }
  return [jaStringMethods getTimeAsNiceVagueString:totalTime];
}

+(NSString*)getTotalFileSizeForSongsAsString:(NSArray*)songs {
  int i, totalSongs = [songs count];
  unsigned long int totalKilobytes = 0;
  for (i = 0; i < totalSongs; i++) {
    // be careful here because we can easily overflow
    totalKilobytes += [[songs objectAtIndex:i] getSize] / 1024;
  }
  return [jaStringMethods kilobytesToMBString:totalKilobytes];
}

// calculate the number of files needed based on how many songs are being exported
+(int)filesNeededSongs:(int)songs {
  int filesNeeded = 0;
  int maxSongsPerFile = [PREFERENCES integerForKey:prHTMLMaxSongsPerFile];
  if (maxSongsPerFile <= 0) {
    maxSongsPerFile = songs;
  }
  while (songs > 0) {
    filesNeeded++;
    songs -= maxSongsPerFile;
  }
  return filesNeeded;
}

// calculate the number of files needed based on how many albums are being exported
+(int)filesNeededAlbums:(int)albums {
  int filesNeeded = 0;
  int maxAlbumsPerFile = [PREFERENCES integerForKey:prHTMLMaxAlbumsPerFile];
  if (maxAlbumsPerFile <= 0) {
    maxAlbumsPerFile = albums;
  }
  while (albums > 0) {
    filesNeeded++;
    albums -= maxAlbumsPerFile;
  }
  return filesNeeded;
}

+(NSMutableString*)ensureEndSlash:(NSMutableString*)string {
  if ([string length] > 0) {
    if (![[string substringFromIndex:([string length] - 1)] isEqualToString:@"/"]) {
      [string appendString:@"/"];
    }
  }
  else {
    [string appendString:@"/"];
  }
  return string;
}

+(NSMutableString*)ensureStartSlash:(NSMutableString*)string {
  if ([string length] > 0) {
    if (![[string substringWithRange:NSMakeRange(0,1)] isEqualToString:@"/"]) {
      [string insertString:@"/" atIndex:0];
    }
  }
  else {
    [string appendString:@"/"];
  }
  return string;
}

/*
 Take the path to the music file. Drop the path to the music folder from its beginning.
 If it is not in the music folder, return nil.
 */

+(NSString*)dropPath:(NSString*)patha fromPath:(NSString*)pathb {
  int i;
  NSMutableArray *pathCa = [[[NSMutableArray alloc] init] autorelease];
  NSMutableArray *pathCb = [[[NSMutableArray alloc] init] autorelease];
  [pathCa addObjectsFromArray:[patha pathComponents]];
  [pathCb addObjectsFromArray:[pathb pathComponents]];
  if ([pathCa count] > 0) {
    if ([((NSString*)[pathCa objectAtIndex:0]) isEqualToString:@"/"]) {
      [pathCa removeObjectAtIndex:0];
    }
  }
  if ([pathCb count] > 0) {
    if ([((NSString*)[pathCb objectAtIndex:0]) isEqualToString:@"/"]) {
      [pathCb removeObjectAtIndex:0];
    }
  }
  if ([pathCb count] < ([pathCa count] + 1)) {
    return nil;
  }
  for (i = 0; i < [pathCa count]; i++) {
    if (![((NSString*)[pathCa objectAtIndex:i]) isEqualToString:((NSString*)[pathCb objectAtIndex:0])]) {
      return nil;
    }
    else {
      [pathCb removeObjectAtIndex:0];
    }
  }
  return [NSString pathWithComponents:pathCb];
}

+(NSString*)getSongNameLinkedIfNecessary:(Song*)s {
  NSMutableString *linkPath;
  NSMutableString *currentSongString;
  NSString *tempString;
  BOOL includeLinks = [PREFERENCES boolForKey:prHTMLAddWebServerLinks];
  if (includeLinks && (![[s getName] isEqualToString:@""])) {
    currentSongString = [[NSMutableString alloc] init];
    linkPath = [[NSMutableString alloc] init];
    [linkPath appendString:[PREFERENCES stringForKey:prWebServerPath]];
    [HTML ensureEndSlash:linkPath];
    [HTML ensureStartSlash:linkPath];
    tempString = [self dropPath:[PREFERENCES stringForKey:prMusicFolderPath] fromPath:[s getLocation]];
    if (tempString == nil) {
      if ([linkPath length] > 0) {
        [linkPath deleteCharactersInRange:NSMakeRange(0, [linkPath length])];
      }
    }
    else {
      [linkPath appendString:tempString];
    }
    // Get rid of double slashes in the path
    if ([linkPath length] > 0) {
      [jaStringMethods replaceString:@"//" inString:linkPath withString:@"/"];
    }
    if (![linkPath isEqualToString:@""]) {
      [currentSongString appendString:@"<a href=\""];
      [currentSongString appendString:linkPath];
      [currentSongString appendString:@"\">"];
    }
    [currentSongString appendString:[s getName]];
    [currentSongString appendString:@"</a>"];
    [linkPath release];
    [currentSongString autorelease];
    return currentSongString;
  }
  else {
    return [s getName];
  }
}

#pragma mark -

+(NSMutableArray*)getFileCenter:(NSArray*)songs {
  NSMutableArray *songStrings = [[NSMutableArray alloc] init];
  NSMutableString *currentSongString;
  Song *currentSong;
  int songCount = [songs count];
  int i, j, k = 0;
  BOOL oddRow = FALSE;
  BOOL lastRow = FALSE;
  BOOL lastField = FALSE;
  NSArray *fieldOrder = [[IPController getMain] getFieldOrder];
  // Per Song
  for (i = 0; i < songCount; i++) {
    currentSongString = [[NSMutableString alloc] init];
    currentSong = [songs objectAtIndex:i];
    oddRow = !oddRow;
    lastRow = (i == (songCount - 1));
    if (oddRow) {
      [currentSongString appendString:@"<tr class=\"alt\">"];
    }
    else {
      [currentSongString appendString:@"<tr class=\"nonalt\">"];
    }
    // Put all the per-field exception formats here
    // In set playlist formats, fieldOrder is only used for sorting
    // Per Field
    for (j = 0; j < [fieldOrder count]; j++) {
      lastField = (j == ([fieldOrder count] - 1));
      // Add row numbers if asked for
      if (j == 0) {
        if ([PREFERENCES boolForKey:prHTMLShouldNumberRows]) {
          [currentSongString appendString:@"<td>"];
          [currentSongString appendString:[jaStringMethods intAsString:(i + 1)]];
          [currentSongString appendString:@".</td>"];
        }
      }
      // Field pre-text
      [currentSongString appendString:@"<td>"];
      if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Name", TRANSERROR)]) {
        [currentSongString appendString:[HTML getSongNameLinkedIfNecessary:currentSong]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Artist", TRANSERROR)]) {
        [currentSongString appendString:[currentSong getArtist]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Album", TRANSERROR)]) {
        [currentSongString appendString:[currentSong getAlbum]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Location", TRANSERROR)]) {
        [currentSongString appendString:[currentSong getLocation]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Genre", TRANSERROR)]) {
        [currentSongString appendString:[currentSong getGenre]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Composer", TRANSERROR)]) {
        [currentSongString appendString:[currentSong getComposer]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Kind", TRANSERROR)]) {
        [currentSongString appendString:[currentSong getKind]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Comments", TRANSERROR)]) {
        [currentSongString appendString:[currentSong getComments]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"SampleRate", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getSampleRate] toMString:currentSongString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Time", TRANSERROR)]) {
        [currentSongString appendString:[jaStringMethods getTimeAsString:[currentSong getTime]]];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"BitRate", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getBitRate] toMString:currentSongString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Rating", TRANSERROR)]) {
        if ([PREFERENCES boolForKey:prHTMLUseStars] && ([currentSong getRating] != 0)) {
          for (k = 0; k < [currentSong getRating]; k++) {
            [currentSongString appendString:@"*"];
          }
        }
        else {
          [jaStringMethods appendInt:[currentSong getRating] toMString:currentSongString printZero:NO];
        }
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"PlayCount", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getPlaycount] toMString:currentSongString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"TrackNumber", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getTrackNumber] toMString:currentSongString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Year", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getYear] toMString:currentSongString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"BPM", TRANSERROR)]) {
        [jaStringMethods appendInt:[currentSong getBPM] toMString:currentSongString printZero:NO];
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Disc Number", TRANSERROR)]) {
        if ([currentSong getDiscNumber] < 1) {
          [currentSongString appendString:@"?"];
        }
        else {
          [jaStringMethods appendInt:[currentSong getDiscNumber] toMString:currentSongString printZero:NO];
        }
        [currentSongString appendString:@" of "];
        if ([currentSong getDiscCount] < 1) {
          [currentSongString appendString:@"?"];
        }
        else {
          [jaStringMethods appendInt:[currentSong getDiscCount] toMString:currentSongString printZero:NO];
        }
      }
      else if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Size", TRANSERROR)]) {
        [currentSongString appendString:[jaStringMethods kilobytesToMBString:([currentSong getSize] / 1024)]];
      }
      // At end of field
      [currentSongString appendString:@"</td>"];
    }
    // at end of song
    [currentSongString appendString:@"</tr>\n"];
    [songStrings addObject:currentSongString];
    [currentSongString release];
  }
  for (i = 0; i < songCount; i++) {
    [jaStringMethods replaceString:@"&" inString:[songStrings objectAtIndex:i] withString:@"&amp;" ];
  }
  [songStrings autorelease];
  return songStrings;
}

// add nowrap where it belongs... page number, size
+(NSMutableArray*)makeExportStrings:(NSArray*)songs forFilePaths:(NSMutableArray*)filePaths playlistName:(NSString*)playlistName {
  int i, j, k, l, m;
  int totalSongs = [songs count];
  int maxSongsPerFile;
  int filesNeeded = 0;
  NSMutableString *exportString;
  NSMutableArray *fileStrings = [[NSMutableArray alloc] init];
  NSMutableArray *fileLinkingStrings = [[NSMutableArray alloc] init];
  NSMutableArray *fileCenterStrings;
  NSArray *fieldOrder = [[IPController getMain] getFieldOrder];
  // set up maxSongsPerFile as it will be used later
  if ([PREFERENCES integerForKey:prHTMLMaxSongsPerFile] == 0) {
    maxSongsPerFile = totalSongs;
  }
  else {
    maxSongsPerFile = [PREFERENCES integerForKey:prHTMLMaxSongsPerFile];
  }
  // Add headers
  filesNeeded = [HTML filesNeededSongs:totalSongs];
  for (i = 0; i < filesNeeded; i++) {
    exportString = [[NSMutableString alloc] init];
    [exportString appendString:@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\n"];
    [exportString appendString:@"\"http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd\">\n\n"];
    [exportString appendString:@"<html>\n<head>\n<title>"];
    [exportString appendString:playlistName];
    [exportString appendString:@"</title>\n"];
    [exportString appendString:@"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html;charset=UTF-8\">\n"];
    [exportString appendString:@"<style type=\"text/css\">\n<!--\n"];
    [exportString appendString:@"body {font-family: Verdana, Arial, Helvetica, sans-serif; background-color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLBGColor]];
    [exportString appendString:@"; color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLTextColor]];
    [exportString appendString:@";}\n"];
    if ([PREFERENCES integerForKey:prHTMLFontSize] == 1) {
      [exportString appendString:@"td {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: larger;}\n"];
    }
    else if ([PREFERENCES integerForKey:prHTMLFontSize] == -1) {
      [exportString appendString:@"td {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: smaller;}\n"];
    }
    else {
      [exportString appendString:@"td {font-family: Verdana, Arial, Helvetica, sans-serif;}\n"];
    }
    [exportString appendString:@"a:link {color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLTextColor]];
    [exportString appendString:@"; text-decoration: underline;}\n"];
    [exportString appendString:@"a:visited {color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLTextColor]];
    [exportString appendString:@"; text-decoration: underline;}\n"];
    [exportString appendString:@"a:hover {color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLTextColor]];
    [exportString appendString:@"; text-decoration: underline;}\n"];
    [exportString appendString:@"a:active {color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLTextColor]];
    [exportString appendString:@"; text-decoration: underline;}\n"];
    [exportString appendString:@".header {font-size: 140%; text-align: left;}\n"];
    [exportString appendString:@".alt {background: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLOddColor]];
    [exportString appendString:@"}\n"];
    [exportString appendString:@".nonalt {background: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLEvenColor]];
    [exportString appendString:@"}\n"];
    [exportString appendString:@"-->\n</style>\n"];
    [exportString appendString:@"</head>\n<body bgcolor=\"#FFFFFF\">\n"];
    [exportString appendString:@"<table align=\"center\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\">\n"];
    [exportString appendString:@"<tr><td"];
    if ([fieldOrder count] != 1) {
      [exportString appendString:@" colspan=\""];
      if ([PREFERENCES boolForKey:prHTMLShouldNumberRows]) {
        [exportString appendString:[jaStringMethods intAsString:([fieldOrder count])]];
      }
      else {
        [exportString appendString:[jaStringMethods intAsString:[fieldOrder count] - 1]];
      }
      [exportString appendString:@"\""];
    }
    [exportString appendString:@">\n"];
    [exportString appendString:[NSString stringWithFormat:@"<strong class=\"header\">%@: %@", NSLocalizedString(@"Playlist", TRANSERROR), playlistName]];
    [exportString appendString:@"</strong></td>\n<td align=\"right\" colspan=\"1\">"];
    [exportString appendString:NSLocalizedString(@"Page", TRANSERROR)];
    [exportString appendString:@": "];
    [exportString appendString:[jaStringMethods intAsString:(i + 1)]];
    [exportString appendString:@"/"];
    [exportString appendString:[jaStringMethods intAsString:filesNeeded]];
    [exportString appendString:@"</td></tr>"];
    if (![[PREFERENCES objectForKey:prHTMLHeader] isEqualToString:@""]) {
      [exportString appendString:@"<tr><td"];
      if ([fieldOrder count] != 1) {
        [exportString appendString:@" colspan=\""];
        if ([PREFERENCES boolForKey:prHTMLShouldNumberRows]) {
          [exportString appendString:[jaStringMethods intAsString:([fieldOrder count] + 1)]];
        }
        else {
          [exportString appendString:[jaStringMethods intAsString:[fieldOrder count]]];
        }
        [exportString appendString:@"\""];
      }
      [exportString appendString:@">"];
      [exportString appendString:[PREFERENCES objectForKey:prHTMLHeader]];
      [exportString appendString:@"</td></tr>\n"];
    }
    if (filesNeeded > 1) {
      NSMutableString *linkCode = [[NSMutableString alloc] init];
      // Set up new table row
      [linkCode appendString:@"<tr><td"];
      if ([fieldOrder count] != 1) {
        [linkCode appendString:@" colspan=\""];
        if ([PREFERENCES boolForKey:prHTMLShouldNumberRows]) {
          [linkCode appendString:[jaStringMethods intAsString:([fieldOrder count] + 1)]];
        }
        else {
          [linkCode appendString:[jaStringMethods intAsString:[fieldOrder count]]];
        }        
        [linkCode appendString:@"\""];
      }
      [linkCode appendString:@"><p align=\"center\">"];
      [linkCode appendString:NSLocalizedString(@"Page", TRANSERROR)];
      [linkCode appendString:@": "];
      // Add links
      for (m = 1; m <= filesNeeded; m++) {
        if ((i + 1) == m) {
          [linkCode appendString:[jaStringMethods intAsString:m]];
        }
        else {
          [linkCode appendString:@"<a href=\""];
          [linkCode appendString:[[filePaths objectAtIndex:(m - 1)] lastPathComponent]];
          [linkCode appendString:@"\">"];
          [linkCode appendString:[jaStringMethods intAsString:m]];
          [linkCode appendString:@"</a>"];
        }
        if (m != filesNeeded) {
          [linkCode appendString:@" | "];
        }
      }
      // finish new table row
      [linkCode appendString:@"</p></td></tr>\n"];
      [exportString appendString:linkCode];
      [fileLinkingStrings addObject:linkCode];
    }
    // Field headings
    [exportString appendString:@"<tr>"];
    // Add row numbers if asked for
    if ([PREFERENCES boolForKey:prHTMLShouldNumberRows]) {
      [exportString appendString:@"<td><b><i>#</i></b></td>"];
    }
    for (j = 0; j < [fieldOrder count]; j++) {
      [exportString appendString:@"<td><b><i>"];
      if ([[fieldOrder objectAtIndex:j] isEqualToString:NSLocalizedString(@"Rating", TRANSERROR)]) {
        [exportString appendString:[NSLocalizedString(@"Rating", TRANSERROR) stringByAppendingString:@" (1-5)"]];
      }
      else {
        [exportString appendString:[fieldOrder objectAtIndex:j]];
      }
      [exportString appendString:@"</i></b></td>"];
    }
    [exportString appendString:@"</tr>\n"];
    [fileStrings addObject:exportString];
    [exportString release];
  }
  // Make and add center of file strings
  fileCenterStrings = [HTML getFileCenter:songs];
  for (k = 0; k < filesNeeded; k++) {
    for (l = (k * maxSongsPerFile); ((l < ((k + 1) * maxSongsPerFile)) && (l < [fileCenterStrings count])); l++) {
      [[fileStrings objectAtIndex:k] appendString:[fileCenterStrings objectAtIndex:l]];
    }
  }
  // Add footers
  for (k = 0; k < filesNeeded; k++) {
    if ([fileLinkingStrings count] > 0) {
      [[fileStrings objectAtIndex:k] appendString:[fileLinkingStrings objectAtIndex:k]];
    }
    [[fileStrings objectAtIndex:k] appendString:@"</table>\n"];
    // output playlist data
    [[fileStrings objectAtIndex:k] appendString:@"<p align=\"center\"><b><font size=\"-1\">"];
    [[fileStrings objectAtIndex:k] appendString:playlistName];
    [[fileStrings objectAtIndex:k] appendString:@": "];
    [[fileStrings objectAtIndex:k] appendString:[jaStringMethods intAsString:totalSongs]];
    [[fileStrings objectAtIndex:k] appendString:[NSString stringWithFormat:@" %@, ", NSLocalizedString(@"songs", TRANSERROR)]];
    [[fileStrings objectAtIndex:k] appendString:[HTML getTotalTimeForSongsAsString:songs]];
    [[fileStrings objectAtIndex:k] appendString:@", "];
    [[fileStrings objectAtIndex:k] appendString:[HTML getTotalFileSizeForSongsAsString:songs]];
    [[fileStrings objectAtIndex:k] appendString:@"</font></b></p>\n"];
    [[fileStrings objectAtIndex:k] appendString:@"</body>\n</html>\n"];
  }
  [fileStrings autorelease];
  [fileLinkingStrings release];
  return fileStrings;
}

+(NSMutableArray*)makeAlbumBasedExportStrings:(Playlist*)playlist forFilePaths:(NSMutableArray*)filePaths {
  int i, k, l, m;
  int totalTime = 0;
  unsigned long int totalKilobytes = 0;
  NSArray *songs = [playlist getSongs];
  NSArray *albums = [playlist getAlbums];
  NSArray *tmpArray;
  int totalSongs = [songs count];
  int totalAlbums = [albums count];
  int maxAlbumsPerFile;
  int filesNeeded = 0;
  NSString *playlistName = [playlist getName];
  NSMutableString *exportString;
  NSMutableArray *fileStrings = [[NSMutableArray alloc] init];
  NSMutableArray *fileLinkingStrings = [[NSMutableArray alloc] init];
  // calculate time and size
  for (i = 0; i < totalSongs; i++) {
    totalTime += [[songs objectAtIndex:i] getTime];
  }
  for (i = 0; i < totalSongs; i++) {
    // be careful here because we can easily overflow
    totalKilobytes += [[songs objectAtIndex:i] getSize] / 1024;
  }
  // set up maxSongsPerFile as it will be used later
  if ([PREFERENCES integerForKey:prHTMLMaxAlbumsPerFile] == 0) {
    maxAlbumsPerFile = totalAlbums;
  }
  else {
    maxAlbumsPerFile = [PREFERENCES integerForKey:prHTMLMaxAlbumsPerFile];
  }
  // Add headers
  filesNeeded = [HTML filesNeededAlbums:totalAlbums];  
  for (i = 0; i < filesNeeded; i++) {
    exportString = [[NSMutableString alloc] init];
    [exportString appendString:@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\n"];
    [exportString appendString:@"\"http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd\">\n\n<html>\n<head>\n<title>"];
    [exportString appendString:playlistName];
    [exportString appendString:@"</title>\n<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html;charset=UTF-8\">\n"];
    [exportString appendString:@"<style type=\"text/css\">\n<!--\n"];
    [exportString appendString:@"body {font-family: Verdana, Arial, Helvetica, sans-serif; background-color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLBGColor]];
    [exportString appendString:@"; color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLTextColor]];
    [exportString appendString:@";}\n"];
    if ([PREFERENCES integerForKey:prHTMLFontSize] == 1) {
      [exportString appendString:@"td {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: larger;}\n"];
    }
    else if ([PREFERENCES integerForKey:prHTMLFontSize] == -1) {
      [exportString appendString:@"td {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: smaller;}\n"];
    }
    else {
      [exportString appendString:@"td {font-family: Verdana, Arial, Helvetica, sans-serif;}\n"];
    }
    [exportString appendString:@"a:link {color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLTextColor]];
    [exportString appendString:@"; text-decoration: underline;}\n"];
    [exportString appendString:@"a:visited {color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLTextColor]];
    [exportString appendString:@"; text-decoration: underline;}\n"];
    [exportString appendString:@"a:hover {color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLTextColor]];
    [exportString appendString:@"; text-decoration: underline;}\n"];
    [exportString appendString:@"a:active {color: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLTextColor]];
    [exportString appendString:@"; text-decoration: underline;}\n"];    
    [exportString appendString:@".header {font-size: 140%; text-align: left;}\n.alt {background: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLOddColor]];
    [exportString appendString:@"}\n.nonalt {background: #"];
    [exportString appendString:[PREFERENCES stringForKey:prHTMLEvenColor]];
    [exportString appendString:@"}\n-->\n</style>\n"];
    [exportString appendString:@"</head>\n<body bgcolor=\"#FFFFFF\">\n"];
    [exportString appendString:@"<table width=\"100%\" align=\"center\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\">\n"];
    [exportString appendString:@"<tr><td>\n"];
    [exportString appendString:[NSString stringWithFormat:@"<strong class=\"header\">%@: %@", NSLocalizedString(@"Playlist", TRANSERROR), playlistName]];
    [exportString appendString:@"</strong></td>\n<td align=\"right\">"];
    [exportString appendString:NSLocalizedString(@"Page", TRANSERROR)];
    [exportString appendString:@": "];
    [exportString appendString:[jaStringMethods intAsString:(i + 1)]];
    [exportString appendString:@"/"];
    [exportString appendString:[jaStringMethods intAsString:filesNeeded]];
    [exportString appendString:@"</td></tr>"];
    if (![[PREFERENCES objectForKey:prHTMLHeader] isEqualToString:@""]) {
      [exportString appendString:@"<tr><td colspan=\"2\">"];
      [exportString appendString:[PREFERENCES objectForKey:prHTMLHeader]];
      [exportString appendString:@"</td></tr>\n"];
    }
    if (filesNeeded > 1) {
      NSMutableString *linkCode = [[NSMutableString alloc] init];
      // Set up new table row
      [linkCode appendString:@"<tr><td colspan=\"2\"><p align=\"center\">"];
      [linkCode appendString:NSLocalizedString(@"Page", TRANSERROR)];
      [linkCode appendString:@": "];
      // Add links
      for (m = 1; m <= filesNeeded; m++) {
        if ((i + 1) == m) {
          [linkCode appendString:[jaStringMethods intAsString:m]];
        }
        else {
          [linkCode appendString:@"<a href=\""];
          [linkCode appendString:[[filePaths objectAtIndex:(m - 1)] lastPathComponent]];
          [linkCode appendString:@"\">"];
          [linkCode appendString:[jaStringMethods intAsString:m]];
          [linkCode appendString:@"</a>"];
        }
        if (m != filesNeeded) {
          [linkCode appendString:@" | "];
        }
      }
      // finish new table row
      [linkCode appendString:@"</p></td></tr>\n"];
      [exportString appendString:linkCode];
      [fileLinkingStrings addObject:linkCode];
    }
    [fileStrings addObject:exportString];
    [exportString release];
  }
  i = 0; // i tracks the album we're on
  for (k = 0; k < filesNeeded; k++) { // k tracks the filestring we're on
    for (l = 0; (l < maxAlbumsPerFile) && (i < totalAlbums); l++) { // l tracks the number of albums per filestring
      tmpArray = [albums objectAtIndex:i];
      // export the album table
      exportString = [[NSMutableString alloc] init];
      [exportString appendString:@"<tr><td colspan=\"2\">\n"];
      [exportString appendString:@"<table width=\"100%\" border=\"1\" cellpadding=\"5\" cellspacing=\"0\">\n"];
      [exportString appendString:@"<tr><td width=\"40%\" valign=\"top\">\n"];
      // album data here
      [exportString appendString:[NSString stringWithFormat:@"<b><font size=\"+1\">%@</font></b>\n",
        [[tmpArray objectAtIndex:0] getArtist]]]; // just use the artist from the first song
      [exportString appendString:[NSString stringWithFormat:@"<br><b>%@</b>\n<br><i>", [[tmpArray objectAtIndex:0] getAlbum]]];
      if ([[tmpArray objectAtIndex:0] getYear] != nil) {
        [jaStringMethods appendInt:[[tmpArray objectAtIndex:0] getYear] toMString:exportString printZero:NO];
      }
      if ([[tmpArray objectAtIndex:0] getGenre] != nil) {
        if ([[tmpArray objectAtIndex:0] getYear] != nil) {
          [exportString appendString:@", "];
        }
        [exportString appendString:[[tmpArray objectAtIndex:0] getGenre]];
      }
      [exportString appendString:@"</i>\n"];
      [exportString appendString:[NSString stringWithFormat:@"<br><br>%@: ", NSLocalizedString(@"Total Time", TRANSERROR)]];
      [exportString appendString:[HTML getTotalTimeForSongsAsString:tmpArray]];
      [exportString appendString:[NSString stringWithFormat:@"<br>%@: ", NSLocalizedString(@"Total File Size", TRANSERROR)]];
      [exportString appendString:[HTML getTotalFileSizeForSongsAsString:tmpArray]];
      [exportString appendString:@"</td>\n<td width=\"60%\" valign=\"top\">\n"];
      // song table here
      [exportString appendString:@"<table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\">\n"];
      for (m = 0; m < [tmpArray count]; m++) {
        [exportString appendString:@"<tr>\n"];
        // track number row
        if (m % 2) {
          [exportString appendString:@"<td class=\"nonalt\">"];
        }
        else {
          [exportString appendString:@"<td class=\"alt\">"];
        }
        if ([[tmpArray objectAtIndex:m] getTrackNumber] != 0) {
          [jaStringMethods appendInt:[[tmpArray objectAtIndex:m] getTrackNumber] toMString:exportString printZero:NO];
          [exportString appendString:@"."];
        }
        [exportString appendString:@"</td>\n"];
        // song name row
        if (m % 2) {
          [exportString appendString:@"<td class=\"nonalt\" width=\"100%\">"];
        }
        else {
          [exportString appendString:@"<td class=\"alt\" width=\"100%\">"];
        }
        [exportString appendString:[HTML getSongNameLinkedIfNecessary:[tmpArray objectAtIndex:m]]];
        [exportString appendString:@"</td>\n"];
        // track time row
        if (m % 2) {
          [exportString appendString:@"<td class=\"nonalt\">"];
        }
        else {
          [exportString appendString:@"<td class=\"alt\">"];
        }
        [exportString appendString:[jaStringMethods getTimeAsString:[[tmpArray objectAtIndex:m] getTime]]];
        [exportString appendString:@"</td>\n</tr>\n"];
      }
      [exportString appendString:@"</table>\n</td></tr></table>\n</td></tr>\n"];
      [[fileStrings objectAtIndex:k] appendString:exportString];
      [exportString release];
      i++;
    }
  }
  // Add footers
  for (k = 0; k < filesNeeded; k++) {
    if ([fileLinkingStrings count] > 0) {
      [[fileStrings objectAtIndex:k] appendString:[fileLinkingStrings objectAtIndex:k]];
    }
    [[fileStrings objectAtIndex:k] appendString:@"</table>\n"];
    // output playlist data
    [[fileStrings objectAtIndex:k] appendString:@"<p align=\"center\"><b><font size=\"-1\">"];
    [[fileStrings objectAtIndex:k] appendString:playlistName];
    [[fileStrings objectAtIndex:k] appendString:@": "];
    [[fileStrings objectAtIndex:k] appendString:[jaStringMethods intAsString:totalSongs]];
    [[fileStrings objectAtIndex:k] appendString:[NSString stringWithFormat:@" %@, ", NSLocalizedString(@"songs", TRANSERROR)]];
    [[fileStrings objectAtIndex:k] appendString:[jaStringMethods getTimeAsNiceVagueString:totalTime]];
    [[fileStrings objectAtIndex:k] appendString:@", "];
    [[fileStrings objectAtIndex:k] appendString:[jaStringMethods kilobytesToMBString:totalKilobytes]];
    [[fileStrings objectAtIndex:k] appendString:@"</font></b></p>\n"];
    [[fileStrings objectAtIndex:k] appendString:@"</body>\n</html>\n"];
  }
  [fileStrings autorelease];
  [fileLinkingStrings release];
  return fileStrings;
}

+(void)saveHTMLTo:(NSString*)filePath playlist:(Playlist*)playlist albumBased:(BOOL)aBased {
  int i, filesNeeded = 0;
  NSMutableArray *exportStrings;
  NSMutableArray *filePaths = [[[NSMutableArray alloc] init] autorelease];
  NSMutableArray *songs = [[[NSMutableArray alloc] init] autorelease];
  [songs addObjectsFromArray:[playlist getSongs]];
  // Get rid of duplicate rows from output if prefs say so
  if (!aBased && [PREFERENCES boolForKey:prHTMLRemoveDupes]) {
    [Common removeDuplicateSongsFromList:songs];
  }
  // sort the songs if iTunes Ordering isn't requested
  if ((!aBased) && (![PREFERENCES boolForKey:priTunesOrdering])) {
    [songs sortUsingSelector:@selector(mainSort:)];
  }
  // get the number of files needed
  if (aBased) {
    filesNeeded = [HTML filesNeededAlbums:[[playlist getAlbums] count]];
  }
  else {
    filesNeeded = [HTML filesNeededSongs:[songs count]];
  }
  // show alert if too many files are needed
  if (filesNeeded > 75) {
    NSRunCriticalAlertPanel(NSLocalizedString(@"TooManyFilesErrorTitle", TRANSERROR), NSLocalizedString(@"TooManyFilesErrorText", TRANSERROR), NSLocalizedString(@"OKButtonText", TRANSERROR), nil, nil);
  }
  else {
    NSMutableString *pathTMP;
    BOOL fileAlreadyExistsFlag = FALSE;
      // Make file names
    for (i = 0; i < filesNeeded; i++) {
      if (i == 0) {
        [filePaths addObject:filePath];
      }
      else {
        pathTMP = [[NSMutableString alloc] init];
        [pathTMP appendString:[filePath stringByDeletingPathExtension]];
        [pathTMP appendString:[jaStringMethods intAsString:(i + 1)]];
        [pathTMP appendString:@"."];
        [pathTMP appendString:[filePath pathExtension]];
        [filePaths addObject:pathTMP];
        [pathTMP release];
      }
    }
    // Make export strings
    if (aBased) {
      exportStrings = [HTML makeAlbumBasedExportStrings:playlist forFilePaths:filePaths];
    }
    else {
      exportStrings = [HTML makeExportStrings:songs forFilePaths:filePaths playlistName:[playlist getName]];
    }
    // Start at index 1 since 0 is the original name handled by the save panel
    for (i = 1; i < [filePaths count]; i++) {
      if ([FILEMANAGER fileExistsAtPath:[filePaths objectAtIndex:i]]) {
        fileAlreadyExistsFlag = TRUE;
        break;
      }
    }
    // the variable "i" carries over pointing to the offending file
    if (fileAlreadyExistsFlag) {
      NSMutableString *errorString = [[NSMutableString alloc] initWithString:NSLocalizedString(@"FileExistsErrorText1", TRANSERROR)];
      [errorString appendString:[[filePaths objectAtIndex:i] lastPathComponent]];
      [errorString appendString:NSLocalizedString(@"FileExistsErrorText2", TRANSERROR)];
      [errorString appendString:[[filePaths objectAtIndex:0] lastPathComponent]];
      [errorString appendString:@"\"."];
      NSRunCriticalAlertPanel(NSLocalizedString(@"FileExistsErrorTitle", TRANSERROR), [NSString stringWithString:errorString], NSLocalizedString(@"OKButtonText", TRANSERROR), nil, nil);
      [errorString release];
    }
    else {
      BOOL writeResult = FALSE;
      // export files
      for (i = 0; i < [exportStrings count]; i++) {
        writeResult = FALSE;
        writeResult = [[jaStringMethods convertToUTF8:[exportStrings objectAtIndex:i]] writeToFile:[filePaths objectAtIndex:i] atomically:YES];
        if (!writeResult) {
          [Common handleWriteError];
          break;
        }
      }
    }
  }
}

@end
