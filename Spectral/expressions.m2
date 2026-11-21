-- M2's expressions as the shell draws them: each class it lays out drawn by its
-- own shape, part by part, and each operator as a row of its operands and signs.

row = shaped_RowExpression
parenthesized = part -> shaped(Parenthesize, { shape part })
operatorSign = text -> atom(text, HLG "Operator", "MathNormal")
space = atom(" ", HLG "Canvas", "MathNormal")

-- Whether an expression of a class is parenthesized beside an operator, where
-- its own terms would read as the operator's, and as the base of a power, where
-- the exponent would raise only its last part.
bracketedAsOperand = method(Dispatch => Type)
bracketedAsOperand Thing := class' -> false
bracketedAsOperand Sum := class' -> true
bracketedAsOperand Equation := class' -> true
bracketedAsBase = method(Dispatch => Type)
bracketedAsBase Thing := class' -> false
bracketedAsBase Sum := class' -> true
bracketedAsBase Product := class' -> true
bracketedAsBase TensorProduct := class' -> true
bracketedAsBase Divide := class' -> true
bracketedAsBase Minus := class' -> true
bracketedAsBase Power := class' -> true
bracketedAsBase BinaryOperation := class' -> true
operand = part -> (
	if bracketedAsOperand class expression part then
		parenthesized part
	else shape part
)
base = part -> (
	if bracketedAsBase class expression part then
		parenthesized part
	else shape part
)

-- A value is drawn by its expression, down to what M2 spells by itself: an atom
-- coloured and set as its class says.
shape Thing := x -> (
	e := expression x;
	if instance(e, Holder) and e#0 === x then
		atom(toString x, highlightGroup class x, font class x)
	else shape e
)
shape Holder := held -> shape held#0
-- An expression holding a drawing already made, for parts no value spells.
Drawn = new WrapperType of Holder
shape Drawn := held -> held#0
-- An expression no shape is installed for is spelled as M2 spells it.
shape Expression := e -> atom(toString e, HLG "Text", "TextTT")

-- A fraction is its numerator over its denominator, a row its parts side by
-- side; a label beneath or above its base keeps the base's baseline.
shape Divide := fraction -> shaped(Divide, { shape fraction#0, shape fraction#1 })
shape RowExpression := parts -> shaped(RowExpression, shape \ toList parts)
shape UnderExpression := labelled -> shaped(UnderExpression, { shape labelled#0,
	shape labelled#1 })
shape OverExpression := labelled -> shaped(OverExpression, { shape labelled#0,
	shape labelled#1 })
shape Parenthesize := held -> parenthesized held#0

-- A list's items are drawn by their expressions, so a ring a name holds keeps
-- its name; each kind of list is fenced as M2 fences it.
shape List := items -> shaped(List, shape@@expression \ toList items)
shape Array := items -> shaped(Array, shape@@expression \ toList items)
shape Sequence := items -> shaped(Sequence, shape@@expression \ toList items)
shape AngleBarList := items -> shaped(AngleBarList, shape@@expression \ toList items)
shape VerticalList := items -> shaped(VerticalList, shape@@expression \ toList items)

-- A grid is its rows of cells; aligned rows are cells in columns, the last
-- running on; a tree is its branches, each a label over its subtree.
shape Table := rows -> shaped(Table, (cells -> shape \ toList cells) \ toList rows)
shape AlignedExpression := rows -> shaped(AlignedExpression, (cells -> shape
		\ toList cells) \ toList rows)
shape TreeExpression := branches -> shaped(TreeExpression, (branch' -> {
	shape branch'#0, shape branch'#1
}) \ toList branches)

-- A sum is its terms between plus signs, a negative term's minus standing in
-- for its plus; the empty sum is 0.
shape Sum := terms -> (
	if #terms == 0 then
		return shape 0;
	pluses := (term -> if not instance(term, Minus) then
				operatorSign "+") \ drop(toList terms, 1);
	row delete(null, mingle(shape \ toList terms, pluses))
)
-- A product is its factors side by side, as maths juxtaposes them, a dot only
-- before one beginning with a number or a negation, which would run into the
-- factor before it: 2xy², but x·2 and x·-y. The empty product is 1.
shape Product := factors -> (
	if #factors == 0 then
		return shape 1;
	dots := (factor -> if leadsWithNumber factor then
				operatorSign "·") \ drop(toList factors, 1);
	row delete(null, mingle(operand \ toList factors, dots))
)
-- Whether a factor's drawing begins with a numeral or a minus sign: a value's
-- as its expression's, a power's or a script's as its base's.
leadsWithNumber = method(Dispatch => Thing)
leadsWithNumber Thing := x -> (
	e := expression x;
	instance(e, Expression) and leadsWithNumber e
)
leadsWithNumber Expression := e -> false
leadsWithNumber Holder := held -> instance(held#0, Number)
leadsWithNumber Minus := negated -> true
leadsWithNumber Power := power -> leadsWithNumber power#0
leadsWithNumber Subscript := indexed -> leadsWithNumber indexed#0
leadsWithNumber Superscript := raised -> leadsWithNumber raised#0
shape Minus := negated -> row { operatorSign "-", operand negated#0 }
shape TensorProduct := factors -> row between(operatorSign "⊗", operand \ toList factors)
shape DirectSum := summands -> row between(operatorSign "⊕", operand \ toList summands)
shape Equation := sides -> row between(row { space, operatorSign toString symbol ==,
	space }, operand \ toList sides)

-- A power raises its exponent over its base, as a superscript does; a subscript
-- lowers its index, a sequence of indices spelled with commas.
shape Power := power -> shaped(Superscript, { base power#0, shape power#1 })
shape Superscript := raised -> shaped(Superscript, { base raised#0, shape raised#1 })
shape Subscript := indexed -> shaped(Subscript, { operand indexed#0,
	if instance(indexed#1, Sequence) then
		row between(atom(toString symbol ,, HLG "Delimiter", "MathNormal"), shape
				\ toList indexed#1)
	else shape indexed#1 })

-- frac R, cokernel M: a function applied by juxtaposition, a space between it
-- and its argument, which a bracketed one follows directly, as in R[x] and
-- OO_X(1); f(x, y): a function applied to its arguments.
shape Adjacent := application -> row join({ shape application#0 },
	if instance(application#1, Array) or instance(application#1, Parenthesize) then
		{} else { space }, { base application#1 })
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
		shaped(Superscript, { base left, row { operatorSign "⊗", shape right } })
	else if operator === symbol ** then
		row { operand left, operatorSign "⊗", operand right }
	else row { operand left, space, operatorSign toString operator, space, operand right }
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

-- A degree, a module's or one a complex is graded by, set apart from the
-- values beside it in the colour of degrees.
degreeShape = method(Dispatch => Thing)
degreeShape ZZ := n -> atom(toString n, HLG "Degree", "MathNormal")
degreeShape List := degree -> shaped(List, degreeShape \ degree)

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
		shaped(MatrixExpression, merge(grid, hashTable { Degrees => (side ->
				degreeShape \ side)
				\ degrees#0#1 }, last))
	else if #options > 0 then
		shaped(Table, prepend({ shaped(MatrixExpression, grid) },
			(option -> { shape option }) \ options))
	else shaped(MatrixExpression, grid)
)
-- A vector is a column; SparseVectorExpression{n, {(i, x), …}} the vector of
-- length n with x at i, zeros and all; SparseMonomialVectorExpression the sum
-- of each a·m times the i-th basis vector, which M2 spells <i>.
shape VectorExpression := vector' -> shape new MatrixExpression from ((entry -> { entry })
		\ toList vector')
shape SparseVectorExpression := sparse -> (
	entries := hashTable sparse#1;
	shape VectorExpression((i -> if entries#?i then
				entries#i
			else expression 0) \ toList(0 ..< sparse#0))
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
			new TreeExpression from branch \ toList e
		else e }
