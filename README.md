# TIGNode - Twitter IRC Gateway powered by Node

- Twitter IRC Gateway
- Use User Streams
- Powered by Node.js
- Grouping via channel
 - I want to do this by 'grouping on apps', not lists on twitter.com

## Usage
Clone this repository, and run.

    $ bin/tignode

Access to ```localhost:16673``` with your twitter screen_name as nick.
(Can't use '-' in nick, I think nick validation in ircd.js is too strict.)

## Configuration
Config file is ```config/config.json```.

## (want) TODO
- Mention, Fav, RT using Typablemap (Want now!)
- Specing (hmm.. Is it difficult?)
- Grouping (remaining implementation KICK. PART)
- Event (like Favorited, Followed) would be announced in #events channel
