#!/usr/bin/env python3
import socket
import time

class AmiClient:
    def __init__(self, host='127.0.0.1', port=5038, user='pbxsch', secret='changeme'):
        self.host = host
        self.port = port
        self.user = user
        self.secret = secret
        self.sock = None

    def connect(self):
        s = socket.create_connection((self.host, self.port), timeout=5)
        self.sock = s
        # read banner
        _ = s.recv(4096)
        login = f"Action: Login\r\nUsername: {self.user}\r\nSecret: {self.secret}\r\nEvents: off\r\n\r\n"
        s.sendall(login.encode())
        time.sleep(0.1)
        resp = s.recv(4096).decode(errors='ignore')
        return resp

    def originate_playback(self, channel, application='Playback', appdata=None, timeout=30000):
        """
        Originate to a SIP channel to run an application (e.g., Playback).
        channel: 'SIP/1000'
        application: 'Playback'
        appdata: filename without extension (Asterisk playback requires file in sounds dir or full path via 'Local' usage)
        """
        if not self.sock:
            self.connect()
        action = 'Action: Originate\r\n'
        action += f'Channel: {channel}\r\n'
        action += f'Context: from-internal\r\n'
        action += f'Exten: 1000\r\n'
        action += f'Priority: 1\r\n'
        action += f'Timeout: {timeout}\r\n'
        if application and appdata:
            action += f'Application: {application}\r\n'
            action += f'AppData: {appdata}\r\n'
        action += '\r\n'
        self.sock.sendall(action.encode())
        time.sleep(0.1)
        try:
            resp = self.sock.recv(8192).decode(errors='ignore')
        except Exception:
            resp = ''
        return resp

    def close(self):
        if self.sock:
            try:
                self.sock.close()
            except:
                pass
            self.sock = None

