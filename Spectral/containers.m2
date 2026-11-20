-- Containers: their items between the delimiters of their kind, each drawn as a
-- part; a container that holds itself is drawn once.

-- A visible list is its items between the delimiters of its kind, a vertical
-- one standing them one under another. A mutable list, a partition and a set
-- are lists apart from their names, which the type beside them gives, though
-- none is a visible list; a set lists its members in the order its keys come.
rod VisibleList := items -> Rod {apply(items, rod')}
rod MutableList := rod Partition := items -> Rod {apply(toList items, rod')}
rod Set := set' -> rod' keys set'

-- The key before `=>` is coloured as an option's name is in code when it is
-- spelled by a symbol or a string, whatever builds the pair.
optionKey := key -> (
	if instance(key, Holder) then
		optionKey key#0
	else if instance(key, Symbol) or instance(key, String) then
		rod' key ++ {Highlight => HLG "Option"}
	else rod' key
)
rod Option := pair -> Rod {RowExpression {optionKey pair#0,
	Rod {Holder {" => "}, Highlight => HLG "Operator"}, rod' pair#1}}

-- A numbered vertical list numbers its rows from 0, the rows aligned beside
-- their numbers.
rod NumberedVerticalList := items -> Rod {VerticalList {Rod {AlignedExpression apply(
	#items, i -> {Rod {Holder {toString i | "."}, Group => HLG "Number"},
		rod' items#i}
)}}}

-- Pairs already drawn stacked between braces, keys, arrows and values aligned.
tabulated := drawnPairs -> Rod {VerticalList {Rod {AlignedExpression apply(
	drawnPairs, (key, entry) -> {key, rod' symbol =>, entry}
)}}}
-- A table keeping the stock formatting shows its pairs; any other is spelled as
-- M2 spells it: a type, a package or a Gröbner basis is a table too, which no
-- one means to read pair by pair. A tally is the table of its counts.
rod HashTable := table -> (
	stock := base -> lookup(expression, class table) === lookup(expression, base)
		and lookup(net, class table) === lookup(net, base);
	if any({HashTable, MutableHashTable}, stock) then
		tabulated apply(pairs table, (key, entry) -> (optionKey key, rod' entry))
	else spelledAsM2 table
)
rod VirtualTally := tally' -> tabulated apply(pairs tally', (key, count) ->
		(optionKey key, rod' count))

-- A class hierarchy is a tree of its subclasses, each level sorted as M2's own
-- net sorts it. A class name is a label coloured as a type, so a ring's name
-- never typesets the hierarchy.
rod Descent := tree -> Rod {TreeExpression apply(sort(pairs tree,
	toString@@net@@first), pair -> {
		rod' toString net pair#0 ++ {Highlight => HLG "Type"},
		rod' pair#1
	})}

-- speek'_n x: the drawing of x laid out as the table it is, n levels of
-- drawings deep: Rod over its fields, its Shape the class of its expression
-- over the expression's parts, and each part past the depth by the text it
-- prints as. A Rod draws as itself, so speek'_2 rod' x shows x's.
speek' = deepened(x -> speek x, (depth, x) -> (
	node := rod'_0 x;
	shown := part -> (
		if instance(part, Rod) then
			(if depth > 1 then
						speek'_(depth - 1) part
					else Rod {Holder {toString part}, Highlight =>
							HLG "Muted"}) else if instance(part, Option) then
			rod' new Option from {part#0, shown part#1}
		else if instance(part, BasicList) then
			Rod {apply(toList part, shown)}
		else rod' part
	);
	shape := node#Shape;
	fields := apply(sort(pairs node, toString@@first), (key, entry) -> (optionKey key,
		if key === Shape then
			Rod {RowExpression {rod' class shape, Rod {apply(toList shape,
				shown)}}}
		else rod' entry));
	Rod {RowExpression {rod' Rod, tabulated fields}}
))
speek Thing := speek'_1
