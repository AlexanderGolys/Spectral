-- Containers: their items between the delimiters of their kind, each at the
-- container's own depth; a container that holds itself is drawn once.

-- A visible list is its items between the delimiters of its kind, a vertical
-- one standing them one under another.
rod VisibleList := items -> contentsOf(items, items -> Rod {apply(items, rod)})
-- A mutable list, a partition and a set are lists apart from their names,
-- which the type beside them gives, though none is a visible list. A set lists
-- its members in the order its expression does.
rod MutableList := rod Partition := items -> contentsOf(items, items ->
		Rod {apply(toList items, rod)})
rod Set := set' -> rod keys set'
highlightGroup Option := class' -> HLG "Option"
rod Option := pair -> contentsOf(pair, pair -> Rod {RowExpression {optionKey pair#0,
	Rod {Holder {" => "}, Highlight => HLG "Operator"}, rod pair#1}})

-- A numbered vertical list numbers its rows from 0, the rows aligned beside
-- their numbers.
rod NumberedVerticalList := items -> contentsOf(items, items -> Rod {VerticalList {
	Rod {AlignedExpression apply(#items, i -> {Rod {Holder {toString i | "."},
		Class => ZZ}, rod items#i})}
}})

-- A table keeping the stock formatting shows its pairs, keys and arrows aligned.
-- Any other is drawn as itself: a type, a package or a Gröbner basis is a table
-- too, which no one means to read pair by pair.
tabulated List := drawnPairs -> Rod {VerticalList {Rod {AlignedExpression apply(
	drawnPairs, (key, entry) -> {key, rod symbol =>, entry}
)}}}
tabulated HashTable := table -> tabulated apply(pairs table, (key, entry) ->
		(optionKey key, rod entry))
rod HashTable := table -> (
	stock := base -> lookup(expression, class table) === lookup(expression, base)
		and lookup(net, class table) === lookup(net, base);
	if any({HashTable, MutableHashTable}, stock) then
		contentsOf(table, tabulated)
	else (lookup(rod, Thing)) table
)
-- A tally is the table of its counts, as a hash table is drawn.
rod VirtualTally := tally' -> contentsOf(tally', tabulated)

-- A class hierarchy is a tree of its subclasses, each level sorted as M2's own
-- net sorts it. A class name is a label coloured as a type, so a ring's name
-- never typesets the hierarchy.
rod Descent := tree -> contentsOf(tree, tree -> Rod {TreeExpression apply(
	sort(pairs tree, toString@@net@@first), pair -> {
		rod(toString net pair#0) ++ {Highlight => Type},
		rod pair#1
	}
)})
