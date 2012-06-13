#! /usr/bin/env ruby
# coding: utf-8

require "rubygems"
gem "builtinextension"
require "string_color.rb"
require "string_mismatch.rb"

#Class for one item of quizes.
#This class does not print to stdout.
#That should be done by class that deal with interface.
#
#quizId was deplicated. quizStr will work so.
#
#QuizGame ライブラリでは問題文の構造として以下のようなモデルを考えている。
# 1. 以下の英単語を日本語単語に訳せ。
#   (1) dog
#   (2) cat
#
# 2. 以下の日本語単語を英単語に訳せ。
#   (1) 牛
#   (2) 馬
#
# 1. や 2. に続く文は requirement、属する小問全てに対する要求。
# (1) や (2) に続くのは question、 実際に対処する要素。
# これらに対する解答は answer
# 正否に関わらない補足情報が supplement
#この用語を使う。
#
#requirement を Problem 内では保持しない。
#多くの場合、上位の構造で保持して同種の問題を繰り返すものだから。
class Problem
  attr_reader :question, :answer, :supplement

  def initialize( question, answer, supplement = nil )
    @question    = question
    @answer      = answer
    @supplement  = supplement
  end

  #問題文を表示。
  #Problem 側がこのメソッドを持つことについて。
  #問題が必ずしも文でないことがあるため。
  #たとえばヒアリングの問題なんかでは、
  #Problem クラスインスタンスがその再生方法などを持っているべきだ。
  def exhibit_question( io = STDOUT )
    io.puts @question
  end

  #problem の supplement があれば、それを出力。
  #なければ何もせず処理を返す。
  def show_supplement( io = STDOUT )
    return if ( @supplement == nil )

    io.puts "[supplement]"
    io.puts "  #{@supplement}"
  end

  #正誤判定。
  #正誤判定は Problem 内で行う。
  #Problem のサブクラスで正誤判定条件を変更できる。
  #MEMO: 今のところ ignorecase しているが、本来は厳密に一致せんとあかん。
  def correct?( data )
    return true if /^#{@answer}$/i =~ data
    return false
  end

  #@answer と str を比較して、
  #正しい部分はデフォルト色、間違った部分は強調色で表示する
  #文字列を生成。
  #正しい部分は、先頭から連続して一致する部分と定義。
  #後ろの一致とかは実装が難しい。
  #str が @answer より短ければ同じ長さになるように末尾に _ を補う。
  def emphasize_wrong( str )
    index = @answer.mismatch( str )

    #index が nil、すなわち @answer と str が完全に一致しているとき、そのまま返す。
    return str unless index

    #差があれば間違い以降を赤字にして返す。
    correct_part = str[0..( index - 1 )]
    wrong_part = str[index .. (-1) ]

    #str が短ければ同じ長さになるように末尾に _ を補う。
    wrong_part += "_" * ( @answer.size - str.size ) if ( @answer.size > str.size )

    return ( correct_part + wrong_part.color( :red ) )
  end

end
