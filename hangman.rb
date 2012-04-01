# hangman
# a Ruby hangman game
# Built using the FXRuby GUI Library

# supporting libraries
require 'yaml'
require 'rubygems'
require 'fox16'

include Fox

# ====================================================================
# some constants that affect program operation

# show/hide the splash screen
SHOW_SPLASH = true

# test mode: enable test mode to run an automated test of the game
# logic without the interactive user interface
TEST_MODE = false

# number of guesses the player can make before they lose
MAX_GUESSES = 6


# ====================================================================
# some global variables

# the word list.  Read the list of words from the text file words.txt,
# split the list into an array, and store the result in the variable
# $dictionary
$dictionary = File.read('words.txt').split()


# ====================================================================
# the hangman game "engine"

# The game logic for the hangman game.
#
# Encodes the rules of the game and keeps track of the game state:
# what word the player is trying to guess, what guesses they have made,
# whether they have won or lost, etc.
#
class Hangman
	# Set up the initial state of a hangman game.  A new game can be
	# given an optional starting word to be used as the word to guess;
	# if one is not supplied, the game starts with a random word from 
	# the dictionary.
	def initialize(word=nil)
		# if there is a word, use it
		if word != nil
			@word = word
		else
			# otherwise use a random word from the dictionary
			@word = nil # FIX FIX FIX FIX FIX FIX 
		end
		
		# the player's guesses
		@bad_guesses = []
		@good_guesses = []
	end
	
	# Guess a letter.  Return true if the guessed letter is in the
	# word, false otherwise.
	#
	# updates the appropriate guess list (either @good_ or @bad_)
	# with the newly guessed letter
	#
	# if the player has already won or lost, this method returns nil
	# and does not change the state of the game.
	#
	def guess(letter)
		
		if(@word.include?(letter))
		  @good_guesses.add(letter)
	  end
	
	end
	
	# returns the word the player is trying to guess
	def word()
		return @word
	end
	
	# the total number of guesses the player has made
	def total_guess_count()
		# TODO: fill in method body
		return -1
	end
	
	# the number of bad guesses ("misses") the player has made
	def bad_guess_count()
		# TODO: fill in method body
		return -1
	end
	
	# return the list of misses, i.e. bad guesses, the player has made
	def misses()
		return @bad_guesses
	end
	
	# return true if the player has lost the game
	def lost?()
		lose_game = false
		
		if (bad_guess_count() == MAX_GUESSES)
			lose_game = true
		end
		
		return lose_game
	end
	
	# return true if the player has won the game
	def won?()
		win_game = false
		
		if()
		  win_game = true
	  end
		
		return win_game
	end
	
	# Return the word with any letters the player has not guessed hidden.
	#
	# This method returns a copy of the game word that hides any letters
	# the player has not guessed yet with an '_'.
	#
	# For example, suppose the game word is 'dog' and the player has 
	# guessed the letters a, e, i, and o.  This method would return the 
	# string
	#
	#			_o_
	#
	def guessed_word()
		result = ''

		# TODO: fill in method body
		
		return result
	end
	
	# Return the hidden letter version of the word, formatted with extra
	# spaces for easier reading.
	def to_s()
		return guessed_word().split('').join(' ')
	end
	
	# Return a one-line summary of the game status.
	def status()
		return to_s() + ", #{total_guess_count()} guesses (#{bad_guess_count()} bad), won? #{won?}, lost? #{lost?}"
	end
end



# ====================================================================
# supporting variables, methods, and classes
# ====================================================================
# automated game logic test

def test_hangman_logic()
	hangman = Hangman.new('programming')
	
	puts hangman
	
	['a', 'b', 'i', 'e', 'o'].each() do |letter|
		hangman.guess(letter)
	end
	
	puts hangman.status()

	# test win
	'programming'.split('').each() do |letter|
		hangman.guess(letter)
	end
	
	puts hangman.status()
	
	# test loss
	puts
	hangman = Hangman.new('ruby')
	
	puts hangman
	
	['a', 'u', 'i', 'e', 'o'].each() do |letter|
		hangman.guess(letter)
	end
	
	puts hangman.status()
	
	hangman.guess('s')
	hangman.guess('t')
	
	puts hangman.status()
end


# font cache for changing label and text widget fonts
FONT = {}

# the game UI
$game = nil

# The main application window
#
# Contains the main game UI.  Also
# contains some supporting and convenience methods for interacting
# with the game logic.  This class relies on many of the student 
# methods defined above for display and gameplay.
class HangmanGUI < FXMainWindow
	
	# initialize the main game GUI and the instance variables for the game
	def initialize(app)
		@hangman = Hangman.new()

		# the hangman image files
		image_filenames = Dir['./icons/hangman/*'].sort()
		@image_icons = image_filenames.map{|name| load_icon(name, app)}

		# Invoke base class initialize method first
		super(app, "CS 1300 Ruby Hangman", nil, nil, DECOR_ALL, 0, 0, 800, 600)
		setIcon(load_icon('icons/ShemmatContained.png', app))
		setMiniIcon(load_icon('icons/ShemmatContained.ico', app, FXICOIcon))
		
		# the container for the game's widgets
		FXVerticalFrame.new(self,
		  FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X|LAYOUT_FILL_Y) do |frame|
		
			# @hangman_label shows the hangman graphical display and the
			# masked version of the word to guess
			@icon_index = 0
			icon = @image_icons[@icon_index]
			@hangman_label = FXLabel.new(frame, "\n#{@hangman.to_s()}\n", icon, 
						:opts => TEXT_BELOW_ICON | JUSTIFY_CENTER_X | LAYOUT_CENTER_X | LAYOUT_FILL_Y)
			@hangman_label.font = FONT['Courier 24 bold']
			
			# the label showing the player's incorrect guesses
			@miss_label = FXLabel.new(frame, 'misses: ', nil, :opts => JUSTIFY_LEFT)
			@miss_label.font = FONT['Helvetica 18']
			
			# frame for user answer label and text box
			FXHorizontalFrame.new(frame, LAYOUT_FILL_X) do |guessFrame|
				FXLabel.new(guessFrame, 'Enter the letter to guess: ')
				
				# text box for user answers
				@answers = FXTextField.new(guessFrame, 50, nil, 0, TEXTFIELD_ENTER_ONLY)
				@answers.layoutHints = LAYOUT_CENTER_X
				@answers.font = FONT['Courier 14']
				@answers.setFocus()
			end
		end
	
		# event handler for user answer text box
		@answers.connect(SEL_COMMAND) do
			# if the guess was wrong, update the icon
			if not @hangman.guess(@answers.text.to_s()[0].chr())
				@icon_index += 1
				@image_icons[@icon_index].create()
				@hangman_label.icon = @image_icons[@icon_index]
			end
			
			# update the labels and prepare for the next turn
			@hangman_label.text = "\n#{@hangman.to_s()}\n"
			@miss_label.text = 'misses: ' + @hangman.misses().join(', ')
			@answers.selectAll()
			
			# check to see if the game is over
			play_again = nil
			if @hangman.lost?
				play_again = game_over('You lost; the correct answer was' +
									   "\n\n        #{@hangman.word}\n")
			elsif @hangman.won?
				play_again = game_over('Congratulations!  You win!')
			end
			
			if play_again == 0
				exit
			elsif play_again == 1
				# reset the game state and start a new game
				@hangman = Hangman.new()
				@icon_index = 0
				@image_icons[@icon_index].create()
				@hangman_label.icon = @image_icons[@icon_index]
				@miss_label.text = 'misses: '
				@hangman_label.text = "\n#{@hangman.to_s()}\n"
			end
		end
	end
  
	# Start
	def create
		super
		show(PLACEMENT_SCREEN)
	end
	
	# Show the game over dialog, which shows the final outcome of the
	# game and allows the player to quit or play again.
	def game_over(message)
		dialog = FXDialogBox.new(self, nil, DECOR_TITLE|DECOR_BORDER,
							:padLeft => 0, :padRight => 0, :padTop => 0, :padBottom => 0)

		# frame to hold the splash screen components
		frame = FXVerticalFrame.new(dialog, LAYOUT_FILL_X)
		
		# the main label that holds the splash image and application title
		label = FXLabel.new(frame, message, nil, 
							:opts => TEXT_BELOW_ICON | JUSTIFY_LEFT)
		label.font = FONT['Courier 24 bold']
		
		label.text += "\nDo you want to play again?\n"
		
		  # Bottom buttons
		buttons = FXHorizontalFrame.new(dialog,
		  LAYOUT_SIDE_BOTTOM|FRAME_NONE|LAYOUT_FILL_X|PACK_UNIFORM_WIDTH,
		  :padLeft => 40, :padRight => 40, :padTop => 20, :padBottom => 20)
	  
		# Cancel
		FXButton.new(buttons, "&Quit", nil, dialog, FXDialogBox::ID_CANCEL,
		  FRAME_RAISED|FRAME_THICK|LAYOUT_RIGHT|LAYOUT_CENTER_Y)
		
		# Accept
		accept = FXButton.new(buttons, "&Play Again", nil, dialog, FXDialogBox::ID_ACCEPT,
		  FRAME_RAISED|FRAME_THICK|LAYOUT_RIGHT|LAYOUT_CENTER_Y)
		
		accept.setDefault  
		accept.setFocus
		
		return dialog.execute()
	end
end

# load an icon from a file
def load_icon(filename, application, type=FXPNGIcon)
	icon = nil
	File.open(filename, 'rb') do |f|
		icon = type.new(application, f.read)
	end
	
	return icon
end

# initialize the fonts that the application uses
def initialize_fonts(application)
	[12, 14, 16, 18, 24].each() do |size|
		FONT["Courier #{size}"] = FXFont.new(application, 'Courier New', size)
		FONT["Helvetica #{size}"] = FXFont.new(application, 'Helvetica', size)
	end
	
	FONT['Courier 24 bold'] = FXFont.new(application, 'Courier New', 24, FXFont::Bold)
end

# Display the startup splash screen dialog
def splash_screen(application)
	# select a random splash image to display
	images = Dir['./splash/*.{PNG,png}']
	icon = load_icon(images[rand(images.length())], application)

	# the splash screen dialog
	splash = FXDialogBox.new(application, nil, FRAME_LINE,
							:padLeft => 0, :padRight => 0, :padTop => 0, :padBottom => 0)
	
	# frame to hold the splash screen components
	frame = FXVerticalFrame.new(splash, LAYOUT_FILL_X)
	
	# the main label that holds the splash image and application title
	label = FXLabel.new(frame, 'CS 1300 Ruby Hangman', icon, 
						:opts => TEXT_BELOW_ICON | JUSTIFY_LEFT)
	label.font = FONT['Courier 24 bold']

	# People tell me I like to talk... so let's add a chatty message
	message = [
		'', 
		"Guess the word in #{MAX_GUESSES} tries, or you\'ll swing!",
	]
	
	FXLabel.new(frame, message.join("\n"), :opts => JUSTIFY_LEFT | TEXT_AFTER_ICON) do |theLabel|
		theLabel.font = FONT['Helvetica 12']
	end

	# set the splash screen to display for 5 seconds
	application.addTimeout(5000, :repeat => false) do
		splash.close()
	end
	
	# fire it up
	splash.execute(PLACEMENT_SCREEN)
end

if __FILE__ == $0
	if not TEST_MODE
		# Make application
		application = FXApp.new("CS 1300 Hangman", "UWG CS")
		application.create()
		
		initialize_fonts(application)
		
		if SHOW_SPLASH
			splash_screen(application)
		end
		
		# Make window
		$game = HangmanGUI.new(application)
		$game.create()

		# Run
		application.run
	else
		test_hangman_logic()
	end
end
