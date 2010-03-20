LuaHunspell - Matt White (pbsurf at gmail.com)
19 March 2010

A prebuilt DLL is available for SciTE.  See instructions below for building a custom version.

Using with SciTE:

1. Copy hunspell.dll to SciTE folder (e.g., C:\Program Files\wscite).
2. Extract scite_lua\spellcheck.lua to scite_lua folder (assumes SciTE ExtMan is in use).
3. spellcheck.lua assumes en_US dictionary files (.aff, .dic) are located in SciTE folder.  Otherwise, set the 'spell.dictpath' and/or 'spell.dictname' properties in SciTEGlobal.properties or SciTEUser.properties.  Dictionaries files available at http://hunspell.sourceforge.net/.
4. Tools->Toggle Spelling (F9) checks the document and underlines misspelled words; a second time turns off underlining.  Double-click on a word to see suggestions.  Double-click suggestion to make replacement.  The keyboard shortcut can be changed in spellcheck.lua.  Spell checking must be turned off and back on to refresh. 

Installing SciTE ExtMan under Windows: 
- Ignore this if you already have ExtMan working.

1. Obtain extman.lua and spawner-ex.dll from scite-debug (http://scitedebug.luaforge.net/) and copy to SciTE folder.  The version of extman.lua from the the lua-users wiki may not work, at least on Vista.
2. In SciTE properties file (i.e., SciTEGlobal.properties or SciTEUser.properties), add the following:
    ext.lua.startup.script=$(SciteDefaultHome)\extman.lua 
Must use a backslash ('\') here for scite-debug ExtMan or scite_lua folder won't be found (strangely, '/' does work for some other verisions of ExtMan).
3. Create scite_lua subfolder in SciTE folder.  Place lua scripts (e.g. spellcheck.lua) here.


Building (Visual C++):

1. Extract contents of hunspell into hunspell source distribution (from, e.g., hunspell-1.2.9.tar.gz)
2. Open src\lua\luahunspell.vcproj (VC++ 2005 project) and adjust "Additional Dependencies" under Configuration Properties->Linker->Input as necessary.  The enclosed SciTE.lib can be used if building SciTE version.
3. Build hunspell.dll.  For SciTE, select SciTE-Release configuration.

Usage example:
  require("hunspell")
  hunspell.init("C:\\hunspell\\en_US.aff", "C:\\hunspell\\en_US.dic")
  iswordrecogized = hunspell.spell("teh")
  suggestions = hunspell.suggest("teh")  -- returns table of strings


spellcheck.lua changes:

0.1c - 2010/03/19:
- made dictionary loading check optional (default is to skip check - see spell_testword variable)
- dictionary path and name can be set in SciTE properties file
- changed to modern indicators instead of style byte indicators; fixes failure with HTML files
- moved word extraction code into a generic for iterator, minor improvements; added simple word extraction function
- word used for generating suggestions now agrees with underlined word
- added a tools menu command to show suggestions without double-clicking
0.1b - 2010/03/11: 
- initial version