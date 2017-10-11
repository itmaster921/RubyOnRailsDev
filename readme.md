# Ruby on Rails
# Style Guide

This is Style Guide. It was inspired by [Airbnb's guide](https://github.com/airbnb/ruby)

## Table of Contents
  1. [Pull Requests](#pull-requests)
  1. [Commenting](#commenting)
    1. [File/class-level comments](#fileclass-level-comments)
    1. [Function comments](#function-comments)
    1. [Block and inline comments](#block-and-inline-comments)
    1. [Punctuation, spelling, and grammar](#punctuation-spelling-and-grammar)
    1. [TODO comments](#todo-comments)
    1. [Commented-out code](#commented-out-code)
  1. [Whitespace](#whitespace)
    1. [Indentation](#indentation)
    1. [Inline](#inline)
    1. [Newlines](#newlines)
  1. [Line Length](#line-length)
  1. [API Documentation](#api-documentation)



## Pull Requests

**What a Pull Request should include?**

A pull request at mywebsite should always include the following:
* Descriptive title of the fix or feature.
* Necessary information in the Pull Request description.
 * [ticket_link] to the related issue in the project management system.
 * Any additional information that may be of help to the reviewer.
* Code required by the feature
* Tests covering the feature on a necessary level *(a spacing issue PR etc. do not require tests)*
* Necessary commenting on the feature, see [Commenting](#commenting) for more information
* A Pull Request including changes to the API or new content to it should always include edits to [API documentation](https://github.com/Ampersports/amperbooking/blob/master/API.md)

### Commit template:
```
A short one sentence description of the change (#ticket_number).

If a longer description is needed, it will appear here. If not, this line won't appear.

* bullets of important changes.
* unrelated to the main commit message.
```
Merges ##{pull_request_number}

LGTM given by: @god, @otherReviewerName

The [ticket_link] provides detail on what ticket the commit is related to inside of our project management system (JIRA or Trello).

Squash merging ensures that every change is shown in full context of the delivered feature, so if you do git-blame on a line, you will see the full feature that introduced the change.


## Commenting

> Though a pain to write, comments are absolutely vital to keeping our code
> readable. The following rules describe what you should comment and where. But
> remember: while comments are very important, the best code is
> self-documenting. Giving sensible names to types and variables is much better
> than using obscure names that you must then explain through comments.

> When writing your comments, write for your audience: the next contributor who
> will need to understand your code. Be generous — the next one may be you!

Portions of this section borrow heavily from the AirBNB, Google C++ and Python style guides.

### File/class-level comments

Every class definition should have an accompanying comment that describes what
it is for and how it should be used.

A file that contains zero classes or more than one class should have a comment
at the top describing its contents.

```ruby
# Automatic conversion of one locale to another where it is possible, like
# American to British English.
module Translation
  # Class for converting between text between similar locales.
  # Right now only conversion between American English -> British, Canadian,
  # Australian, New Zealand variations is provided.
  class PrimAndProper
    def initialize
      @converters = { :en => { :"en-AU" => AmericanToAustralian.new,
                               :"en-CA" => AmericanToCanadian.new,
                               :"en-GB" => AmericanToBritish.new,
                               :"en-NZ" => AmericanToKiwi.new,
                             } }
    end

  ...

  # Applies transforms to American English that are common to
  # variants of all other English colonies.
  class AmericanToColonial
    ...
  end

  # Converts American to British English.
  # In addition to general Colonial English variations, changes "apartment"
  # to "flat".
  class AmericanToBritish < AmericanToColonial
    ...
  end
```

All files, including data and config files, should have file-level comments.

```ruby
# List of American-to-British spelling variants.
#
# This list is made with
# lib/tasks/list_american_to_british_spelling_variants.rake.
#
# It contains words with general spelling variation patterns:
#   [trave]led/lled, [real]ize/ise, [flav]or/our, [cent]er/re, plus
# and these extras:
#   learned/learnt, practices/practises, airplane/aeroplane, ...

sectarianizes: sectarianises
neutralization: neutralisation
...
```

### Function comments

Every function declaration should have comments immediately preceding it that
describe what the function does and how to use it. These comments should be
descriptive ("Opens the file") rather than imperative ("Open the file"); the
comment describes the function, it does not tell the function what to do. In
general, these comments do not describe how the function performs its task.
Instead, that should be left to comments interspersed in the function's code.

Every function should mention what the inputs and outputs are, unless it meets
all of the following criteria:

* not externally visible
* very short
* obvious

You may use whatever format you wish. In Ruby, two popular function
documentation schemes are [TomDoc](http://tomdoc.org/) and
[YARD](http://rubydoc.info/docs/yard/file/docs/GettingStarted.md). You can also
just write things out concisely:

```ruby
# Returns the fallback locales for the_locale.
# If opts[:exclude_default] is set, the default locale, which is otherwise
# always the last one in the returned list, will be excluded.
#
# For example:
#   fallbacks_for(:"pt-BR")
#     => [:"pt-BR", :pt, :en]
#   fallbacks_for(:"pt-BR", :exclude_default => true)
#     => [:"pt-BR", :pt]
def fallbacks_for(the_locale, opts = {})
  ...
end
```

### Block and inline comments

The final place to have comments is in tricky parts of the code. If you're
going to have to explain it at the next code review, you should comment it now.
Complicated operations get a few lines of comments before the operations
commence. Non-obvious ones get comments at the end of the line.

```ruby
def fallbacks_for(the_locale, opts = {})
  # dup() to produce an array that we can mutate.
  ret = @fallbacks[the_locale].dup

  # We make two assumptions here:
  # 1) There is only one default locale (that is, it has no less-specific
  #    children).
  # 2) The default locale is just a language. (Like :en, and not :"en-US".)
  if opts[:exclude_default] &&
      ret.last == default_locale &&
      ret.last != language_from_locale(the_locale)
    ret.pop
  end

  ret
end
```

On the other hand, never describe the code. Assume the person reading the code
knows the language (though not what you're trying to do) better than you do.

<a name="no-block-comments"></a>Related: do not use block comments. They cannot
  be preceded by whitespace and are not as easy to spot as regular comments.
  <sup>[[link](#no-block-comments)]</sup>

  ```ruby
  # bad
  =begin
  comment line
  another comment line
  =end

  # good
  # comment line
  # another comment line
  ```

### Punctuation, spelling and grammar

Pay attention to punctuation, spelling, and grammar; it is easier to read
well-written comments than badly written ones.

Comments should be as readable as narrative text, with proper capitalization
and punctuation. In many cases, complete sentences are more readable than
sentence fragments. Shorter comments, such as comments at the end of a line of
code, can sometimes be less formal, but you should be consistent with your
style.

Although it can be frustrating to have a code reviewer point out that you are
using a comma when you should be using a semicolon, it is very important that
source code maintain a high level of clarity and readability. Proper
punctuation, spelling, and grammar help with that goal.

### TODO comments

Use TODO comments for code that is temporary, a short-term solution, or
good-enough but not perfect.

TODOs should include the string TODO in all caps, followed by the full name
of the person who can best provide context about the problem referenced by the
TODO, in parentheses. A colon is optional. A comment explaining what there is
to do is required. The main purpose is to have a consistent TODO format that
can be searched to find the person who can provide more details upon request.
A TODO is not a commitment that the person referenced will fix the problem.
Thus when you create a TODO, it is almost always your name that is given.

```ruby
  # bad
  # TODO(RS): Use proper namespacing for this constant.

  # bad
  # TODO(drumm3rz4lyfe): Use proper namespacing for this constant.

  # good
  # TODO(Ringo Starr): Use proper namespacing for this constant.
```

### Commented-out code

* <a name="commented-code"></a>Never leave commented-out code in our codebase.
    <sup>[[link](#commented-code)]</sup>

There are cases in our old codebase where this exists, and is being cleaned up.

## Whitespace

### Indentation

* <a name="default-indentation"></a>Use soft-tabs with a two
    space-indent.<sup>[[link](#default-indentation)]</sup>

* <a name="indent-when-as-case"></a>Indent `when` as deep as `case`.
    <sup>[[link](#indent-when-as-case)]</sup>

    ```ruby
    case
    when song.name == 'Misty'
      puts 'Not again!'
    when song.duration > 120
      puts 'Too long!'
    when Time.now.hour > 21
      puts "It's too late"
    else
      song.play
    end

    kind = case year
           when 1850..1889 then 'Blues'
           when 1890..1909 then 'Ragtime'
           when 1910..1929 then 'New Orleans Jazz'
           when 1930..1939 then 'Swing'
           when 1940..1950 then 'Bebop'
           else 'Jazz'
           end
    ```

* <a name="align-function-params"></a>Align function parameters either all on
    the same line or one per line.<sup>[[link](#align-function-params)]</sup>

    ```ruby
    # bad
    def self.create_translation(phrase_id, phrase_key, target_locale,
                                value, user_id, do_xss_check, allow_verification)
      ...
    end

    # good
    def self.create_translation(phrase_id,
                                phrase_key,
                                target_locale,
                                value,
                                user_id,
                                do_xss_check,
                                allow_verification)
      ...
    end

    # good
    def self.create_translation(
      phrase_id,
      phrase_key,
      target_locale,
      value,
      user_id,
      do_xss_check,
      allow_verification
    )
      ...
    end
    ```

* <a name="indent-multi-line-bool"></a>Indent succeeding lines in multi-line
    boolean expressions.<sup>[[link](#indent-multi-line-bool)]</sup>

    ```ruby
    # bad
    def is_eligible?(user)
      Trebuchet.current.launch?(ProgramEligibilityHelper::PROGRAM_TREBUCHET_FLAG) &&
      is_in_program?(user) &&
      program_not_expired
    end

    # good
    def is_eligible?(user)
      Trebuchet.current.launch?(ProgramEligibilityHelper::PROGRAM_TREBUCHET_FLAG) &&
        is_in_program?(user) &&
        program_not_expired
    end
    ```

### Inline

* <a name="trailing-whitespace"></a>Never leave trailing whitespace.
    <sup>[[link](#trailing-whitespace)]</sup>

* <a name="space-before-comments"></a>When making inline comments, include a
    space between the end of the code and the start of your comment.
    <sup>[[link](#space-before-comments)]</sup>

    ```ruby
    # bad
    result = func(a, b)# we might want to change b to c

    # good
    result = func(a, b) # we might want to change b to c
    ```

* <a name="spaces-operators"></a>Use spaces around operators; after commas,
    colons, and semicolons; and around `{` and before `}`.
    <sup>[[link](#spaces-operators)]</sup>

    ```ruby
    sum = 1 + 2
    a, b = 1, 2
    1 > 2 ? true : false; puts 'Hi'
    [1, 2, 3].each { |e| puts e }
    ```

* <a name="no-space-before-commas"></a>Never include a space before a comma.
    <sup>[[link](#no-space-before-commas)]</sup>

    ```ruby
    result = func(a, b)
    ```

* <a name="spaces-block-params"></a>Do not include space inside block
    parameter pipes. Include one space between parameters in a block.
    Include one space outside block parameter pipes.
    <sup>[[link](#spaces-block-params")]</sup>

    ```ruby
    # bad
    {}.each { | x,  y |puts x }

    # good
    {}.each { |x, y| puts x }
    ```

* <a name="no-space-after-!"></a>Do not leave space between `!` and its
    argument.<sup>[[link](#no-space-after-!)]</sup>

    ```ruby
    !something
    ```

* <a name="no-spaces-braces"></a>No spaces after `(`, `[` or before `]`, `)`.
    <sup>[[link](#no-spaces-braces)]</sup>

    ```ruby
    some(arg).other
    [1, 2, 3].length
    ```

* <a name="no-spaces-string-interpolation"></a>Omit whitespace when doing
    string interpolation.<sup>[[link](#no-spaces-string-interpolation)]</sup>

    ```ruby
    # bad
    var = "This #{ foobar } is interpolated."

    # good
    var = "This #{foobar} is interpolated."
    ```

* <a name="no-spaces-range-literals"></a>Don't use extra whitespace in range
    literals.<sup>[[link](#no-spaces-range-literals)]</sup>

    ```ruby
    # bad
    (0 ... coll).each do |item|

    # good
    (0...coll).each do |item|
    ```

### Newlines

* <a name="multiline-if-newline"></a>Add a new line after `if` conditions span
    multiple lines to help differentiate between the conditions and the body.
    <sup>[[link](#multiline-if-newline)]</sup>

    ```ruby
    if @reservation_alteration.checkin == @reservation.start_date &&
       @reservation_alteration.checkout == (@reservation.start_date + @reservation.nights)

      redirect_to_alteration @reservation_alteration
    end
    ```

* <a name="newline-after-conditional"></a>Add a new line after conditionals,
    blocks, case statements, etc.<sup>[[link](#newline-after-conditional)]</sup>

    ```ruby
    if robot.is_awesome?
      send_robot_present
    end

    robot.add_trait(:human_like_intelligence)
    ```

* <a name="newline-different-indent"></a>Don’t include newlines between areas
    of different indentation (such as around class or module bodies).
    <sup>[[link](#newline-different-indent)]</sup>

    ```ruby
    # bad
    class Foo

      def bar
        # body omitted
      end

    end

    # good
    class Foo
      def bar
        # body omitted
      end
    end
    ```

* <a name="newline-between-methods"></a>Include one, but no more than one, new
    line between methods.<sup>[[link](#newline-between-methods)]</sup>

    ```ruby
    def a
    end

    def b
    end
    ```

* <a name="method-def-empty-lines"></a>Use a single empty line to break between
    statements to break up methods into logical paragraphs internally.
    <sup>[[link](#method-def-empty-lines)]</sup>

    ```ruby
    def transformorize_car
      car = manufacture(options)
      t = transformer(robot, disguise)

      car.after_market_mod!
      t.transform(car)
      car.assign_cool_name!

      fleet.add(car)
      car
    end
    ```

* <a name="trailing-newline"></a>End each file with a newline. Don't include
    multiple newlines at the end of a file.
    <sup>[[link](#trailing-newline)]</sup>

## Line Length

Keeping code visually grouped together (as a 100-character line limit enforces)
makes it easier to understand. For example, you don't have to scroll back and
forth on one line to see what's going on -- you can view it all together.

Here are examples from our codebase showing several techniques for
breaking complex statements into multiple lines that are all < 100
characters. Notice techniques like:

* liberal use of linebreaks inside unclosed `(` `{` `[`
* chaining methods, ending unfinished chains with a `.`
* composing long strings by putting strings next to each other, separated
  by a backslash-then-newline.
* breaking long logical statements with linebreaks after operators like
  `&&` and `||`

```ruby
scope = Translation::Phrase.includes(:phrase_translations).
  joins(:phrase_screenshots).
  where(:phrase_screenshots => {
    :controller => controller_name,
    :action => JAROMIR_JAGR_SALUTE,
  })
```

```ruby
translation = FactoryGirl.create(
  :phrase_translation,
  :locale => :is,
  :phrase => phrase,
  :key => 'phone_number_not_revealed_time_zone',
  :value => 'Símanúmerið þitt verður ekki birt. Það er aðeins hægt að hringja á '\
            'milli 9:00 og 21:00 %{time_zone}.'
)
```

```ruby
if @reservation_alteration.checkin == @reservation.start_date &&
   @reservation_alteration.checkout == (@reservation.start_date + @reservation.nights)

  redirect_to_alteration @reservation_alteration
end
```

```erb
<% if @presenter.guest_visa_russia? %>
  <%= icon_tile_for(I18n.t("email.reservation_confirmed_guest.visa.details_header",
                           :default => "Visa for foreign Travelers"),
                    :beveled_big_icon => "stamp") do %>
    <%= I18n.t("email.reservation_confirmed_guest.visa.russia.details_copy",
               :default => "Foreign guests travelling to Russia may need to obtain a visa...") %>
  <% end %>
<% end %>
```

These code snippets are very much more readable than the alternative:

```ruby
scope = Translation::Phrase.includes(:phrase_translations).joins(:phrase_screenshots).where(:phrase_screenshots => { :controller => controller_name, :action => JAROMIR_JAGR_SALUTE })

translation = FactoryGirl.create(:phrase_translation, :locale => :is, :phrase => phrase, :key => 'phone_number_not_revealed_time_zone', :value => 'Símanúmerið þitt verður ekki birt. Það er aðeins hægt að hringja á milli 9:00 og 21:00 %{time_zone}.')

if @reservation_alteration.checkin == @reservation.start_date && @reservation_alteration.checkout == (@reservation.start_date + @reservation.nights)
  redirect_to_alteration @reservation_alteration
end
```

```erb
<% if @presenter.guest_visa_russia? %>
  <%= icon_tile_for(I18n.t("email.reservation_confirmed_guest.visa.details_header", :default => "Visa for foreign Travelers"), :beveled_big_icon => "stamp") do %>
    <%= I18n.t("email.reservation_confirmed_guest.visa.russia.details_copy", :default => "Foreign guests travelling to Russia may need to obtain a visa prior to...") %>
  <% end %>
<% end %>
```

# API Documentation

Our API Documentation is located [here](https://github.com/Ampersports/amperbooking/blob/master/API.md).
