-- Expressions: each class laid out in the notation it stands for, its operands
-- drawn with their own classes. Operators set their operands as maths.

-- An expression is drawn as its class lays it out, marked with that class unless
-- the layout is a value drawn whole, which keeps its own.
specNet Expression := shape -> (
	drawn := formatted shape;
	if drawn#?Class then
		drawn
	else drawn ++ {Class => class shape}
)
specNet Holder := held -> specNet held#0
-- A class without a layout of its own is spelled by its name over its parts.
formatted Expression := shape -> row {atom(toString class shape, Type),
	listed(toList shape, "{", "}")}

-- What reads as several terms is parenthesized beside an operator, and anything
-- compound as the base of a power.
looseOperand := {Sum, Equation}
looseBase := {Sum, Product, TensorProduct, Divide, Minus, Power, BinaryOperation}
operand (Thing, List) := (part, loose) -> (
	drawn := specNet part;
	if any(loose, class' -> drawsAs(drawn, class')) then
		parenthesized drawn
	else drawn
)
space := atom(" ", "Canvas")

-- A sum is its terms between plus signs, each negative term's minus sign
-- standing in for one; the empty sum is 0.
AssociativeExpression.typesetOperands = true
formatted Sum := sum -> (
	if #sum == 0 then
		return specNet 0;
	row flatten apply(#sum, i -> (
		term := specNet sum#i;
		if i == 0 or drawsAs(term, Minus) then {term} else {atom("+", "Operator"), term}
	))
)
scan({(Product, "·"), (TensorProduct, "⊗"), (DirectSum, "⊕"), (Equation, " == ")},
	(class', sign) -> formatted class' := factors -> joined(apply(toList factors,
		factor -> operand(factor, looseOperand)), sign, "Operator"))

Minus.typesetOperands = true
formatted Minus := minus -> row {atom("-", "Operator"), operand(minus#0, looseOperand)}

Adjacent.typesetOperands = true
formatted RowExpression := formatted Adjacent := formatted SheafExpression :=
	shape -> row apply(toList shape, specNet)

Parenthesize.typesetOperands = true
specNet Parenthesize := lookup(specNet, Expression)
formatted Parenthesize := held -> parenthesized specNet held#0

ZeroExpression.typeset = true
OneExpression.typeset = true

Divide.typeset = true
Divide.typesetOperands = true
formatted Divide := quotient -> fraction(specNet quotient#0, specNet quotient#1)

-- A power raises its exponent over its base, as a superscript does.
Power.typeset = true
Power.typesetOperands = true
Superscript.typeset = true
Superscript.typesetOperands = true
formatted Power := formatted Superscript := power -> script(operand(power#0, looseBase),
	null, specNet power#1)

-- A subscript lowers its index, a sequence of indices spelled with commas.
Subscript.typeset = true
Subscript.typesetOperands = true
formatted Subscript := indexed -> script(operand(indexed#0, looseOperand),
	if instance(indexed#1, Sequence) then
		joined(apply(toList indexed#1, specNet), ",", "Delimiter")
	else specNet indexed#1, null)

-- f(x, y): a function applied to its arguments.
formatted FunctionApplication := application -> row {specNet application#0,
	parenthesized if instance(application#1, Sequence) then
			joined(apply(toList application#1, specNet), ", ", "Delimiter")
		else specNet application#1}

-- A map is target ⟵ source, its label over the arrow; a chain of maps is one
-- row, so a chain too wide breaks between its maps.
MapExpression.typeset = true
MapExpression.typesetOperands = true
formatted MapExpression := map -> (
	arrow := atom("⟵", "MapArrow");
	target := specNet map#0;
	row join(if drawsAs(target, MapExpression) then
				target.Items
			else {target}, {
				if #map > 2 then
					labelled("Over", arrow, specNet map#2)
				else arrow,
				specNet map#1
			})
)

-- UnderExpression{base, label}: a label centred beneath an expression, keeping
-- the expression's baseline; a complex sets each module's degree under it.
UnderExpression = new HeaderType of Expression
UnderExpression.typeset = true
UnderExpression.typesetOperands = true
formatted UnderExpression := under -> labelled("Under", specNet under#0, specNet under#1)

-- `key => entry` and the other binary operators, spaced apart, but for the
-- tensor product and tensor power, set as products and powers are. The key
-- before `=>` is coloured as an option's name is in code when it is spelled by
-- a name or a string, whatever builds the pair.
BinaryOperation.typesetOperands = true
formatted BinaryOperation := operation -> (
	(operator, left, right) := toSequence operation;
	if operator === symbol ^** then
		script(operand(left, looseBase), null, row {atom("⊗", "Operator"), specNet right})
	else if operator === symbol ** then
		joined({operand(left, looseOperand), operand(right, looseOperand)}, "⊗",
			"Operator")
	else if operator === symbol => then
		row {optionKey left, space, specNet operator, space, specNet right}
	else row {operand(left, looseOperand), space, specNet operator, space,
		operand(right, looseOperand)}
)
optionKey Thing := specNet
optionKey Holder := held -> optionKey held#0
optionKey Symbol := optionKey String := key -> specNet key ++ {Highlight => Option}

-- A matrix is a grid of its entries in parentheses, which only holds them, so
-- they keep their own setting; its Degrees stand beside its rows, and any other
-- option under it. A table is the same grid, bare, and a vector a column.
formatted MatrixExpression := matrix -> (
	rows := select(toList matrix, row -> not instance(row, Option));
	options := select(toList matrix, row -> instance(row, Option));
	degrees := select(options, option -> option#0 === Degrees);
	drawn := grid(apply(rows, row -> apply(toList row, specNet)), "Matrix");
	if #degrees > 0 then
		drawn ++ {Degrees => apply(first degrees#0#1, specNet)}
	else if #options > 0 then
		grid(prepend({drawn}, apply(options, option -> {specNet option})), "Bare")
	else drawn
)
formatted Table := table -> grid(apply(toList table, row -> apply(toList row, specNet)),
	"Bare")
formatted VectorExpression := vector -> grid(apply(toList vector, entry ->
		{specNet entry}), "Matrix")

-- Rows of cells, AlignedExpression{{a, b, c}, …}: every cell but a row's last
-- sits in a column aligned across the rows, and the last runs on, wrapping
-- beneath where it started.
AlignedExpression = new HeaderType of Expression
net AlignedExpression := aligned -> netList(apply(toList aligned, toList),
	Boxes => false, HorizontalSpace => 1)
formatted AlignedExpression := aligned -> grid(apply(toList aligned, row ->
		apply(toList row, specNet)), "Aligned")
