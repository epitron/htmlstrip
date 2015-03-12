require 'epitools'
require 'ox'

class Ox::Element

  GOOD_TAGS = Set.new %w[b i p span div] # Whitelisted tags...
  def good?
    GOOD_TAGS.include? name
  end

  NON_TEXT_TAGS = Set.new %w[script style]  
  def non_text?
    NON_TEXT_TAGS.include? name
  end

  SELF_CLOSING_TAGS = Set.new %w[br hr]
  def self_closing?
    SELF_CLOSING_TAGS.include? name
  end

end


class Parser < Ox::Sax

  ###################################################
  # Init
  ###################################################

  attr_accessor :root, :stack

  def initialize
    @root = Ox::Document.new(:version => '1.0')
    @stack = [@root]
  end

  ###################################################
  # Element Handlers
  ###################################################

  def start_element(name)
    tag = Ox::Element.new(name)

    stack.last << tag # unless tag.self_closing?
    stack << tag
  end

  def end_element(name)
    stack.pop
  end

  def attr(name, value)
    stack.last[name] = value
  end

  def text(value)
    stack.last << value
  end


  ###################################################
  # Make it go!
  ###################################################

  def parse!(file)
    if file.is_a? String
      if file[/\.gz/]
        require 'epitools/zopen'
        file = zopen(file)
      else
        file = open(file)
      end
    end

    Ox.sax_parse(self, file)
    self
  end

  def indent
    "  " * (stack.size-1)
  end

  def print(node=nil, depth=0)
    if node
      dent = "  "*depth

      case node
      when String
        puts "#{dent}#{node.inspect}" unless node.empty?
      when Ox::Element
        tag = [node.name, *node.attributes.map{|k,v| "#{k}=#{v.inspect}"}].join(" ")
        puts "#{dent}<#{tag}>"
        node.nodes.each { |n| print(n, depth+1) }
        puts "#{dent}</#{node.name}>"
      else
        raise "WTF"
      end
    else
      root.nodes.each { |n| print(n) }
    end
  end

end



class Stripper < Parser

  def initialize
    super
    @good = @root
  end

  def start_element(name)
    tag = Ox::Element.new(name)

    stack << tag
    puts "#{indent}/~~ #{name}"

    if tag.good?
      @good << tag
      @good = tag
    end
  end

  def end_element(name)
    puts "#{indent}\\__ #{name}"
    stack.pop
  end

  def attr(name, value)
    puts "#{indent}  #{name} => #{value.inspect}"
    stack.last[name] = value
  end

  def text(value)
    puts "#{indent}text #{value}"
    @good << value unless stack.last.non_text?
  end

end


if $0 == __FILE__
  ARGV.each do |arg|
    puts "Parsing #{arg}..."
    parser = time { Parser.new.parse!(arg) }
    # parser.print
  end
end
