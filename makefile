ROTHUI := https://github.com/zorker/rothui/trunk/wow8.0

all: embeds

clean:
	rm -rf embeds

embeds: clean
	svn export $(ROTHUI)/rLib embeds/rLib & \
  svn export $(ROTHUI)/rActionBar embeds/rActionBar & \
  svn export $(ROTHUI)/rButtonTemplate embeds/rButtonTemplate