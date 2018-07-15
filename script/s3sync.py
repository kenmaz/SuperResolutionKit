from datetime import timedelta, tzinfo
from keras.callbacks import Callback
import datetime
import os

class JST(tzinfo):
    def utcoffset(self, dt):
        return timedelta(hours=9)

    def dst(self, dt):
        return timedelta(0)

    def tzname(self, dt):
        return 'JST'

class S3SyncCallback(Callback):

    def __init__(self, s3_base_url, log_dir):
        target = datetime.datetime.now(tz=JST()).strftime('%Y%m%d_%H%M%S')
        self.s3_url = '%s/%s' % (s3_base_url, target)
        self.log_dir = log_dir
        print('s3 sync: %s' % self.s3_url)

    def on_epoch_end(self, epoch, logs=None):
        self.sync()

    def sync(self):
        cmd = "aws s3 sync %s %s" % (self.log_dir, self.s3_path)
        print cmd
        res = (os.system(cmd) == 0)
        print res
        return res

