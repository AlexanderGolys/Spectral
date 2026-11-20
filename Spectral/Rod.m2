-- The drawing itself: what a Rod is, the shapes it is built from, how a value
-- unfolds into one, and what every class draws as until its own block says otherwise.

-- A Rod is one shaped node with its parts in named fields, as a formula in
-- TeX is a tree of such constructs:
--   Atom      Text drawn as its Class, maybe with its own Tex: a name, a number, a sign
--   Row       Items set side by side; a line too long may break between them
--   Join      Items with a Separator between each two, as a list's entries
--   Script    a Base with a Sub, a Sup, or both, as x_2^2
--   Fraction  a Numerator over a Denominator
--   Fence     a Body between the Left and Right delimiters
--   Grid      Rows of cells, aligned as Align says: "Matrix" in parentheses,
--             "Bare", "LeftAligned", or "Aligned", whose last cell of a row runs
--             on; a matrix may carry the Degrees of its rows beside them
--   Over, Under  a Label above or below a Base
--   Diagram   Pieces {{row, column}, piece} joined by Arrows {from, to, label},
--             each end a {row, column}, the label null when there is none
--   Tree      Branches {label, subtree}, a hierarchy drawn branch by branch
-- Any node may carry a Highlight, the class it and its parts are coloured as
-- in place of their own, reaching Reach levels below it (all of them when
-- unset), and a Target it links to:
--   rod Ideal := I -> (lookup(rod, Thing)) I ++ {Highlight => Keyword} While drawn, a node also keeps the Class it is drawn as and the
-- Type of the value it stands for, which decide what is typeset.
-- 1/2 is Fraction{Atom{"1", ZZ}, Atom{"2", ZZ}}.
new Rod from List := (Rod, fields) -> hashTable fields
Rod ++ List := Rod => (node, fields) -> new Rod from merge(node,
	hashTable fields, last@@splice)
rod Rod := identity
net Rod := net@@speek

atom (String, Thing) := (text, class') -> new Rod from {
	Shape => "Atom",
	symbol Text => text,
	Class => class'
}
row List := items -> new Rod from {
	Shape => "Row",
	Items => items
}
joined (List, String, Thing) := (items, separator, class') -> new Rod from {
	Shape => "Join",
	Items => items,
	Separator => atom(separator, class')
}
listed (List, String, String) := (items, left, right) -> fence(left, right,
	joined(apply(items, rod), ", ", "Delimiter"))
script (Rod, Thing, Thing) := (base, sub, sup) -> new Rod from {
	Shape => "Script",
	Base => base,
	Sub => sub,
	Sup => sup
}
fraction (Rod, Rod) := (numerator, denominator) -> new Rod from {
	Shape => "Fraction",
	Numerator => numerator,
	Denominator => denominator
}
fence (String, String, Rod) := (left, right, body) -> new Rod from {
	Shape => "Fence",
	Left => left,
	Right => right,
	Body => body
}
parenthesized Rod := body -> fence("(", ")", body)
grid (List, String) := (rows, align) -> new Rod from {
	Shape => "Grid",
	Rows => rows,
	Align => align
}
labelled (String, Rod, Rod) := (shape, base, label) -> new Rod from {
	Shape => shape,
	Base => base,
	Label => label
}

-- Whether a node is drawn as `type`, or as something derived from it.
drawsAs (Rod, Type) := (node, type) -> (node#?Class
		and instance(node.Class, Type) and ancestor(type, node.Class))

-- The fields holding a node's parts, in the order the parts are read.
partFields := {Items, Separator, Base, Sub, Sup, Numerator, Denominator, Label,
	Body, Rows, Degrees, Pieces, Arrows, Straight, Branches}
-- The parts a node is drawn from: every Rod in its part fields.
parts Rod := node -> flatten apply(select(partFields, field -> node#?field),
	field -> nested node#field)
nested Thing := value -> {}
nested Rod := node -> {node}
nested VisibleList := items -> flatten apply(toList items, nested)

-- The value with every Rod in it passed through `change`.
changedIn (Thing, Function) := (value, change) -> value
changedIn (Rod, Function) := (node, change) -> change node
changedIn (VisibleList, Function) := (items, change) -> apply(items,
	item -> changedIn(item, change))
-- The node with each part passed through `change(field, part)`.
partsChanged (Rod, Function) := (node, change) -> new Rod from applyPairs(node,
	(field, value) -> (field, changedIn(value, part -> change(field, part))))

-- The nearest setting of `field` in the ancestry of `type`, which must be a `kind`.
nearestSetting (Symbol, Type, Type) := (field, type, kind) -> (
	setting := (first select(ancestors type, ancestor -> ancestor#?field))#field;
	if not instance(setting, kind) then
		error(toString field | " must be a " | toString kind);
	setting
)

-- Mark each atom whether it is typeset: by the class it is drawn as or the
-- class of the value it stands for, or for being held by a typeset value or an
-- operator, unless its class keeps a typewriter face. The script of a subscript
-- or superscript keeps its own setting; a node built only to lay out its parts
-- passes on what it was given.
typesetMarked (Rod, Boolean) := (node, forced) -> (
	if not (node#?Class or node#?symbol Type) then
		return partsChanged(node, (field, part) -> typesetMarked(part, forced));
	classes := apply({Class, symbol Type}, field -> if node#?field then
				node#field);
	setting := field -> any(classes, class' -> instance(class', Type)
			and nearestSetting(field, class', Boolean));
	mathematical := setting typeset;
	operator := setting typesetOperands;
	marked := not setting typewriter and (forced or mathematical or operator);
	indexed := any(classes, class' -> instance(class', Type)
			and (ancestor(Subscript, class') or ancestor(Superscript, class')));
	if node.Shape === "Atom" then
		node ++ {Typeset => marked}
	else partsChanged(node, (field, part) -> typesetMarked(part,
		if operator then
			not (indexed and member(field, {Sub, Sup}))
		else marked and mathematical))
)

-- Values being drawn: a container that holds itself is drawn once.
beingDrawn := new MutableList
-- How many more values may be unfolded inside the one being drawn; unset
-- outside a drawing.
unfoldable := null
-- Clear what a drawing that threw part-way left behind, so the next drawing
-- starts outside any; the shell calls it after every result.
forgetDrawing = () -> (beingDrawn = new MutableList; unfoldable = null)

-- A container drawn by `draw`, at the container's own depth; a container
-- already being drawn, which holds itself, is drawn opaque.
contentsOf (Thing, Function) := (container, draw) -> (
	if any(toList beingDrawn, ancestor -> ancestor === container) then
		return opaque container;
	beingDrawn#(#beingDrawn) = container;
	budget := unfoldable;
	result := try draw container
		else opaque container;
	unfoldable = budget;
	beingDrawn = new MutableList from drop(toList beingDrawn, -1);
	result ++ {symbol Type => class container}
)

-- Draw x from `shape`, its expression with each parameter spelled in place
-- given back as the parameter itself, so that it is drawn at the next depth.
unfolding (Thing, Thing) := (x, shape) -> (
	unfoldable ?? return rod'(nearestSetting(symbol valueDepth, class x, ZZ), x);
	name := placeholder x;
	if name =!= null and unfoldable <= 0 then
		return atom(name, Symbol) ++ {symbol Type => class x};
	held := fold((drawn, parameter) -> (
		spelled := expression parameter;
		substituted := part -> if part === spelled then
				Holder {parameter}
			else if instance(part, Expression) and not instance(part, Holder) then
			apply(part, substituted)
		else part;
		substituted drawn
	), shape, parameters x);
	if name =!= null then
		unfoldable -= 1;
	result := rod held ++ {symbol Type => class x};
	if name =!= null then
		unfoldable += 1;
	result
)

rod' (ZZ, Thing) := (depth, x) -> (
	outer := unfoldable;
	unfoldable = depth;
	result := rod x;
	unfoldable = outer;
	result
)

-- A part a drawing introduces for a structure, as {name, part, shape} or
-- {name, part, shape, level}: spelled by its name until the drawing has that
-- many levels left to unfold (one by default), then drawn from its shape.
Intermediate = new HeaderType of Expression
rod Intermediate := part -> (
	(name, component, shape) := toSequence take(part, 3);
	level := if #part > 3 then
			part#3
		else 1;
	if unfoldable =!= null and unfoldable < level then
		rod name ++ {symbol Type => class component}
	else rod shape ++ {symbol Type => class component}
)

-- Thing: what every class draws as until its own block says otherwise.
-- A value is drawn as what its expression is made of, down to expressions that
-- hold nothing but the value itself; its type is a bounded fold of its parts.
Thing.typeDepth = 1
Thing.valueDepth = 1
-- Whether a drawing is set as typeset maths: values of a mathematical type,
-- and the shapes only typesetting draws well. Whatever such a value holds is
-- typeset with it; anything typeset only to sit beside it, a name or a string
-- in the same list, keeps a typewriter face.
Thing.typeset = false
-- Operators set their operands as maths, all but the script of a subscript or
-- superscript. Containers only hold their entries, which keep their own setting.
Thing.typesetOperands = false
-- An operator's operands of a typewriter class still keep a typewriter face.
Thing.typewriter = false
-- A mathematical type is typed by the values it is built over rather than by
-- the parts of its expression.
Thing.typedByParameters = false
-- The shell's highlight group a value of the class is coloured as.
Thing.highlightGroup = "Text"
-- Structures whose kind goes by a conventional name are what the value depth
-- counts: past it an unnamed one keeps only that name.
placeholder Thing := Nothing => x -> null
-- The values a structure is built over, which its expression spells in place.
parameters Thing := x -> {}
-- What a value is drawn from.
spelledShape (Thing, Thing) := (x, shape) -> shape
-- Values whose expression holds nothing but themselves.
opaque Thing := x -> atom(spelling x, class x) ++ {symbol Type => class x}
spelling Thing := x -> try toString x else toString class x
rod Thing := x -> (
	shape := expression x;
	if instance(shape, Holder) and shape#0 === x then
		opaque x
	else if instance(shape, Holder) and instance(shape#0, Symbol) then
		rod shape#0
	else unfolding(x, spelledShape(x, shape))
)
specType Thing := x -> specType'(nearestSetting(symbol typeDepth, class x, ZZ), x)
-- Each level of a type below the outermost unfolds the values it is built
-- over, or the parts of its expression, one level further.
specType' (ZZ, Thing) := (depth, x) -> (
	shape := expression x;
	inner := if depth <= 1 then
			return rod class x
		else if nearestSetting(symbol typedByParameters, class x, Boolean) then
		apply(parameters x, parameter -> rod'(depth - 2, parameter))
	else if instance(shape, Expression) and not instance(shape, Holder) then
		apply(toList shape, part -> specType'(depth - 1,
			if instance(part, Holder) then
				part#0
			else part))
	else return rod class x;
	row {rod class x, fence("[", "]", joined(inner, ", ", "Delimiter"))}
)

-- speek x: the Rod x is drawn as, one level deep, as peek shows an object;
-- speek'(depth, x) shows it `depth` levels deep.
speek' (ZZ, Thing) := (depth, x) -> speek'(depth, rod x)
speek' (ZZ, Rod) := (depth, node) -> (
	if node.Shape === "Atom" then
		"Atom{" | format node.Text | ", " | toString node.Class | "}"
	else if depth <= 0 then
		node.Shape | "{...}"
	else node.Shape | "{" | demark(", ", apply(parts node, part ->
			speek'(depth - 1, part))) | "}"
)
speek Thing := x -> speek'(1, x)

-- What the shell is sent for a value or its type: the Rod with every atom's
-- Class and every Highlight named by the highlight group it is coloured as, a
-- type by its nearest highlightGroup. What only decides the drawing stays behind.
transmitted Rod := node -> (
	group := class' -> if instance(class', Type) then
			nearestSetting(symbol highlightGroup, class', String)
		else class';
	new Rod from join(
		select(pairs partsChanged(node, (field, part) -> transmitted part),
			(field, value) -> not member(field, {Class, symbol Type, Highlight})),
		if node.Shape === "Atom" then {Class => group node.Class} else {},
		if node.?Highlight then {Highlight => group node.Highlight} else {}
	)
)
drawnAs = x -> transmitted(try typesetMarked(rod x, false)
		else opaque x) ++ {
			Fallback => (try toString net x),
			Code => (try toString x)
		}
typedAs = x -> transmitted(try typesetMarked(specType x, false)
		else opaque class x)
