-- M2's expressions as the shell draws them: the classes it lays out as they are,
-- part by part, and the operators as rows of their operands and signs.

-- What reads as several terms is parenthesized beside an operator, and anything
-- compound as the base of a power.
looseOperand = { Sum, Equation }
looseBase = { Sum, Product, TensorProduct, Divide, Minus, Power, BinaryOperation }

row = shaped_RowExpression
parenthesized = part -> shaped(Parenthesize, { shape part })
operand = (part, loose) -> (
    if any(loose, instance_(expression part)) then
        parenthesized part
    else shape part
)
signAtom = text -> atom(text, HLG "Operator", "MathNormal")
space = atom(" ", HLG "Canvas", "MathNormal")

-- A value is drawn by its expression, down to what M2 spells by itself, an atom.
byExpression = x -> (
    e := expression x;
    if instance(e, Holder) and e#0 === x then
        leaf x
    else shape e
)
shape Thing := byExpression
shape Holder := held -> shape held#0
-- An expression holding a drawing already made, for parts no value spells.
Drawn = new WrapperType of Holder
shape Drawn := held -> held#0
-- An expression no shape is installed for is spelled as M2 spells it.
shape Expression := e -> atom(toString e, HLG "Text", "TextTT")

-- The shapes the shell draws, part by part, and as rows of cells; a list's
-- items are drawn by their expressions, so a ring a name holds keeps its name.
(class' -> shape class' := parts -> shaped(class', shape \ toList parts)) \ {
    Divide, RowExpression, UnderExpression, OverExpression
}
(class' -> shape class' := items -> shaped(class', shape @@ expression
        \ toList items)) \ {
            List, Array, Sequence, AngleBarList, VerticalList
        }
(class' -> shape class' := rows -> shaped(class', (cells -> shape \ toList cells)
        \ toList rows)) \ { Table, AlignedExpression, TreeExpression }
shape Parenthesize := held -> parenthesized held#0

-- A sum is its terms between plus signs, a negative term's minus standing in
-- for its plus; the empty sum is 0.
shape Sum := terms -> if #terms == 0 then shape 0 else row delete(null, mingle(
    apply(toList terms, shape),
    apply(drop(toList terms, 1), term -> if not instance(term, Minus) then
                signAtom "+")
))
-- A product is its factors side by side, as maths juxtaposes them, a dot only
-- before one beginning with a number or a negation, which would run into the
-- factor before it: 2xy², but x·2 and x·-y.
shape Product := factors -> if #factors == 0 then shape 1 else row delete(null, mingle(
    apply(toList factors, factor -> operand(factor, looseOperand)),
    apply(drop(toList factors, 1), factor -> if leadsWithNumber factor then
                signAtom "·")
))
leadsWithNumber = factor -> (
    e := expression factor;
    instance(e, Minus) or (instance(e, Holder) and instance(e#0, Number))
        or (any({ Power, Subscript, Superscript }, instance_e) and leadsWithNumber e#0)
)
shape Minus := negated -> row { signAtom "-", operand(negated#0, looseOperand) }
scan({ (TensorProduct, "⊗"), (DirectSum, "⊕"), (Equation, " == ") }, (class', text) ->
        shape class' := terms -> row between(signAtom text, apply(toList terms, term ->
                operand(term, looseOperand))))

-- A power raises its exponent over its base, as a superscript does; a subscript
-- lowers its index, a sequence of indices spelled with commas.
shape Power := shape Superscript := power -> shaped(Superscript, {
    operand(power#0, looseBase), shape power#1
})
shape Subscript := indexed -> shaped(Subscript, { operand(indexed#0, looseOperand),
    if instance(indexed#1, Sequence) then
        row between(atom(",", HLG "Delimiter", "MathNormal"), shape \ toList indexed#1)
    else shape indexed#1 })

-- frac R, cokernel M: a function applied by juxtaposition, a space between it
-- and its argument, which a bracketed one follows directly, as in R[x] and
-- OO_X(1); f(x, y): a function applied to its arguments.
shape Adjacent := application -> row join({ shape application#0 },
    if instance(application#1, Array) or instance(application#1, Parenthesize) then
        {} else { space }, { operand(application#1, looseBase) })
shape FunctionApplication := application -> row { shape application#0,
    if instance(application#1, Sequence) then
        shape application#1
    else parenthesized application#1 }

-- `key => value` is drawn as the option it builds; the tensor product and power
-- are set as products and powers are; any other binary operator is spaced apart.
shape BinaryOperation := operation -> (
    (operator, left, right) := toSequence operation;
    if operator === symbol => then
        shape new Option from { left, right }
    else if operator === symbol ^** then
        shaped(Superscript, { operand(left, looseBase), row { signAtom "⊗",
            shape right } })
    else if operator === symbol ** then
        row { operand(left, looseOperand), signAtom "⊗", operand(right, looseOperand) }
    else row { operand(left, looseOperand), space, signAtom toString operator, space,
        operand(right, looseOperand) }
)

-- A map is target ⟵ source, its label over the arrow; a chain of maps is one
-- row, so a chain too wide breaks between its maps.
shape MapExpression := map' -> (
    arrow := atom("⟵", HLG "MapArrow", "MathNormal");
    row join(if instance(map'#0, MapExpression) then
                (shape map'#0).Parts
            else { shape map'#0 },
        { if #map' > 2 then
                    shaped(OverExpression, { arrow, shape map'#2 })
                else arrow, shape map'#1 })
)

-- A matrix is a grid of its entries, its Degrees, of its rows and its columns,
-- beside it and any other option under it. A zero map, which M2 spells
-- {zero => (target, source)}, is 0, as M2 prints it.
shape MatrixExpression := matrix' -> (
    rows := select(toList matrix', entries -> not instance(entries, Option));
    options := select(toList matrix', entries -> instance(entries, Option));
    degrees := select(options, option -> option#0 === Degrees);
    grid := hashTable { symbol Rows => (entries -> shape \ toList entries) \ rows };
    if any(options, option -> option#0 === symbol zero) then
        shape 0
    else if #degrees > 0 then
        shaped(MatrixExpression, merge(grid, hashTable { Degrees => (side -> shape \ side)
                \ degrees#0#1 }, last))
    else if #options > 0 then
        shaped(Table, prepend({ shaped(MatrixExpression, grid) },
            (option -> { shape option }) \ options))
    else shaped(MatrixExpression, grid)
)
-- A vector is a column; SparseVectorExpression{n, {(i, x), …}} the vector of
-- length n with x at i, zeros and all; SparseMonomialVectorExpression the sum
-- of each a·m times the i-th basis vector, which M2 spells <i>.
shape VectorExpression := vector' -> shape new MatrixExpression from apply(toList vector',
    entry -> { entry })
shape SparseVectorExpression := sparse -> (
    entries := new MutableList from sparse#0 : expression 0;
    scan(sparse#1, (i, entry) -> entries#i = entry);
    shape VectorExpression toList entries
)
shape SparseMonomialVectorExpression := sparse -> shape sum(sparse#1, (i, m, a) ->
        expression a*expression m*Drawn { atom("<" | toString i | ">",
            HLG "Variable", "MathNormal") })

-- A diagram's pieces at their places and its arrows' labels, and its Straight
-- diagram in turn.
shape DiagramExpression := diagram -> shaped(DiagramExpression, hashTable {
    symbol Pieces => (piece -> { piece#0, shape piece#1 }) \ diagram#0,
    symbol Arrows => (arrow -> { arrow#0, arrow#1, if arrow#2 =!= null then
                shape arrow#2 })
        \ diagram#1,
    Straight => if #diagram > 2 then
            shape diagram#2#1
})

-- An expression as the tree of its classes, each over its parts; a part that is
-- no expression, or holds one value, is drawn as itself.
branch = e -> { class e, if instance(e, Expression) and not instance(e, Holder) then
            new TreeExpression from apply(toList e, branch)
        else e }
