#! /usr/bin/env ruby
# coding: utf-8

require 'helper'
require "stringio"
require "test/unit"

require "quizgame/problem.rb"

class TC_Problem < Test::Unit::TestCase
  def setup
    @p00 = Problem.new( "vortex", "vortices", "ラテン系語尾" )
    @p01 = Problem.new( "これはペンです。", "This is a pen.", "かんたん" )
    @p02 = Problem.new( "ふ", "むべ", "第22")
    @p03 = Problem.new( "4 underscore after abc", "abc____" )
  end

  def test_exhibit_question
    io = StringIO.new; @p00.exhibit_question( io ) ; io.rewind
    assert_equal( ["vortex\n"                ], io.readlines )

    io = StringIO.new; @p01.exhibit_question( io ) ; io.rewind
    assert_equal( ["これはペンです。\n"      ], io.readlines )

    io = StringIO.new; @p02.exhibit_question( io ) ; io.rewind
    assert_equal( ["ふ\n"                    ], io.readlines )

    io = StringIO.new; @p03.exhibit_question( io ) ; io.rewind
    assert_equal( ["4 underscore after abc\n"], io.readlines )
  end

  def test_show_supplement
    io = StringIO.new
    @p00.show_supplement( io )
    io.rewind
    assert_equal( "[supplement]\n", io.readline )
    assert_equal( "  ラテン系語尾\n", io.readline )
    assert_raise( EOFError ){ io.readline }
    io.close

    io = StringIO.new
    @p03.show_supplement( io )
    io.rewind
    assert_raise( EOFError ){ io.readline }
    io.close
  end


  def test_correct?
    assert_equal(true,  @p00.correct?("vortices"))
    assert_equal(false, @p00.correct?("vortice"))
    assert_equal(false, @p00.correct?("vorticese"))

    assert_equal(true,  @p01.correct?("This is a pen."))
    assert_equal(false, @p01.correct?("They are pens."))
    assert_equal(false, @p01.correct?("This is pen."))

    assert_equal(false, @p02.correct?("む"))
    assert_equal(true,  @p02.correct?("むべ"))
    assert_equal(false, @p02.correct?("むべし"))

    assert_equal(true,  @p00.correct?("VORTICES"))
  end

  def test_emphasize_wrong
    #correct
    assert_equal( "vortices", @p00.emphasize_wrong( "vortices" ) )
    #short
    assert_equal( "vort" + "\e[31;49m____\e[39;49m", @p00.emphasize_wrong( "vort" ) )
    #long
    assert_equal( "vortices" + "\e[31;49mes\e[39;49m", @p00.emphasize_wrong( "vorticeses" ) )
    #wrong
    assert_equal( "vor" + "\e[31;49mrices\e[39;49m", @p00.emphasize_wrong( "vorrices" ) )

    assert_equal( "abc" + "\e[31;49m____\e[39;49m", @p03.emphasize_wrong( "abc" ) )
    assert_equal( "abc____", @p03.emphasize_wrong( "abc____" ) )
  end
end

