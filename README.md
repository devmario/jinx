jinx
====

server
-------------------------------------------------------------------------------------------------
database

```
user - [uid] nickname, picture, push token, unit, unit time
game id list - [uid] 'current.to':game id dict, game id:'wordpair, turn' dict
game - [uid, to, time] turn, 'word pair' dict 
game queue - [game id, to uid] message (only memcache, always remove)
```

-------------------------------------------------------------------------------------------------
code

```
get main
    kakao talk id
    nickname(is exist)
    pickture(is exist)
    push token(is exist)
    
    user info
    'game id, last word pair, user id pair, turn, success' list

send message
    kakao talk id
    game id(is exist)
    to kakao talk id(if not random)
    to kakao talk nickname(if not random, is not game user)
    to kakao talk picture(if not random, is not game user)
    success(is match)
    message

get game
    game id
    
    message list

get game queue
    kakao talk id
    game id
    
    turn
    match
    message
```

-------------------------------------------------------------------------------------------------
install

```
sudo apt-get update
sudo apt-get install git-core

sudo vi /etc/apt/sources.list
deb http://www.apache.org/dist/cassandra/debian 11x main
deb-src http://www.apache.org/dist/cassandra/debian 11x main

gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
gpg --export --armor F758CE318D77295D | sudo apt-key add -
gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00
gpg --export --armor 2B5C1B00 | sudo apt-key add -

sudo apt-get update
sudo apt-get install cassandra

sudo apt-get install python-pip python-dev build-essential
sudo pip install --upgrade pip
sudo pip install --upgrade virtualenv

sudo pip install python-memcached
sudo pip install tornado
sudo pip install pycassa
```

-------------------------------------------------------------------------------------------------
cassandra

```
CREATE COLUMN FAMILY user WITH comparator = UTF8Type AND key_validation_class=UTF8Type;
CREATE COLUMN FAMILY game WITH comparator = UTF8Type AND key_validation_class=UTF8Type;
CREATE COLUMN FAMILY gamelist WITH comparator = UTF8Type AND key_validation_class=UTF8Type;
```
