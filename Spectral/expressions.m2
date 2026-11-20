-- Expressions: each class laid out in the notation it stands for, its operands
-- drawn with their own classes. Operators set their operands as maths.

-- An expression is drawn as its class lays it out, marked with that class unless
-- the layout is a value drawn whole, which keeps its own.
rod Expression := shape -> (
	drawn := formatted shape;
	if drawn#?Class then
		drawn
	else drawn ++ {Class => class shape}
)
rod Holder := held -> rod held#0
-- A shape is drawn as itself, its parts drawn in turn; a class without a
-- layout of its own is spelled by its name over its parts.
formatted Expression := shape -> (
	if shapeOf shape =!= null then
		Rod {apply(shape, rod)}
	else Rod {RowExpression {Rod {Holder {toString class shape}, {Class => Type}},
		Rod {apply(toList shape, rod)}}}
)

-- What reads as several terms is parenthesized beside an operator, and anything
-- compound as the base of a power.
looseOperand := {Sum, Equation}
looseBase := {Sum, Product, TensorProduct, Divide, Minus, Power, BinaryOperation}
operand (Thing, List) := (part, loose) -> (
	drawn := rod part;
	if any(loose, class' -> drawsAs(drawn, class')) then
		Rod {Parenthesize {drawn}}
	else drawn
)
space := Rod {Holder {" "}, {Highlight => HLG "Canvas"}}
-- A sign between operands, coloured as an operator.
sign := text -> Rod {Holder {text}, {Highlight => HLG "Operator"}}

-- A sum is its terms between plus signs, each negative term's minus sign
-- standing in for one; the empty sum is 0.
typesetOperands AssociativeExpression := class' -> true
formatted Sum := sum -> (
	if #sum == 0 then
		return rod 0;
	Rod {RowExpression flatten apply(#sum, i -> (
		term := rod sum#i;
		if i == 0 or drawsAs(term, Minus) then {term} else {sign "+", term}
	))}
)
scan({(Product, "·"), (TensorProduct, "⊗"), (DirectSum, "⊕"), (Equation, " == ")},
	(class', text) -> formatted class' := factors -> Rod {RowExpression between(
		sign text, apply(toList factors, factor -> operand(factor, looseOperand))
	)})

typesetOperands Minus := class' -> true
formatted Minus := minus -> Rod {RowExpression {sign "-", operand(minus#0,
	looseOperand)}}

formatted SheafExpression := shape -> Rod {RowExpression apply(toList shape, rod)}

-- frac R, cokernel M: a function applied by juxtaposition, a space between it
-- and its argument, which a bracketed one follows directly, as in R[x] and
-- OO_X(1).
typesetOperands Adjacent := class' -> true
formatted Adjacent := application -> Rod {RowExpression join({rod application#0},
	if instance(application#1, Array) or instance(application#1, Parenthesize) then
		{} else {space},
	{operand(application#1, looseBase)})}

-- A parenthesized expression is a holder that keeps its parentheses.
typesetOperands Parenthesize := class' -> true
rod Parenthesize := lookup(rod, Expression)

typeset ZeroExpression := class' -> true
typeset OneExpression := class' -> true

typeset Divide := typesetOperands Divide := class' -> true

-- A power raises its exponent over its base, as a superscript does.
typeset Power := typesetOperands Power := class' -> true
typeset Superscript := typesetOperands Superscript := class' -> true
formatted Power := formatted Superscript := power -> Rod {Superscript {
	operand(power#0, looseBase), rod power#1
}}

-- A subscript lowers its index, a sequence of indices spelled with commas.
typeset Subscript := typesetOperands Subscript := class' -> true
formatted Subscript := indexed -> Rod {Subscript {operand(indexed#0, looseOperand),
	if instance(indexed#1, Sequence) then
		Rod {RowExpression between(Rod {Holder {","}, {Highlight => HLG "Delimiter"}},
			apply(toList indexed#1, rod))}
	else rod indexed#1}}

-- f(x, y): a function applied to its arguments.
formatted FunctionApplication := application -> Rod {RowExpression {
	rod application#0,
	if instance(application#1, Sequence) then
		Rod {apply(application#1, rod)}
	else Rod {Parenthesize {rod application#1}}
}}

-- A map is target ⟵ source, its label over the arrow; a chain of maps is one
-- row, so a chain too wide breaks between its maps.
typeset MapExpression := typesetOperands MapExpression := class' -> true
formatted MapExpression := map -> (
	arrow := Rod {Holder {"⟵"}, {Highlight => HLG "MapArrow"}};
	target := rod map#0;
	Rod {RowExpression join(if drawsAs(target, MapExpression) then
				toList target#0
			else {target}, {
				if #map > 2 then
					Rod {OverExpression {arrow, rod map#2}}
				else arrow,
				rod map#1
			})}
)

-- A label over or under an expression: a map's over its arrow, and a complex
-- sets each module's degree under it.
typeset UnderExpression := typesetOperands UnderExpression := class' -> true
typeset OverExpression := typesetOperands OverExpression := class' -> true

-- `key => entry` and the other binary operators, spaced apart, but for the
-- tensor product and tensor power, set as products and powers are. The key
-- before `=>` is coloured as an option's name is in code when it is spelled by
-- a name or a string, whatever builds the pair.
typesetOperands BinaryOperation := class' -> true
formatted BinaryOperation := operation -> (
	(operator, left, right) := toSequence operation;
	Rod {if operator === symbol ^** then
				Superscript {operand(left, looseBase), Rod {RowExpression {sign "⊗",
					rod right}}}
			else if operator === symbol ** then
			RowExpression {operand(left, looseOperand), sign "⊗",
				operand(right, looseOperand)}
		else if operator === symbol => then
			RowExpression {optionKey left, space, rod operator, space, rod right}
		else RowExpression {operand(left, looseOperand), space, rod operator, space,
			operand(right, looseOperand)}}
)
optionKey Thing := rod
optionKey Holder := held -> optionKey held#0
optionKey Symbol := optionKey String := key -> rod key ++ {Highlight => Option}

-- A matrix is a grid of its entries in parentheses, which only holds them, so
-- they keep their own setting; its Degrees stand beside its rows, and any other
-- option under it. A table is the same grid, bare, and a vector a column.
formatted MatrixExpression := matrix -> (
	rows := select(toList matrix, row -> not instance(row, Option));
	options := select(toList matrix, row -> instance(row, Option));
	degrees := select(options, option -> option#0 === Degrees);
	drawn := apply(rows, row -> apply(toList row, rod));
	if #degrees > 0 then
		Rod {new MatrixExpression from append(drawn, Degrees => apply(
			first degrees#0#1, rod
		))}
	else if #options > 0 then
		Rod {Table prepend({Rod {new MatrixExpression from drawn}}, apply(options,
			option -> {rod option}))}
	else Rod {new MatrixExpression from drawn}
)
formatted Table := table -> Rod {new Table from apply(toList table, row ->
		apply(toList row, rod))}
formatted VectorExpression := vector -> Rod {new MatrixExpression from apply(
	toList vector, entry -> {rod entry}
)}

-- SparseVectorExpression{n, {(i, x), …}}: the vector of length n with x at i,
-- drawn whole, zeros and all, as a vector is.
formatted SparseVectorExpression := sparse -> (
	entries := new MutableList from sparse#0 : expression 0;
	scan(sparse#1, (i, entry) -> entries#i = entry);
	formatted VectorExpression toList entries
)
-- SparseMonomialVectorExpression{n, {(i, m, a), …}}: the sum of each a·m times
-- the i-th basis vector, which M2 spells <i> and treats as a variable.
formatted SparseMonomialVectorExpression := sparse -> rod sum(sparse#1, (i, m, a) ->
		expression a*expression m*hold Rod {Holder {"<" | toString i | ">"},
			{Class => Symbol}})

-- Rows of cells are drawn cell by cell: aligned rows, and a tree's branches.
formatted AlignedExpression := formatted TreeExpression := rows -> Rod {
	apply(rows, row -> apply(toList row, rod))
}
-- A diagram draws its pieces and the labels of its arrows, and its Straight
-- diagram in turn.
formatted DiagramExpression := diagram -> Rod {new DiagramExpression from join(
	{apply(diagram#0, piece -> {piece#0, rod piece#1}), apply(diagram#1, arrow ->
			{arrow#0, arrow#1, if arrow#2 =!= null then
						rod arrow#2})},
	apply(drop(toList diagram, 2), option -> option#0 => rod option#1)
)}
