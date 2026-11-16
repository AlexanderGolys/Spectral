-- Expressions: the shapes values are spelled in, drawn part by part with each
-- part's class, operators setting their operands as maths.

-- An expression is drawn as its parts; a holder as what it holds.
specNet Expression := shape -> new SpecNet from (class shape, apply(toList shape,
	specNet))
specNet Holder := held -> specNet held#0

Parenthesize.typesetOperands = true
specNet Parenthesize := lookup(specNet, Expression)

-- Sums, products and the like.
AssociativeExpression.typesetOperands = true
Minus.typesetOperands = true
Adjacent.typesetOperands = true

ZeroExpression.typeset = true
OneExpression.typeset = true

Divide.typeset = true
Divide.typesetOperands = true

Power.typeset = true
Power.typesetOperands = true

Superscript.typeset = true
Superscript.typesetOperands = true

Subscript.typeset = true
Subscript.typesetOperands = true

MapExpression.typeset = true
MapExpression.typesetOperands = true

-- UnderExpression{base, label}: a label centred beneath an expression, keeping
-- the expression's baseline; a complex sets each module's degree under it.
UnderExpression = new HeaderType of Expression
UnderExpression.typeset = true
UnderExpression.typesetOperands = true

-- `key => entry` and the other binary operators. The key before `=>` is coloured
-- as an option's name is in code when it is spelled by a name or a string,
-- whatever builds the pair.
BinaryOperation.typesetOperands = true
specNet BinaryOperation := operation -> (
	(operator, key, entry) := toSequence operation;
	if operator === symbol => then
		new SpecNet from (class operation, {specNet operator, optionKey key,
			specNet entry})
	else (lookup(specNet, Expression)) operation
)
optionKey Thing := specNet
optionKey Holder := held -> optionKey held#0
optionKey Symbol := optionKey String := key -> specNet key ++ {Highlight => {"Option"}}

-- A matrix only holds its entries, which keep their own setting; each row is a
-- list of them.
specNet MatrixExpression := matrix -> new SpecNet from (class matrix,
	apply(toList matrix, row -> if instance(row, Option) then
				specNet row
			else new SpecNet from (List, apply(toList row, specNet))))

-- Rows of cells, AlignedExpression{{a, b, c}, …}: every cell but a row's last
-- sits in a column aligned across the rows, and the last runs on, wrapping
-- beneath where it started.
AlignedExpression = new HeaderType of Expression
net AlignedExpression := aligned -> netList(apply(toList aligned, toList),
	Boxes => false, HorizontalSpace => 1)
specNet AlignedExpression := aligned -> new SpecNet from (class aligned,
	apply(toList aligned, row -> new SpecNet from (List, apply(toList row, specNet))))
