-- m2-ls: disable E19
-- -*- coding: utf-8 -*-
newPackage(
	"Spectral",
	Version => "0.5.2",
	Date => "November 20, 2026",
	Headline => "drawing values as structured, typed trees",
	PackageImports => { "Complexes", "Varieties", "Text" },
	Authors => { {
		Name => "Alexander Golys",
		Email => "alexandergolys@gmail.com",
		HomePage => "https://eigenflux.dev"
	} },
	HomePage => "https://github.com/AlexanderGolys/Spectral",
	Keywords => { "Interfaces" },
	AuxiliaryFiles => true,
	DebuggingMode => false
)

-- The highlight groups a drawing is coloured with, those of the shell's that
-- code and its values can be; the shell colours nothing a drawing names
-- otherwise.
highlightGroups = {"Text", "Muted", "Canvas", "Keyword", "Operator", "Delimiter",
	"Punctuation", "Comment", "String", "Number", "Boolean", "Builtin", "Variable",
	"Type", "Function", "Macro", "Option", "Package", "MapArrow", "MarkupLink"}

export {
	"Rod",
	"rod",
	"rod'",
	"specType",
	"specType'",
	"speek",
	"speek'",
	"formatted",
	"drawsAs",
	"HLG",
	"UnderExpression",
	"OverExpression",
	"AlignedExpression",
	"DiagramExpression",
	"TreeExpression",
	"typeDepth",
	"valueDepth",
	"typeset",
	"typesetOperands",
	"typewriter",
	"highlightGroup",
	"keepNames"
}


-- The fields a drawing's meta may name: Class, the type it is drawn as; a
-- Highlight colouring it and its parts, reaching Reach levels below it; the
-- Target it links to; an atom's own Tex; the Type of the value it stands for;
-- whether an atom is Typeset; and, for a value drawn whole, its Fallback text,
-- its Code, a documentation page's Html, the TypeNames the page resolves and
-- the ExampleWidth its examples were archived at.
drawingFields = {Class, Highlight, Reach, Target, Tex, symbol Type, Typeset,
	Fallback, Code, Html, TypeNames, ExampleWidth}

-- HLG "Operator": a highlight group by its name, one of highlightGroups; any
-- other name is an error where the group is made.
HLG = new SelfInitializingType of BasicList

-- Spectral's own shapes, laid out as no class of Core's is.
-- UnderExpression{base, label}, OverExpression{base, label}: a label centred
-- beneath or above an expression, keeping the expression's baseline.
UnderExpression = new HeaderType of Expression
OverExpression = new HeaderType of Expression
-- AlignedExpression{{a, b, c}, …}: rows of cells, every cell but a row's last
-- in a column aligned across the rows, the last running on and wrapping beneath
-- where it started, as a table's values beside its keys.
AlignedExpression = new HeaderType of Expression
-- DiagramExpression{pieces, arrows}: pieces {{row, column}, piece} on a grid,
-- joined by arrows {from, to, label}, each end a {row, column} and the label
-- null when there is none; Straight => diagram gives the same diagram for a
-- layout in characters when this one runs arrows across columns.
DiagramExpression = new HeaderType of Expression
-- TreeExpression{{label, subtree}, …}: a hierarchy, each branch a label over
-- its subtree.
TreeExpression = new HeaderType of Expression

-- The shapes the shell draws, each an expression class a drawing is laid out
-- as: Holder{text} an atom, the texts of a row or a list side by side or
-- between their delimiters, a fraction, a subscript and a superscript, a matrix
-- with its rows' Degrees beside them, a bare table of cells, and Spectral's
-- own. An expression of a class derived from one is drawn as that one.
shapes = { Holder, RowExpression, Parenthesize, Divide, Subscript, Superscript,
	List, Array, Sequence, AngleBarList, VerticalList, MatrixExpression, Table,
	AlignedExpression, UnderExpression, OverExpression, DiagramExpression,
	TreeExpression }

-- A drawing, the format string a value is shown by: Rod{shape, meta}, an
-- expression of one of the shapes whose parts are drawings in turn, and what
-- it says of how it is drawn: Class, the type it is drawn as, which colours an
-- atom and decides what is typeset; a Highlight colouring it and its parts in
-- place of their own, reaching Reach levels below it (all when unset); a Target
-- it links to; an atom's own Tex. M2 prints it as the expression it is:
-- rod(1/2) is Rod{1/2, {Class => Divide}}, its parts Rod{Holder{"1"}, …}.
Rod = new HeaderType of Expression

-- The public drawing, what the shell shows a value as. Install rod for a
-- class to draw its values differently, or formatted for an expression class to
-- lay its expressions out differently.
-- rod x: x drawn from its expression, each part laid out by its class.
rod = method(Dispatch => Thing, TypicalValue => Rod)
-- rod'(depth, x): rod x unfolding `depth` levels of its notation, in place of
-- x's class's valueDepth.
rod' = method(TypicalValue => Rod)
-- specType x: the type annotation shown beside x, as detailed as its class's
-- typeDepth: 1/2 is QQ, and R^2, a module of typeDepth 2, is Module[R].
specType = method(Dispatch => Thing, TypicalValue => Rod)
-- specType'(depth, x): specType x at an explicit depth.
specType' = method(TypicalValue => Rod)
-- speek x: x inspected as peek inspects it, drawn: its class and what it holds,
-- each part drawn as itself. speek{1/2} reads List{1/2}, and speek of a ring
-- its class with the pairs of its table.
speek = method(Dispatch => Thing, TypicalValue => Rod)
-- speek'(depth, x): speek x unfolding `depth` levels of containers, as peek'.
speek' = method(TypicalValue => Rod)
-- formatted e: an expression drawn as its class lays it out, before it is
-- marked with that class: a shape as itself, its parts drawn in turn, and any
-- other class as shapes: a sum as a row of its terms between plus signs.
formatted = method(Dispatch => Thing, TypicalValue => Rod)

-- drawsAs(drawn, type): whether a drawing is laid out as `type` or a class
-- derived from it: drawsAs(rod(x + 1), Sum) is true.
drawsAs = method(TypicalValue => Boolean)
-- shapeOf e: the shape an expression is drawn as, the nearest of its class's
-- ancestors among the shapes; null for one that is none.
shapeOf = method(Dispatch => Thing)

-- The drawing's own machinery, used by the methods of every class.
-- field key: the field of a drawing's meta a key names, Spectral's own symbol
-- spelled as the key is.
field = method(Dispatch => Thing)
-- parts drawn extends Core's parts to drawings: the drawings a node is built
-- from, in the order they are read.
-- nested part: the drawings in a part of a shape, a drawing or lists of them.
nested = method(Dispatch => Thing, TypicalValue => List)
-- changedIn(part, change): a part of a shape with each drawing in it changed.
changedIn = method()
-- partsChanged(drawn, change): the drawing with each drawing in its shape
-- passed through change(position, part), `position` the index of the shape's
-- part it sits in.
partsChanged = method(TypicalValue => Rod)
-- transmitted drawn: the drawing as the shell is sent it, a table of its
-- shape's name, its Parts and its options, and what it says of how it is drawn,
-- every colour named by its highlight group.
-- transmitted(draw, x, fallback): draw x so, typeset where it should be, or
-- the fallback drawn opaque when drawing throws.
transmitted = method(TypicalValue => Rod)
-- tabulated table: the pairs of a hash table stacked between braces, keys,
-- arrows and values aligned; tabulated pairs does so for pairs already drawn.
tabulated = method(Dispatch => Thing, TypicalValue => Rod)
-- opaque x: x as an atom of its own class, spelled by its text (see spelling).
-- Used for values whose expression holds nothing but themselves.
opaque = method(Dispatch => Thing, TypicalValue => Rod)
-- spelling x: the text an opaque atom of x shows, toString x by default.
spelling = method(Dispatch => Thing, TypicalValue => String)
-- contentsOf(container, draw): a container drawn by the function `draw`, at the
-- container's own depth; a container already being drawn, which holds itself,
-- is drawn opaque rather than endlessly.
contentsOf = method(TypicalValue => Rod)
-- unfolding(x, shape): x drawn from its expression `shape`, its parameters
-- drawn as themselves; inside another drawing, x drawn by its name when it has
-- one (see keepNames).
-- drawnWithin(depth, x, draw): draw() run inside the drawing of x, unfolding
-- `depth` levels; a drawing inside none is the drawing of x, the one value
-- spelled out from its definition rather than by its name.
drawnWithin = method()
unfolding = method(TypicalValue => Rod)
-- typesetMarked(drawn, forced): the drawing with every atom marked whether it
-- is typeset maths, by the typeset, typesetOperands and typewriter settings;
-- `forced` when a typeset value holds the drawing.
typesetMarked = method(TypicalValue => Rod)
-- operand(part, loose): an operand drawn, parenthesized when it is laid out as
-- one of the classes in `loose`.
operand = method(TypicalValue => Rod)
-- arranged(e, straight): the DiagramExpression of a ComplexMapExpression e, its
-- target under its source by degree, or shifted under the components when
-- straight.
arranged = method(TypicalValue => DiagramExpression)

-- Settings: what a class says of how its values are drawn, each a method of the
-- class itself returning a constant, found up the class's ancestry as any
-- method is: install `highlightGroup Gene := class' -> HLG "Keyword"` to change one.
-- typeDepth T: how many levels of a T's type its annotation shows.
typeDepth = method(Dispatch => Type, TypicalValue => ZZ)
-- valueDepth T: how many levels of its own notation a T unfolds: a complex
-- names its modules C_i and differentials d_i until it unfolds more than one.
valueDepth = method(Dispatch => Type, TypicalValue => ZZ)
-- typeset T: whether a T is set as typeset maths.
typeset = method(Dispatch => Type, TypicalValue => Boolean)
-- typesetOperands T: whether a T, an operator, sets its operands as maths.
typesetOperands = method(Dispatch => Type, TypicalValue => Boolean)
-- typewriter T: whether a T keeps a typewriter face even as an operand.
typewriter = method(Dispatch => Type, TypicalValue => Boolean)
-- typedByParameters T: whether a T's type lists the values it is built over
-- rather than the parts of its expression.
typedByParameters = method(Dispatch => Type, TypicalValue => Boolean)
-- highlightGroup T: the shell's highlight group a T is coloured as.
highlightGroup = method(Dispatch => Type, TypicalValue => HLG)

-- keepNames T: a T assigned to a global name is from then on drawn by that
-- name inside other values, as M2 spells a ring: after keepNames Ideal and
-- I = ideal(x^2), S/I is drawn as S/I, while J := ideal(x^2) leaves S/J
-- drawn as S/(x^2). A drawing of I itself still spells it out.
keepNames = method(TypicalValue => Nothing)
-- globalName x: the name a kept x was last assigned to, null when none.
globalName = method(Dispatch => Thing)

-- Hooks a class's block installs to say how its values are drawn.
-- definition x: the expression x stands for, spelled out though x has a name:
-- QQ[x] for R = QQ[x], whose expression is R. The value a drawing is of is
-- drawn from its definition, everything inside it from its expression.
definition = method(Dispatch => Thing)
-- optionsDropped e: the expression without the options its arrays list, each
-- a `=>` operation: QQ[x, Degrees => {1}] is QQ[x].
optionsDropped = method(Dispatch => Thing)
-- parameters x: the values x is built over, which its expression spells in
-- place and a typedByParameters type lists: a module's is {its ring}.
parameters = method(Dispatch => Thing, TypicalValue => List)
-- spelledShape(x, shape): the expression x is drawn from, given its expression
-- `shape`: a module drops the `^1` M2 spells rank one with.
spelledShape = method()
-- optionKey key: the key before `=>`, coloured as an option's name when it is
-- spelled by a symbol or a string.
optionKey = method(Dispatch => Thing, TypicalValue => Rod)

-- Links: what a source position or a documentation page points to.
-- named x: whether x is the value of the global name it spells: sin is, an
-- anonymous x -> x is not.
named = method(Dispatch => Thing, TypicalValue => Boolean)
-- sourceLines position: the lines of code at a source position, as code shows
-- them; null when they are nowhere to be read.
sourceLines = method(Dispatch => Thing)
-- lined(lines, class): the lines one under another, each an atom of `class`, a
-- type.
lined = method(TypicalValue => Rod)
-- sourceTarget position: the file:// URL of a FilePosition, its file found on
-- the load path; null when the file cannot be found.
sourceTarget = method(Dispatch => Thing)
-- foldedPath path: a path cut to its file and one directory above it:
-- "/a/b/c/file.m2" is "[...]/c/file.m2".
foldedPath = method()
-- documentationTags page: the nodes a documentation page links to, each TO,
-- TO2 and TOH target once.
documentationTags = method(Dispatch => Thing)
-- attributeText text: the text escaped to sit in a quoted HTML attribute.
attributeText = method()

-- How a value is drawn, class by class: each class's settings and methods stand
-- together in one block, in the file of its subject.
load "./Spectral/Rod.m2"
load "./Spectral/expressions.m2"
load "./Spectral/containers.m2"
load "./Spectral/language.m2"
load "./Spectral/algebra.m2"
load "./Spectral/complexes.m2"
load "./Spectral/varieties.m2"
load "./Spectral/hypertext.m2"

-- Drawing fields are keys, never values: their symbols stay unset.
scan(values currentPackage#"private dictionary", key ->
		if isMutable key and value key === key then
		protect key)

beginDocumentation()
doc ///
Node
  Key
    Spectral
  Headline
    structured value and type formatting
  Description
    Text
      @TO rod@ draws a value as its expression, each part laid out in one of
      the @TO "shapes"@ the shell draws and coloured by one of its highlight
      groups, an @TO HLG@. @TO specType@ lays out the type
      of a value the same way. Both are what the
      @HREF{"https://github.com/AlexanderGolys/spectral-m2", "spectral-m2"}@
      shell draws its results from, and work on their own: a @TO Rod@ prints as
      the text it lays out. @TO speek@ inspects a value as @TO peek@ does, its
      class and what it holds, drawn.
    Example
      R = QQ[x, y];
      rod((x + 1)/2)
      speek {1, 1/2, x}
  Subnodes
    Rod
    rod
    "shapes"
    HLG
    "drawing meta"
    specType
    speek
    keepNames
Node
  Key
    AlignedExpression
  Headline
    rows aligned in columns, each ending in a cell that runs on
  Usage
    AlignedExpression{{a, b, c}, {d, e, f}}
  Description
    Text
      Every cell but a row's last sits in a column aligned across the rows.
      The last cell takes the rest of the width: when it is too long it wraps,
      continuing beneath where it started rather than at the left margin.
      A hash table draws its pairs this way, each key and its arrow in aligned
      columns; install @TO rod@ for a type to draw it the same way.
    Example
      AlignedExpression{{"x", symbol =>, 1}, {"longer", symbol =>, {1, 2, 3}}}
Node
  Key
    UnderExpression
  Headline
    center a label beneath an expression
  Usage
    UnderExpression{base, label}
  Description
    Text
      Keeps the baseline of the base while placing the label below it.
      Complexes compose this with @TO MapExpression@ to show module degrees,
      and a map's label sits over its arrow as an @TO OverExpression@.
Node
  Key
    Rod
  Headline
    an expression with how it is drawn
  Usage
    Rod{shape}
    Rod{shape, meta}
  Description
    Text
      A Rod is the format string a value is shown by: an expression in one of
      the @TO "shapes"@, its parts Rods in turn, and its meta, a list of options
      saying how it is drawn, as listed under @TO "drawing meta"@. Being an
      expression, it prints as the text it lays out. An atom is a Holder of its
      text, coloured by the Class it is drawn as or by its Highlight.
      The shell is sent the tree with each colour named by its highlight
      group, see @TO highlightGroup@; the value itself is never sent.
    Example
      R = QQ[x, y];
      rod((x + 1)/2)
      Rod {Divide {rod x, Rod {Holder {"n"}, {Highlight => HLG "Keyword"}}}}
      speek rod(1/2)
Node
  Key
    rod
    (rod, Thing)
    rod'
    (rod', ZZ, Thing)
  Headline
    lay a value out as a tree of shapes
  Usage
    rod x
    rod'(depth, x)
  Description
    Text
      The default method unfolds @TO expression@ until an expression holds
      nothing but its value: a named value ends at its symbol, so nothing is
      read from inside rings or varieties. Each class of expression is laid out
      by @TO formatted@ in @TO "shapes"@: a sum as a row of its terms between
      plus signs, a power as a superscript, a matrix as itself. Install
      @TO expression@ for a new type to compose existing expressions,
      @TO formatted@ for an expression class to lay it out differently, or rod
      for a type to build its @TO Rod@ directly.
    Example
      R = QQ[x, y];
      formatted Sum := s -> Rod {RowExpression between(Rod {Holder {" (+) "},
	      {Highlight => HLG "Operator"}}, apply(toList s, rod))};
      rod(x + y)
Node
  Key
    formatted
    (formatted, Expression)
  Headline
    lay out an expression of a class
  Usage
    formatted e
  Description
    Text
      The @TO Rod@ an expression of e's class is drawn as, which @TO rod@
      marks with that class. An expression of one of the @TO "shapes"@ is drawn
      as itself, its parts drawn in turn; a class without a layout of its own
      is spelled by its name over its parts.
Node
  Key
    valueDepth
    (valueDepth, Thing)
  Headline
    control how far a value's own notation unfolds
  Usage
    valueDepth T
  Description
    Text
      Install valueDepth for a type as a method returning a non-negative
      integer, as valueDepth Complex := class' -> 2 is; the method nearest in
      the type's ancestry applies. It counts the levels of notation a value
      introduces for its own parts. A complex is a chain of its modules C_i
      and differentials d_i between zeros; past depth one these names give
      way to the modules and matrices. A map of complexes draws its two
      complexes the same way, but its matrices wait one level longer than
      their modules, so at its default depth of 2 its arrows carry names, and
      valueDepth ComplexMap := class' -> 3 shows the matrices. Any other value
      has a depth of 1, and a complex 2. Explicit rod' calls use their
      supplied depth. What a value is built over is drawn whole unless it has
      a name; see @TO keepNames@.
    Example
      valueDepth Complex
Node
  Key
    keepNames
    (keepNames, Type)
  Headline
    draw the values of a class by the global names they are assigned to
  Usage
    keepNames T
  Description
    Text
      From then on a T assigned to a global name with = is drawn by that name
      inside every other value, as M2 spells a ring by its name; one assigned
      with := keeps being drawn whole. The value a drawing is of is always
      spelled out from its definition: I itself is drawn as its generators,
      and a named ring R = QQ[x] as QQ[x]. A name is forgotten
      once it is assigned something else. Only drawings change: M2's own net
      and toString of the value are left as they are. Ideals, modules,
      matrices, ring maps, complexes, maps of complexes, coherent sheaves and
      sheaf maps keep their names; a quotient ring by a named ideal is drawn
      over the ideal's name.
    Example
      R = QQ[x, y];
      I = ideal(x^2, y^3);
      rod(R/I)
      J := ideal(x^2);
      rod(R/J)
      rod I
      rod R
Node
  Key
    typeset
    (typeset, Thing)
    typesetOperands
    (typesetOperands, Thing)
    typewriter
    (typewriter, Thing)
  Headline
    choose which values are set as typeset maths
  Usage
    typeset T
    typesetOperands T
    typewriter T
  Description
    Text
      Install these for a type as methods returning true or false, as
      typeset Number := class' -> true is; the method nearest in the type's
      ancestry applies. A value is drawn as a typeset picture only
      when some part of it is typeset, and the rest of the picture keeps a
      typewriter face. A part is typeset when its class, or the class of the
      value it stands for, has typeset true, or when it is held by such a
      value or is an operand of an operator, a type with typesetOperands true.
      The index of a subscript or superscript keeps its own setting, and a part
      whose class has typewriter true is never typeset.
      Number, RingElement, Ring, Module, Matrix and the like have typeset true.
      Sums, products, tensor products, powers, quotients, maps and the other
      operator expressions have typesetOperands true, so a symbol in a sum is
      set as maths; MatrixExpression, VectorExpression and Table only hold
      their entries. String, Net, Boolean, Nothing and Function have typewriter true.
    Example
      {typeset QQ, typesetOperands Sum, typewriter String}
Node
  Key
    typeDepth
    (typeDepth, Thing)
  Headline
    control the detail in a type annotation
  Usage
    typeDepth T
  Description
    Text
      Install typeDepth for a type as a method returning a non-negative
      integer; the method nearest in the type's ancestry controls specType,
      and subclasses may override it. Any value has a depth of 1, a module 2.
      Install it in the shell's init file to change it for every session.
      Explicit specType' calls use their supplied depth.
    Example
      typeDepth Module
Node
  Key
    highlightGroup
    (highlightGroup, Thing)
  Headline
    choose the colour a class is drawn in
  Usage
    highlightGroup T
  Description
    Text
      Install highlightGroup for a type as a method returning an
      @TO HLG@; the method nearest in the type's ancestry applies, to an
      atom of the type and to a Highlight naming it. Any class is HLG "Text"
      unless it says otherwise: Number is HLG "Number", RingElement and Symbol
      are HLG "Variable", Ring and Type are HLG "Type", String is HLG "String", and
      Function is HLG "Function".
    Example
      highlightGroup Ring
      MyRing = new Type of Ring;
      highlightGroup MyRing := class' -> HLG "Function";
      highlightGroup MyRing
Node
  Key
    HLG
  Headline
    the shell's colours a drawing can name
  Description
    Text
      HLG "name" is a highlight group of the shell's by its name, one of those
      code and its values are coloured with, and any other name an error:
      Text, Muted, Canvas, Keyword, Operator, Delimiter, Punctuation, Comment,
      String, Number, Boolean, Builtin, Variable, Type, Function, Macro, Option,
      Package, MapArrow and MarkupLink. A Highlight in a drawing's
      @TO "drawing meta"@ and a @TO highlightGroup@ name one of them.
    Example
      HLG "Operator"
      Rod {Holder {"+"}, {Highlight => HLG "Operator"}}
Node
  Key
    specType
    (specType, Thing)
    specType'
    (specType', ZZ, Thing)
  Headline
    format structured type information for a value
  Usage
    specType x
    specType'(depth, x)
  Description
    Text
      Receives the original value. The depth is a non-negative integer.
      specType x shows as many levels as the @TO typeDepth@ of x's class: 1
      for most values, 2 for a module. Install typeDepth in the shell or its
      init file to change it. Explicit specType' calls override it.
      Modules and matrices use their base ring as a parameter; coherent
      sheaves and sheaf maps use the sheaf of rings they are modules over, and
      a sheaf of rings uses its variety. Each further level unfolds an unnamed
      parameter one step.
      Depth one gives the outer type. Each further level folds one layer of
      components to their types. Containers retain positional element types;
      the same expression tree supplies the constructor and component types.
Node
  Key
    speek
    (speek, Thing)
    speek'
    (speek', ZZ, Thing)
    (speek', ZZ, BasicList)
    (speek', ZZ, HashTable)
  Headline
    inspect a value as peek does, drawn
  Usage
    speek x
    speek'(depth, x)
  Description
    Text
      The analogue of @TO peek@, a @TO Rod@ rather than a net: a list or an
      expression is its class over its entries, a hash table its class, its
      parent when it has one, and its pairs, sorted as peek sorts them. Each
      entry is inspected one level less deep; past the depth, one level by
      default, and for anything else, a value is drawn as itself. A Rod is a
      list too, so speek shows the shape and the meta of a drawing.
    Example
      speek {1, 1/2, {2}}
      speek'(2, {1, 1/2, {2}})
      speek rod(1/2)
Node
  Key
    "shapes"
    drawsAs
    (drawsAs, Rod, Type)
    OverExpression
    DiagramExpression
    TreeExpression
  Headline
    the expression classes the shell draws
  Usage
    shapes
    drawsAs(drawn, type)
  Description
    Text
      A @TO Rod@ is an expression of one of these classes, its parts Rods:
      Holder{text}, an atom; RowExpression, its items side by side;
      Parenthesize; Divide, a fraction; Subscript and Superscript; List, Array,
      Sequence and AngleBarList, their items between their delimiters, and
      VerticalList, one under another; MatrixExpression, its rows in
      parentheses, its Degrees beside them; Table, a bare grid of cells; and
      Spectral's own @TO AlignedExpression@, @TO UnderExpression@,
      OverExpression{base, label}, DiagramExpression{pieces, arrows}, pieces
      {{row, column}, piece} joined by arrows {from, to, label} with a Straight
      diagram for a layout in characters, and TreeExpression{{label, subtree},
      ...}. An expression of a class derived from one is drawn as that one.
      drawsAs tells whether a drawing is laid out as an expression class.
    Example
      R = QQ[x, y];
      Rod {Superscript {rod x, rod 2}}
      drawsAs(rod(x + 1), Sum)
Node
  Key
    "drawing meta"
  Headline
    what the meta of a Rod may carry
  Description
    Text
      Its fields are named by symbols Spectral keeps to itself, which a meta
      names by spelling: Highlight => HLG "Keyword" names Spectral's Highlight
      whatever symbol Highlight is where it is written, and a name that is no
      field is an error. Class is the type a node is drawn as, which colours an atom by its
      @TO highlightGroup@ and decides what is typeset. Highlight is an
      @TO HLG@, or a type naming its highlightGroup, the node and its
      parts are coloured as in place of their own; Reach, when set, is how
      many levels below the node it reaches, 0 for the node alone. Target is a
      link the node opens, and Tex the TeX of an atom that has its own.
    Example
      R = QQ[x, y];
      rod Ideal := I -> (lookup(rod, Thing)) I ++ {Highlight => Keyword, Reach => 1};
      speek rod ideal(x, y)
///

-- Worked examples of what Spectral draws, each checked: what a drawing reads as,
-- at depths given explicitly rather than by any class's setting.

TEST ///
-- A Rod is an expression with how it is drawn: Rod{shape, meta}, its parts Rods.
R = QQ[x, y]
half = rod(1/2)
assert instance(half, Rod)
assert instance(half#0, Divide)
assert all(toList half#0, part -> instance(part, Rod))
assert(toString half == "1/2")
assert drawsAs(rod(x + 1), Sum)
-- Built by hand, a drawing is the expression it lays out.
assert(toString Rod {RowExpression {rod x, Rod {Holder {" (+) "},
	{Highlight => HLG "Operator"}}, rod y}} == "x (+) y")
///

TEST ///
-- A colour is one of the shell's highlight groups, and a meta names only the
-- fields a drawing has: anything made up is an error where it is written.
assert(HLG "Operator" === HLG "Operator")
assert(try (HLG "Operatr"; false) else true)
assert(try (Rod {Holder {"+"}, {Hilight => HLG "Operator"}}; false) else true)
///

TEST ///
-- rod'(depth, C): a complex names its modules C_i and differentials d_i at depth
-- one, and shows the modules themselves from depth two.
R = QQ[x, y]
C = freeResolution coker vars R
named = toString net rod'(1, C)
assert(match("C", named) and match("d", named))
spelled = toString net rod'(2, C)
assert(not match("C", spelled) and match("R", spelled))
///

TEST ///
-- A value assigned with = is drawn by its name inside other values; the value
-- a drawing is of is spelled out, and one assigned with := keeps its notation.
R = QQ[x, y]
I = ideal(x^2, y^3)
assert(toString rod(R/I) == "R/I")
assert match("ideal", toString rod I)
J := ideal(x^2)
assert(toString rod(R/J) != "R/J")
///

TEST ///
-- specType'(depth, x): the type annotation, as deep as asked: a module over its
-- ring from depth two.
R = QQ[x, y]
assert(toString specType'(1, R^2) == "Module")
assert(toString specType'(2, R^2) == "Module[R]")
assert(toString specType'(1, 1/2) == "QQ")
///

TEST ///
-- speek'(depth, x): x inspected as peek inspects it, drawn: a list as its class
-- over its entries, a hash table as its class over its pairs.
assert(toString speek'(1, {1, 2}) == "List{1, 2}")
assert(toString speek'(2, {1, {2}}) == "List{1, List{2}}")
assert match("HashTable", toString net speek'(1, new HashTable from {symbol a => 1}))
///
end--
