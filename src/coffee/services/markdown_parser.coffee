class App.Services.MarkdownParser
  TAB_TO_SPACES = '  '

  @parse: (input)->
    new App.Services.MarkdownParser().parse(input)

  parse: (@input) ->
    @game = new App.Models.Game(
      parsedAt: Date.now()
    )
    @parser = null
    _.each @input.split("\n"), (line) =>
      @parseLine(line)
    @game

  parseLine: (line) ->
    lineDescriptor = @cleanup(line)
    line = lineDescriptor.line
    return if _.isEmpty(line)
    if line == "# runner"
      @parser = new App.Services.RunnerParser(@game.runner())
      return
    if @parser
      @parser.parseLine(lineDescriptor)

  cleanup: (line) ->
    {line: line.trim().toLowerCase(), indent: @countIndent(line)}

  countIndent: (line) ->
    matched = line.replace(/\t/g, TAB_TO_SPACES).match(/^\s+/)
    if matched then matched[0].length else 0

  @parseCounter: (line, acceptedValues) ->
    regex = new RegExp("^(\\d)+\\s(#{acceptedValues.join("|")})$")
    if (m = line.match(regex))
      {type: m[2], amount: parseInt(m[1])}


class App.Services.SectionParser
  constructor: (@object) ->
    @parser = null
    @indent = null

  parseLine: (lineDescriptor)->
    unless @indent?
      @indent = lineDescriptor.indent
    if lineDescriptor.indent == @indent
      console.log(this.constructor.name, "ParseRoot", lineDescriptor)
      @parseRoot(lineDescriptor.line)
    else if @parser
      console.log(this.constructor.name, " >> ", lineDescriptor)
      @parser.parseLine(lineDescriptor)

class App.Services.CardParser extends App.Services.SectionParser

  parseRoot: (line)->
    console.log("FINDER")
    card = App.Services.CardFinder.find(line)
    if card
      @object.add(title: card.title, code: card.code)
    

class App.Services.RunnerParser extends App.Services.SectionParser
  parsers:
    'grip': App.Services.GripParser
    'installed': App.Services.RunnerBoardParser
    'heap': App.Services.HeapParser

  parseRoot: (line)->
    counter = App.Services.MarkdownParser.parseCounter(line, ['credits', 'tags'])
    if counter
      @object.set(counter.type, counter.amount)
    switch line
      when 'grip'
        @parser = new App.Services.CardParser(@object.grip())
        return

