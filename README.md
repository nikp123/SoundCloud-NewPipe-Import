# SoundCloud-NewPipe-Import
This is a script that grabs your SoundCloud likes and playlists and puts them into a "NewPipe database"

## What will I need?
You will need:
 * a POSIX-compliant enviroment (macOS, GNU/Linux, BSD, Cygwin, WSL... etc)
 * a modern version of BASH (don't use your 90s thing here)
 * sqlite3 (for managing the database files)
 * jq (a JSON data maniputaion tool)
 * zip and unzip commands
 * a SoundCloud username
 * a SoundCloud client key (because we have to be autorized to use the API)
 * a NewPipe export file (to preserve your existing settings, subscriptions, playlist data, etc...)

### What if I don't have a POSIX environment?
Well, this is not for you then, sorry :(

### What if I can't get some of the commands/packages?
Well, in most cases these are simple utilities, and they should be simple to compile as well.

## How do I get a SoundCloud client key?
The problem is that this script probably violates the SoundCloud API ToS, so it isn't the best idea to share my keys here.

I would gladely PM you my key, but the problem is that if this becomes too popular 
and one of the soundcloud engeeneers notice, it's game over.

To get one, you'll need to [register an app](https://soundcloud.com/you/apps/new),
but as of the time of writing this it's unfortunately unavailable :(

So a workaround would be to steal a client key from popular media players and use the temporarely, 
DO NOT OVER-USE THEM BECAUSE THEY ARE SHARED AND WOULD PROBABLY RUIN THE EXPERIENCE FOR OTHER USERS.

I AM NOT RESPONSIBLE FOR WHAT YOU DO TO THAT KEY. JUST HAVE THAT IN MIND. IT'S UP TO YOU.

## How do I get the "export file" for NewPipe?
NOTE: This is based off of version 0.13.7 as of the time of writing this.

How to proceed: 
 * Open the app on your phone/tablet/whatever.
 * On the top right corner tap the three vertical dots
 * On the new pop-up select "Settings"
 * Once you're in a new "settings" screen, press the Content button (which has a globe icon on it)
 * Scroll all the way down until you get to "Export database" and press it
 * Choose wherever you would like to store it

That's this part done. Now it's a nice reminder to keep this file as something may go wrong, perhaps even BADLY.

So always make backups. Or in this case, keep them ;)

## What do I do with the new export file and how does this script function?
You'll need to get the newly exported zip file onto your computer, I don't know how, just do it.

Once you've done it, clone this repository and follow the orders.

 * change the directory to the script
 * and run as follows ``./import_soundcloud.sh location_of_the_zip_file your_soundcloud_username the_client_key``
 * wait for the script to do it's magic (it may take a while on slower machines)

And on the same directory from where you ran the script there should be a new file called ``newpipe_new.zip```

Now get this file back onto your phone somehow. I mean, just reverse what you did for the export file back, silly.

Once you got the new file back, proceed as following:
 * Open the app on your phone/tablet/whatever.
 * On the top right corner tap the three vertical dots
 * On the new pop-up select "Settings"
 * Once you're in a new "settings" screen, press the Content button (which has a globe icon on it)
 * Scroll all the way down until you get to "Import database" and press it
 * And select your newly created ``newpipe_new.zip``

Done, enjoy :D

## This didn't copy my liked playlists or reposts.

For the liked playlists there is no API call I found that "ACTUALLY" works.

You can't just grab a list of reposts in SoundCloud, it doesn't work like that.

## Future ideas
None as of now, as I'm pretty satisfied with what I made. But you are free to contribute.

## Contributions

Contribute all you like, I'm open for suggestions, tweaks, additions, code changes, really big code changes.

Just two rules for contributing code:
 * Use tabs, as I don't like running vim commands for indenting so often.
 * Don't use bloated solutions, like calling a external python or node.js script. Keep it simple, dummy.

## License

Look at the LICENSE file in this repository. I can't believe it, it's GPL3.

