doc ///
Node
  Key
    Spectral
  Headline
    structured value and type formatting
  Description
    Text
      @TO specNet@ preserves expression structure and the classes of components.
      @TO specType@ independently formats the type of a value. Both are what
      the @HREF{"https://github.com/AlexanderGolys/spectral-m2", "spectral-m2"}@
      shell draws its results from, and work on their own: @TO speek@ shows the
      structure a value is drawn as.
    Example
      speek(1/2)
  Subnodes
    SpecNet
    specNet
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
    transmissible expression structure with component classes
  Description
    Text
      A SpecNet holds the class that lays it out under Classes, its ordered
      Children, and the symbol Text, whose string replaces the children of an
      opaque value. Optional fields annotate it: Highlight names the semantic
      class to colour it by, Tex its native TeX, Target a source or
      documentation link, and Html, TypeNames and ExampleWidth a documentation
      page. Fallback and Code carry the value's net and input spelling. Class
      objects are transmitted as their ancestry; the original value is never
      transmitted.
Node
  Key
    specNet
    (specNet, Thing)
    specNet'
    (specNet', ZZ, Thing)
  Headline
    format a value without flattening its expression
  Usage
    specNet x
    specNet'(depth, x)
  Description
    Text
      The default method unfolds @TO expression@, preserving each component's
      class, until an expression holds nothing but its value: a named value
      ends at its symbol, so nothing is read from inside rings or varieties.
      Install @TO expression@ for a new type to compose existing expression
      shapes, or install specNet to customize its transmissible representation.
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
    inspect structured formatting
  Usage
    speek x
    speek'(depth, x)
///
