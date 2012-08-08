#! /usr/bin/env ruby
# coding: utf-8

require "rubygems"
gem "builtinextension"
require "string_color.rb"
require "string_mismatch.rb"

gem "weightedpicker"
require "weightedpicker.rb"

require "quizgame/problem.rb"
require "yaml"

include Math

# クイズゲームを管理・実行するクラス。
class QuizGame
  QUIT_STR = "q"
  #NEXT_STR = ""
  NUM_EMPTY_LINE = 8
  #MINIMUM_INTERVAL = 10 #同じ問題を再出題する最短の interval

  class QuizGame::NoQuizError < Exception; end

  # クイズデータを読み込む。
  def initialize(requirement, problems, picker)
    @requirement = requirement
    @problems    = problems
    @picker      = picker
  end

  # 条件を満たすまでクイズを実行。
  # norma は終了条件の数
  def run(norma)
    correct_count = 0
    problem_count = 0
    show_statement(norma)
    puts "Requirement: ", @requirement

    start_time = Time.new

    while (problem_count < norma )
      id = @picker.pick
      problem = @problems[id]

      puts "-"*60
      print "[Q.#{problem_count+1}, #{id}] "
      problem.exhibit_question

      input_str = user_input
      (puts "-- Interrupted --"; break) if (input_str == QUIT_STR)
      #(puts "-- Next --"; next) if (input_str == NEXT_STR)

      problem_count += 1
      if problem.correct?(input_str)
        correct_count += 1
        @picker.lighten(id)
      else
        @picker.weigh(id)
      end

      puts show_result(problem, input_str)
      puts problem.show_supplement
      #pp correct_count
      #pp problem_count
      #pp @norma
      printf( "[%d correct / %d problems / %d norma]\n",
        correct_count, problem_count, norma)
    end

    puts "="*60
    sleep(0.35) #Visual effect. A little stop before showing results.
    if (correct_count == norma)
      show_great
    end

    printf("result: [%d correct / %d problems]",
        correct_count, problem_count)

    begin
      printf("  %2d\%\n", (correct_count.to_f/ problem_count*100).to_i)
    rescue FloatDomainError
      puts "  No problem is answered."
    end

    print "Time: ", Time.now - start_time, "\n"
  end

  private

  #ゲーム開始前に情報を提示。
  def show_statement(norma, io = $stdout)
    io.puts "#{QUIT_STR}[Enter] for immediately quit."
    io.puts
    io.puts "This program has #{@problems.size} problems."
    io.print "Norma: " + norma.to_s.color(:green) + " "
    io.puts "problems."
  end

  def user_input(input = STDIN, output = $stdout)
    output.print "\n" * NUM_EMPTY_LINE
    output.print "input: "
    return input.gets.chomp!
  end

  #
  def show_result(problem, str, io = $stdout)
    if (problem.correct?(str) == false)
      io.puts "×: ".color(:red) + problem.emphasize_wrong(str)
    end
    io.puts "○: #{problem.answer}"
  end


  def show_great
    print "\n"
    great = Array.new
    puts "■■■■■□■■■■■□■■■■■□■■■■■□■■■■■□■□■".color(:red   )
    puts "■□□□□□■□□□■□■□□□□□■□□□■□□□■□□□■□■".color(:yellow)
    puts "■□■■■□■■■■■□■■■■■□■■■■■□□□■□□□■□■".color(:green )
    puts "■□□□■□■□□■□□■□□□□□■□□□■□□□■□□□□□□".color(:cyan  )
    puts "■■■■■□■□□□■□■■■■■□■□□□■□□□■□□□■□■".color(:blue  )
    puts
    puts "All answers are correct!"
    puts
  end

end
