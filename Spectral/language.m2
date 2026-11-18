-- The language's own objects: text, names, keywords, functions and the source
-- positions they come from. None of them is maths, even as an operand.

String.typewriter = true
spelling String := identity

Net.typewriter = true
-- A net is its lines one under another; a string, one line of them, is spelled
-- by itself.
lined (List, Thing) := (lines, class') -> grid(apply(lines, line -> {atom(line,
	class')}), "Bare")
rod Net := text -> lined(unstack text, Net)
rod String := lookup(rod, Thing)

-- Handles on what the language runs on are spelled by their names, never maths.
scan({Dictionary, File, NetFile, Database, Task, Mutex, Error, FunctionBody,
	Pseudocode, SymbolBody, Manipulator}, class' ->
		class'.typewriter = true)
-- A timed value is the value with the time it took beneath, as M2 prints it.
rod Time := timed -> grid({{rod timed#1}, {atom("-- " | toString timed#0
		| " seconds", "Comment")}}, "Bare")

-- An atomic integer is the integer it holds.
rod AtomicInt := counter -> rod(new ZZ from counter) ++ {symbol Type => AtomicInt}
Boolean.typewriter = true
Nothing.typewriter = true

-- A name stands for its value.
opaque Symbol := name -> (lookup(opaque, Thing)) name ++ {symbol Type => class value name}

-- An indexed variable x_1 is drawn as the subscript it is spelled with.
rod IndexedVariable := variable -> rod new Subscript from toList variable

-- An operator keyword is coloured as an operator; any other as a keyword.
rod Keyword := keyword -> opaque keyword ++ {
	Highlight => if operatorAttributes#?keyword then
			"Operator"
		else Keyword
}

-- A function links to its source.
Function.typewriter = true
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
						sourceTarget position
			}
)

-- A source position is linked by its file, found on the load path, and spelled
-- with the file's name and one directory above it.
sourceTarget FilePosition := position -> (
	file := position#0;
	found := select(prepend(file, apply(path, directory -> directory | file)),
		fileExists);
	if #file > 0 and #found > 0 then
		urlEncode concatenate(
			"file://", toAbsolutePath first found,
			"#L", toString position#1, ":C", toString position#2,
			if #position > 3 then
				("-L", toString position#3, ":C", toString position#4) else ""
		)
)
foldedPath String := path -> (
	parts := select(separate("/", path), part -> part != "");
	parents := drop(parts, -1);
	if #parents == 0 then
		last parts
	else if #parents == 1 then
		(if first path == "/" then
					"/"
				else "") | demark("/", parts)
	else "[...]/" | demark("/", take(parts, -2))
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
spelling FilePosition := position -> concatenate(
	foldedPath position#0, ":", toString position#1, ":", toString position#2,
	if #position > 3 then
		("-", toString position#3, ":", toString position#4) else ""
)
rod FilePosition := position -> opaque position ++ {
	symbol Text => spelling position,
	Target => sourceTarget position
}
