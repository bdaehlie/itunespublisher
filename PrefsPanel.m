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

#import "PrefsPanel.h"
#import "IPController.h"
#import "Common.h"

@implementation PrefsPanel

static PrefsPanel *sharedInstance = nil;

+ (PrefsPanel*)sharedInstance {
  return sharedInstance ? sharedInstance : [[self alloc] init];
}

- (id)init {
  if (sharedInstance) {
    [self dealloc];
  }
  else {
    sharedInstance = [super init];
  }
  return sharedInstance;
}

- (void)awakeFromNib {
  [musicPathField setStringValue:[PREFERENCES stringForKey:prMusicFolderPath]];
  [serverPathField setStringValue:[PREFERENCES stringForKey:prWebServerPath]];
}

/*
 ACTIONS
 */

-(IBAction)showPanel:(id)sender {
  if (!mainTabView) {
    NSWindow *theWindow;
    [NSBundle loadNibNamed:@"Prefs" owner:self];
    theWindow = [mainTabView window];
    [theWindow setMenu:nil];
    [theWindow center];
  }
  [[mainTabView window] makeKeyAndOrderFront:nil];
}

-(IBAction)showLinksPanel:(id)sender {
  [self showPanel:sender];
  // Select the links tab
  [mainTabView selectTabViewItemAtIndex:0];
}

+(NSString*)getFolderPathWithOpenPanel {
  NSOpenPanel *op = [NSOpenPanel openPanel];
  [op setCanChooseFiles:NO];
  [op setAllowsMultipleSelection:NO];
  [op setResolvesAliases:YES];
  [op setCanChooseDirectories:YES];
  if ([op runModalForTypes:nil] == NSOKButton) {
    return [[op filenames] objectAtIndex:0];
  }
  else {
    return nil;
  }
}

-(IBAction)findMusicFolderPath:(id)sender {
  NSString *path = [PrefsPanel getFolderPathWithOpenPanel];
  if (path != nil) {
    [PREFERENCES setObject:path forKey:prMusicFolderPath];
    [musicPathField setStringValue:path];
  }
}

-(void)controlTextDidChange:(NSNotification *)aNotification {
  if ([aNotification object] == musicPathField) {
    [PREFERENCES setObject:[musicPathField stringValue] forKey:prMusicFolderPath];
  }
  else if ([aNotification object] == serverPathField) {
    [PREFERENCES setObject:[serverPathField stringValue] forKey:prWebServerPath];
  }
}

@end
