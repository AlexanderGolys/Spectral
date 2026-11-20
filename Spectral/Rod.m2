-- The drawing itself: what a Rod is, how a value unfolds into one, and what
-- every class draws as until its own block says otherwise.

-- Rod{shape} or Rod{shape, meta}, the meta a list of options:
--   Rod{Holder{"+"}, {Highlight => HLG "Operator"}}
--   Rod{Divide{rod 1, rod 2}}
new Rod from List := (Rod, contents) -> (
	meta := if #contents > 1 then
			contents#1
		else {};
	{contents#0, if instance(meta, HashTable) then
				meta
			else hashTable apply(meta, entry -> field entry#0 => entry#1)}
)
Rod ++ List := Rod => (node, fields) -> Rod {node#0, join(pairs node#1, fields)}
rod Rod := identity

-- A key names the field of drawingFields spelled as it is, whichever symbol it
-- was where it was written, so {Highlight => …} names Spectral's Highlight from
-- any package; any other key is an error.
field Symbol := key -> (
	named := select(drawingFields, field' -> toString field' == toString key);
	if #named == 0 then
		error("no field " | toString key | " of a drawing; there are "
				| demark(", ", apply(drawingFields, toString)))
	else first named
)

new HLG from String := (HLG, name) -> (
	if member(name, highlightGroups) then
		{name} else error("no highlight group " | format name | "; there are "
				| demark(", ", highlightGroups))
)
net HLG := toString HLG := group -> "HLG " | format group#0

-- A drawing prints as the expression it is.
net Rod := net@@first
toString Rod := toString@@first
texMath Rod := texMath@@first

shapeOf Thing := x -> (
	(select(ancestors class x, ancestor -> member(ancestor, shapes)))#0 ?? null
)

-- Spectral's shapes print as they are laid out: a label over or under its base
-- keeps the base's baseline; a diagram keeps its pieces in their places, without
-- the arrows text cannot draw; a tree indents each subtree beneath its label.
net UnderExpression := under -> net under#0 || net under#1

net OverExpression := over -> (
	(base, label) := (net over#0, net over#1);
	(label || base)^(depth label + height base)
)

net AlignedExpression := aligned -> netList(apply(toList aligned, toList),
	Boxes => false, HorizontalSpace => 1)

net DiagramExpression := diagram -> (
	places := hashTable apply(diagram#0, piece -> piece#0 => net piece#1);
	(rows, columns) := toSequence apply(2, k -> max apply(keys places, place ->
			place#k));
	netList(apply(rows + 1, row -> apply(columns + 1, column ->
			places#{ row, column } ?? "")), Boxes => false, HorizontalSpace => 1)
)

net TreeExpression := tree -> stack apply(toList tree, branch -> stack prepend(
	net branch#0, apply(unstack net branch#1, line -> "  " | line)
))

-- Whether a node is drawn as `type`, or as something derived from it.
drawsAs (Rod, Type) := (node, type) -> (node#1#?Class
		and ancestor(type, node#1#Class))

-- The drawings a node is drawn from, every Rod in its shape's parts.
parts Rod := node -> nested toList node#0
nested Thing := part -> {}
nested Rod := node -> { node }
nested BasicList := items -> flatten apply(toList items, nested)

-- A part with every Rod in it passed through `change`.
changedIn (Thing, Function) := (part, change) -> part
changedIn (Rod, Function) := (node, change) -> change node
changedIn (BasicList, Function) := (items, change) -> apply(items,
	item -> changedIn(item, change))
partsChanged (Rod, Function) := (node, change) -> Rod {
	new class node#0 from apply(#node#0, position -> changedIn(node#0#position,
		part -> change(position, part))),
	node#1
}

-- Mark each atom whether it is typeset: by the class it is drawn as or the
-- class of the value it stands for, or for being held by a typeset value or an
-- operator, unless its class keeps a typewriter face. The script of a subscript
-- or superscript, its second part, keeps its own setting; a node built only to
-- lay out its parts passes on what it was given.
typesetMarked (Rod, Boolean) := (node, forced) -> (
	meta := node#1;
	classes := select({ Class, symbol Type }, field -> meta#?field)/(field ->
			meta#field);
	setting := setting' -> any(classes, setting');
	operator := setting typesetOperands;
	marked := not setting typewriter and (forced or setting typeset or operator);
	indexed := any(classes, class' -> ancestor(Subscript, class')
			or ancestor(Superscript, class'));
	if shapeOf node#0 === Holder then
		node ++ { Typeset => marked }
	else if #classes == 0 then
		partsChanged(node, (position, part) -> typesetMarked(part, forced))
	else partsChanged(node, (position, part) -> typesetMarked(part,
		if operator then
			not (indexed and position == 1)
		else marked and setting typeset))
)

-- Values being drawn: a container that holds itself is drawn once.
beingDrawn := new MutableList
-- How many levels of notation the value being drawn unfolds, and that value,
-- which alone is spelled out from its definition though it has a name; both
-- unset outside a drawing.
unfoldable := null
outermost := null
-- Clear what a drawing that threw part-way left behind, so the next drawing
-- starts outside any; the shell calls it after every result.
forgetDrawing = () -> (
	beingDrawn = new MutableList;
	(unfoldable, outermost) = (null, null)
)
drawnWithin (ZZ, Thing, Function) := (depth, x, draw) -> (
	(outer, spelled) := (unfoldable, outermost);
	if outer === null then
		outermost = x;
	unfoldable = depth;
	result := draw();
	(unfoldable, outermost) = (outer, spelled);
	result
)

-- The global name each value of a class keeping names was last assigned to,
-- which it is drawn by from then on, as M2 spells a ring by its name: `=` hides
-- a value behind its name, `:=` keeps it spelled out. A name is forgotten when
-- it is assigned something else.
globalNames := new MutableHashTable
keepNames Type := class' -> (
	(assigned, released) := (lookup(GlobalAssignHook, class'),
		lookup(GlobalReleaseHook, class'));
	class'.GlobalAssignHook = (name, x) -> (
		if assigned =!= null then
			assigned(name, x);
		if not globalNames#?x then
			globalNames#x = name
	);
	class'.GlobalReleaseHook = (name, x) -> (
		if released =!= null then
			released(name, x);
		if globalNames#?x and globalNames#x === name then
			remove(globalNames, x)
	);
)
globalName Thing := x -> if globalNames#?x then globalNames#x

-- A container drawn by `draw`, at the container's own depth; a container
-- already being drawn, which holds itself, is drawn opaque.
contentsOf (Thing, Function) := (container, draw) -> (
	unfoldable ?? return rod'(valueDepth class container, container);
	if any(toList beingDrawn, ancestor -> ancestor === container) then
		return opaque container;
	beingDrawn#(#beingDrawn) = container;
	budget := unfoldable;
	result := try draw container
		else opaque container;
	unfoldable = budget;
	beingDrawn = new MutableList from drop(toList beingDrawn, -1);
	result ++ { symbol Type => class container }
)

-- Draw x from `shape`, its expression with each parameter spelled in place
-- given back as the parameter itself, so that it is drawn in its turn; a named
-- x is drawn by its name.
unfolding (Thing, Thing) := (x, shape) -> (
	unfoldable ?? return rod'(valueDepth class x, x);
	name := if x =!= outermost then
			globalName x;
	if name =!= null then
		return rod name;
	held := fold((drawn, parameter) -> (
		spelled := expression parameter;
		substituted := part -> if part === spelled then
				Holder { parameter }
			else if instance(part, Expression) and not instance(part, Holder) then
			apply(part, substituted)
		else part;
		substituted drawn
	), shape, parameters x);
	rod held ++ { symbol Type => class x }
)

rod' (ZZ, Thing) := (depth, x) -> drawnWithin(depth, x, () -> rod x)

-- A part a drawing introduces for a structure, as {name, part, shape} or
-- {name, part, shape, level}: spelled by its name until the drawing unfolds
-- more levels than that (one by default), then drawn from its shape.
Intermediate = new HeaderType of Expression
rod Intermediate := part -> (
	(name, component, shape) := toSequence take(part, 3);
	level := if #part > 3 then
			part#3
		else 1;
	if unfoldable =!= null and unfoldable <= level then
		rod name ++ { symbol Type => class component }
	else rod shape ++ { symbol Type => class component }
)

-- Thing: what every class draws as until its own block says otherwise.
-- A value is drawn as what its expression is made of, down to expressions that
-- hold nothing but the value itself; its type is a bounded fold of its parts.
typeDepth Thing := valueDepth Thing := class' -> 1
-- Whether a drawing is set as typeset maths: values of a mathematical type,
-- and the shapes only typesetting draws well. Whatever such a value holds is
-- typeset with it; anything typeset only to sit beside it, a name or a string
-- in the same list, keeps a typewriter face.
typeset Thing := class' -> false
-- Operators set their operands as maths, all but the script of a subscript or
-- superscript. Containers only hold their entries, which keep their own setting.
typesetOperands Thing := class' -> false
-- An operator's operands of a typewriter class still keep a typewriter face.
typewriter Thing := class' -> false
-- A mathematical type is typed by the values it is built over rather than by
-- the parts of its expression.
typedByParameters Thing := class' -> false
highlightGroup Thing := class' -> HLG "Text"
-- The values a structure is built over, which its expression spells in place.
parameters Thing := x -> {}
-- What a value is drawn from.
spelledShape (Thing, Thing) := (x, shape) -> shape
definition Thing := expression
optionsDropped Thing := identity
optionsDropped Expression := shape -> apply(shape, optionsDropped)
optionsDropped Array := items -> new Array from apply(select(toList items, item ->
		not (instance(item, BinaryOperation) and item#0 === symbol =>)),
	optionsDropped)
-- Values whose expression holds nothing but themselves.
opaque Thing := x -> Rod { Holder { spelling x }, {
	Class => class x,
	symbol Type => class x
} }
spelling Thing := x -> try toString x else toString class x
rod Thing := x -> (
	unfoldable ?? return rod'(valueDepth class x, x);
	shape := if x === outermost then
			definition x
		else expression x;
	if instance(shape, Holder) and shape#0 === x then
		opaque x
	else if instance(shape, Holder) and instance(shape#0, Symbol) then
		rod shape#0
	else unfolding(x, spelledShape(x, shape))
)
specType Thing := x -> specType'(typeDepth class x, x)
-- Each level of a type below the outermost unfolds the values it is built
-- over, or the parts of its expression, one level further. A type is drawn
-- inside the drawing of its value, so what the value is built over is drawn by
-- its name.
specType' (ZZ, Thing) := (depth, x) -> (
	unfoldable ?? return drawnWithin(valueDepth class x, x, () ->
			specType'(depth, x));
	shape := expression x;
	inner := if depth <= 1 then
			return rod class x
		else if typedByParameters class x then
		apply(parameters x, parameter -> rod'(depth - 2, parameter))
	else if instance(shape, Expression) and not instance(shape, Holder) then
		apply(toList shape, part -> specType'(depth - 1,
			if instance(part, Holder) then
				part#0
			else part))
	else return rod class x;
	Rod { RowExpression { rod class x, Rod { new Array from inner } } }
)

-- speek x: x inspected as peek inspects it, `depth` levels of containers deep,
-- one by default: a list or an expression as its class over its entries, a
-- table as its class, its parent when it has one, and its pairs sorted as peek
-- sorts them; anything else, and anything past the depth, drawn as itself.
-- A Rod is a table too, so speek'(3, rod x) shows the tree x is drawn as.
speek' (ZZ, Thing) := (depth, x) -> rod x
speek' (ZZ, BasicList) := (depth, items) -> (
	if depth <= 0 then
		rod items
	else Rod { RowExpression { rod class items, Rod { apply(toList items, item ->
			speek'(depth - 1, item)) } } }
)
speek' (ZZ, HashTable) := (depth, table) -> (
	if depth <= 0 then
		rod table
	else Rod { RowExpression {
		if parent table =!= Nothing then
			Rod { RowExpression { rod class table, Rod { Holder { " of " },
				{ Highlight => HLG "Keyword" } }, rod parent table } }
		else rod class table,
		tabulated apply(sort(pairs table, toString@@first), (key, entry) ->
				(optionKey key, speek'(depth - 1, entry)))
	} }
)
speek Thing := x -> speek'(1, x)

-- What the shell is sent for a value, its type or its inspection: the shape's
-- name, its Parts and its options as fields of their own, and what the drawing
-- says of how it is drawn, an atom's colour named by the highlight group of its
-- Class and a Highlight by its own, a type by its highlightGroup. What only
-- decides the drawing stays behind.
transmitted Rod := node -> (
	(shape, meta) := toSequence node;
	group := class' -> (if instance(class', Type) then
				highlightGroup class'
			else class')#0;
	options := select(toList shape, part -> instance(part, Option));
	hashTable join(
		{
			Shape => toString shapeOf shape,
			Parts => apply(select(toList shape,
				part -> not instance(part, Option)), part -> changedIn(part,
					transmitted))
		},
		apply(options, option -> option#0 => changedIn(option#1, transmitted)),
		select(pairs meta, (field, value) -> not member(field, { Class,
			symbol Type, Highlight })),
		if shapeOf shape === Holder and meta#?Class then { Group =>
				group meta#Class } else {},
		if meta#?Highlight then { Highlight => group meta#Highlight } else {}
	)
)
transmitted (Function, Thing, Thing) := (draw, x, fallback) -> transmitted(
	try typesetMarked(draw x, false)
	else opaque fallback
)
drawnAs = x -> transmitted(x -> rod x ++ {
	Fallback => (try toString net x),
	Code => (try toString x)
}, x, x)
typedAs = x -> transmitted(specType, x, class x)
inspectedAs = x -> transmitted(speek, x, x)
