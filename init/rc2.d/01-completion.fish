complete -c kafka -x -a topic -d 'create a new topic'
complete -c kafka -x -a topics -d 'list all topics'
complete -c kafka -x -a help  -d 'list all commands'
complete -c kafka -x -a groups -d 'get all of the consumer groups'
complete -c kafka -x -a offsets -d '<topic> get all of the offsets for a topic'
complete -c kafka -x -a totaloffsets -d '<topic> total offsets for a topic'
complete -c kafka -x -a size -d '<group> Get the size of the offsets for consumer group supplied'

