# TIGNode - Twitter IRC Gateway powered by Node

- Twitter IRC Gateway
- Use User Streams
- Powered by Node.js
- Grouping via channel
 - Original grouping on apps. (Not lists on twitter.com)
- Mention, Fav and RT from typablemap
 - `/me re hoge Message`
 - `/me fav fuga`
 - `/me rt piyo`

## Usage
Clone this repository, and run.

    $ bin/tignode

Access to ```localhost:16673``` with your twitter screen_name as nick.


## Note
Can't use '-' in nick.(Nick validation in ircd.js is strict.)

## Configuration
Config file is ```config/config.json```.

## (want) TODO
- Specing (hmm.. Is it difficult?)
- Grouping (remaining implementation KICK. PART)
- Event (like Favorited, Followed) would be announced in #events channel
