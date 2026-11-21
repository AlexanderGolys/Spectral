-- Values where their expression is not the whole story: what M2 spells by
-- itself, coloured and set as its class says; rings, modules and containers;
-- the language's own objects; and the types beside values.

-- How a leaf of each class is coloured and set.
highlightGroup Thing := HLG => class' -> HLG "Text"
highlightGroup Number := HLG => class' -> HLG "Number"
highlightGroup Symbol := HLG => class' -> HLG "Variable"
highlightGroup RingElement := HLG => class' -> HLG "Variable"
highlightGroup Ring := HLG => class' -> HLG "Type"
highlightGroup RingFamily := HLG => class' -> HLG "Type"
highlightGroup Type := HLG => class' -> HLG "Type"
highlightGroup String := HLG => class' -> HLG "String"
highlightGroup Function := HLG => class' -> HLG "Function"
highlightGroup ScriptedFunctor := HLG => class' -> HLG "Function"
highlightGroup Command := HLG => class' -> HLG "Macro"
highlightGroup Keyword := HLG => class' -> HLG "Keyword"
highlightGroup Boolean := HLG => class' -> HLG "Boolean"
highlightGroup Nothing := HLG => class' -> HLG "Builtin"
highlightGroup Package := HLG => class' -> HLG "Package"
font Thing := String => class' -> "TextTT"
font Number := String => class' -> "MathNormal"
font RingElement := String => class' -> "MathNormal"
font Ring := String => class' -> "MathNormal"
font RingFamily := String => class' -> "MathNormal"
font ScriptedFunctor := String => class' -> "MathNormal"
typewritten = (text, group) -> atom(text, group, "TextTT")

-- A name stands for the value it holds, coloured and set as that value is.
shape Symbol := name -> atom(toString name, highlightGroup class value name,
	font class value name)
-- A name in what a ring's value is spelled by that is one of the ring's
-- generators is held as a generator, and set as a ring element is whatever the
-- name holds now: the T of a degrees ring, unbound in the session, as 1 - T^2.
Generator = new WrapperType of Holder
shape Generator := held -> atom(toString held#0, highlightGroup RingElement, font RingElement)
generatorsHeld = method()
generatorsHeld(Thing, List) := (part, names) -> part
generatorsHeld(Symbol, List) := (name, names) -> (
	if member(name, names) then
		Generator { name }
	else name
)
generatorsHeld(BasicList, List) := BasicList => (parts, names) ->
	apply(parts, part -> generatorsHeld(part, names))
-- The names a ring's generators are spelled by, its coefficient rings' too: the
-- a of a_1, and none for a ring no generators build, as ZZ or QQ.
generatorNames = method()
generatorNames Ring := List => ring' -> {}
generatorNames PolynomialRing := List => ring' -> join(gens ring' / generatorName @@ baseName,
	generatorNames coefficientRing ring')
generatorNames QuotientRing := List => generatorNames @@ ambient
generatorNames GaloisField := List => generatorNames @@ ambient
generatorNames FractionField := List => generatorNames @@ baseRing
generatorName = method()
generatorName Symbol := Symbol => identity
generatorName IndexedVariable := Symbol => variable -> variable#0
shape RingElement := element ->
	shape generatorsHeld(expression element, generatorNames ring element)
shape Matrix := matrix' -> shape generatorsHeld(expression matrix', generatorNames ring matrix')
shape Ideal := ideal' -> shape generatorsHeld(expression ideal', generatorNames ring ideal')
-- An operator keyword is coloured as an operator; any other is a keyword.
shape Keyword := keyword -> typewritten(toString keyword,
	if operatorAttributes#?keyword then
		HLG "Operator"
	else highlightGroup Keyword)
-- An inexact number is a numeral, whatever its sign; null is spelled as M2 spells it.
shape InexactNumber := number -> atom(toString number, highlightGroup class number,
	font class number)
shape Nothing := nothing -> atom(toString nothing, highlightGroup Nothing, font Nothing)

-- A ring is drawn by what it is built from, as M2 describes it, without the
-- options only a description lists: QQ[x, Degrees => {1}] is QQ[x]. A ring M2
-- describes as itself is its name, QQ and ZZ their doubled letter in the
-- blackboard alphabet maths writes them in: ℚ, ℤ.
shape Ring := ring' -> (
	description := (describe ring')#0;
	if ring' === QQ or ring' === ZZ then
		atom(first characters toString ring', highlightGroup Ring, "MathBB")
	else if instance(description, Ring) then
		atom(toString ring', highlightGroup class ring', font class ring')
	else shape generatorsHeld(optionsDropped description, generatorNames ring')
)
optionsDropped = method(Dispatch => Thing)
optionsDropped Thing := identity
optionsDropped Expression := BasicList => e -> apply(e, optionsDropped)
optionsDropped Holder := identity
optionsDropped Array := BasicList => items -> select(items, item ->
		not (instance(item, BinaryOperation) and item#0 === symbol =>))
-- RR and CC are ℝ and ℂ; any other family of fields, as RRi, is its name.
shape InexactFieldFamily := family -> (
	if family === RR or family === CC then
		atom(first characters toString family, highlightGroup class family, "MathBB")
	else atom(toString family, highlightGroup class family, font class family)
)
-- The structure sheaf OO is 𝒪; any other functor, as Ext or HH, is its name.
shape ScriptedFunctor := functor -> (
	if functor === OO then
		atom(first characters toString functor, highlightGroup ScriptedFunctor, "MathCal")
	else atom(toString functor, highlightGroup ScriptedFunctor, font ScriptedFunctor)
)

-- A module's rank is an index on it, as in R^2, and M2 spells rank one as an
-- explicit ^1 its type already tells apart from the base; a sheaf is spelled as
-- a module is, each summand of OO_X^1(1) ++ OO_X^1(2) too.
rankOneDropped = method(Dispatch => Thing)
rankOneDropped Thing := identity
rankOneDropped Adjacent := BasicList => application -> apply(application, rankOneDropped)
rankOneDropped DirectSum := BasicList => summands -> apply(summands, rankOneDropped)
rankOneDropped Superscript := power -> (
	if instance(power#1, OneExpression) then
		power#0
	else power
)
shape Module := module' ->
	shape rankOneDropped generatorsHeld(expression module', generatorNames ring module')
shape CoherentSheaf := sheaf -> shape rankOneDropped expression sheaf
-- A mutable matrix is drawn as a matrix is, without the mark M2 spells it apart by.
shape MutableMatrix := matrix' -> shape generatorsHeld(select(expression matrix', entries ->
		not (instance(entries, Option) and entries#0 === symbol MutableMatrix)),
	generatorNames ring matrix')

-- `key => value`, the key coloured as an option's name is in code when it is
-- spelled by a symbol or a string, whatever builds the pair.
optionKey = method(Dispatch => Thing)
optionKey Thing := shape
optionKey Holder := key -> optionKey key#0
optionKey Symbol := key -> typewritten(toString key, HLG "Option")
optionKey String := key -> typewritten(key, HLG "Option")
arrow = typewritten(toString symbol =>, HLG "Operator")
shape Option := pair -> row { optionKey pair#0, space, arrow, space, shape pair#1 }

-- Pairs stacked between braces, keys, arrows and values aligned.
tabulated = pairs' -> shaped(VerticalList, { shaped(AlignedExpression,
	((key, entry) -> { optionKey key, arrow, shape entry }) \ toList pairs') })
-- A table keeping the stock formatting shows its pairs; any other is drawn by
-- its expression, as any value is: a type, a package or a Gröbner basis is a
-- table too, which no one means to read pair by pair.
shape HashTable := table -> (
	stock := kind -> lookup(expression, class table) === lookup(expression, kind)
		and lookup(net, class table) === lookup(net, kind);
	if stock HashTable or stock MutableHashTable then
		tabulated pairs table
	else (lookup(shape, Thing)) table
)
-- A tally is the table of its counts, and a numbered list the table of its
-- items by their places, as M2 numbers them.
shape VirtualTally := tabulated@@pairs
shape NumberedVerticalList := tabulated@@pairs

-- A mutable list and a partition are lists apart from their names, which the
-- type beside them gives; a set lists its members in the order its keys come.
shape MutableList := shape@@toList
shape Partition := shape@@toList
shape Set := shape@@keys

-- Betti numbers in the table M2 sets them in, each cell as M2 spells it: the
-- homological degrees above, a row for each slanted degree under the totals,
-- each beginning with its label, and a count of none in the mark M2 sets for it,
-- coloured as a label is.
shape BettiTally := b -> (
	degrees := sort unique(first \ keys b);
	slants := sort unique((key -> key#2 - key#0) \ keys b);
	counted := chosen -> sum(select(keys b, chosen), key -> b#key);
	counts := prepend((i -> counted(key -> key#0 == i)) \ degrees,
		(slant -> (i -> counted(key -> key#0 == i and key#2 - key#0 == slant))
				\ degrees) \ slants);
	cells := (line -> select(separate(" ", line), cell -> #cell > 0)) \ unstack net b;
	label := text -> typewritten(text, HLG "Muted");
	count := (text, n) -> typewritten(text, if n == 0 then
				HLG "Muted"
			else HLG "Number");
	shaped(Table, prepend(prepend(label concatenate(), (degree ->
			typewritten(degree, HLG "Number")) \ first cells),
		((row', counts') -> prepend(label first row', count@@toSequence \ transpose {
			drop(row', 1), counts'
		}))@@toSequence \ transpose { drop(cells, 1), counts }))
)

-- A type is its name, but one M2 spells with a star beneath it, the class of
-- the numbers of every precision, is that name subscripted by the star: RR' is ℝ_*.
shape Type := type' -> (
	rows := unstack net type';
	if #rows == 2 and replace(" ", "", rows#1) == "*" then
		shape Subscript { value rows#0, symbol * }
	else atom(toString type', highlightGroup Type, font Type)
)
-- A class hierarchy is a tree of what each class holds, each level sorted as
-- M2's own net sorts it, each drawn as the value it is: a type by its name, ZZ
-- as ℤ, InexactNumber^* with its star raised, a command as a command.
shape Descent := tree -> shaped(TreeExpression, ((class', subtree) ->
		{ shape class', shape subtree })
		\ sort(pairs tree, toString@@net@@first))

-- The language's own objects: text, timings, counters and indexed variables.
-- Text is its lines, coloured as its class is, a string as a string; a timing
-- is its value above the line M2 says how long it took on.
lined = (lines', group) -> shaped(Table, (line -> { typewritten(line, group) }) \ lines')
shape Net := text -> lined(unstack net text, highlightGroup class text)
shape Time := timed -> shaped(Table, { { shape timed#1 },
	{ typewritten(last unstack net timed, HLG "Comment") } })
shape AtomicInt := counter -> shape new ZZ from counter
shape IndexedVariable := variable -> shape Subscript toList variable

-- A function is spelled by its name, or shown by its code when it has none. The
-- code at a position is cut from the lines M2 shows for it, from its file, the
-- current input or the history.
shape Function := function' -> (
	position := locate function';
	name := toString function';
	shown := if position =!= null and not (isGlobalSymbol name
			and value getGlobalSymbol name === function') then
			try code position;
	if shown === null then
		atom(name, highlightGroup class function', font class function')
	else (
		lines' := select(toList (last shown)#0, line -> instance(line, String));
		if #position > 4 then (
			lines' = append(drop(lines', -1), substring(last lines', 0, position#4));
			lines' = prepend(substring(first lines', position#2), drop(lines', 1))
		);
		lined(lines', highlightGroup Net)
	)
)
-- A command is spelled by its name, or shown as the function it runs when no
-- global name holds it.
shape Command := command -> (
	name := toString command;
	if isGlobalSymbol name and value getGlobalSymbol name === command then
		atom(name, highlightGroup Command, font Command)
	else shape command#0
)

-- A file is spelled with its name and the directory holding it, the directories
-- above those left out: /a/b/c/file.m2 as [...]/c/file.m2. A source position is
-- spelled as M2 spells it, its file so shortened, and links to its file, found
-- on the load path; a function, and a command, links to its source.
shortenedFile = file -> (
	directories := select(separate(Spelling.PathSeparator, file), part -> #part > 0);
	kept := 2;
	if #directories <= kept then
		file
	else demark(Spelling.PathSeparator, prepend(Spelling.Elided, take(
		directories, -kept
	)))
)
shortened = position -> shortenedFile position#0 | substring(
	toString position, #position#0
)
shape FilePosition := position -> typewritten(shortened position, HLG "MarkupLink")
location = method(Dispatch => Thing)
location Thing := Nothing => x -> null
location Function := function' -> (
	position := locate function';
	if position =!= null then
		location position
)
location Command := command -> location command#0
location FilePosition := position -> (
	file := position#0;
	found := select(prepend(file, (directory -> directory | file) \ path), fileExists);
	if #position > 2 and #file > 0 and #found > 0 then
		urlEncode concatenate(Spelling.FileScheme, toAbsolutePath first found,
			Spelling.LineMark, toString position#1, Spelling.ColumnMark,
			toString position#2,
			if #position > 4 then (Spelling.RangeMark, toString position#3,
				Spelling.ColumnMark, toString position#4))
)

-- The type beside a value: its class, over the values it is built over where it
-- is, by their names.
typeShape Thing := shape@@class
over = (x, parameters) -> row { shape class x, shape new Array from parameters }
-- An ideal, a module, a complex and a sheaf are over their ring.
typeShape Ideal := ideal' -> over(ideal', { ring ideal' })
typeShape Module := module' -> over(module', { ring module' })
typeShape Complex := complex -> over(complex, { ring complex })
typeShape CoherentSheaf := sheaf -> over(sheaf, { ring sheaf })
-- A sheaf of rings is over its variety.
typeShape SheafOfRings := sheaf -> over(sheaf, { variety sheaf })
-- A map is from its source to its target.
typeShape Matrix := map' -> over(map', { MapExpression { map'.target, map'.source } })
typeShape SheafMap := map' -> over(map', { MapExpression { map'.target, map'.source } })
