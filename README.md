# TIGNode - Twitter IRC Gateway powered by Node

Is under construction...

- Twitter IRC Gateway
- Use User Streams
- Powered by Node.js

## Usage
    $ bin/tignode

And access to ```localhost:16673``` with your twitter screen_name as nick.
(Can't use '-' in nick, I think nick validation in ircd.js is too strict.)

## Configuration
Config file is ```config/config.json```.

## (want) TODO
- multi line tweet
- character reference (like &gt;)
- Specing (hmm.. Is it difficult?)
- Mention, Fav, RT using Typablemap
- Grouping via channel (I want to do this by 'grouping on apps', not lists on twitter.com)
- Event(like Favorited, Followed) would be announced in #events.(?)
