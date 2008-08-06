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

#import <Cocoa/Cocoa.h>

#define PREFERENCES [NSUserDefaults standardUserDefaults]
#define FILEMANAGER [NSFileManager defaultManager]
#define TRANSERROR @"TRANSLATION ERROR"

/*
 The point of this is to avoid mis-spelling preference key values.
 By always using the NSString value, the compiler catches mis-spellings.
 */

// general prefs
extern NSString *prLastSaveDir;
extern NSString *prMusicDataFolder;
extern NSString *prMusicFolderPath;
extern NSString *prWebServerPath;
extern NSString *prSortOrder;
extern NSString *prFieldOrder;
extern NSString *priTunesOrdering;

// html export prefs
extern NSString *prHTMLRemoveDupes;
extern NSString *prHTMLOddColor;
extern NSString *prHTMLEvenColor;
extern NSString *prHTMLBGColor;
extern NSString *prHTMLTextColor;
extern NSString *prHTMLAddWebServerLinks;
extern NSString *prHTMLHeader;
extern NSString *prHTMLUseStars;
extern NSString *prHTMLMaxSongsPerFile;
extern NSString *prHTMLMaxAlbumsPerFile;
extern NSString *prHTMLFontSize;
extern NSString *prHTMLShouldNumberRows;
extern NSString *prHTMLAlbumBased;

// delimited text prefs
extern NSString *prDTEncoding;
extern NSString *prDTRemoveDupes;
extern NSString *prDTPadding;
extern NSString *prDTDelimiter;

@interface Common : NSObject {

}

+(NSColor*)RGBStringToNSColor:(NSString*)string;
+(NSString*)NSColorToRGBString:(NSColor*)color;
+(void)handleWriteError;
+(void)removeDuplicateSongsFromList:(NSMutableArray*)songlist;

@end
