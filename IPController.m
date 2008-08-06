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

#import "IPController.h"
#import "PrefsPanel.h"
#import "jaStringMethods.h"
#import "Common.h"
#import "M3U.h"
#import "QTSS.h"
#import "HTML.h"
#import "DelimitedText.h"

#define DEFAULT_ODD_COLOR @"e7e7e7"
#define DEFAULT_EVEN_COLOR @"FFFFFF"
#define DEFAULT_BG_COLOR @"FFFFFF"
#define DEFAULT_TEXT_COLOR @"000000"

@implementation IPController

IPController *mainController;

// tells which tab is for each format
enum {
  ipHTML = 0,
  ipDelimitedText = 1,
  ipM3U = 2,
  ipQTSS = 3
};

// For referencing controller object
+ (IPController*)getMain {
  return mainController;
}

+ (void)initialize {
  NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
  [defaultPrefs setObject:@"NO" forKey:prHTMLRemoveDupes];
  [defaultPrefs setObject:DEFAULT_ODD_COLOR forKey:prHTMLOddColor];
  [defaultPrefs setObject:DEFAULT_EVEN_COLOR forKey:prHTMLEvenColor];
  [defaultPrefs setObject:DEFAULT_BG_COLOR forKey:prHTMLBGColor];
  [defaultPrefs setObject:DEFAULT_TEXT_COLOR forKey:prHTMLTextColor];
  [defaultPrefs setObject:@"UTF-8" forKey:prDTEncoding];
  [defaultPrefs setObject:@"~" forKey:prLastSaveDir];
  [defaultPrefs setObject:@"NO" forKey:priTunesOrdering];
  [defaultPrefs setObject:@"NO" forKey:prHTMLAddWebServerLinks];
  [defaultPrefs setObject:@"" forKey:prHTMLHeader];
  [defaultPrefs setObject:@"NO" forKey:prHTMLUseStars];
  [defaultPrefs setObject:@"0" forKey:prHTMLMaxSongsPerFile];
  [defaultPrefs setObject:@"0" forKey:prHTMLMaxAlbumsPerFile];
  [defaultPrefs setObject:@"~/Music/iTunes" forKey:prMusicDataFolder];
  [defaultPrefs setObject:@"" forKey:prMusicFolderPath];
  [defaultPrefs setObject:@"" forKey:prWebServerPath];
  [defaultPrefs setObject:@"0" forKey:prHTMLFontSize];
  [defaultPrefs setObject:@"YES" forKey:prHTMLShouldNumberRows];
  [defaultPrefs setObject:@"NO" forKey:prHTMLAlbumBased];
  [defaultPrefs setObject:@"NO" forKey:prDTRemoveDupes];
  [defaultPrefs setObject:@"NO" forKey:prDTPadding];
  [defaultPrefs setObject:@"0" forKey:prDTDelimiter];
  [defaultPrefs setObject:[NSMutableArray arrayWithCapacity:0] forKey:prSortOrder];
  [defaultPrefs setObject:[NSMutableArray arrayWithCapacity:0] forKey:prFieldOrder];
  [PREFERENCES registerDefaults:defaultPrefs];
}

-(void)dealloc {
  [XMLAccess release];
  [exportOptions release];
  [fieldOrder release];
  [sortOrder release];
  [super dealloc];
}

-(void)setUpControls {
  // set up export field and sorting options window controls
  exportOptions = [[NSMutableArray arrayWithObjects:NSLocalizedString(@"Artist", TRANSERROR), NSLocalizedString(@"Album", TRANSERROR), NSLocalizedString(@"Name", TRANSERROR), NSLocalizedString(@"Genre", TRANSERROR), NSLocalizedString(@"Location", TRANSERROR), NSLocalizedString(@"SampleRate", TRANSERROR), NSLocalizedString(@"Time", TRANSERROR), NSLocalizedString(@"BitRate", TRANSERROR), NSLocalizedString(@"Rating", TRANSERROR), NSLocalizedString(@"PlayCount", TRANSERROR), NSLocalizedString(@"TrackNumber", TRANSERROR), NSLocalizedString(@"Composer", TRANSERROR), NSLocalizedString(@"Comments", TRANSERROR), NSLocalizedString(@"Year", TRANSERROR), NSLocalizedString(@"Kind", TRANSERROR), NSLocalizedString(@"BPM", TRANSERROR), NSLocalizedString(@"Disc Number", TRANSERROR), NSLocalizedString(@"Size", TRANSERROR), nil] retain];
  [exportOptions sortUsingSelector:@selector(compare:)];
  fieldOrder = [[NSMutableArray alloc] init];
  sortOrder = [[NSMutableArray alloc] init];
  if ([[PREFERENCES objectForKey:prFieldOrder] count] > 0) {
    int i;
    [fieldOrder addObjectsFromArray:[PREFERENCES objectForKey:prFieldOrder]];
    [sortOrder addObjectsFromArray:[PREFERENCES objectForKey:prSortOrder]];
    for (i = 0; i < [fieldOrder count]; i++) {
      [exportOptions removeObject:[fieldOrder objectAtIndex:i]];
    }
  }
  [addFieldButton setImage:[[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"arrow_r.tif"]] autorelease]];
  [removeFieldButton setImage:[[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"arrow_l.tif"]] autorelease]];
  if ([PREFERENCES boolForKey:priTunesOrdering]) {
    [iTunesOrderingButton setState:NSOnState];
  }
  else {
    [iTunesOrderingButton setState:NSOffState];
  }
  [saveButton setEnabled:([fieldView numberOfRows] > 0)];
  // do this after everything else in the export field and sorting options window
  [optionsView reloadData];
  [fieldView reloadData];
  [sortView reloadData];
  
  // set up general main window controls
  [playlistPopUp removeAllItems];
  [playlistPopUp addItemsWithTitles:[XMLAccess getPlaylistNames]];
  [playlistPopUp selectItemAtIndex:0];
  [exportButton setEnabled:YES];
  
  // set up HTML controls
  [htmlOddColorWell setColor:[Common RGBStringToNSColor:[PREFERENCES stringForKey:prHTMLOddColor]]];
  [htmlEvenColorWell setColor:[Common RGBStringToNSColor:[PREFERENCES stringForKey:prHTMLEvenColor]]];
  [htmlBGColorWell setColor:[Common RGBStringToNSColor:[PREFERENCES stringForKey:prHTMLBGColor]]];
  [htmlTextColorWell setColor:[Common RGBStringToNSColor:[PREFERENCES stringForKey:prHTMLTextColor]]];
  if ([PREFERENCES integerForKey:prHTMLFontSize] == 1) {
    [htmlFontSizePopUp selectItemWithTitle:NSLocalizedString(@"Larger", TRANSERROR)];
  }
  else if ([PREFERENCES integerForKey:prHTMLFontSize] == -1) {
    [htmlFontSizePopUp selectItemWithTitle:NSLocalizedString(@"Smaller", TRANSERROR)];
  }
  else {
    [htmlFontSizePopUp selectItemWithTitle:NSLocalizedString(@"Normal", TRANSERROR)];
  }
  if ([PREFERENCES boolForKey:prHTMLUseStars]) {
    [htmlUseStarsButton setState:NSOnState];
  }
  else {
    [htmlUseStarsButton setState:NSOffState];
  }
  if ([PREFERENCES integerForKey:prHTMLMaxSongsPerFile] == 0) {
    [htmlMaxSongsPerFilePopUp selectItemWithTitle:NSLocalizedString(@"Unlimited", TRANSERROR)];
  }
  else {
    [htmlMaxSongsPerFilePopUp selectItemWithTitle:[PREFERENCES stringForKey:prHTMLMaxSongsPerFile]];
  }
  if ([PREFERENCES integerForKey:prHTMLMaxAlbumsPerFile] == 0) {
    [htmlMaxAlbumsPerFilePopUp selectItemWithTitle:NSLocalizedString(@"Unlimited", TRANSERROR)];
  }
  else {
    [htmlMaxAlbumsPerFilePopUp selectItemWithTitle:[PREFERENCES stringForKey:prHTMLMaxAlbumsPerFile]];
  }
  if ([PREFERENCES boolForKey:prHTMLShouldNumberRows]) {
    [htmlIncludeRowNumbersButton setState:NSOnState];
  }
  else {
    [htmlIncludeRowNumbersButton setState:NSOffState];
  }
  [htmlHeaderTextField setString:[PREFERENCES objectForKey:prHTMLHeader]];
  if ([PREFERENCES boolForKey:prHTMLRemoveDupes]) {
    [htmlRemoveDupesButton setState:NSOnState];
  }
  else {
    [htmlRemoveDupesButton setState:NSOffState];
  }
  if ([PREFERENCES boolForKey:prHTMLAddWebServerLinks]) {
    [htmlIncludeLinksButton setState:NSOnState];
  }
  else {
    [htmlIncludeLinksButton setState:NSOffState];
  }
  if ([PREFERENCES boolForKey:prHTMLAlbumBased]) {
    [htmlAlbumBasedExportButton setState:NSOnState];
  }
  else {
    [htmlAlbumBasedExportButton setState:NSOffState];
  }
  
  // set up delimited text controls
  [dtEncodingPopUp selectItemWithTitle:[PREFERENCES stringForKey:prDTEncoding]];
  [dtDelimiterPopUp selectItemAtIndex:[PREFERENCES integerForKey:prDTDelimiter]];
  if ([PREFERENCES boolForKey:prDTRemoveDupes]) {
    [dtRemoveDupesButton setState:NSOnState];
  }
  else {
    [dtRemoveDupesButton setState:NSOffState];
  }
  if ([PREFERENCES boolForKey:prDTPadding]) {
    [dtPaddingButton setState:NSOnState];
  }
  else {
    [dtPaddingButton setState:NSOffState];
  }
}

-(void)saveControlStates {
  // save export field and sorting options window controls
  [PREFERENCES setObject:fieldOrder forKey:prFieldOrder];
  [PREFERENCES setObject:sortOrder forKey:prSortOrder];
  [PREFERENCES setBool:([iTunesOrderingButton state] == NSOnState) forKey:priTunesOrdering];
  
  // save HTML controls
  [PREFERENCES setObject:[Common NSColorToRGBString:[htmlOddColorWell color]] forKey:prHTMLOddColor];
  [PREFERENCES setObject:[Common NSColorToRGBString:[htmlEvenColorWell color]] forKey:prHTMLEvenColor];
  [PREFERENCES setObject:[Common NSColorToRGBString:[htmlBGColorWell color]] forKey:prHTMLBGColor];
  [PREFERENCES setObject:[Common NSColorToRGBString:[htmlTextColorWell color]] forKey:prHTMLTextColor];
  if ([[htmlFontSizePopUp titleOfSelectedItem] isEqualToString:NSLocalizedString(@"Larger", TRANSERROR)]) {
    [PREFERENCES setObject:@"1" forKey:prHTMLFontSize];
  }
  else if ([[htmlFontSizePopUp titleOfSelectedItem] isEqualToString:NSLocalizedString(@"Smaller", TRANSERROR)]) {
    [PREFERENCES setObject:@"-1" forKey:prHTMLFontSize];
  }
  else {
    [PREFERENCES setObject:@"0" forKey:prHTMLFontSize];
  }
  [PREFERENCES setBool:([htmlUseStarsButton state] == NSOnState) forKey:prHTMLUseStars];
  [PREFERENCES setInteger:[[htmlMaxSongsPerFilePopUp selectedItem] tag] forKey:prHTMLMaxSongsPerFile];
  [PREFERENCES setInteger:[[htmlMaxAlbumsPerFilePopUp selectedItem] tag] forKey:prHTMLMaxAlbumsPerFile];
  [PREFERENCES setBool:([htmlIncludeRowNumbersButton state] == NSOnState) forKey:prHTMLShouldNumberRows];
  [PREFERENCES setObject:[htmlHeaderTextField string] forKey:prHTMLHeader];
  [PREFERENCES setBool:([htmlRemoveDupesButton state] == NSOnState) forKey:prHTMLRemoveDupes];
  [PREFERENCES setBool:([htmlIncludeLinksButton state] == NSOnState) forKey:prHTMLAddWebServerLinks];
  [PREFERENCES setBool:([htmlAlbumBasedExportButton state] == NSOnState) forKey:prHTMLAlbumBased];
  
  // save delimited text controls
  [PREFERENCES setObject:[dtEncodingPopUp titleOfSelectedItem] forKey:prDTEncoding];
  [PREFERENCES setBool:([dtRemoveDupesButton state] == NSOnState) forKey:prDTRemoveDupes];
  [PREFERENCES setInteger:[dtDelimiterPopUp indexOfSelectedItem] forKey:prDTDelimiter];
  [PREFERENCES setBool:([dtPaddingButton state] == NSOnState) forKey:prDTPadding];
}

- (void)awakeFromNib {
  // init XML/plist access
  XMLAccess = [[XMLAccessor alloc] init];
  // Set double click actions
  [optionsView setDoubleAction:@selector(addField:)];
  [fieldView setDoubleAction:@selector(removeField:)];
  [sortView setDoubleAction:@selector(removeField:)];
  // Set up for drag'n'drop
  [fieldView setVerticalMotionCanBeginDrag:TRUE];
  [sortView setVerticalMotionCanBeginDrag:TRUE];
  [fieldView registerForDraggedTypes:[NSArray arrayWithObject:@"NSStringPboardType"]];
  [sortView registerForDraggedTypes:[NSArray arrayWithObject:@"NSStringPboardType"]];
  // This is so we have a pointer to the app controller
  mainController = self;
  [[exportButton window] makeKeyAndOrderFront:self];
  [self setUpControls];
  // disallow some stuff initially based on whether or not album export is selected
  if ([htmlAlbumBasedExportButton state] == NSOnState) {
    [htmlIncludeRowNumbersButton setEnabled:NO];
    [htmlRemoveDupesButton setEnabled:NO];
    [htmlMaxSongsPerFilePopUp setEnabled:NO];
    [htmlMaxAlbumsPerFilePopUp setEnabled:YES];
  }
  else {
    [htmlIncludeRowNumbersButton setEnabled:YES];
    [htmlRemoveDupesButton setEnabled:YES];
    [htmlMaxSongsPerFilePopUp setEnabled:YES];
    [htmlMaxAlbumsPerFilePopUp setEnabled:NO];
  }
}

-(IBAction)iTunesOrderingStateChanged:(id)sender {
  [sortView reloadData];
}

-(IBAction)toggleAlbumExport:(id)sender {
  if ([sender state] == NSOnState) {
    [htmlIncludeRowNumbersButton setEnabled:NO];
    [htmlRemoveDupesButton setEnabled:NO];
    [htmlMaxAlbumsPerFilePopUp setEnabled:YES];
    [htmlMaxSongsPerFilePopUp setEnabled:NO];
  }
  else {
    [htmlIncludeRowNumbersButton setEnabled:YES];
    [htmlRemoveDupesButton setEnabled:YES];
    [htmlMaxAlbumsPerFilePopUp setEnabled:NO];
    [htmlMaxSongsPerFilePopUp setEnabled:YES];
  }
}

-(IBAction)endFieldSelect:(id)sender {
  fieldSelectOK = (sender == saveButton);
  [NSApp stopModal];
}

-(IBAction)export:(id)sender {
  int tvIndex = [mainTabView indexOfTabViewItem:[mainTabView selectedTabViewItem]];
  [self saveControlStates]; // save all the control states to prefs
  if (tvIndex == 0) { // HTML
    if ([htmlAlbumBasedExportButton state] == NSOnState) {
      [self saveExport:self];
    }
    else {
      [NSApp beginSheet:[optionsView window] modalForWindow:[mainTabView window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
      [NSApp runModalForWindow:[optionsView window]];
      [NSApp endSheet:[optionsView window]];
      [[optionsView window] orderOut:self];
      if (fieldSelectOK) {
        [self saveExport:self];
      }
    }
  }
  else if (tvIndex == 1) { // Delimited Text
    [NSApp beginSheet:[optionsView window] modalForWindow:[mainTabView window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [NSApp runModalForWindow:[optionsView window]];
    [NSApp endSheet:[optionsView window]];
    [[optionsView window] orderOut:self];
    if (fieldSelectOK) {
      [self saveExport:self];
    }
  }
  else if (tvIndex == 2) { // M3U
    [self saveExport:self];
  }
  else if (tvIndex == 3) { // QTSS
    [self saveExport:self];
  }
}

-(IBAction)saveExport:(id)sender {
  NSSavePanel *sp = [NSSavePanel savePanel];
  int exportType = [mainTabView indexOfTabViewItem:[mainTabView selectedTabViewItem]];
  NSMutableString *saveFileName = [[NSMutableString alloc] init];
  NSString *defaultDirectory = [[PREFERENCES stringForKey:prLastSaveDir] stringByStandardizingPath];
  [saveFileName appendString:[playlistPopUp titleOfSelectedItem]];
  [jaStringMethods replaceString:@"/" inString:saveFileName withString:@"-"];
  if (exportType == ipHTML) { // HTML
    [sp setRequiredFileType:@"html"];
    [saveFileName appendString:@".html"];
  }
  else if (exportType == ipDelimitedText) { // Delimited Text
    [sp setRequiredFileType:@"txt"];
    [saveFileName appendString:@".txt"];
  }
  else if (exportType == ipQTSS) { // QT Streaming Server
    [sp setRequiredFileType:@"playlist"];
    [saveFileName appendString:@".playlist"];
  }
  else { // M3U
    [sp setRequiredFileType:@"m3u"];
    [saveFileName appendString:@".m3u"];
  }
  // Show file extension in save panel
  [sp setCanSelectHiddenExtension:NO];
  [sp setExtensionHidden:NO];
  // Run the save panel
  if ([FILEMANAGER fileExistsAtPath:defaultDirectory]) {
    [sp beginSheetForDirectory:defaultDirectory file:[NSString stringWithString:saveFileName]
        modalForWindow:[mainTabView window] modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
  }
  else {
    [sp beginSheetForDirectory:NSHomeDirectory() file:[NSString stringWithString:saveFileName]
        modalForWindow:[mainTabView window] modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
  }
  [saveFileName release];
}

-(void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  if (returnCode == NSOKButton) {
    NSString *filePath = [sheet filename];
    Playlist *selectedList = [XMLAccess getPlaylist:[playlistPopUp titleOfSelectedItem]];
    int tvIndex = [mainTabView indexOfTabViewItem:[mainTabView selectedTabViewItem]];
    // set last save dir
    [PREFERENCES setObject:[filePath stringByDeletingLastPathComponent] forKey:prLastSaveDir];
    if (tvIndex == 0) { // HTML
      if (selectedList != nil) {
        [HTML saveHTMLTo:[filePath stringByStandardizingPath] playlist:selectedList albumBased:([htmlAlbumBasedExportButton state] == NSOnState)];
      }
    }
    else if (tvIndex == 1) { // Delimited Text
      if (selectedList != nil) {
        [DelimitedText saveDTTo:[filePath stringByStandardizingPath] playlist:selectedList];
      }
    }
    else if (tvIndex == 2) { // M3U
      if (selectedList != nil) {
        [M3U saveM3UTo:[filePath stringByStandardizingPath] playlist:selectedList];
      }
    }
    else if (tvIndex == 3) { // QTSS
      if (selectedList != nil) {
        [QTSS saveQTSSTo:[filePath stringByStandardizingPath] playlist:selectedList];
      }
    }
  }
}

-(IBAction)setHTMLColorsToDefault:(id)sender {
  [PREFERENCES setObject:DEFAULT_ODD_COLOR forKey:prHTMLOddColor];
  [htmlOddColorWell setColor:[Common RGBStringToNSColor:[PREFERENCES stringForKey:prHTMLOddColor]]];
  [PREFERENCES setObject:DEFAULT_EVEN_COLOR forKey:prHTMLEvenColor];
  [htmlEvenColorWell setColor:[Common RGBStringToNSColor:[PREFERENCES stringForKey:prHTMLEvenColor]]];
  [PREFERENCES setObject:DEFAULT_BG_COLOR forKey:prHTMLBGColor];
  [htmlBGColorWell setColor:[Common RGBStringToNSColor:[PREFERENCES stringForKey:prHTMLBGColor]]];
  [PREFERENCES setObject:DEFAULT_TEXT_COLOR forKey:prHTMLTextColor];
  [htmlTextColorWell setColor:[Common RGBStringToNSColor:[PREFERENCES stringForKey:prHTMLTextColor]]];
}

-(IBAction)setUpHTMLLinking:(id)sender {
  [[PrefsPanel sharedInstance] showLinksPanel:sender];
}

-(IBAction)setDTEncodingToDefault:(id)sender {
  [dtEncodingPopUp selectItemAtIndex:0];
}

-(NSMutableArray*)getFieldOrder {
  return fieldOrder;
}

-(NSMutableArray*)getSortOrder {
  return sortOrder;
}

-(IBAction)refreshLibrarySelector:(id)sender {
  [XMLAccess loadData];
  [playlistPopUp removeAllItems];
  [playlistPopUp addItemsWithTitles:[XMLAccess getPlaylistNames]];
}

-(IBAction)addField:(id)sender {
  int selectedRow = [optionsView selectedRow];
  [fieldOrder addObject:[exportOptions objectAtIndex:selectedRow]];
  [sortOrder addObject:[exportOptions objectAtIndex:selectedRow]];
  [exportOptions removeObjectAtIndex:selectedRow];
  [optionsView reloadData];
  [fieldView reloadData];
  [sortView reloadData];
  [saveButton setEnabled:([fieldView numberOfRows] > 0)];
}

-(IBAction)removeField:(id)sender {
  NSTableView *senderTable;
  NSMutableArray *senderArray;
  NSString *objectToRemove;
  if ([sortView numberOfSelectedRows] > 0) {
    senderTable = sortView;
    senderArray = sortOrder;
  }
  else {
    senderTable = fieldView;
    senderArray = fieldOrder;
  }
  objectToRemove = [senderArray objectAtIndex:[senderTable selectedRow]];
  [exportOptions addObject:objectToRemove];
  [fieldOrder removeObject:objectToRemove];
  [sortOrder removeObject:objectToRemove];
  [optionsView reloadData];
  [fieldView reloadData];
  [sortView reloadData];
  [saveButton setEnabled:([fieldView numberOfRows] > 0)];
  [exportOptions sortUsingSelector:@selector(compare:)];
}

-(IBAction)showPrefs:(id)sender {
  [[PrefsPanel sharedInstance] showPanel:sender];
}

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
  ;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [self saveControlStates];
}

/*
 TableView Delegate Methods
 */

- (void)tableViewSelectionDidChange:(NSNotification*)aNotification {
  NSTableView *senderView = [aNotification object];
  if (senderView == optionsView) {
    [addFieldButton setEnabled:([optionsView numberOfSelectedRows] > 0)];
  }
  else {
    [removeFieldButton setEnabled:([senderView numberOfSelectedRows] > 0)];
  }
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
  if (aTableView == optionsView) {
    return [exportOptions count];
  }
  else if (aTableView == fieldView) {
    return [fieldOrder count];
  }
  else if (aTableView == sortView) {
    if ([iTunesOrderingButton state] == NSOnState) {
      return 0;
    }
    else {
      return [sortOrder count];
    }
  }
  else { // Just avoids the compiler warning
    return 0;
  }
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
  if (aTableView == optionsView) {
    return [exportOptions objectAtIndex:rowIndex];
  }
  else if (aTableView == fieldView) {
    return [fieldOrder objectAtIndex:rowIndex];
  }
  else if (aTableView == sortView) {
    return [sortOrder objectAtIndex:rowIndex];
  }
  else { // avoids the compiler warning
    return nil;
  }
}

- (BOOL)tableView:(NSTableView*)aTableView shouldEditTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex {
  return FALSE;
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView {
  NSTableView *responder = (NSTableView*)[[fieldView window] firstResponder];
  if ((aTableView == responder) && (aTableView != optionsView)) {
    if (aTableView == fieldView) {
      [sortView deselectAll:self];
    }
    else {
      [fieldView deselectAll:self];
    }
  }
  return TRUE;
}

/*
 For drag'n'drop
 */

- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard {
  int row = [[rows objectAtIndex:0] intValue];
  NSString *string;
  if (tableView == fieldView) {
    string = [fieldOrder objectAtIndex:row];
  }
  else {
    string = [sortOrder objectAtIndex:row];
  }
    // Tell the pasteboard what type it could contain
    // This clears the pasteboard
    // owner:nil means that data is immediately available and
    // the we don't need to keep owner instances around because
    // they might be called at a later time
  [pboard declareTypes:[NSArray arrayWithObject:@"NSStringPboardType"] owner:nil];
    // Add the data of to the pasteboard
  [pboard setString:string forType:@"NSStringPboardType"];
  return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
    // Only allow drags within the same NSTableView
  if (tv != [info draggingSource]) {
    return NSDragOperationNone;
  }
  if (op == NSTableViewDropOn) {
    [tv setDropRow:row dropOperation:NSTableViewDropAbove];
  }
  return NSTableViewDropAbove;
}

- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op {
    // get the pasteboard where all out data is stored
  NSPasteboard *pboard = [info draggingPasteboard];
  NSString *title = [pboard stringForType:@"NSStringPboardType"];
  NSString *selectedTitle = nil;
  int oldRow;
  if (tv == fieldView) {
    oldRow = [fieldOrder indexOfObject:title];
  }
  else {
    oldRow = [sortOrder indexOfObject:title];
  }
    // Remember what was selected
  if ([tv selectedRow] > -1 ) {
    if (tv == fieldView) {
      selectedTitle = [fieldOrder objectAtIndex:[tv selectedRow]];
    }
    else {
      selectedTitle = [sortOrder objectAtIndex:[tv selectedRow]];
    }
  }
    // perform the swap
  if (tv == fieldView) {
    if (row == -1) {
      [fieldOrder removeObject:title];
      [fieldOrder addObject:title];
    }
    else if (row > [fieldOrder indexOfObject:title]) {
      [fieldOrder insertObject:title atIndex:row];
      [fieldOrder removeObjectAtIndex:[fieldOrder indexOfObject:title]];
    }
    else {
      [fieldOrder removeObject:title];
      [fieldOrder insertObject:title atIndex:row];
    }
  }
  else {
    if (row == -1) {
      [sortOrder removeObject:title];
      [sortOrder addObject:title];
    }
    else if (row > [sortOrder indexOfObject:title]) {
      [sortOrder insertObject:title atIndex:row];
      [sortOrder removeObjectAtIndex:[sortOrder indexOfObject:title]];
    }
    else {
      [sortOrder removeObject:title];
      [sortOrder insertObject:title atIndex:row];
    }
  }
  // Correct the selection
  if (selectedTitle != nil) {
    if (tv == fieldView) {
      [tv selectRow:[fieldOrder indexOfObject:selectedTitle] byExtendingSelection:NO];
    }
    else {
      [tv selectRow:[sortOrder indexOfObject:selectedTitle] byExtendingSelection:NO];
    }
  }
  // Update the table
  [tv reloadData];
  return YES;
}

/*
 Menu Item
*/


// this is just here so the menu will call validateMenuItem
-(IBAction)doNothing:(id)sender {
  ;
}

-(BOOL)validateMenuItem:(NSMenuItem *)anItem {
  return YES;
}

@end
