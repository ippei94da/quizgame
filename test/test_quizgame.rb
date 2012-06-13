#! /usr/bin/env ruby
# coding: utf-8

require 'helper'
require "test/unit"
require "stringio"
require "fileutils"
require "quizgame/quizgame.rb"

class QuizGame
  attr_accessor :problem_selector, :requirement, :yaml_mtime, :norma
  public :user_input, :show_result, :show_statement
end

class TC_QuizGame < Test::Unit::TestCase
  QUIZ_FILE = "test/tmp.yaml"

  def setup
    FileUtils.rm QUIZ_FILE if FileTest.exist? QUIZ_FILE

    requirement =  "Answer English spell."
    problems = {
      "p1" => Problem.new( "1", "one", "いち" ),
      "p2" => Problem.new( "2", "two", "に" )
    }
    wp = WeightedPicker.new(QUIZ_FILE, ["p1", "p2"])
    @qg00 = QuizGame.new(requirement, problems, wp)
  end

  def teardown
    FileUtils.rm QUIZ_FILE if FileTest.exist? QUIZ_FILE
  end

  def test_initialize
    #assert FileTest.exist?(@weight_file)
  end

  def test_run
    #run には WeightedPicker 経由の乱数要素が含まれるので、
    #妥当なテストが書けない。
    #1問だけにするとか、両方同じ答えにするとか手はあるが。
  end

  def test_show_statement
    io = StringIO.new
    @qg00.show_statement( 10, io )
    io.rewind
    assert_equal( "q[Enter] for immediately quit.\n", io.readline )
    assert_equal( "\n", io.readline )
    assert_equal( "This program has 2 problems.\n", io.readline )
    assert_equal( "Norma: \e[32;49m10\e[39;49m problems.\n", io.readline )
    assert_raise( EOFError ){ io.readline }
    io.close
  end

  def test_user_input
    input = StringIO.new
    output = StringIO.new
    input.puts "test_user_input"
    input.rewind
    assert_equal( "test_user_input", @qg00.user_input( input, output ) )
  end

  def test_show_result
    io = StringIO.new
    @qg00.show_result( Problem.new( "1", "one"  , "supplement1" ), "one", io )
    io.rewind
    assert_equal( "○: one\n", io.readline )
    assert_raise( EOFError ){ io.readline }
    io.close

    io = StringIO.new
    @qg00.show_result( Problem.new( "1", "one"  , "supplement1" ), "oo", io )
    io.rewind
    assert_equal( "\e[31;49m×: \e[39;49mo\e[31;49mo_\e[39;49m\n", io.readline )
    assert_equal( "○: one\n", io.readline )
    assert_raise( EOFError ){ io.readline }
    io.close
  end

end

