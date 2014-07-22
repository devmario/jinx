# -*- coding:utf-8 -*-
#!/usr/bin/env python

import memcache
import pycassa

import hashlib
import json
import time
import random
import socket, ssl, struct

from energy import Energy

#todo stamina
ENERGY_MAX = 10
ENERGY_INTERVAL = 300

def gidtouid(gid):
    print 'gidtouid:', gid,
    v = gid.split('!')
    v[1] = v[1].split(':')[0]
    print v
    return v

def cassaconn(schema):
    pool = pycassa.ConnectionPool('jinx')
    cf = pycassa.ColumnFamily(pool, schema)
    return cf

memcache_connection = memcache.Client(['127.0.0.1:11211'], debug=0)
def memconn():
    return memcache_connection

def ppair(pair, myid):
    return pair
    ppair = {}
    for key, val in pair.items():
        if key == myid:
            ppair['friend'] = val
        else:
            ppair['me'] = val
    return val

class Database(object):
    @classmethod
    def schema(cls):
        return cls.__name__.lower()

    def __init__(self, row_id):
        self.schema = self.schema()
        self.cas_key = row_id
        self.mem_key = hashlib.md5(self.schema + "." + self.cas_key).hexdigest()
        self.prop = {}
        self.prop['id'] = row_id

    def set(self):
        cassaconn(self.schema).insert(self.cas_key, self.prop)
        memconn().set(self.mem_key, json.dumps(self.prop))
        return True

    def get(self):
        mem = memconn()
        v = mem.get(self.mem_key)
        if v is not None:
            self.prop = json.loads(v)
            return True
        cas = cassaconn(self.schema)
        try:
            v = cas.get(self.cas_key)
            if v is not None:
                self.prop = v
                mem.set(self.mem_key, json.dumps(self.prop))
                return True
        except pycassa.NotFoundException:
            return False
        return False

    @classmethod
    def get_by_id(cls, rowid):
        _o = cls(rowid)
        if _o.get() == True:
            return _o
        return None

    @classmethod
    def new_or_get_by_id(cls, rowid):
        _o = cls.get_by_id(rowid)
        if _o != None:
            return _o
        _o = cls(rowid)
        if _o.set() == True:
            return _o
        return None

    @classmethod
    def get_by_id_multi(cls, l):
        o = cls.get_by_id_multi_dict(l)
        arr = []
        for k in o:
            arr.append(o[k])
        return arr

    @classmethod
    def get_by_id_multi_dict(cls, l):
        mk = []
        mc = {}
        for rowid in l:
            k = hashlib.md5(cls.__name__ + "." + rowid).hexdigest()
            mk.append(k)
            mc[k] = rowid
        m = memconn()
        vm = m.get_multi(mk)
        v = {}
        for k in vm:
            v[k] = json.loads(vm[k])
        for k in v:
            del mc[k]
        ck = []
        for k in mc:
            ck.append(mc[k])
        c = cassaconn(cls.schema())
        vc = c.multiget(ck)
        for k in vc:
            _mk = hashlib.md5(cls.__name__ + "." + k).hexdigest()
            m.set(_mk, json.dumps(vc[k]))
            v[k] = vc[k]

        o = {}
        for k in v:
            ins = cls(v[k]['id'])
            ins.prop = v[k]
            o[k] = ins
        return o


class User(Database):
    def get_stamina(self):
        used = int(self.prop['energy_used'] if 'energy_used' in self.prop else 0)
        used_at = int(self.prop['energy_used_at'] if 'energy_used_at' in self.prop else 0)
        e = Energy(ENERGY_MAX, ENERGY_INTERVAL, used=used, used_at=used_at)
        return e

    def save_stamina(self, e):
        self.prop['energy_used'], self.prop['energy_used_at'] = str(e.used), str(e.used_at)

    def use_stamina(self):
        e = self.get_stamina()
        if e.current() > 0:
            e.use()
        self.save_stamina(e)

    def update(self, nickname, picture, token):
        if token == '(null)':
            token = ''
        if not nickname and not picture and not token:
            return False
        if nickname:
            self.prop['nickname'] = nickname
        if picture:
            self.prop['picture'] = picture
        if token:
            self.prop['token'] = token
        return True

    def to_dict(self, isme):
        data = self.prop
        if isme:
            data['energy_used'] = int(self.prop['energy_used'] if 'energy_used' in self.prop else 0)
            data['energy_used_at'] = int(self.prop['energy_used_at'] if 'energy_used_at' in self.prop else 0)
            data['energy_max'] = ENERGY_MAX
            data['energy_interval'] = ENERGY_INTERVAL
        else:
            if 'token' in data:
                del data['token']
            if 'energy_used' in data:
                del data['energy_used']
            if 'energy_used_at' in data:
                del data['energy_used_at']
        if 'isappuser' in data:
            data['isappuser'] = True
        return data

class Game(Database):
    @classmethod
    def make_id(cls, uid, toid):
        return uid + '!' + toid + ":" + str(time.time())

    @property
    def pairs(self):
        if 'wordpairs' in self.prop:
            return json.loads(self.prop['wordpairs'])
        return []

    @pairs.setter
    def pairs(self, value):
        self.prop['wordpairs'] = json.dumps(value)

    @property
    def last_pair(self):
        if 'wordpairx' in self.prop:
            return json.loads(self.prop['wordpairx'])
        return {}

    @last_pair.setter
    def last_pair(self, value):
        self.prop['wordpairx'] = json.dumps(value)

    @property
    def round(self):
        return len(self.pairs) + 1

    def say(self, uid, message):
        last_pair = self.last_pair

        if uid in last_pair:
            return False

        last_pair[uid] = message

        if len(last_pair) == 2:
            pairs = self.pairs
            pairs.append(last_pair)
            self.pairs = pairs
            self.last_pair = {}
        else:
            self.last_pair = last_pair

        return True

    def ismatch(self):
        d = self.last_pair
        if len(d) != 0:
            return False
        w = None
        if len(self.pairs) > 0:
            w = self.pairs[-1].values()
        if w == None:
            return True
        elif len(w) == 2:
            if w[0] == w[1]:
                return True
        elif len(w) == 0:
            return True
        return False

    def match(self, uid):
        if self.ismatch() == False:
            return None
        uids = gidtouid(self.prop['id'])
        frienduid = ''
        if uid == uids[0]:
            frienduid = uids[1]
        else:
            frienduid = uids[0]
        if uid in uids:
            data = {}
            if 'success' in self.prop:
                data = json.loads(self.prop['success'])
            data[uid] = 'complete'
            g = None
            if 'next_id' in self.prop:
                ''
            else:
                self.prop['next_id'] = Game.make_id(uid, frienduid)
            g = Game.new_or_get_by_id(self.prop['next_id'])
            gl = Gamelist.get_by_id(uid)
            gl.add_current_game(frienduid, self.prop['next_id'])
            gl.set_game(g)
            gl.set()
            self.prop['success'] = json.dumps(data)
            self.set()
            return g
        return None

    def get_gamelist_wordpair(self):
        if 'word' in self.prop:
            word = json.loads(self.prop['word'])
            last = None
            prev = None
            if len(word) > 0:
                last = word[len(word) - 1]
            if len(word) > 1:
                prev = word[len(word) - 2]
            if last != None:
                w = None
                for v in last:
                    if w == v:
                        return last
                    else:
                        w = v
            if prev != None:
                return prev
            return {}
        return {}

    def to_dict(self, my_id, need_user = False):
        gid = self.prop['id']
        result = {
            'id': gid,
            'round': self.round,
        }
        if my_id:
            result['wordpairs'] = [ppair(pair, my_id) for pair in self.pairs]
            result['last_wordpair'] = ppair(self.last_pair, my_id)
        else:
            result['wordpairs'] = self.pairs
            result['last_wordpair'] = self.last_pair
        uids = gidtouid(gid)
        result['user_id'] = uids[0] if uids[0] != my_id else uids[1]
        if need_user:
            user = User.get_by_id(result['user_id'])
            result['user'] = user.to_dict(False)
            del result['user_id']
        return result

class Gamelist(Database):
    @property
    def playing_users(self):
        if 'playing_users' in self.prop:
            return json.loads(self.prop['playing_users'])
        return {}

    @playing_users.setter
    def playing_users(self, dic):
        self.prop['playing_users'] = json.dumps(dic)

    @property
    def game_ids(self):
        if 'game_ids' in self.prop:
            return json.loads(self.prop['game_ids'])
        return []

    @game_ids.setter
    def game_ids(self, dic):
        self.prop['game_ids'] = json.dumps(dic)

    def get_current_game_id(self, to):
        try:
            return self.playing_users[to]
        except KeyError:
            return None

    def add_current_game(self, to, gid):
        d =  self.playing_users
        d[to] = gid
        self.playing_users = d

    def end_current_game(self, to):
        d = self.playing_users
        del d[to]
        self.playing_users = d

    def set_game(self, game_obj):
        gid = game_obj.prop['id']
        self.prop[gid] = json.dumps(game_obj.to_dict(False))
        d = self.game_ids
        if gid not in d:
            d.append(gid)
        self.game_ids = d
        print 'game added:', d

    def to_dict(self, my_id):
        playings = []
        history = []
        playing_users = self.playing_users
        print 'playing_users:', self.playing_users
        print 'game_ids:', self.game_ids
        user_dict = {}
        for gid in self.game_ids:
            game = json.loads(self.prop[gid])
            game['id'] = gid
            uids = gidtouid(gid)
            user_dict[gid] = uids[0] if uids[0] != my_id else uids[1]
            game['user_id'] = user_dict[gid]
            print gid, ':', game
            if gid in playing_users.values():
                playings.append(game)
            else:
                history.append(game)
        user_array = []
        for k in user_dict:
            user_array.append(user_dict[k])
        users = User.get_by_id_multi(user_array)
        users_dict = {}
        for user in users:
            users_dict[user.prop['id']] = user.to_dict(False)
        for i in range(len(playings)):
            playings[i]['user'] = users_dict[playings[i]['user_id']]
            del playings[i]['user_id']
        for i in range(len(history)):
            history[i]['user'] = users_dict[history[i]['user_id']]
            del history[i]['user_id']
        return {
            'playings': playings,
            'history': history,
        }

    def getuids(self):
        uids = set()
        for gid in self.game_ids:
            uidpair = gidtouid(gid)
            uids.add(uidpair[0])
            uids.add(uidpair[1])
        return uids


class RandomColumn(object):
    @classmethod
    def set(cls, category, columnid):
        cas = cassaconn(category)
        count = cas.get_count('random')
        cas.insert('random', {str(count):columnid})

    @classmethod
    def get(cls, category):
        cas = cassaconn(category)
        #느릴수도....
        count = cas.get_count('random')
        if count < 2:
            return None
        k = str(random.randrange(0, count))
        d = cas.get('random', columns = [k])
        if k in d:
            return d[k]
        return None

class Queue(object):
    @classmethod
    def push(cls, uid, gid, to, message, turn):
        m = memconn()
        k = hashlib.md5('queue.' + to).hexdigest()
        v = m.get(k)
        if v != None:
            v = json.loads(v)
        else:
            v = []
        v.append({'uid':uid,'gid':gid,'message':message, 'round':turn})
        m.set(k, json.dumps(v))
        return True

    @classmethod
    def pop(cls, uid):
        m = memconn()
        k = hashlib.md5('queue.' + uid).hexdigest()
        v = m.get(k)
        if v != None:
            m.delete(k)
            v = json.loads(v)
            for index in range(len(v)):
                uid = v[index]['uid']
                del v[index]['uid']
                u = User.get_by_id(uid)
                v[index]['user'] = u.to_dict(False)
            v = json.dumps(v)
            return v
        else:
            return '[]'
