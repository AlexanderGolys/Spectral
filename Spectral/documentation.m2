-- Documentation pages, sent as M2 writes them, except that a link to a node
-- carries the node's key as the M2 string `help` reads, and a source position
-- links to its file under a shortened spelling.

-- The print width M2 runs documentation examples at, Core's ArgPrintWidthN in
-- run.m2: archived example output cannot be unwrapped without it, and Core
-- exports no name for it.
exampleWidth = 77

-- The nodes a page links to, by their tags.
linkedTags = method()
linkedTags Thing := part -> {}
linkedTags Hypertext := part -> flatten(linkedTags \ toList part)
linkedTags TO := link -> { link#0 }
linkedTags TO2 := link -> { link#0 }
linkedTags TOH := link -> { link#0 }

-- The HTML of a page with each link to a node pointing at the node's key, spelled
-- as the M2 string `help` reads, so the shell can open it. M2 links a tag wherever
-- it appears with the same target, so the target its own link gets is the one to
-- replace.
keysLinked = page' -> fold((linked, tag) -> (
	anchor := html TO { tag };
	target := regex(///href="[^"]*"///, anchor);
	key := fold((escaped, entity) -> replace(entity#0, entity#1, escaped),
		format format tag,
		{ ("&", "&amp;"), ("\"", "&quot;"), ("<", "&lt;"), (">", "&gt;") });
	if target === null then
		linked
	else demark("href=\"" | key | "\"", separate(regexQuote substring(target#0, anchor),
		linked))
), html page', unique linkedTags page')

-- Each match of a pattern in a page replaced by what a function makes of the
-- match and the page, for replacements no backreference can spell.
rewritten = (pattern, rewrite, page') -> (
	done := "";
	while (found := regex(pattern, page')) =!= null do (
		done = done | substring(page', 0, found#0#0) | rewrite(found, page');
		page' = substring(page', found#0#0 + found#0#1)
	);
	done | page'
)

-- A link to a file spelled with its whole directory, which is most of a line and
-- none of what is wanted, is spelled as a source position is: its file's name,
-- one directory above it, and the position.
pathsShortened = page' -> rewritten(///(<a href="file://([^"#]*)[^"]*">)([^<]*)</a>///,
	(found, page'') -> (
		path' := substring(found#2, page'');
		text := substring(found#3, page'');
		substring(found#1, page'') | (if substring(text, 0, #path') == path' then
					shortenedFile path' | substring(text, #path')
				else text) | "</a>"
	), page')

-- A source position set as code, `name.m2:12:3`, links to its file, found on the
-- load path; one whose file cannot be found stays as it is.
sourcesLinked = page' -> rewritten(
	///<span class="tt">([^<]*\.m2):([0-9]+):([0-9]+)</span>///,
	(found, page'') -> (
		file := replace("&amp;", "&", replace("&gt;", ">", replace("&lt;", "<",
			substring(found#1, page''))));
		target := location new FilePosition from { file, value substring(found#2, page''),
			value substring(found#3, page'') };
		original := substring(found#0, page'');
		if target === null then
			original
		else "<a href=\"" | target | "\">" | original | "</a>"
	), page'
)

-- A page as the shell lays it out: its HTML, the width its examples were archived
-- at, and the names it may resolve as types.
page = page' -> hashTable {
	symbol html => sourcesLinked pathsShortened keysLinked page',
	symbol exampleWidth => exampleWidth,
	symbol typeNames => unique flatten((dictionary -> select(keys dictionary, name ->
			instance(value dictionary#name, Type))) \ dictionaryPath)
}