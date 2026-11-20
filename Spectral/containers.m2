-- Containers: their items between the delimiters of their kind, each at the
-- container's own depth; a container that holds itself is drawn once.

scan({(VisibleList, "{", "}"), (MutableList, "{", "}"), (Array, "[", "]"),
	(Sequence, "(", ")")}, (class', left, right) ->
		rod class' := items -> contentsOf(items, items -> listed(toList items, left,
			right)))
-- A partition and a set are lists apart from their names, which the type beside
-- them gives, though neither is a visible list. A set lists its members in the
-- order its expression does.
rod Partition := lookup(rod, VisibleList)
rod Set := set' -> (lookup(rod, VisibleList)) keys set'
rod AngleBarList := items -> contentsOf(items, items -> fence("⟨", "⟩", row {
	atom("|", "Punctuation"),
	joined(apply(toList items, rod), ", ", "Delimiter"),
	atom("|", "Punctuation")
}))
highlightGroup Option := class' -> "Option"
rod Option := pair -> contentsOf(pair, pair -> joined({optionKey pair#0,
	rod pair#1}, " => ", "Operator"))

-- A vertical container stands its rows one under another, left-aligned between
-- braces; a numbered one numbers them from 0.
stacked List := rows -> fence("{", "}", row {atom(" ", "Canvas"), grid(rows,
	"LeftAligned"), atom(" ", "Canvas")})
rod VerticalList := items -> contentsOf(items, items -> stacked apply(toList items,
	item -> {rod item}))
rod NumberedVerticalList := items -> contentsOf(items, items -> stacked apply(
	#items, i -> {atom(toString i | ".", ZZ), rod items#i}
))

-- A table keeping the stock formatting shows its pairs, keys and arrows aligned.
-- Any other is drawn as itself: a type, a package or a Gröbner basis is a table
-- too, which no one means to read pair by pair.
tabulated List := drawnPairs -> stacked {{grid(apply(drawnPairs, (key, entry) ->
		{key, rod symbol =>, entry}), "Aligned")}}
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
rod Descent := tree -> contentsOf(tree, tree -> new Rod from {
	Shape => "Tree",
	Branches => apply(sort(pairs tree, toString@@net@@first), pair -> {
		rod(toString net pair#0) ++ {Highlight => Type},
		rod pair#1
	})
})
