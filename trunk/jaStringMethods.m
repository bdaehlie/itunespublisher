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

#import "jaStringMethods.h"
#import <Math.h>

@implementation jaStringMethods

// IS case sensitive, 10.2 and later only
+(NSMutableString*)replaceString:(NSString*)stringToReplace inString:(NSMutableString*)string withString:(NSString*)replacementString {
  [string replaceOccurrencesOfString:stringToReplace withString:replacementString options:0 range:NSMakeRange(0, [string length])];
  return string;
}

+(NSString*)intAsString:(int)i {
  // use sprintf() here instead - then init NSString with cString
  return [[NSNumber numberWithInt:i] stringValue];
}

+(NSString*)floatAsString:(float)i {
  // use sprintf() here instead - then init NSString with cString
  return [[NSNumber numberWithFloat:i] stringValue];
}

+(BOOL)stringOnlyContainsNumerics:(NSString*)s {
  int i;
  int stringLength = [s length];
  NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
  for (i = 0; i < stringLength; i++) {
    if (![digits characterIsMember:[s characterAtIndex:i]]) {
      return FALSE;
    }
  }
  return TRUE;
}

+(void)appendInt:(int)i toMString:(NSMutableString*)s printZero:(BOOL)f {
  if (f) {
    [s appendString:[jaStringMethods intAsString:i]];
  }
  else {
    if (i != 0) {
      [s appendString:[jaStringMethods intAsString:i]];
    }
  }
}

// Returns the time in the format:
// hh:mm:ss.t
+(NSString*)getTimeAsString:(int)seconds {
  int s;
  int min;
  NSMutableString *myString;
  if (seconds == 0) {
    return @"";
  }
  s = seconds % 60;
  min = seconds / 60;
  myString = [[[NSMutableString alloc] init] autorelease];
  [myString appendString:[jaStringMethods intAsString:min]];
  [myString appendString:@":"];
  if (s < 10) {
    [myString appendString:@"0"];
  }
  [myString appendString:[jaStringMethods intAsString:s]];
  return [NSString stringWithString:myString];
}

// Returns the time in the format:
// X.X Days, or X.X Hours, or X.X Minutes, or X Seconds, whichever is less
// always rounds down in the first decimal place
+(NSString*)getTimeAsNiceVagueString:(int)seconds {
  int s, m, h, d;
  if (seconds < 60) {
    return [NSString stringWithFormat:@"%i %@", seconds, NSLocalizedString(@"seconds", TRANSERROR)];
  }
  s = seconds % 60;
  m = (seconds - s) / 60;
  if (m < 60) {
    return [NSString stringWithFormat:@"%1.1f %@", ((double)m + (floor(((double)s / (double)60.0) * 10) / 10)), NSLocalizedString(@"minutes", TRANSERROR)];
  }
  h = (m - (m % 60)) / 60;
  m = m % 60;
  if (h < 24) {
    return [NSString stringWithFormat:@"%1.1f %@", ((double)h + (floor(((double)m / (double)60.0) * 10) / 10)), NSLocalizedString(@"hours", TRANSERROR)];
  }
  d = (h - (h % 24)) / 24;
  h = h % 24;
  return [NSString stringWithFormat:@"%1.1f %@", ((double)d + (floor(((double)h / (double)24.0) * 10) / 10)), NSLocalizedString(@"days", TRANSERROR)];
}

+(NSString*)kilobytesToMBString:(unsigned long int)kilobytes {
  unsigned long int k, m, g;
  if (kilobytes < 1024) {
    return [NSString stringWithFormat:@"%U %@", kilobytes, NSLocalizedString(@"K", TRANSERROR)];
  }
  m = (kilobytes - (kilobytes % 1024)) / 1024;
  k = kilobytes % 1024;
  if (m < 1024) {
    return [NSString stringWithFormat:@"%1.1f %@", ((double)m + (floor(((double)k / (double)1024.0) * 10) / 10)), NSLocalizedString(@"MB", TRANSERROR)];
  }
  g = (m - (m % 1024)) / 1024;
  m = m % 1024;
  return [NSString stringWithFormat:@"%1.1f %@", ((double)g + (floor(((double)m / (double)1024.0) * 10) / 10)), NSLocalizedString(@"GB", TRANSERROR)];
}

// Convert UTF-8 string to Latin-1
+(NSData*)convertToLatin1:(NSString*)utf8String {
  return [utf8String dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:YES];
}

// Explicit conversion to UTF-8
+(NSData*)convertToUTF8:(NSString*)utf8String {
  return [utf8String dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
}

// Convert UTF-8 string to NSNonLossyASCIIStringEncoding
+(NSData*)convertToASCII:(NSString*)utf8String {
  return [utf8String dataUsingEncoding:NSNonLossyASCIIStringEncoding allowLossyConversion:YES];
}

@end
