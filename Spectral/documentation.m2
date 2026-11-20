doc ///
Node
  Key
    Spectral
  Headline
    structured value and type formatting
  Description
    Text
      @TO rod@ lays a value out as a tree of shapes, as TeX lays out a
      formula, each atom coloured by its class. @TO specType@ lays out the type
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
    atom
    Highlight
    specType
    speek
    keepNames
    UnderExpression
    AlignedExpression
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
      Complexes compose this with @TO MapExpression@ to show module degrees.
Node
  Key
    Rod
  Headline
    a value laid out as a tree of shapes
  Description
    Text
      A Rod is the format string a value is shown by: the expression it lays
      out, each part keeping its colour, whether it is typeset and its own TeX.
      M2 prints a Rod as the text it lays out; @TO speek@ shows its fields.
      A Rod is one node of a layout, its parts in fields named by its
      shape: an Atom of text in the colour of its class, a Row or a Join of
      items, a Script, a Fraction, a Fence, a Grid, a label Over or Under a
      base, a Diagram of pieces joined by arrows, or a Tree. Each shape has a
      constructor, listed under @TO atom@, and any node may carry the
      attributes listed under @TO Highlight@. The shell is sent the tree with
      each atom named by the highlight group of its class, see
      @TO highlightGroup@; the value itself is never sent.
    Example
      R = QQ[x, y];
      rod((x + 1)/2)
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
      by @TO formatted@, a sum between plus signs, a power as a script, a
      matrix as a grid. Install @TO expression@ for a new type to compose
      existing expression shapes, @TO formatted@ for an expression class to lay
      it out differently, or rod for a type to draw it from the shapes
      under @TO atom@ directly.
    Example
      R = QQ[x, y];
      formatted Sum := s -> joined(apply(toList s, rod), " (+) ", "Operator");
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
      The layout of an expression of e's class, which @TO rod@ marks with
      that class. A class without a layout of its own is spelled by its name
      over its parts.
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
      Install highlightGroup for a type as a method returning the name of one
      of the shell's highlight groups; the method nearest in the type's
      ancestry applies, to an atom of the type and to a Highlight naming it. An atom
      or a Highlight given a string rather than a type names its group
      directly, as atom("+", "Operator") does. Any class is "Text" unless it
      says otherwise: Number is "Number", RingElement and Symbol are "Variable", Ring and Type
      are "Type", String is "String", and Function is "Function".
    Example
      highlightGroup Ring
      MyRing = new Type of Ring;
      highlightGroup MyRing := class' -> "Function";
      highlightGroup MyRing
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
      hash table too, so speek shows the fields a drawing is made of.
    Example
      speek {1, 1/2, {2}}
      speek'(2, {1, 1/2, {2}})
      speek rod(1/2)
Node
  Key
    atom
    (atom, String, Thing)
    row
    (row, List)
    joined
    (joined, List, String, Thing)
    listed
    (listed, List, String, String)
    script
    (script, Rod, Thing, Thing)
    (fraction, Rod, Rod)
    fence
    (fence, String, String, Rod)
    parenthesized
    (parenthesized, Rod)
    grid
    (grid, List, String)
    labelled
    (labelled, String, Rod, Rod)
    drawsAs
    (drawsAs, Rod, Type)
  Headline
    the shapes a Rod is built from
  Usage
    atom(text, class)
    row items
    joined(items, separator, class)
    listed(items, left, right)
    script(base, sub, sup)
    fraction(numerator, denominator)
    fence(left, right, body)
    parenthesized body
    grid(rows, align)
    labelled(shape, base, label)
    drawsAs(drawn, type)
  Description
    Text
      An atom is text in the colour of its class: a type, or the name of a
      colour such as "Operator", "Delimiter" or "Punctuation". A row sets its
      items side by side, and a join puts an atom of the separator between
      each two; listed draws values, joins them by commas and fences them.
      A script is a base with a subscript, a superscript or both, the one
      absent null. A grid's rows are lists of cells, aligned as "Matrix", in
      parentheses, "Bare", "LeftAligned", or "Aligned", where each row's last
      cell runs on. A label sits "Over" or "Under" its base. drawsAs tells
      whether a drawing is laid out as an expression class.
    Example
      R = QQ[x, y];
      script(atom("x", Symbol), rod 1, rod 2)
      drawsAs(rod(x + 1), Sum)
Node
  Key
    Highlight
    Reach
    Target
    Tex
  Headline
    what any node of a Rod may carry
  Description
    Text
      Highlight is a class the node and its parts are coloured as, in place of
      their own; Reach, when set, is how many levels below the node it reaches,
      0 for the node alone. Target is a link the node opens, and Tex the TeX of
      an atom that has its own.
    Example
      R = QQ[x, y];
      rod Ideal := I -> (lookup(rod, Thing)) I ++ {Highlight => Keyword, Reach => 1};
      speek rod ideal(x, y)
///
