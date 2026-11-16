-- The drawing itself: what a SpecNet is, how a value unfolds into one, and what
-- every class draws as until its own block says otherwise.

-- A drawing is a class laid out over ordered children; an opaque one is spelled
-- by its text instead. Further fields annotate it: `drawing ++ {Tex => …}`.
new SpecNet from Sequence := (SpecNet, shape) -> hashTable {
	Classes => shape#0,
	Children => toList shape#1,
	symbol Text => null
}

SpecNet ++ List := SpecNet => (drawing, fields) -> new SpecNet from merge(drawing,
	hashTable fields, last@@splice)
-- What a drawing stands for: its value's class, or for a component that is only
-- part of an expression, the expression's own.
valueClass SpecNet := drawn -> if drawn.?Type then drawn.Type else drawn.Classes
specNet SpecNet := identity
net SpecNet := net@@speek

-- The nearest setting of `field` in the ancestry of `type`.
nearestSetting (Symbol, Type) := (field, type) -> (
	owner := first select(ancestors type, ancestor -> ancestor#?field);
	if not instance(owner#field, Boolean) then
		error(toString field | " must be true or false");
	owner#field
)

nearestSetting (Symbol, Thing) := (field, x) -> false

-- The nearest setting of `depth` in the ancestry of x's class.
configuredDepth (Symbol, Thing) := (depth, x) -> (
	owner := first select(ancestors class x, ancestor -> ancestor#?depth);
	if not instance(owner#depth, ZZ) or owner#depth < 0 then
		error(toString depth | " must be a non-negative integer");
	owner#depth
)

-- Mark each part of a drawing whether it is typeset: by its own class or the
-- class of the value it stands for, or for being held by a typeset value or
-- an operator, unless its class keeps a typewriter face.
typesetMarked (SpecNet, Boolean) := (drawn, forced) -> (
	classes := {drawn.Classes, valueClass drawn};
	setting := field -> any(classes, nearestSetting_field);
	mathematical := setting typeset;
	operator := setting typesetOperands;
	marked := not setting typewriter and (forced or mathematical or operator);
	indexed := any(classes, class' -> instance(class', Type)
			and (ancestor(Subscript, class') or ancestor(Superscript, class')));
	drawn ++ {
		Typeset => marked,
		Children => apply(#drawn.Children, position -> typesetMarked(
			drawn.Children#position,
			if operator then
				not (indexed and position > 0)
			else marked and mathematical
		))
	}
)

-- Values being drawn: a container that holds itself is drawn once.
drawing := new MutableList
-- How many more values may be unfolded inside the one being drawn; unset
-- outside a drawing.
unfoldable := null
-- Clear what a drawing that threw part-way left behind, so the next drawing
-- starts outside any; the shell calls it after every result.
forgetDrawing = () -> (drawing = new MutableList; unfoldable = null)

-- A container drawn as `items`, each at the container's own depth.
contentsOf (Thing, List) := (container, items) -> (
	if any(toList drawing, ancestor -> ancestor === container) then
		return opaque container;
	drawing#(#drawing) = container;
	budget := unfoldable;
	result := try new SpecNet from (class container, apply(items, specNet))
		else opaque container;
	unfoldable = budget;
	drawing = new MutableList from drop(toList drawing, -1);
	result
)

-- Draw x from `shape`, its expression with each parameter spelled in place
-- given back as the parameter itself, so that it is drawn at the next depth.
unfolding (Thing, Thing) := (x, shape) -> (
	unfoldable ?? return specNet'(configuredDepth(symbol valueDepth, x), x);
	name := placeholder x;
	if name =!= null and unfoldable <= 0 then
		return opaque x ++ {
			Classes => Symbol,
			symbol Text => name
		};
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
	result := specNet held ++ {symbol Type => class x};
	if name =!= null then
		unfoldable += 1;
	result
)

specNet' (ZZ, Thing) := (depth, x) -> (
	outer := unfoldable;
	unfoldable = depth;
	result := specNet x;
	unfoldable = outer;
	result
)

-- A part a drawing introduces for a structure, as {name, part, shape} or
-- {name, part, shape, level}: spelled by its name until the drawing has that
-- many levels left to unfold (one by default), then drawn from its shape.
Intermediate = new HeaderType of Expression
specNet Intermediate := part -> (
	(name, component, shape) := toSequence take(part, 3);
	level := if #part > 3 then
			part#3
		else 1;
	if unfoldable =!= null and unfoldable < level then
		specNet name ++ {symbol Type => class component}
	else specNet shape ++ {symbol Type => class component}
)

-- Thing: what every class draws as until its own block says otherwise.
-- A value is drawn as what its expression is made of, down to expressions that
-- hold nothing but the value itself; its type is a bounded fold of that drawing.
Thing.typeDepth = 1
Thing.valueDepth = 1
-- Whether a drawing is set as typeset maths: values of a mathematical type,
-- and the shapes only typesetting draws well. Whatever such a value holds is
-- typeset with it; anything typeset only to sit beside it, a name or a string
-- in the same list, keeps a typewriter face.
Thing.typeset = false
-- Operators set their operands as maths, all but the index of a subscript or
-- superscript. Containers only hold their entries, which keep their own setting.
Thing.typesetOperands = false
-- An operator's operands of a typewriter class still keep a typewriter face.
Thing.typewriter = false
-- A mathematical type is typed by the values it is built over rather than by
-- its expression's components.
Thing.typedByParameters = false
-- Structures whose kind goes by a conventional name are what the value depth
-- counts: past it an unnamed one keeps only that name.
placeholder Thing := Nothing => x -> null
-- The values a structure is built over, which its expression spells in place.
parameters Thing := x -> {}
-- What a value is drawn from.
spelledShape (Thing, Thing) := (x, shape) -> shape
-- Values whose expression holds nothing but themselves.
opaque Thing := x -> new SpecNet from {
	Classes => class x,
	symbol Type => class x,
	Children => {},
	symbol Text => spelling x
}
spelling Thing := x -> try toString x else toString class x
specNet Thing := x -> (
	shape := expression x;
	if instance(shape, Holder) and shape#0 === x then
		opaque x
	else if instance(shape, Holder) and instance(shape#0, Symbol) then
		specNet shape#0
	else unfolding(x, spelledShape(x, shape))
)
specType Thing := x -> specType'(configuredDepth(symbol typeDepth, x), x)
-- Each level of a type below the outermost folds one level of the value, or for
-- a type typed by its parameters, unfolds each parameter once.
specType' (ZZ, Thing) := (depth, x) -> (
	if depth <= 1 then
		specNet class x
	else if nearestSetting(symbol typedByParameters, class x) then
		new SpecNet from (RowExpression, {
			specNet class x,
			new SpecNet from (Array, apply(parameters x,
				parameter -> specNet'(depth - 2, parameter)))
		})
	else specType'(depth, specNet'(depth - 1, x))
)
specType' (ZZ, SpecNet) := (depth, drawn) -> (
	if depth <= 1 or drawn.Text =!= null then
		specNet valueClass drawn
	else new SpecNet from (RowExpression, {
		specNet valueClass drawn,
		new SpecNet from (Array, apply(drawn.Children,
			child -> specType'(depth - 1, child)))
	})
)

speek' (ZZ, Thing) := (depth, x) -> speek'(depth, specNet x)
speek' (ZZ, SpecNet) := Option => (depth, drawn) -> valueClass drawn => (
	if drawn.Text =!= null then
		drawn.Text
	else if depth <= 0 then
		"..."
	else apply(drawn.Children, child -> speek'(depth - 1, child))
)
speek Thing := x -> speek'(2, x)

-- What the shell sends for a value and its type: the drawing marked for
-- typesetting, the value's net and code beside it, and an opaque leaf when
-- drawing throws, so a broken specNet never loses the result. Presentation
-- metadata is attached only here, at the boundary to the shell.
drawnAs = x -> try typesetMarked(specNet x, false) ++ {
	Fallback => (try toString net x),
	Code => (try toString x)
} else opaque x
typedAs = x -> try typesetMarked(specType x, false) else opaque class x
