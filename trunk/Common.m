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

#import "Common.h"
#import "IPController.h"

// general prefs
NSString *prLastSaveDir = @"LastSaveDir";
NSString *prMusicDataFolder = @"iTunes Data Folder";
NSString *prMusicFolderPath = @"Music Folder Path";
NSString *prWebServerPath = @"Web Server Path";
NSString *prSortOrder = @"SortOrder";
NSString *prFieldOrder = @"FieldOrder";
NSString *priTunesOrdering = @"iTunesOrdering";

// html export prefs
NSString *prHTMLRemoveDupes = @"HTMLRemoveDupes";
NSString *prHTMLOddColor = @"HTMLOddColor";
NSString *prHTMLEvenColor = @"HTMLEvenColor";
NSString *prHTMLBGColor = @"HTMLBGColor";
NSString *prHTMLTextColor = @"HTMLTextColor";
NSString *prHTMLAddWebServerLinks = @"HTMLAddWebServerLinks";
NSString *prHTMLHeader = @"HTMLHeader";
NSString *prHTMLUseStars = @"HTMLUseStars";
NSString *prHTMLMaxSongsPerFile = @"HTMLMaxSongsPerFile";
NSString *prHTMLMaxAlbumsPerFile = @"HTMLMaxAlbumsPerFile";
NSString *prHTMLFontSize = @"HTMLFontSize";
NSString *prHTMLShouldNumberRows = @"HTMLShouldNumberRows";
NSString *prHTMLAlbumBased = @"HTMLAlbumBased";

// delimited text prefs
NSString *prDTEncoding = @"DelimitedTextEncoding";
NSString *prDTRemoveDupes = @"DelimitedTextRemoveDupes";
NSString *prDTPadding = @"DelimitedTextPadding";
NSString *prDTDelimiter = @"DelimitedTextDelimiter";

@implementation Common

+(NSColor*)RGBStringToNSColor:(NSString*)string {
  NSColor *exportColor;
  float redVal = ((float)strtol([[string substringWithRange:NSMakeRange(0, 2)] cString], nil, 16) / 255);
  float greenVal = ((float)strtol([[string substringWithRange:NSMakeRange(2, 2)] cString], nil, 16) / 255);
  float blueVal = ((float)strtol([[string substringWithRange:NSMakeRange(4, 2)] cString], nil, 16) / 255);
  exportColor = [NSColor colorWithDeviceRed:redVal green:greenVal blue:blueVal alpha:1.0];
  return exportColor;
}

+(NSString*)NSColorToRGBString:(NSColor*)color {
  NSMutableString *colorString = [[NSMutableString alloc] init];
  char buf[3];
  color = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
  sprintf(buf, "%02x", (int)([color redComponent] * 255));
  [colorString appendString:[NSString stringWithCString:buf]];
  sprintf(buf, "%02x", (int)([color greenComponent] * 255));
  [colorString appendString:[NSString stringWithCString:buf]];
  sprintf(buf, "%02x", (int)([color blueComponent] * 255));
  [colorString appendString:[NSString stringWithCString:buf]];
  [colorString autorelease];
  return [NSString stringWithString:colorString];
}

+(void)handleWriteError {
  NSBeep();
  NSRunCriticalAlertPanel(NSLocalizedString(@"WriteErrorTitle", TRANSERROR), NSLocalizedString(@"WriteErrorText", TRANSERROR), NSLocalizedString(@"OKButtonText", TRANSERROR), nil, nil);
}

+(void)removeDuplicateSongsFromList:(NSMutableArray*)songlist {
  NSArray *fieldOrder = [[IPController getMain] getFieldOrder];
  int fieldCount = [fieldOrder count];
  int songCount = [songlist count];
  int i, j, k;
  for (i = 0; i < (songCount - 1); i++) {
    for (j = i + 1; j < songCount; j++) {
      for (k = 0; k < fieldCount; k++) {
        if (![[songlist objectAtIndex:i] compareField:[fieldOrder objectAtIndex:k] withSong:[songlist objectAtIndex:j]]) {
          break;
        }
      }
      if (k == fieldCount) {
        [songlist removeObjectAtIndex:j];
        songCount--;
        j--;
      }
    }
  }
}

@end
