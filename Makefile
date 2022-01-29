install:
	curl https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt -o dictionary.txt
	touch bad-in-dictionary.txt
	bundle install
