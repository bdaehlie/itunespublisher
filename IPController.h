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

/*
This app is dedicated to the DJs and musicians that make life so much better.
The joy of programming is half code and half background music.
*/

#import <Cocoa/Cocoa.h>
#import "XMLAccessor.h"

@interface IPController : NSObject {
  // main window
  IBOutlet NSPopUpButton *playlistPopUp;
  IBOutlet NSButton *exportButton;
  IBOutlet NSTabView *mainTabView;
  
  // html tab
  IBOutlet NSColorWell *htmlOddColorWell;
  IBOutlet NSColorWell *htmlEvenColorWell;
  IBOutlet NSColorWell *htmlBGColorWell;
  IBOutlet NSColorWell *htmlTextColorWell;
  IBOutlet NSButton *htmlColorDefaultsButton;
  IBOutlet NSPopUpButton *htmlFontSizePopUp;
  IBOutlet NSButton *htmlUseStarsButton;
  IBOutlet NSPopUpButton *htmlMaxSongsPerFilePopUp;
  IBOutlet NSPopUpButton *htmlMaxAlbumsPerFilePopUp;
  IBOutlet NSButton *htmlIncludeRowNumbersButton;
  IBOutlet NSTextView *htmlHeaderTextField;
  IBOutlet NSButton *htmlRemoveDupesButton;
  IBOutlet NSButton *htmlIncludeLinksButton;
  IBOutlet NSButton *htmlSetUpLinkingButton;
  IBOutlet NSButton *htmlAlbumBasedExportButton;
  
  // delimited text tab
  IBOutlet NSPopUpButton *dtEncodingPopUp;
  IBOutlet NSButton *dtDefaultEncodingButton;
  IBOutlet NSButton *dtRemoveDupesButton;
  IBOutlet NSPopUpButton *dtDelimiterPopUp;
  IBOutlet NSButton *dtPaddingButton;
  
  // data field and sort selection window
  IBOutlet NSTableView *optionsView;
	IBOutlet NSTableView *fieldView;
	IBOutlet NSTableView *sortView;
  IBOutlet NSButton *iTunesOrderingButton;
  IBOutlet NSButton *saveButton;
  IBOutlet NSButton *addFieldButton;
	IBOutlet NSButton *removeFieldButton;
  	
	@private
	XMLAccessor *XMLAccess;
	NSMutableArray *exportOptions;
	NSMutableArray *fieldOrder;
  NSMutableArray *sortOrder;
  BOOL fieldSelectOK;
}

+(IPController*)getMain;
-(NSMutableArray*)getFieldOrder;
-(NSMutableArray*)getSortOrder;

-(IBAction)iTunesOrderingStateChanged:(id)sender;
-(IBAction)endFieldSelect:(id)sender;
-(IBAction)export:(id)sender;
-(IBAction)refreshLibrarySelector:(id)sender;
-(IBAction)showPrefs:(id)sender;
-(IBAction)setHTMLColorsToDefault:(id)sender;
-(IBAction)setUpHTMLLinking:(id)sender;
-(IBAction)setDTEncodingToDefault:(id)sender;
-(IBAction)toggleAlbumExport:(id)sender;
-(IBAction)addField:(id)sender;
-(IBAction)removeField:(id)sender;
-(IBAction)saveExport:(id)sender;
-(IBAction)doNothing:(id)sender;
-(BOOL)validateMenuItem:(NSMenuItem *)anItem;

@end
