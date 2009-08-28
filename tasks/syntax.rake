require "#{File.dirname(__FILE__)}/../tools/syntax_suggester"

INTERACTIVE_SPEIL = "\n"+
  "When prompted for a Ruby expression, you may enter the syntax of a\n"         +
  "resource() or resources() method call. The expression is expected to have\n"  +
  "no receiver. For example, imagine you'd like replacement syntax suggested\n"  +
  "for code like this:\n"                                                        +
  "  map.resources :blogs do |blog|\n"                                           +
  "    blog.resources :articles, :only => [:show,:index]\n"                      +
  "You would enter...\n"                                                         +
  "  resources :blogs       or resources(:blogs)\n"                              +
  "...when prompted for the original Ruby code. And then enter...\n"             +
  "  resources :articles, :only=>[:show,:index]\n"                               +
  "...at the next prompt. Notice you leave off everything to the left,\n"        +
  "including the dot, and everything to the right of the actual method call.\n"  +
  "Each expression must begin with 'resource' or 'resources', and may not\n"     +
  "contain variable names, i.e. all values must be literals. After each\n"       +
  "expression, you'll see suggestions for a back-compatible outlaw_resource()\n" +
  "expression.\n"                                                                +
  "\n"                                                                           +
  "To exit from this interactive loop, just enter a blank expression.\n"

namespace :outlaw do
  namespace :syntax do

    desc 'See plugins/outlaw/doc/syntax_tools. Gives suggestion for each input line of code.'
    task :interactive, :needs=>:environment do
      puts INTERACTIVE_SPEIL
      loop do
        puts "\nRuby expression to translate (blank causes quit):"
        orig_syntax = $stdin.gets.chomp.strip
        exit if orig_syntax==''
        (puts "Expression must begin with resource or resources." ; next) unless orig_syntax =~ /^resources?(\(|\s)/
        ( new_syntax = OutlawResourcesSyntaxSuggester.new.proposed_outlaw_replacement_for_a_single_resources_call(orig_syntax)
          ) rescue (new_syntax = '[error]' ; puts "Unable to translate the expression.\n#{$!}")
        puts new_syntax[0..14]=='outlaw_resource' ? new_syntax : "\n\n#{INTERACTIVE_SPEIL}"
      end ; end

    desc 'See plugins/outlaw/doc/syntax_tools. Scans routes.rb and suggests changes.'
    task :routes_rb, :needs=>:environment do
      @orig_fpath = 'config/routes.rb'
      raise "File not found: #{@orig_fpath}" unless File.exist?(@orig_fpath)
      new_syntax = OutlawResourcesSyntaxSuggester.new.proposed_outlaw_replacement_for_an_entire_script(IO.read(@orig_fpath))
      puts new_syntax
      end

    end
  end
