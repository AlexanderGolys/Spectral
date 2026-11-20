-- The drawing itself: what a Rod is, and how a value is drawn into one by its
-- value, the global names inside it resolved as many times as asked.

-- Rod{shape, field => value, …}: a drawing of `shape` with the given fields;
-- a field given as null is not set, so one may be given only when it applies.
--   Rod{Holder{"+"}, Highlight => HLG "Operator"}
--   Rod{Holder{"x"}, Group => if bound then HLG "Variable"}
new Rod from List := (Rod, contents) -> hashTable select(prepend(Shape => first contents,
	drop(contents, 1)), field -> field#1 =!= null)
-- node ++ {field => value, …}: the drawing with those fields set anew.
Rod ++ List := Rod => (node, fields) -> merge(node, Rod prepend(node.Shape, fields),
	last)

new HLG from String := (HLG, name) -> (
	if member(name, highlightGroups) then
		{name} else error("no highlight group " | format name | "; there are "
				| demark(", ", highlightGroups))
)
net HLG := toString HLG := group -> "HLG " | format group#0

-- A part of a shape with every drawing in it passed through `change`: the lists
-- a shape arranges its parts in are kept, anything else is left as it is.
throughRods := (part, change) -> (
	if instance(part, Rod) then
		change part
	else if instance(part, BasicList) then
		apply(part, item -> throughRods(item, change))
	else part
)

-- A drawing prints as the expression it is: its shape with every part's
-- expression in place of the part.
expression Rod := node -> throughRods(node#Shape, expression)
net Rod := net@@expression
toString Rod := toString@@expression
texMath Rod := texMath@@expression

-- Spectral's shapes print as they are laid out, as text too: a label over or
-- under its base keeps the base's baseline; a diagram keeps its pieces in
-- their places, without the arrows text cannot draw; a tree indents each
-- subtree beneath its label.
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
scan({UnderExpression, OverExpression, AlignedExpression, DiagramExpression,
	TreeExpression}, shape -> toString shape := toString@@net)

-- The drawing in progress: the value it is of, which alone is drawn by its
-- value though a name holds it; how many more times a global name inside it is
-- resolved to its value; the values being drawn, so that a container holding
-- itself is drawn once; and the global name of each value of the named
-- classes. All unset outside a drawing; the shell clears what a drawing that
-- threw part-way left behind after every result.
outermost := null
resolutions := null
beingDrawn := {}
globalNames := null
forgetDrawing = () -> (outermost, resolutions, beingDrawn, globalNames) = (null,
	null, {}, null)

-- The user's values of the named classes by their global names, a value held
-- by several by the first of them in alphabetical order.
userNames := () -> (
	dictionary := User#"private dictionary";
	names := new MutableHashTable;
	scan(sort keys dictionary, name -> (
		x := value dictionary#name;
		if any(namedClasses, class' -> instance(x, class')) and not names#?x then
			names#x = name
	));
	names
)

-- draw() run in the drawing of x, resolving `depth` names; a drawing inside
-- none is the drawing of x.
within := (depth, x, draw) -> (
	starting := resolutions === null;
	if starting then
		(outermost, globalNames) = (x, userNames());
	outer := resolutions;
	resolutions = depth;
	drawn := draw();
	resolutions = outer;
	if starting then
		forgetDrawing();
	drawn
)

-- A value Spectral cannot draw, spelled as M2 spells it.
spelledAsM2 = x -> Rod { Holder { try toString x
		else toString class x },
	Class => class x, Group => HLG "Text" }

-- The expression of a value with each value it is built over that a global
-- name holds drawn in its place: a parameter is a value spelled by its
-- expression, held or bare, as M2 spells a named ring R by Holder{R} or R
-- itself, or `spelling => value` for one spelled otherwise.
heldInPlace := (shape, parameters) -> fold((held, parameter) -> (
	(spelling, x) := if instance(parameter, Option) then
			toSequence parameter
		else (expression parameter, parameter);
	bare := if instance(spelling, Holder) then
			spelling#0;
	inPlace := part -> if part === spelling or part === bare then
			Holder { x }
		else if instance(part, Expression) and not instance(part, Holder) then
		apply(part, inPlace)
	else part;
	if globalNames#?x then
		inPlace held
	else held
), shape, parameters)

-- x drawn by its value: laid out by its class's rod and marked with its class
-- unless it says what it is laid out as. A drawing listing Parameters is yet
-- to be drawn: its Shape is the expression of a value, drawn in turn with its
-- other fields kept.
drawnByValue := x -> (
	if instance(x, Rod) then
		return (if x#?Parameters then
					rod' heldInPlace(x#Shape, x#Parameters) ++ apply(select(pairs x,
						(key, value) -> key =!= Shape and key =!= Parameters),
						(key, value) -> key => value)
				else x);
	draw := lookup(rod, class x);
	if draw === null or any(beingDrawn, held -> held === x) then
		return spelledAsM2 x;
	beingDrawn = append(beingDrawn, x);
	drawn := draw x;
	beingDrawn = drop(beingDrawn, -1);
	if drawn#?Class then
		drawn
	else drawn ++ { Class => class x }
)

-- rod' x, a part of the drawing in progress: by the global name holding it
-- while names are left unresolved, by its value with one resolution fewer when
-- they are resolved, and by its value when no name holds it. Outside a
-- drawing it begins one, resolving none. rod'_n x: x drawn by its value, the
-- names inside it resolved n times.
rod' = deepened(x -> (
	if resolutions === null then
		return within(0, null, () -> rod' x);
	name := if x =!= outermost and globalNames#?x then
			globalNames#x;
	if name === null then
		drawnByValue x
	else if resolutions == 0 then
		Rod { Holder { name }, Class => Symbol, Group => HLG "Variable",
			Typeset => true }
	else within(resolutions - 1, x, () -> drawnByValue x)
), (depth, x) -> within(depth, x, () -> drawnByValue x))
rod Rod := rod'

-- A type annotation: the class of x over its typeParameters, by their names
-- until `depth` resolves them: R^2 is Module[R], and at depth one
-- Module[QQ[x, y]] for R = QQ[x, y].
typeParameters Thing := x -> {}
specType' = deepened(x -> specType x, (depth, x) -> within(0, x, () -> (
	type := rod' class x;
	parameters := typeParameters x;
	if #parameters == 0 then
		type
	else Rod { RowExpression { type, Rod { new Array from apply(parameters,
		parameter -> within(depth, x, () -> rod' parameter)) } } }
)))
specType Thing := specType'_0

-- The shape an expression is drawn as, the nearest of its class's ancestors
-- among the shapes.
shapeOf := shape -> (
	(select(ancestors class shape, ancestor -> member(ancestor, shapes)))#0
)

-- A drawing as the shell is sent it: its shape's name, its Parts and its
-- options as fields of their own, and what it says of how it is drawn, every
-- colour by its highlight group's name. An atom is typeset as it says, or as
-- the drawing holding it is when it says nothing, a drawing saying nothing
-- passing on what it was given. What only decides the drawing stays behind.
drawnHere := { Shape, Class, Parameters, Typeset, Group, Highlight }
transmitted := (node, forced) -> (
	shape := node#Shape;
	typeset := if node#?Typeset then
			node#Typeset
		else forced;
	sent := part -> throughRods(part, part' -> transmitted(part', typeset));
	parts := select(toList shape, part -> not instance(part, Option));
	options := select(toList shape, part -> instance(part, Option));
	atom := shapeOf shape === Holder;
	hashTable join(
		{
			"Shape" => toString shapeOf shape,
			"Parts" => apply(parts, sent)
		},
		apply(options, option -> toString option#0 => sent option#1),
		apply(select(pairs node, (key, value) -> not member(key, drawnHere)),
			(key, value) -> toString key => value),
		if atom then { "Typeset" => typeset } else {},
		if atom and node#?Group then { "Group" => node#Group#0 } else {},
		if node#?Highlight then { "Highlight" => node#Highlight#0 } else {}
	)
)

-- What the shell is sent for a value, its type and its structure; a drawing a
-- broken rod throws out of is sent as the fallback's own text.
sent := (draw, x, fallback) -> transmitted(try draw x
		else spelledAsM2 fallback,
	false)
drawnAs = x -> sent(x -> rod'_0 x ++ {
	Fallback => (try toString net x),
	Code => (try toString x)
}, x, x)
typedAs = x -> sent(specType, x, class x)
inspectedAs = x -> sent(speek, x, x)
