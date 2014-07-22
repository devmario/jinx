# -*- coding:utf-8 -*-
#!/usr/bin/env python

import tornado.ioloop
import tornado.web

from tornado import gen
from tornado.options import define, options, parse_command_line

import hashlib
import json
import time
import random
import socket, ssl, struct

from models import User, Game, Gamelist, RandomColumn, Queue, gidtouid

def send_pushnoti(token, payload):
    theCertfile = 'cert/STST_apns_Ent_Dist.pem'
    theHost = ( 'gateway.push.apple.com', 2195 )
    data = json.dumps( payload )
    byteToken = token.decode('hex') # Python 2
    theFormat = '!BH32sH%ds' % len(data)
    theNotification = struct.pack( theFormat, 0, 32, byteToken, len(data), data )
    ssl_sock = ssl.wrap_socket( socket.socket( socket.AF_INET, socket.SOCK_STREAM ), certfile = theCertfile )
    ssl_sock.connect( theHost )
    ssl_sock.write( theNotification )
    ssl_sock.close()

define("port", default=8080, help="run on the given port", type=int)


route_table = []
def route(url):
    def decorator(handler):
        route_table.append((url, handler))
        return handler
    return decorator

@route('/')
class MainHandler(tornado.web.RequestHandler):
    """

    :url: /
    """
    def get(self):
        uid = self.get_argument('uid', '')
        nickname = self.get_argument('nickname', '')
        picture = self.get_argument('picture', '')
        token = self.get_argument('token', '')

        if not uid:
            self.write(json.dumps({"error":"uid parameter need"}))
            return

        u = User.get_by_id(uid)
        if u is None:
            u = User(uid)
            u.prop['isappuser'] = "true"
            u.update(nickname, picture, token)
            u.set()
            RandomColumn.set('user', uid)
        else:
            needset = False
            if not 'isappuser' in u.prop:
                u.prop['isappuser'] = "true"
                RandomColumn.set('user', uid)
                needset = True
            if u.update(nickname, picture, token):
                needset = True
            if needset:
                u.set()
        data = {}

        gl = Gamelist.new_or_get_by_id(uid)

        data['me'] = u.to_dict(True)
        data['gamelist'] = gl.to_dict(data['me']['id'])
        Queue.pop(uid)
        self.write(json.dumps(data))

@route('/send')
class SendHandler(tornado.web.RequestHandler):
    def get(self):
        uid = self.get_argument('uid', '')
        toid = self.get_argument('toid', '')
        message = self.get_argument('message', '')

        if uid == '':
            self.write('{"error":"uid parameter need"}')
            return

        if toid == '':
            self.write('{"error":"toid parameter need"}')
            return

        if message == '':
            self.write('{"error":"message parameter need"}')
            return

        me = User.new_or_get_by_id(uid)
        if me == None:
            self.write('{"error":"not found"}')

        o = User.new_or_get_by_id(toid)
        if 'token' in o.prop:
            if o.prop['token'] != '(null)':
                payload = {'aps':{'alert':''}}
                if 'nickname' in o.prop:
                    payload['aps']['alert'] = o.prop['nickname'] + '님이 메세지를 보냈습니다!'
                payload['aps']['alert'] = '누국가가 당신에게 메세지를 보냈습니다!'
                payload['aps']['sound'] = 'jinx.wav'
                send_pushnoti(o.prop['token'], payload)

        gl = Gamelist.new_or_get_by_id(uid)
        glto = Gamelist.new_or_get_by_id(toid)
        gid = gl.get_current_game_id(toid)
        newgame = gid is None
        if newgame:
            gid = Game.make_id(uid, toid)
        g = Game.new_or_get_by_id(gid)
        if g.say(uid, message):
            g.set()
            gl.set_game(g)
            glto.set_game(g)
            if newgame:
                gl.add_current_game(toid, gid)
                glto.add_current_game(uid, gid)
            gl.set()
            glto.set()
            Queue.push(uid, gid, toid, message, g.round)

        data = {}
        data['game'] = g.to_dict(uid, True)
        self.write(json.dumps(data))

@route('/get')
class GetHandler(tornado.web.RequestHandler):
    def get(self):
        uid = self.get_argument('uid', '')
        gid = self.get_argument('gid', '')
        if gid == '':
            self.write('{"error":"gid parameter need"}')
            return

        o = Game.get_by_id(gid)
        if o == None:
            self.write(json.dumps({'error': "not found", 'gid': gid}))
            return

        data = {}
        data['game'] = o.to_dict(uid, True)
        self.write(json.dumps(data))

@route('/queue')
class QueueHandler(tornado.web.RequestHandler):
    def get(self):
        uid = self.get_argument('uid', '')
        self.write(Queue.pop(uid))

@route('/random')
class RandomHandler(tornado.web.RequestHandler):
    def get(self):
        uid_me = self.get_argument('uid', '')
        if uid_me == '':
            self.write('{"error":"need uid"}')
            return
        uid = RandomColumn.get('user')
        while uid == uid_me:
            uid = RandomColumn.get('user')
        u = None
        if uid != None:
            u = User.get_by_id(uid)
        if u != None:
            u = u.to_dict(False)
        data = {'pick': u}

        self.write(json.dumps(data))

@route('/success')
class SuccessHandler(tornado.web.RequestHandler):
    def get(self):
        uid = self.get_argument('uid', '')
        gid = self.get_argument('gid', '')
        if uid == '' or gid == '':
            self.write('{"error":"uid, gid"}')
            return

        g = Game.get_by_id(gid)
        if g == None:
            self.write('{"error":"game not found"}')
            return

        next_game = g.match(uid)
        if next_game != None:
            data = {}
            data['game'] = next_game.to_dict(uid, True)
            self.write(json.dumps(data))
            return
        self.write('{}')

def main():
    parse_command_line()
    app = tornado.web.Application(route_table,)
    app.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()

if __name__ == "__main__":
    main()

