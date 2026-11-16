-- Containers: their items between the delimiters of their kind, each at the
-- container's own depth; a container that holds itself is drawn once.

scan({(VisibleList, "{", "}"), (MutableList, "{", "}"), (Array, "[", "]"),
	(Sequence, "(", ")")}, (class', left, right) ->
		specNet class' := items -> contentsOf(items, items -> listed(toList items, left,
			right)))
specNet AngleBarList := items -> contentsOf(items, items -> fence("⟨", "⟩", row {
	atom("|", "Punctuation"),
	joined(apply(toList items, specNet), ", ", "Delimiter"),
	atom("|", "Punctuation")
}))
specNet Option := pair -> contentsOf(pair, pair -> joined({optionKey pair#0,
	specNet pair#1}, " => ", "Operator"))

-- A vertical container stands its rows one under another, left-aligned between
-- braces; a numbered one numbers them from 0.
stacked List := rows -> fence("{", "}", row {atom(" ", "Canvas"), grid(rows,
	"LeftAligned"), atom(" ", "Canvas")})
specNet VerticalList := items -> contentsOf(items, items -> stacked apply(toList items,
	item -> {specNet item}))
specNet NumberedVerticalList := items -> contentsOf(items, items -> stacked apply(
	#items, i -> {atom(toString i | ".", ZZ), specNet items#i}
))

-- A table keeping the stock formatting shows its pairs, keys and arrows aligned.
specNet HashTable := table -> (
	stock := base -> lookup(expression, class table) === lookup(expression, base)
		and lookup(net, class table) === lookup(net, base);
	if any({HashTable, MutableHashTable}, stock) then
		contentsOf(table, table -> stacked {{grid(apply(pairs table, pair -> {
			optionKey pair#0, specNet symbol =>, specNet pair#1
		}), "Aligned")}})
	else (lookup(specNet, Thing)) table
)

-- A class hierarchy is a tree of its subclasses, each level sorted as M2's own
-- net sorts it. A class name is a label coloured as a type, so a ring's name
-- never typesets the hierarchy.
specNet Descent := tree -> contentsOf(tree, tree -> new SpecNet from {
	Shape => "Tree",
	Branches => apply(sort(pairs tree, pair -> toString net pair#0), pair -> {
		specNet(toString net pair#0) ++ {Highlight => Type},
		specNet pair#1
	})
})
