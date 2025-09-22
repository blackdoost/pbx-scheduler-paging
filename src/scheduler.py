#!/usr/bin/env python3
import threading
import time
from datetime import datetime, time as dt_time
from ami_client import AmiClient
from astral import LocationInfo
from astral.sun import sun

# NOTE: Implement real DB access in place of stubs below

def get_schedule_rules():
    return []


def get_playlist_tracks(playlist_id):
    return []


class PlayJob(threading.Thread):
    def __init__(self, playlist_id, zone_ids, window_start, window_end):
        super().__init__()
        self.playlist_id = playlist_id
        self.zone_ids = zone_ids
        self.window_start = window_start
        self.window_end = window_end
        self.ami = AmiClient()

    def run(self):
        # compute total duration, then loop tracks and use AMI to play
        tracks = get_playlist_tracks(self.playlist_id)
        if not tracks:
            return
        now = datetime.now()
        while datetime.now() < self.window_end:
            for t in tracks:
                # for each zone originte playback (simplified)
                for z in self.zone_ids:
                    channel = z  # expects SIP/<ext>
                    self.ami.originate_playback(channel, application='Playback', appdata=t['filename'])
                # sleep track duration
                time.sleep(t.get('duration', 1))
                if datetime.now() >= self.window_end:
                    break


def compute_azan_times_for_city(city, latitude, longitude, date=None):
    city_info = LocationInfo(city, "", "UTC", latitude, longitude)
    s = sun(city_info.observer, date=date)
    # return fajr, dhuhr, asr (approx via astral names)
    return {
        'fajr': s.get('dawn'),
        'dhuhr': s.get('noon'),
        'asr': s.get('afternoon') if 'afternoon' in s else s.get('sunset')
    }


def main_loop():
    while True:
        now = datetime.now()
        rules = get_schedule_rules()
        for r in rules:
            # check active and spawn PlayJob if needed
            pass
        time.sleep(10)


if __name__ == '__main__':
    main_loop()