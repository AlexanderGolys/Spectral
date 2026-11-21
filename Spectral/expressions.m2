-- Expressions: each class laid out in the notation it stands for, its parts drawn
-- in turn. An operator sets its operands as maths.

rod Holder := held -> rod' held#0
-- A shape that only places its parts is drawn as itself; a fraction, parentheses
-- and a label over or under an expression set their parts as maths.
rod RowExpression := shape -> Rod {apply(shape, rod')}
rod Divide := rod Parenthesize := rod UnderExpression := rod OverExpression :=
	shape -> Rod {apply(shape, rod'), mathsFont}

-- What reads as several terms is parenthesized beside an operator, and anything
-- compound as the base of a power.
looseOperand := {Sum, Equation}
looseBase := {Sum, Product, TensorProduct, Divide, Minus, Power, BinaryOperation}
laidOutAs := (drawn, classes) -> drawn#?Class and any(classes, class' ->
		ancestor(class', drawn#Class))
operand := (part, loose) -> (
	drawn := rod' part;
	if laidOutAs(drawn, loose) then
		Rod {Parenthesize {drawn}}
	else drawn
)
space := Rod {Holder {" "}, Highlight => HLG "Canvas"}
-- A sign between operands, coloured as an operator.
sign := text -> Rod {Holder {text}, Highlight => HLG "Operator"}

-- A sum is its terms between plus signs, each negative term's minus sign
-- standing in for one; the empty sum is 0.
rod Sum := sum -> (
	if #sum == 0 then
		return rod' 0;
	Rod {RowExpression flatten apply(#sum, i -> (
		term := rod' sum#i;
		if i == 0 or laidOutAs(term, {Minus}) then {term} else {sign "+", term}
	)), mathsFont}
)
-- Whether a drawing begins with one laid out as one of `classes`, through the
-- shapes that set their first part first on its line: 2^3 begins with a number.
beginsWith := (drawn, classes) -> laidOutAs(drawn, classes) or (
	any({RowExpression, Subscript, Superscript}, instance_(drawn#Shape))
		and beginsWith(drawn#Shape#0, classes)
)
-- A product is its factors side by side, as maths juxtaposes them, so x*y is
-- drawn as xy is; a dot stands before a factor beginning with a number or a
-- negation, which would read on from the factor before it: x·2, x·-y.
rod Product := factors -> (
	drawn := apply(toList factors, factor -> operand(factor, looseOperand));
	Rod {RowExpression flatten apply(#drawn, i ->
			if i > 0 and beginsWith(drawn#i, {Number, Minus}) then
			{sign "·", drawn#i} else {drawn#i}), mathsFont}
)
scan({(TensorProduct, "⊗"), (DirectSum, "⊕"), (Equation, " == ")},
	(class', text) -> rod class' := factors -> Rod {RowExpression between(sign text,
		apply(toList factors, factor -> operand(factor, looseOperand))), mathsFont})

rod Minus := minus -> Rod {RowExpression {sign "-", operand(minus#0, looseOperand)},
	mathsFont}

rod SheafExpression := shape -> Rod {RowExpression apply(toList shape, rod')}

-- frac R, cokernel M: a function applied by juxtaposition, a space between it
-- and its argument, which a bracketed one follows directly, as in R[x] and
-- OO_X(1).
rod Adjacent := application -> Rod {RowExpression join({rod' application#0},
	if instance(application#1, Array) or instance(application#1, Parenthesize) then
		{} else {space},
	{operand(application#1, looseBase)}), mathsFont}

-- A power raises its exponent over its base, as a superscript does.
rod Power := rod Superscript := power -> Rod {Superscript {operand(power#0,
	looseBase), rod' power#1}, mathsFont}

-- A subscript lowers its index, a sequence of indices spelled with commas.
rod Subscript := indexed -> Rod {Subscript {operand(indexed#0, looseOperand),
	if instance(indexed#1, Sequence) then
		Rod {RowExpression between(Rod {Holder {","}, Highlight => HLG "Delimiter"},
			apply(toList indexed#1, rod'))}
	else rod' indexed#1}, mathsFont}

-- f(x, y): a function applied to its arguments.
rod FunctionApplication := application -> Rod {RowExpression {
	rod' application#0,
	if instance(application#1, Sequence) then
		Rod {apply(application#1, rod')}
	else Rod {Parenthesize {rod' application#1}}
}}

-- A map is target ⟵ source, its label over the arrow; a chain of maps is one
-- row, so a chain too wide breaks between its maps.
rod MapExpression := map -> (
	arrow := Rod {Holder {"⟵"}, Highlight => HLG "MapArrow"};
	target := rod' map#0;
	Rod {RowExpression join(if laidOutAs(target, {MapExpression}) then
				toList target#Shape
			else {target}, {
				if #map > 2 then
					Rod {OverExpression {arrow, rod' map#2}}
				else arrow,
				rod' map#1
			}), mathsFont}
)

-- `key => entry` is drawn as the option it builds; the other binary operators
-- are spaced apart, but for the tensor product and tensor power, set as
-- products and powers are.
rod BinaryOperation := operation -> (
	(operator, left, right) := toSequence operation;
	if operator === symbol => then
		return rod' new Option from {left, right};
	Rod {if operator === symbol ^** then
				Superscript {operand(left, looseBase), Rod {RowExpression {sign "⊗",
					rod' right}}}
			else if operator === symbol ** then
			RowExpression {operand(left, looseOperand), sign "⊗",
				operand(right, looseOperand)}
		else RowExpression {operand(left, looseOperand), space, rod' operator, space,
			operand(right, looseOperand)}, mathsFont}
)

-- A matrix is a grid of its entries in parentheses, which only holds them, so
-- they keep their own setting; its Degrees, of its rows and its columns, stand
-- beside it, and any other option under it. A zero map is spelled by M2 as
-- {zero => (target, source)}, and drawn as M2 prints it: 0. A table is the same
-- grid, bare, and a vector a column.
rod MatrixExpression := matrix -> (
	rows := select(toList matrix, row -> not instance(row, Option));
	options := select(toList matrix, row -> instance(row, Option));
	degrees := select(options, option -> option#0 === Degrees);
	entries' := apply(rows, row -> apply(toList row, rod'));
	if any(options, option -> option#0 === symbol zero) then
		rod' 0
	else if #degrees > 0 then
		Rod {new MatrixExpression from append(entries', Degrees => apply(
			degrees#0#1, side -> apply(side, rod')
		))}
	else if #options > 0 then
		Rod {Table prepend({Rod {new MatrixExpression from entries'}}, apply(options,
			option -> {rod' option}))}
	else Rod {new MatrixExpression from entries'}
)
rod Table := table -> Rod {new Table from apply(toList table, row ->
		apply(toList row, rod'))}
rod VectorExpression := vector -> Rod {new MatrixExpression from apply(
	toList vector, entry -> {rod' entry}
)}

-- SparseVectorExpression{n, {(i, x), …}}: the vector of length n with x at i,
-- drawn whole, zeros and all, as a vector is.
rod SparseVectorExpression := sparse -> (
	entries := new MutableList from sparse#0 : expression 0;
	scan(sparse#1, (i, entry) -> entries#i = entry);
	rod' VectorExpression toList entries
)
-- SparseMonomialVectorExpression{n, {(i, m, a), …}}: the sum of each a·m times
-- the i-th basis vector, which M2 spells <i> and treats as a variable.
rod SparseMonomialVectorExpression := sparse -> rod' sum(sparse#1, (i, m, a) ->
		expression a*expression m*hold Rod {Holder {"<" | toString i | ">"},
			Group => HLG "Variable"})

-- Rows of cells are drawn cell by cell: aligned rows, and a tree's branches.
rod AlignedExpression := rod TreeExpression := rows -> Rod {
	apply(rows, row -> apply(toList row, rod'))
}
-- A diagram draws its pieces and the labels of its arrows, and its Straight
-- diagram in turn.
rod DiagramExpression := diagram -> Rod {new DiagramExpression from join(
	{apply(diagram#0, piece -> {piece#0, rod' piece#1}), apply(diagram#1, arrow ->
			{arrow#0, arrow#1, if arrow#2 =!= null then
						rod' arrow#2})},
	apply(drop(toList diagram, 2), option -> option#0 => rod' option#1)
)}
