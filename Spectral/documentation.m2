doc ///
Node
  Key
    Spectral
  Headline
    structured value and type formatting
  Description
    Text
      @TO specNet@ lays a value out as a tree of shapes, as TeX lays out a
      formula, each atom coloured by its class. @TO specType@ lays out the type
      of a value the same way. Both are what the
      @HREF{"https://github.com/AlexanderGolys/spectral-m2", "spectral-m2"}@
      shell draws its results from, and work on their own: @TO speek@ shows the
      tree a value is drawn as.
    Example
      speek(1/2)
  Subnodes
    SpecNet
    specNet
    atom
    Highlight
    specType
    speek
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
      columns; install @TO specNet@ for a type to draw it the same way.
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
    SpecNet
  Headline
    a value laid out as a tree of shapes
  Description
    Text
      A SpecNet is one node of a layout, its parts in fields named by its
      shape: an Atom of text in the colour of its class, a Row or a Join of
      items, a Script, a Fraction, a Fence, a Grid, a label Over or Under a
      base, a Diagram of pieces joined by arrows, or a Tree. Each shape has a
      constructor, listed under @TO atom@, and any node may carry the
      attributes listed under @TO Highlight@. The shell is sent the tree with
      the classes its atoms are coloured by gathered in one table; the value
      itself is never sent.
    Example
      R = QQ[x, y];
      speek'(2, (x + 1)/2)
Node
  Key
    specNet
    (specNet, Thing)
    specNet'
    (specNet', ZZ, Thing)
  Headline
    lay a value out as a tree of shapes
  Usage
    specNet x
    specNet'(depth, x)
  Description
    Text
      The default method unfolds @TO expression@ until an expression holds
      nothing but its value: a named value ends at its symbol, so nothing is
      read from inside rings or varieties. Each class of expression is laid out
      by @TO formatted@, a sum between plus signs, a power as a script, a
      matrix as a grid. Install @TO expression@ for a new type to compose
      existing expression shapes, @TO formatted@ for an expression class to lay
      it out differently, or specNet for a type to draw it from the shapes
      under @TO atom@ directly.
    Example
      R = QQ[x, y];
      formatted Sum := s -> joined(apply(toList s, specNet), " (+) ", "Operator");
      speek'(2, x + y)
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
      The layout of an expression of e's class, which @TO specNet@ marks with
      that class. A class without a layout of its own is spelled by its name
      over its parts.
Node
  Key
    valueDepth
  Headline
    control how many unnamed values a drawing unfolds
  Description
    Text
      Assign a non-negative integer to a type's valueDepth field. A value is
      drawn from its expression, and each value unfolded inside another costs
      one level; the items of a list cost none. Past the depth an unnamed value
      keeps only a placeholder: R for a ring, M for a module, X for a variety,
      C for a complex. Named values always keep their name. A complex is a
      chain of its modules C_i and differentials d_i between zeros; at the
      next depth these names give way to the modules and matrices, and each
      further level substitutes one more name. A map of complexes draws its
      two complexes the same way, but its matrices wait one level longer than
      their modules, so at its default depth of 2 its arrows carry names, and
      ComplexMap.valueDepth = 3 shows the matrices.
      Thing.valueDepth is 1 and Complex.valueDepth is 2. Explicit specNet'
      calls use their supplied depth.
Node
  Key
    typeset
    typesetOperands
    typewriter
  Headline
    choose which values are set as typeset maths
  Description
    Text
      Assign true or false to these fields of a type; the nearest setting in
      the type's ancestry applies. A value is drawn as a typeset picture only
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
Node
  Key
    typeDepth
  Headline
    control the detail in a type annotation
  Description
    Text
      Assign a non-negative integer to a type's typeDepth field. The nearest
      setting in the type ancestry controls specType; subclasses may override it.
      Thing.typeDepth is 1 and Module.typeDepth is 2. Settings may be assigned
      in the shell's init file. Explicit specType' calls use their supplied depth.
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
      specType uses the nearest typeDepth setting in the type's ancestry.
      Thing.typeDepth is 1; Module.typeDepth is 2. Assign these parameters
      in the shell or its init file. Explicit specType' calls override them.
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
  Headline
    the tree a value is drawn as, as peek shows an object
  Usage
    speek x
    speek'(depth, x)
  Description
    Text
      Each node is spelled by its shape with its parts in braces, each atom by
      its text and class, to the given depth, one level by default.
    Example
      speek'(3, matrix{{1, 2}})
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
    (script, SpecNet, Thing, Thing)
    (fraction, SpecNet, SpecNet)
    fence
    (fence, String, String, SpecNet)
    parenthesized
    (parenthesized, SpecNet)
    grid
    (grid, List, String)
    labelled
    (labelled, String, SpecNet, SpecNet)
    drawsAs
    (drawsAs, SpecNet, Type)
  Headline
    the shapes a SpecNet is built from
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
      speek'(2, script(atom("x", Symbol), specNet 1, specNet 2))
      drawsAs(specNet(x + 1), Sum)
Node
  Key
    Highlight
    Reach
    Target
    Tex
  Headline
    what any node of a SpecNet may carry
  Description
    Text
      Highlight is a class the node and its parts are coloured as, in place of
      their own; Reach, when set, is how many levels below the node it reaches,
      0 for the node alone. Target is a link the node opens, and Tex the TeX of
      an atom that has its own.
    Example
      R = QQ[x, y];
      specNet Ideal := I -> (lookup(specNet, Thing)) I ++ {Highlight => Keyword, Reach => 1};
      speek ideal(x, y)
///
