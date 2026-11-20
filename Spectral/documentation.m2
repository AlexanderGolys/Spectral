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
      groups, an @TO HLGroup@. @TO specType@ lays out the type
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
    HLGroup
    Highlight
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
      saying how it is drawn, as listed under @TO Highlight@. Being an
      expression, it prints as the text it lays out. An atom is a Holder of its
      text, coloured by the Class it is drawn as or by its Highlight.
      The shell is sent the tree with each colour named by its highlight
      group, see @TO highlightGroup@; the value itself is never sent.
    Example
      R = QQ[x, y];
      rod((x + 1)/2)
      Rod {Divide {rod x, Rod {Holder {"n"}, {Highlight => hl$Keyword}}}}
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
	      {Highlight => hl$Operator}}, apply(toList s, rod))};
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
      @TO HLGroup@; the method nearest in the type's ancestry applies, to an
      atom of the type and to a Highlight naming it. Any class is hl$Text
      unless it says otherwise: Number is hl$Number, RingElement and Symbol
      are hl$Variable, Ring and Type are hl$Type, String is hl$String, and
      Function is hl$Function.
    Example
      highlightGroup Ring
      MyRing = new Type of Ring;
      highlightGroup MyRing := class' -> hl$Function;
      highlightGroup MyRing
Node
  Key
    HLGroup
  Headline
    the shell's colours a drawing can name
  Description
    Text
      Each is the constant hl$name of a highlight group of the shell's, those
      code and its values are coloured with: hl$Text, hl$Muted, hl$Canvas,
      hl$Keyword, hl$Operator, hl$Delimiter, hl$Punctuation, hl$Comment,
      hl$String, hl$Number, hl$Boolean, hl$Builtin, hl$Variable, hl$Type,
      hl$Function, hl$Macro, hl$Option, hl$Package, hl$MapArrow and
      hl$MarkupLink. A @TO Highlight@ and a @TO highlightGroup@ name one of them.
    Example
      hl$Operator
      Rod {Holder {"+"}, {Highlight => hl$Operator}}
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
    Straight
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
      shapes
      Rod {Superscript {rod x, rod 2}}
      drawsAs(rod(x + 1), Sum)
Node
  Key
    Class
    Highlight
    Reach
    Target
    Tex
  Headline
    what the meta of a Rod may carry
  Description
    Text
      Class is the type a node is drawn as, which colours an atom by its
      @TO highlightGroup@ and decides what is typeset. Highlight is an
      @TO HLGroup@, or a type naming its highlightGroup, the node and its
      parts are coloured as in place of their own; Reach, when set, is how
      many levels below the node it reaches, 0 for the node alone. Target is a
      link the node opens, and Tex the TeX of an atom that has its own.
    Example
      R = QQ[x, y];
      rod Ideal := I -> (lookup(rod, Thing)) I ++ {Highlight => Keyword, Reach => 1};
      speek rod ideal(x, y)
///
