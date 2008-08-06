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

@interface PrefsPanel : NSObject {
    IBOutlet NSTabView *mainTabView;
    IBOutlet NSTextField *musicPathField;
    IBOutlet NSTextField *serverPathField;
}

// Methods
+(PrefsPanel*)sharedInstance;

// IBActions
-(IBAction)showPanel:(id)sender;
-(IBAction)findMusicFolderPath:(id)sender;
-(IBAction)showLinksPanel:(id)sender;

@end
