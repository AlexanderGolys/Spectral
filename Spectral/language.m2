-- The language's own objects: text, names, keywords, functions and the source
-- positions they come from. None of them is maths, even as an operand.

String.typewriter = true
spelling String := identity

Net.typewriter = true
Boolean.typewriter = true
Nothing.typewriter = true

-- A name stands for its value.
opaque Symbol := name -> (lookup(opaque, Thing)) name ++ {symbol Type => class value name}

-- An indexed variable x_1 is drawn as the subscript it is spelled with.
specNet IndexedVariable := variable -> specNet new Subscript from toList variable

-- An operator keyword is coloured as an operator; any other as a keyword.
specNet Keyword := keyword -> opaque keyword ++ {
	Highlight => if operatorAttributes#?keyword then
			"Operator"
		else Keyword
}

-- A function links to its source.
Function.typewriter = true
specNet Function := function -> opaque function ++ {
	Target => (position := locate function;
		if position =!= null then
			sourceTarget position)
}

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
spelling FilePosition := position -> concatenate(
	foldedPath position#0, ":", toString position#1, ":", toString position#2,
	if #position > 3 then
		("-", toString position#3, ":", toString position#4) else ""
)
specNet FilePosition := position -> opaque position ++ {
	symbol Text => spelling position,
	Target => sourceTarget position
}
