-- The language's own objects: text, names, keywords, functions and the source
-- positions they come from. None of them is maths, even as an operand.

typewriter String := class' -> true
highlightGroup String := class' -> HLG "String"
spelling String := identity

typewriter Net := class' -> true
-- A net is its lines one under another; a string, one line of them, is spelled
-- by itself.
lined (List, Type) := (lines, class') -> Rod {Table apply(lines, line ->
		{Rod {Holder {line}, Class => class'}})}
rod Net := text -> lined(unstack text, Net)
rod String := lookup(rod, Thing)

-- Handles on what the language runs on are spelled by their names, never maths.
scan({Dictionary, File, NetFile, Database, Task, Mutex, Error, FunctionBody,
	Pseudocode, SymbolBody, Manipulator}, handle ->
		typewriter handle := class' -> true)
-- A timed value is the value with the time it took beneath, as M2 prints it.
rod Time := timed -> Rod {Table {{rod timed#1}, {Rod {Holder {"-- "
		| toString timed#0 | " seconds"}, Highlight => HLG "Comment"}}}}

-- An atomic integer is the integer it holds.
rod AtomicInt := counter -> rod(new ZZ from counter) ++ {symbol Type => AtomicInt}
typewriter Boolean := class' -> true
highlightGroup Boolean := class' -> HLG "Boolean"
typewriter Nothing := class' -> true
highlightGroup Nothing := class' -> HLG "Builtin"

-- A type, and a package, is coloured as one.
highlightGroup Type := class' -> HLG "Type"
highlightGroup Package := class' -> HLG "Package"

-- A name stands for its value.
highlightGroup Symbol := class' -> HLG "Variable"
spelledName String := name -> Rod {Holder {name}, Class => Symbol, symbol Type => Symbol}
opaque Symbol := name -> (lookup(opaque, Thing)) name ++ {symbol Type => class value name}

-- An indexed variable x_1 is drawn as the subscript it is spelled with.
rod IndexedVariable := variable -> rod new Subscript from toList variable

-- An operator keyword is coloured as an operator; any other as a keyword.
highlightGroup Keyword := class' -> HLG "Keyword"
rod Keyword := keyword -> opaque keyword ++ {
	Highlight => if operatorAttributes#?keyword then
			HLG "Operator"
		else Keyword
}

-- A function links to its source.
typewriter Function := class' -> true
highlightGroup Function := class' -> HLG "Function"
highlightGroup Command := class' -> HLG "Macro"
-- A function, and a command as the function it runs, is spelled by its name, or
-- shown by its code when it has none, and links to its source.
named Thing := Boolean => x -> (
	name := toString x;
	isGlobalSymbol name and value getGlobalSymbol name === x
)
rod Function := rod Command := runnable -> (
	position := locate runnable;
	code' := if not named runnable and position =!= null then
			sourceLines position;
	(if code' =!= null then
				lined(code', class runnable) ++ {symbol Type => class runnable}
			else opaque runnable) ++ {
				Target => if position =!= null then
						(rod position)#Target
			}
)

-- The code at a position, cut from the lines M2 shows for it, from its file, the
-- current input or the history, whose columns count a tab to the next multiple
-- of 8 just as those lines are expanded; reading a file that has gone is the one
-- failure expected.
sourceLines FilePosition := position -> (
	shown := (try code position) ?? return;
	lines := select(toList (last shown)#0, line -> instance(line, String));
	if #position < 5 then
		return lines;
	lines = append(drop(lines, -1), substring(last lines, 0, position#4));
	prepend(substring(first lines, position#2), drop(lines, 1))
)
-- A source position is spelled with its file's name and one directory above
-- it: /a/b/c/file.m2:12:3 is [...]/c/file.m2:12:3.
spelling FilePosition := position -> (
	parts := select(separate("/", position#0), part -> part != "");
	concatenate(
		if #parts <= 2 then
			position#0
		else "[...]/" | demark("/", take(parts, -2)),
		if #position > 2 then (":", toString position#1, ":",
			toString position#2) else "",
		if #position > 4 then ("-", toString position#3, ":", toString position#4) else ""
	)
)
highlightGroup FilePosition := class' -> HLG "MarkupLink"
-- A source position links to its file, found on the load path.
rod FilePosition := position -> (
	file := position#0;
	found := select(prepend(file, apply(path, directory -> directory | file)),
		fileExists);
	opaque position ++ {Target => if #file > 0 and #found > 0 then
				urlEncode concatenate(
					"file://", toAbsolutePath first found,
					"#L", toString position#1, ":C", toString position#2,
					if #position > 4 then
						("-L", toString position#3, ":C", toString position#4) else ""
				)}
)
