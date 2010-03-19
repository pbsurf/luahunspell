-- Other SciTE lua spell checkers:
--  <http://natowelch.livejournal.com/392888.html>
--  <http://source.contextgarden.net/context/data/scite/scite-ctx.lua>

require("hunspell");  -- assuming hunspell.dll in SciTE folder
hunspell.init("en_US.aff", "en_US.dic");  -- assuming .aff and .dic in SciTE folder 


-- Options
SpellIgnore_CAPS = true;  -- ignore CamelCase, ALLCAPS

-- from http://lua-users.org/wiki/UsingLuaWithScite
-- defaults:
--  INDIC0_MASK: green squiggly line, INDIC1_MASK: blue Ts, INDIC2_MASK: red line
-- INDICS_MASK = INDIC0_MASK & INDIC1_MASK & INDIC2_MASK
function highlight_range(pos, len, ind)
   ind = ind or INDIC0_MASK + INDIC2_MASK;  -- combining the two makes a nice effect
   local es = editor.EndStyled;
   editor:StartStyling(pos, INDICS_MASK);
   editor:SetStyling(len, ind);
   editor:SetStyling(2, INDIC_PLAIN);  -- INDIC_PLAIN = 0
end

-- treat spelling checking as a (per-buffer) toggable mode
-- Although messy, current code for skipping words seems to
--  work reasonably well for LaTeX and markdown.  Depending
--  on the setting of editor.WordChars (write-only, unfortunately)
--  there may be some disagreement between highlighted word and 
--  and word used for generating suggestions (esp. w/ - and ')
function inline_spell()
  if buffer["SpellMode"] then 
    -- clear indicator styling for whole file
    editor:StartStyling(0, INDICS_MASK);
    editor:SetStyling(editor.TextLength, INDIC_PLAIN);
    buffer["SpellMode"] = false;
    return;
  elseif not hunspell.spell("test") then
    -- if dict path is wrong, spell() will return false for every word
    print("Error: hunspell not initialized. Please check dictionary path.");
    return;
  end
  buffer["SpellMode"] = true;
  -- without this call to Colourise, syntax highlighting will be broken 
  -- in regions which haven't been displayed since document was opened
  editor:Colourise(1, -1);
  local alltext = editor:GetText();
  local wstart, wstop, word, pstart = 0, 0, nil, nil;
  while true do 
    -- to do a better job of ignoring URLs, drop "%/" and "%-% here
    wstart, wstop, word = string.find(alltext, "([^%s%-%(%)%/]+)", wstop+1);
    if not wstart then break; end
    -- strip trailing (and leading?) punctuation chars
    -- %p includes some chars I don't want, so be explicit
    pstart = string.find(word, "[%,%.%;%:%/%?%\'%\"%!]+$");
    if pstart then
      word = string.sub(word, 1, pstart-1);
    end
    -- skip word if any remaining chars are not %a (or ')
    -- and optionally if word is CamelCase or ALL CAPS
    if string.find(word, "[^%a%']") 
     or ( SpellIgnore_CAPS and string.find(word, "%u", 2) ) then
      --print("Ignoring "..word);
      --continue;
    elseif not hunspell.spell(word) then
      highlight_range(wstart-1, string.len(word));
    end
  end
end

-- Words manually corrected will retain styling (e.g. red underline) for
--  letters not edited; only way I can think of around this is to monitor
--  OnChar, which I don't really want to do.
-- Only problem with using autocomplete (instead of a user list)
--  seems to be that if misspelled word is prefix of a suggestion,
--  that suggestion is highlighted instead of the first one; also,
--  with a user list, we could have an "add to dict" option
function spell_suggest()
  if not buffer["SpellMode"] or editor:AutoCActive() then return false; end
  
  -- normally, autocomplete list will be hidden if word is not prefix
  --  of (any? all?) item on list.
  editor.AutoCAutoHide = false;
  local pos = editor.CurrentPos;
  local startPos = editor:WordStartPosition(pos, true);
  local endPos = editor:WordEndPosition(pos, true);
  local word = editor:textrange(startPos, endPos);
  --print("Checking word "..word);
  if not hunspell.spell(word) then
    local sug = hunspell.suggest(word);
    if #sug > 0 then
      editor:AutoCShow(string.len(word), table.concat(sug, " "));
    end
  end
  -- suppress other handlers in spell check mode; This 
  --  only works for handlers added after this one!
  return true;
end

scite_OnDoubleClick(spell_suggest);

-- set keyboard shortcut here
scite_Command("Toggle Spelling|inline_spell|F9");

function close_hunspell() 
  --print("Closing Hunspell");
  hunspell.close();
end

--scite_Command("Close Hunspell|close_hunspell|");