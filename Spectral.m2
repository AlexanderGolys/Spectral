-- m2-ls: disable E19
-- -*- coding: utf-8 -*-
newPackage(
	"Spectral",
	Version => "0.1",
	Date => "November 14, 2026",
	Headline => "drawing values as structured, typed trees",
	PackageImports => {"Complexes", "Varieties", "Text"},
	Authors => {{
		Name => "Alexander Golys",
		Email => "alexandergolys@gmail.com",
		HomePage => "https://github.com/AlexanderGolys"
	}},
	HomePage => "https://github.com/AlexanderGolys/Spectral",
	Keywords => {"Interfaces"},
	AuxiliaryFiles => true,
	DebuggingMode => false
)

export {
	"SpecNet",
	"specNet",
	"specType",
	"specType'",
	"speek",
	"speek'",
	"UnderExpression",
	"AlignedExpression",
	"typeDepth",
	"valueDepth",
	"typeset",
	"typesetOperands",
	"typewriter",
	"specNet'"
}

-- What a value is drawn as; see Spectral/SpecNet.m2.
SpecNet = new Type of HashTable

specNet = method(Dispatch => Thing, TypicalValue => SpecNet)
specType = method(Dispatch => Thing, TypicalValue => SpecNet)
specType' = method(TypicalValue => SpecNet)
specNet' = method(TypicalValue => SpecNet)
speek = method(Dispatch => Thing)
speek' = method()

opaque = method(Dispatch => Thing, TypicalValue => SpecNet)
spelling = method(Dispatch => Thing, TypicalValue => String)
sourceTarget = method(Dispatch => Thing)
documentationTags = method(Dispatch => Thing)
attributeText = method()
foldedPath = method()
valueClass = method()
configuredDepth = method()
placeholder = method(Dispatch => Thing)
parameters = method(Dispatch => Thing, TypicalValue => List)
spelledShape = method()
optionKey = method(Dispatch => Thing, TypicalValue => SpecNet)
nearestSetting = method(TypicalValue => Boolean)
typesetMarked = method(TypicalValue => SpecNet)
contentsOf = method(TypicalValue => SpecNet)
unfolding = method(TypicalValue => SpecNet)

-- How a value is drawn, class by class: each class's settings and methods stand
-- together in one block, in the file of its subject.
load "./Spectral/SpecNet.m2"
load "./Spectral/expressions.m2"
load "./Spectral/containers.m2"
load "./Spectral/language.m2"
load "./Spectral/algebra.m2"
load "./Spectral/complexes.m2"
load "./Spectral/varieties.m2"
load "./Spectral/hypertext.m2"

-- Drawing fields are keys, never values: their symbols stay unset.
scan(values currentPackage#"private dictionary", key ->
		if isMutable key and value key === key then
		protect key)

beginDocumentation()
load "./Spectral/documentation.m2"
end--
