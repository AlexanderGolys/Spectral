-- Documentation pages, sent as M2 writes them, except that a link to a node
-- carries the node's key as the M2 string `help` reads, and a source position
-- links to its file under a shortened spelling.

-- The print width M2 runs documentation examples at. Core keeps it to itself,
-- and archived example output cannot be unwrapped without it.
exampleWidth := value Core#"private dictionary"#"ArgPrintWidthN"

-- keysLinked(page, document): the HTML `page` of `document` with each link to a
-- node pointing at the node's key, spelled as the M2 string `help` reads, so
-- the shell can open it. M2 links a tag wherever it appears with the same
-- target, so the target its own link gets is the one to replace.
keysLinked := (page, document) -> (
	links := part -> if instance(part, TO) or instance(part, TO2) or instance(part, TOH)
		then {part#0} else if instance(part, Hypertext) then
		flatten apply(toList part, links)
	else {};
	fold((linked, tag) -> (
		anchor := html TO {tag};
		target := regex(///href="[^"]*"///, anchor);
		key := fold((escaped, entity) -> replace(entity#0, entity#1, escaped),
			format format tag,
			{("&", "&amp;"), ("\"", "&quot;"), ("<", "&lt;"), (">", "&gt;")});
		if target === null then
			linked
		else demark("href=\"" | key | "\"",
			separate(regexQuote substring(target#0, anchor), linked))
	), page, unique links document)
)

-- pathsShortened page: the HTML `page` with the text of each link to a file cut
-- as a source position spells it. `file:///dir/name.m2#L1:C2` is spelled with its whole
-- directory, which is most of a line and none of what is wanted; its text
-- keeps the file's name, one directory above it, and the position.
pathsShortened := page -> (
	pattern := ///(<a href="file://([^"#]*)[^"]*">)([^<]*)</a>///;
	shortened := "";
	while (match := regex(pattern, page)) =!= null do (
		path := substring(match#2, page);
		text := substring(match#3, page);
		shortened = shortened | substring(page, 0, match#0#0) | substring(match#1, page)
			| (if substring(text, 0, #path) == path then
						toString rod new FilePosition from {path} | substring(text, #path)
					else text) | "</a>";
		page = substring(page, match#0#0 + match#0#1)
	);
	shortened | page
)

-- sourcesLinked page: the HTML `page` with each source position set as code,
-- `name.m2:12:3`, made a link to its file, found on the load path; a position
-- whose file cannot be found stays as it is.
sourcesLinked := page -> (
	pattern := ///<span class="tt">([^<]*\.m2):([0-9]+):([0-9]+)</span>///;
	linked := "";
	while (match := regex(pattern, page)) =!= null do (
		file := replace("&amp;", "&", replace("&gt;", ">", replace("&lt;", "<",
			substring(match#1, page))));
		position := rod new FilePosition from {file, value substring(match#2, page),
			value substring(match#3, page)};
		target := if position#?Target then
				position#Target;
		original := substring(match#0, page);
		linked = linked | substring(page, 0, match#0#0)
			| (if target === null then
						original
					else "<a href=\"" | target | "\">" | original | "</a>");
		page = substring(page, match#0#0 + match#0#1)
	);
	linked | page
)

rod Hypertext := page -> Rod {Holder {toString net page},
	Html => sourcesLinked pathsShortened keysLinked(html page, page),
	TypeNames => unique flatten apply(dictionaryPath, dictionary ->
			select(keys dictionary, name -> instance(value dictionary#name, Type))),
	ExampleWidth => exampleWidth
}
