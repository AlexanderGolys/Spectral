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
-- An atom set in a maths alphabet M2 spells its letters twice in, as QQ for
-- ℚ and OO for 𝒪, is spelled so.
expression Rod := node -> (
	if node#?Font and member(node#Font, doubledFonts) then
		Holder {concatenate apply(characters node#Shape#0, letter -> letter | letter)}
	else throughRods(node#Shape, expression)
)
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
			mathsFont }
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

-- A drawing as the shell is sent it: its shape's name and its parts, every
-- atom with the colour and the font it is drawn in. An atom is coloured by a
-- Highlight over it that reaches it, else by its own Group, and set in the
-- Font of the nearest drawing around it that gives one; `over` is the
-- highlight reaching down, with how many more levels it reaches. A matrix
-- sends its Rows and its rows' and columns' Degrees, a diagram its Pieces, its
-- Arrows and its Straight diagram. What only decides the drawing stays behind.
transmitted := (node, font, over) -> (
	shape := node#Shape;
	font = if node#?Font then
			node#Font
		else font;
	if node#?Highlight then
		over = (node#Highlight, if node#?Reach then
					node#Reach
				else infinity);
	below := if over =!= null and over#1 > 0 then (over#0, over#1 - 1);
	sent := part -> throughRods(part, part' -> transmitted(part', font, below));
	parts := select(toList shape, part -> not instance(part, Option));
	options := hashTable select(toList shape, part -> instance(part, Option));
	name := shapeOf shape;
	hashTable {
		"Shape" => if name === Holder then
				"Atom"
			else toString name,
		"Parts" => if name === Holder then
				hashTable {
					"Text" => parts#0,
					"Highlight" => (if over =!= null then
								over#0
							else if node#?Group then
							node#Group
						else HLG "Text")#0,
					"Font" => font
				}
			else if name === MatrixExpression then
			hashTable {
				"Rows" => sent parts,
				"Degrees" => if options#?Degrees then
						sent options#Degrees
			}
		else if name === DiagramExpression then
			hashTable {
				"Pieces" => sent parts#0,
				"Arrows" => sent parts#1,
				"Straight" => if options#?Straight then
						sent options#Straight
			}
		else sent parts
	}
)

-- What the shell is sent for a value: its drawing, where it links to and the
-- documentation page it is, from one drawing; its type; its inspection. A
-- drawing a broken rod throws out of is sent as M2 spells the value.
drawnSafely := (draw, x) -> try draw x else spelledAsM2 x
drawnAs = x -> (
	drawn := drawnSafely(rod'_0, x);
	hashTable {
		"value" => transmitted(drawn, codeFont#1, null),
		"location" => if drawn#?Target then
				drawn#Target,
		"document" => if drawn#?Html then
				hashTable {
					"html" => drawn#Html,
					"exampleWidth" => drawn#ExampleWidth,
					"typeNames" => drawn#TypeNames
				}
	}
)
typedAs = x -> transmitted(try specType x
		else spelledAsM2 class x, codeFont#1, null)
inspectedAs = x -> transmitted(drawnSafely(speek, x), codeFont#1, null)
