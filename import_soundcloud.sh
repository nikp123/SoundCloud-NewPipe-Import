#!/bin/bash
#sqlite3 soundcloud.db "create table android_metadata (locale TEXT);"
#sqlite3 soundcloud.db "CREATE TABLE \`playlists\` (\`uid\` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, \`name\` TEXT, \`thumbnail_url\` TEXT);"
#sqlite3 soundcloud.db "CREATE TABLE \`streams\` (\`uid\` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, \`service_id\` INTEGER NOT NULL, \`url\` TEXT, \`title\` TEXT, \`stream_type\` TEXT, \`duration\` INTEGER, \`uploader\` TEXT, \`thumbnail_url\` TEXT);"
#sqlite3 soundcloud.db "CREATE TABLE \`playlist_stream_join\` (\`playlist_id\` INTEGER NOT NULL, \`stream_id\` INTEGER NOT NULL, \`join_index\` INTEGER NOT NULL, PRIMARY KEY(\`playlist_id\`, \`join_index\`), FOREIGN KEY(\`playlist_id\`) REFERENCES \`playlists\`(\`uid\`) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED, FOREIGN KEY(\`stream_id\`) REFERENCES \`streams\`(\`uid\`) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED)"

unzip $1 &> /dev/null

filename="newpipe.db"
username="$2"
client_id="$3"

userinfo=$(curl "https://api.soundcloud.com/users/$username?client_id=$client_id" 2> /dev/null) 

# NOTICE
echo "Notice: Number may not be accurate because of the semi-broken API"

# Getting info about likes
number_of_likes=$(echo $userinfo|jq -r '.public_favorites_count')
echo -n "Pulling $number_of_likes tracks into 'Soundcloud - Likes'"
address="http://api.soundcloud.com/users/$username/favorites?client_id=$client_id&limit=200&linked_partitioning=1"
j=0
lastcount=0
stream_pos=$(sqlite3 "$filename" "SELECT max(uid) FROM streams")
playlist_pos=$(sqlite3 "$filename" "SELECT max(uid) FROM playlists")
(( playlist_pos++ ))

# count number of songs in the playlist
m=0
for (( i=0; i<number_of_likes; i+=200 )); do
	list=$(curl "$address" 2> /dev/null)
	n=$(echo $list|jq '.collection | length')
	(( m+=n ))
	address=$(echo $list|jq -r '.next_href')
done
(( m-- ))

# insert them into the database
address="http://api.soundcloud.com/users/$username/favorites?client_id=$client_id&limit=200&linked_partitioning=1"
for (( i=0; i<number_of_likes; i+=200 )); do
	IFS=$' '
	# 200 is the undocumented limit of how many songs can be pulled from a single query
	list=$(curl "$address" 2> /dev/null)
	listcount=$(echo $list|jq '.collection | length')
	(( maxcount+=listcount ))
	address=$(echo $list|jq -r '.next_href')
	
	echo -n "."
	stream_url="$(echo $list|jq -r '.collection[].permalink_url')"
	IFS=$'\n' stream_url=($stream_url)
	echo -n "."
	IFS=$' '
	stream_title="$(echo $list|jq -r '.collection[].title')"
	IFS=$'\n' stream_title=($stream_title)
	echo -n "."
	IFS=$' '
	duration="$(echo $list|jq -r '.collection[].duration')"
	IFS=$'\n' duration=($duration)
	echo -n "."
	IFS=$' '
	author="$(echo $list|jq -r '.collection[].user.username')"
	IFS=$'\n' author=($author)
	echo -n "."
	IFS=$' '
	thumbnail_url="$(echo $list|jq -r '.collection[].artwork_url')"
	IFS=$'\n' thumbnail_url=($thumbnail_url)
	echo -n "."
	IFS=$' '

	(( lastcount+=j ))
	for (( j=0; j<listcount; j++ )); do
		((stream_pos++))
		((k=m-j-lastcount))
		check_for_constraint_violation=$(sqlite3 $filename "SELECT uid FROM streams WHERE url=\"${stream_url[$j]}\"")
		if [ -z ${check_for_constraint_violation} ]; then
			((stream_pos++))
			sqlite3 $filename "INSERT INTO streams VALUES ($stream_pos, 1, \"${stream_url[$j]}\", \"${stream_title[$j]}\", \"AUDIO_STREAM\", $(( duration[j]/1000 )), \"${author[$j]}\", \"${thumbnail_url[$j]}\")"
			sqlite3 $filename "INSERT INTO playlist_stream_join VALUES ($playlist_pos, $stream_pos, $k)"
		else
			sqlite3 $filename "INSERT INTO playlist_stream_join VALUES ($playlist_pos, $check_for_constraint_violation, $k)"
		fi
		#echo "Adding $k $stream_pos ${stream_url[$j]} ${stream_title[$j]} ${durstion[$j]} ${author[$j]} ${thumbnail_url[$j]}"
	done
done
stream_id_for_thumbnail_for_playlist=$(sqlite3 $filename "SELECT stream_id FROM playlist_stream_join WHERE playlist_id=$playlist_pos AND join_index=0")
playlist_thumbnail=$(sqlite3 $filename "SELECT thumbnail_url FROM streams WHERE uid=$stream_id_for_thumbnail_for_playlist")
sqlite3 $filename "INSERT INTO playlists VALUES ($playlist_pos, \"SoundCloud - Likes\", \"$playlist_thumbnail\")"
echo "done"

# Import playlists
number_of_playlists=$(echo $userinfo|jq -r '.playlist_count')
playlists_info=$(curl "http://api.soundcloud.com/users/$username/playlists?client_id=$client_id&limit=200" 2> /dev/null)
for (( h=0; h<number_of_playlists; h++ )); do
	number_of_tracks=$(echo $playlists_info|jq -r ".[$h].track_count")
	playlist_title=$(echo $playlists_info|jq -r ".[$h].title")
	stream_pos=$(sqlite3 "$filename" "SELECT max(uid) FROM streams")
	playlist_pos=$(sqlite3 "$filename" "SELECT max(uid) FROM playlists")
	echo -n "Pulling $number_of_tracks tracks into '$playlist_title'"
	(( playlist_pos++ ))
		
	echo -n "."
	stream_url="$(echo $playlists_info|jq -r .[$h].tracks[].permalink_url)"
	IFS=$'\n' stream_url=($stream_url)
	echo -n "."
	IFS=$' '
	stream_title="$(echo $playlists_info|jq -r .[$h].tracks[].title)"
	IFS=$'\n' stream_title=($stream_title)
	echo -n "."
	IFS=$' '
	duration="$(echo $playlists_info|jq -r .[$h].tracks[].duration)"
	IFS=$'\n' duration=($duration)
	echo -n "."
	IFS=$' '
	author="$(echo $playlists_info|jq -r .[$h].tracks[].user.username)"
	IFS=$'\n' author=($author)
	echo -n "."
	IFS=$' '
	thumbnail_url="$(echo $playlists_info|jq -r .[$h].tracks[].artwork_url)"
	IFS=$'\n' thumbnail_url=($thumbnail_url)
	echo -n "."
	IFS=$' '
	
	for (( j=0; j<number_of_tracks; j++ )); do
		check_for_constraint_violation=$(sqlite3 $filename "SELECT uid FROM streams WHERE url=\"${stream_url[$j]}\"")
		if [ -z ${check_for_constraint_violation} ]; then
			((stream_pos++))
			sqlite3 $filename "INSERT INTO streams VALUES ($stream_pos, 1, \"${stream_url[$j]}\", \"${stream_title[$j]}\", \"AUDIO_STREAM\", $(( duration[j]/1000 )), \"${author[$j]}\", \"${thumbnail_url[$j]}\")"
			sqlite3 $filename "INSERT INTO playlist_stream_join VALUES ($playlist_pos, $stream_pos, $j)"
		else
			sqlite3 $filename "INSERT INTO playlist_stream_join VALUES ($playlist_pos, $check_for_constraint_violation, $j)"
		fi
		
		#echo "Adding $k $stream_pos ${stream_url[$j]} ${stream_title[$j]} ${duration[$j]} ${author[$j]} ${thumbnail_url[$j]}"
	done

	stream_id_for_thumbnail_for_playlist=$(sqlite3 $filename "SELECT stream_id FROM playlist_stream_join WHERE playlist_id=$playlist_pos AND join_index=0")
	playlist_thumbnail=$(sqlite3 $filename "SELECT thumbnail_url FROM streams WHERE uid=$stream_id_for_thumbnail_for_playlist")
	sqlite3 $filename "INSERT INTO playlists VALUES ($playlist_pos, \"$playlist_title\", \"$playlist_thumbnail\")"
	echo "done"
done

# To insert a stream
#sqlite3 $filename "INSERT INTO streams VALUES ($stream_pos, 1, \"$stream_url\", \"$stream_title\", \"AUDIO_STREAM\", $duration_in_seconds, \"$author\", \"$thumbnail_url\")"
#sqlite3 $filename "INSERT INTO playlists VALUES ($playlist_pos, \"$playlist_title\", \"$playlist_thumbnail\")
#sqlite3 $filename "INSERT INTO playlist_stream_join VALUES ($playlist_pos, $stream_pos, $position_in_the_playlist)"

zip newpipe_new.zip $filename newpipe.settings &> /dev/null
rm $filename newpipe.settings &> /dev/null
