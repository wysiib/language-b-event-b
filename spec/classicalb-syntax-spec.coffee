describe 'Classical B grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-b-eventb')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.classicalb')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.classicalb'

  describe "literals", ->
    it "tokenizes integer literals", ->
      {tokens} = grammar.tokenizeLine "1 = 5"
      expect(tokens[0]).toEqual value: '1', scopes: [ 'source.classicalb', 'constant.numeric.classicalb' ]
      expect(tokens[2]).toEqual value: '=', scopes: [ 'source.classicalb', 'keyword.operator.equality.classicalb' ]
      expect(tokens[4]).toEqual value: '5', scopes: [ 'source.classicalb', 'constant.numeric.classicalb' ]

  describe "assignment", ->
    it "tokenizes simple assignment", ->
      {tokens} = grammar.tokenizeLine "x := 5"
      expect(tokens[0]).toEqual value: 'x', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[2]).toEqual value: ':=', scopes: [ 'source.classicalb', 'keyword.operator.assignment.classicalb' ]
      expect(tokens[4]).toEqual value: '5', scopes: [ 'source.classicalb', 'constant.numeric.classicalb' ]


  describe "machines", ->
    it "detects the difference between END of MACHINE and END of PRE", ->
      {tokens} = grammar.tokenizeLine "MACHINE test PRE x=5 END END"
      expect(tokens[0]).toEqual value: 'MACHINE', scopes: [ 'source.classicalb', 'meta.machine.classicalb', 'keyword.other.machine.classicalb' ]
      expect(tokens[4]).toEqual value: 'PRE', scopes: [ 'source.classicalb', 'meta.machine.classicalb', 'keyword.control.classicalb' ]
      expect(tokens[10]).toEqual value: 'END', scopes: [ 'source.classicalb', 'meta.machine.classicalb', 'keyword.control.classicalb' ]
      expect(tokens[12]).toEqual value: 'END', scopes: [ 'source.classicalb', 'meta.machine.classicalb', 'keyword.other.machine.classicalb' ]

  describe "operators", ->
    it "detects or correctly", ->
      {tokens} = grammar.tokenizeLine "orb"
      expect(tokens[0]).toEqual value: 'orb', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

      {tokens} = grammar.tokenizeLine "aor"
      expect(tokens[0]).toEqual value: 'aor', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

      {tokens} = grammar.tokenizeLine "aorb"
      expect(tokens[0]).toEqual value: 'aorb', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

      {tokens} = grammar.tokenizeLine "a or b"
      expect(tokens[0]).toEqual value: 'a', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[2]).toEqual value: 'or', scopes: [ 'source.classicalb', 'keyword.operator.logical.classicalb' ]
      expect(tokens[4]).toEqual value: 'b', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

    it "tokenizes some operators correctly", ->
      {tokens} = grammar.tokenizeLine "nn := card(access |> {pp})"
      expect(tokens[0]).toEqual value: 'nn', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[2]).toEqual value: ':=', scopes: [ 'source.classicalb', 'keyword.operator.assignment.classicalb' ]
      expect(tokens[4]).toEqual value: 'card', scopes: [ 'source.classicalb', 'keyword.operator.set.classicalb' ]
      expect(tokens[6]).toEqual value: 'access', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[8]).toEqual value: '|>', scopes: [ 'source.classicalb', 'keyword.operator.relation.classicalb' ]
      expect(tokens[10]).toEqual value: 'pp', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

    it "tokenizes the maplet operator", ->
      {tokens} = grammar.tokenizeLine "uu |-> pp"
      expect(tokens[0]).toEqual value: 'uu', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[1]).toEqual value: ' ', scopes: [ 'source.classicalb' ]
      expect(tokens[2]).toEqual value: '|->', scopes: [ 'source.classicalb', 'keyword.operator.relation.classicalb' ]
      expect(tokens[4]).toEqual value: 'pp', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

  describe "comments", ->
    it "tokenizes an empty block comment", ->
      {tokens} = grammar.tokenizeLine '/**/'
      expect(tokens[0]).toEqual value: '/*', scopes: [ 'source.classicalb', 'comment.block.classicalb', 'punctuation.definition.comment.classicalb' ]
      expect(tokens[1]).toEqual value: '*/', scopes: [ 'source.classicalb', 'comment.block.classicalb', 'punctuation.definition.comment.classicalb' ]
    it "tokenizes a block comment", ->
      {tokens} = grammar.tokenizeLine '/* this is my comment */'
      expect(tokens[0]).toEqual value: '/*', scopes: [ 'source.classicalb', 'comment.block.classicalb', 'punctuation.definition.comment.classicalb' ]
      expect(tokens[1]).toEqual value: ' this is my comment ', scopes: [ 'source.classicalb', 'comment.block.classicalb' ]
      expect(tokens[2]).toEqual value: '*/', scopes: [ 'source.classicalb', 'comment.block.classicalb', 'punctuation.definition.comment.classicalb' ]

  describe "simple clause", ->
    it "tokenizes a simple machine clause including an operator", ->
      {tokens} = grammar.tokenizeLine 'ASSERTIONS access : USER <-> PRINTER'
      expect(tokens[0]).toEqual value: 'ASSERTIONS', scopes: [ 'source.classicalb', 'keyword.other.machineclause.classicalb' ]
      expect(tokens[2]).toEqual value: 'access', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[4]).toEqual value: ':', scopes: [ 'source.classicalb', 'keyword.operator.set.classicalb' ]
      expect(tokens[6]).toEqual value: 'USER', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[8]).toEqual value: '<->', scopes: [ 'source.classicalb', 'keyword.operator.relation.classicalb' ]
      expect(tokens[10]).toEqual value: 'PRINTER', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

  describe "simple implicaton", ->
    it "tokenizes a simple implication", ->
      {tokens} = grammar.tokenizeLine 'a => b'
      expect(tokens[0]).toEqual value: 'a', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[2]).toEqual value: '=>', scopes: [ 'source.classicalb', 'keyword.operator.logical.classicalb' ]
      expect(tokens[4]).toEqual value: 'b', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

  describe "Atelier-B Unicode", ->
    it "tokenizes unicode maplet", ->
      {tokens} = grammar.tokenizeLine "topleft ↦ top_middle"
      expect(tokens[0]).toEqual value: 'topleft', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[2]).toEqual value: '↦', scopes: [ 'source.classicalb', 'keyword.operator.relation.classicalb' ]
      expect(tokens[4]).toEqual value: 'top_middle', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

    it "tokenizes an involved predicate using unicode", ->
      {tokens} = grammar.tokenizeLine "∀(t1,t2).(t1∈TRACKS ∧ t2∈TRACKS ∧ t1≠t2 ⇒ ran(occ(t1)) ∩ ran(occ(t2)) = ∅ )"
      expect(tokens[0]).toEqual value: '∀', scopes: [ 'source.classicalb', 'keyword.operator.logical.classicalb' ]
      expect(tokens[2]).toEqual value: 't1', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[4]).toEqual value: 't2', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[6]).toEqual value: 't1', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[7]).toEqual value: '∈', scopes: [ 'source.classicalb', 'keyword.operator.set.classicalb' ]
      expect(tokens[10]).toEqual value: '∧', scopes: [ 'source.classicalb', 'keyword.operator.logical.classicalb' ]
      expect(tokens[19]).toEqual value: '≠', scopes: [ 'source.classicalb', 'keyword.operator.equality.classicalb' ]
