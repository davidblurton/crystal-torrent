require "spec"
require "../src/bemcoding"

describe "Parser" do
  it "decodes strings" do
    parser = Parser.new "4:spam"
    parser.decode().should eq("spam")
  end

  it "decodes longer strings" do
    parser = Parser.new "13:spam and eggs"
    parser.decode().should eq("spam and eggs")
  end

  it "decodes integers" do
    parser = Parser.new "i3e"
    parser.decode().should eq(3)
  end

  it "decodes longer integers" do
    parser = Parser.new "i345e"
    parser.decode().should eq(345)
  end

  it "decodes negative integers" do
    parser = Parser.new "i-3e"
    parser.decode().should eq(-3)
  end

  it "decodes lists of strings" do
    parser = Parser.new "l4:spam4:eggse"
    parser.decode().should eq(["spam", "eggs"])
  end

  it "decodes lists of integers" do
    parser = Parser.new "li1ei2ei3ee"
    parser.decode().should eq([1, 2, 3])
  end

  it "decodes empty lists" do
    parser = Parser.new "le"
    parser.decode().should eq([] of String)
  end

  it "decodes dictionaries" do
    parser = Parser.new "d3:cow3:moo4:spam4:eggse"
    parser.decode().should eq({"cow" => "moo", "spam" => "eggs"})
  end

  it "decodes dictionaries with lists" do
    parser = Parser.new "d4:spaml1:a1:bee"
    parser.decode().should eq({"spam" => ["a", "b"]})
  end

  # it "decodes empty dictionaries" do
  #   parser = Parser.new "de"
  #   parser.decode().should eq({})
  # end
end
