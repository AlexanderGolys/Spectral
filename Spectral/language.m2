-- The language's own objects: text, names, keywords, functions and the source
-- positions they come from. None of them is maths, even as an operand.

-- Text in a typewriter face, coloured as `group`.
typewritten := (text, group) -> Rod {Holder {text}, codeFont,
	Group => HLG group}
-- Lines one under another, each typewritten.
lined := lines -> Rod {Table apply(lines, line -> {typewritten(line, "Text")})}

rod String := text -> typewritten(text, "String")
rod Net := text -> lined unstack text

-- Handles on what the language runs on are spelled as M2 spells them, never
-- maths.
scan({Dictionary, File, NetFile, Database, Task, Mutex, Error, FunctionBody,
	Pseudocode, SymbolBody, Manipulator}, handle ->
		rod handle := x -> spelledAsM2 x ++ {codeFont})
-- A timed value is the value with the time it took beneath, as M2 prints it.
rod Time := timed -> Rod {Table {{rod' timed#1}, {Rod {Holder {"-- "
		| toString timed#0 | " seconds"}, Highlight => HLG "Comment"}}}}

-- An atomic integer is the integer it holds.
rod AtomicInt := counter -> rod' new ZZ from counter
rod Boolean := truth -> typewritten(toString truth, "Boolean")
rod Nothing := nothing -> typewritten("null", "Builtin")

-- A type, and a package, is spelled by its name and coloured as one.
rod Type := type -> Rod {Holder {toString type}, Group => HLG "Type"}
rod Package := package -> Rod {Holder {toString package}, Group => HLG "Package"}

-- A name stands for its value; an indexed variable x_1 is drawn as the
-- subscript it is spelled with.
rod Symbol := name -> Rod {Holder {toString name}, Group => HLG "Variable"}
rod IndexedVariable := variable -> rod' new Subscript from toList variable

-- An operator keyword is coloured as an operator, set as maths among maths;
-- any other is a keyword.
rod Keyword := keyword -> (
	if operatorAttributes#?keyword then
		Rod {Holder {toString keyword}, Group => HLG "Operator"}
	else typewritten(toString keyword, "Keyword")
)

-- A function, and a command as the function it runs, is spelled by its name,
-- or shown by its code when it has none, and links to its source. The code at
-- a position is cut from the lines M2 shows for it, from its file, the
-- current input or the history, whose columns count a tab to the next multiple
-- of 8 just as those lines are expanded; reading a file that has gone is the
-- one failure expected.
rod Function := rod Command := runnable -> (
	position := locate runnable;
	name := toString runnable;
	named := isGlobalSymbol name and value getGlobalSymbol name === runnable;
	shown := if not named and position =!= null then
			try code position;
	drawn := if shown === null then
			typewritten(name, if instance(runnable, Command) then
						"Macro"
					else "Function")
		else (
			lines := select(toList (last shown)#0, line -> instance(line, String));
			if #position > 4 then (
				lines = append(drop(lines, -1), substring(last lines, 0, position#4));
				lines = prepend(substring(first lines, position#2), drop(lines, 1))
			);
			lined lines
		);
	link := if position =!= null then
			rod position;
	if link =!= null and link#?Target then
		drawn ++ {Target => link#Target}
	else drawn
)

-- A source position is spelled with its file's name and one directory above
-- it, /a/b/c/file.m2:12:3 as [...]/c/file.m2:12:3, and links to its file,
-- found on the load path.
rod FilePosition := position -> (
	file := position#0;
	directories := select(separate("/", file), part -> part != "");
	spelled := concatenate(
		if #directories <= 2 then
			file
		else "[...]/" | demark("/", take(directories, -2)),
		if #position > 2 then (":", toString position#1, ":", toString position#2),
		if #position > 4 then ("-", toString position#3, ":", toString position#4)
	);
	found := select(prepend(file, apply(path, directory -> directory | file)),
		fileExists);
	Rod {Holder {spelled}, Group => HLG "MarkupLink", codeFont,
		Target => if #position > 2 and #file > 0 and #found > 0 then
				urlEncode concatenate(
					"file://", toAbsolutePath first found,
					"#L", toString position#1, ":C", toString position#2,
					if #position > 4 then
						("-L", toString position#3, ":C", toString position#4)
				)}
)
