# See bottom of file for license and copyright information
package Foswiki::Plugins::SpacedWikiWordPlugin;

use strict;
use warnings;

our $VERSION = '1.1';
our $RELEASE = '12 July 2017';
our $SHORTDESCRIPTION = "Space out Wiki Word links automatically";
our $NO_PREFS_IN_TOPIC = 1;

our $spaceOutWikiWordLinks;
our $spaceOutUnderscoreLinks;
our $removeAnchorDashes;
our %dontSpaceSet = ();
our $default_spaceOutWikiWord;

sub _get_bool_pref {
    my ($n, $default) = @_;
    my $v = Foswiki::Func::getPreferencesValue($n);
    return $default unless defined $v;
    $v = Foswiki::Func::expandCommonVariables( $v );
    return $v;
}

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    $spaceOutWikiWordLinks = _get_bool_pref("SPACE_OUT_WIKI_WORD_LINKS", 1);
    $spaceOutUnderscoreLinks = _get_bool_pref("SPACE_OUT_UNDERSCORE_LINKS", 1);
    $removeAnchorDashes = _get_bool_pref("REMOVE_ANCHOR_DASHES", 0);
    my $dontSpaceWords = _get_bool_pref("DONTSPACE", '');
    $dontSpaceWords =~ s/^\s*(.*?)\s*$/$1/;
    %dontSpaceSet = map { $_ => 1 } split( /[,\s]+/, $dontSpaceWords );

    # Monkey patch!
    unless (defined $default_spaceOutWikiWord) {
        $default_spaceOutWikiWord = \&Foswiki::spaceOutWikiWord;
        no warnings;
        *Foswiki::spaceOutWikiWord = \&_spaceOutWikiWord;
        use warnings;
    }
        
    return 1;
}

=pod

---++ renderWikiWordHandler( $linkLabel, $hasExplicitLinkLabel ) -> $text
Handler invoked by the core rendering engine to render a wikiword.
   * =$linkLabel= - the link label to be spaced out
   * =$hasExplicitLinkLabel= - in case of bracket notation: the link label is written as [[TopicName][link label]]

=cut

sub renderWikiWordHandler {
    my ( $linkLabel, $hasExplicitLinkLabel ) = @_;

    # do nothing if this label is defined in the do-not-link list
    $linkLabel =~ s/^(#)//;
    my $dashed = $1 // '';
    
    unless ( $hasExplicitLinkLabel || $dontSpaceSet{$linkLabel}) {
        $linkLabel =~ s/_/ /g if $spaceOutUnderscoreLinks;
        $linkLabel = Foswiki::Func::spaceOutWikiWord($linkLabel)
            if ( $spaceOutWikiWordLinks );
    }
    
    # eat anchor dash
    $dashed = '' if $removeAnchorDashes;

    return ($dashed ? '#' : '') . $linkLabel;
}

=pod

---++ _spaceOutWikiWordLinks( $linkLabel ) -> $text

Monkey-patch replacing Foswiki::spaceOutWikiWord.

   * =$linkLabel= - the link label to be spaced out

=cut

sub _spaceOutWikiWord {
    my ( $word, $sep ) = @_;

    $word //= '';
    $sep  //= ' ';
    my $mark = "\001";
    $word =~ s/([[:upper:]])([[:digit:]])/$1$mark$2/g;
    $word =~ s/([[:digit:]])([[:upper:]])/$1$mark$2/g;
    $word =~ s/([[:lower:]])([[:upper:][:digit:]]+)/$1$mark$2/g;
    $word =~ s/(^|[^[:upper:]])([[:upper:]])([[:upper:]])([[:lower:]])/$1$2$mark$3$4/g;
    $word =~ s/$mark/$sep/g;
    return $word;
}

1;
__END__
Copyright (C) 2008-2017 Foswiki Contributors. All Rights Reserved. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

For licensing info read LICENSE file in the Foswiki root.

As per the GPL, removal of this notice is prohibited.
