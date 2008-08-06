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

#import "XMLAccessor.h"
#import "Common.h"

@implementation XMLAccessor

-(id)init {
	[super init];
  // This needs to be called first because other init methods use it
	dataFilePath = nil;
  [self loadData];
	return self;
}

-(void)dealloc {
	if (dataFilePath != nil) {
    [dataFilePath release];
	}
	[data release];
	[tracks release];
	[playlists release];
	[super dealloc];
}

-(void)loadData {
	if (data != nil) {
    [data release];
	}
	data = [[NSDictionary alloc] initWithContentsOfFile:[self getXMLFilePath]];
	tracks = [data objectForKey:@"Tracks"];
	playlists = [data objectForKey:@"Playlists"];
}

-(NSString*)getXMLFilePath {
  NSString *path1 = [@"~/Music/iTunes/iTunes Music Library.xml" stringByStandardizingPath];
  NSString *path2 = [@"~/Documents/iTunes/iTunes Music Library.xml" stringByStandardizingPath];
  if (dataFilePath != nil) {
    if ([FILEMANAGER fileExistsAtPath:dataFilePath]) {
      return dataFilePath;
    }
  }
  if ([FILEMANAGER fileExistsAtPath:[PREFERENCES stringForKey:prMusicDataFolder]]) {
    dataFilePath = [[PREFERENCES stringForKey:prMusicDataFolder] retain];
  }
  else if ([FILEMANAGER fileExistsAtPath:path1]) {
    dataFilePath = [path1 retain];
  }
  else if ([FILEMANAGER fileExistsAtPath:path2]) {
    dataFilePath = [path2 retain];
  }
  else {
    dataFilePath = [[self findFolderManually] retain];
  }
  [PREFERENCES setObject:dataFilePath forKey:prMusicDataFolder];
  return dataFilePath;
}

-(NSString*)findFolderManually {
  int result, findResult;
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseFiles:FALSE];
  [openPanel setCanChooseDirectories:TRUE];
  result = NSRunCriticalAlertPanel(NSLocalizedString(@"DataNotFoundErrorTitle", TRANSERROR), NSLocalizedString(@"DataNotFoundErrorText1", TRANSERROR), NSLocalizedString(@"FindButtonText", TRANSERROR), NSLocalizedString(@"QuitButtonText", TRANSERROR), nil);
  if (result == NSAlertDefaultReturn) {
    NSString *filePath;
    findResult = [openPanel runModalForDirectory:NSHomeDirectory() file:nil types:nil];
    filePath = [[[openPanel filenames] objectAtIndex:0] stringByAppendingPathComponent:@"iTunes Music Library.xml"];
    if ([FILEMANAGER fileExistsAtPath:filePath]) {
      dataFilePath = [filePath retain];
      return dataFilePath;
    }
    else {
      NSRunCriticalAlertPanel(NSLocalizedString(@"DataNotFoundErrorTitle", TRANSERROR), NSLocalizedString(@"DataNotFoundErrorText2", TRANSERROR), NSLocalizedString(@"QuitButtonText", TRANSERROR), nil, nil);
      [NSApp terminate:self];
    }
  }
  else if (result == NSAlertAlternateReturn) {
    [NSApp terminate:self];
  }
  return @"Shut Up The Compiler"; // never get executed, stops warning
}

-(NSArray*)getPlaylistNames {
	int i, playlistCount = [playlists count];
	NSMutableArray *playlistNames = [[[NSMutableArray alloc] init] autorelease];
	for (i = 0; i < playlistCount; i++) {
		[playlistNames addObject:[[playlists objectAtIndex:i] objectForKey:@"Name"]];
	}
	return [NSArray arrayWithArray:playlistNames];
}

-(Playlist*)getPlaylist:(NSString*)a {
	int i, playlistCount = [playlists count];
	// Run through existing playlists to see if the one we want exists
	for (i = 0; i < playlistCount; i++) {
		if ([[[playlists objectAtIndex:i] objectForKey:@"Name"] isEqualToString:a]) {
			return [[[Playlist alloc] initWithDict:[playlists objectAtIndex:i] andTracks:tracks] autorelease];
		}
	}
	return nil;
}

@end
