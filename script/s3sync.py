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

    def __init__(self, s3_base_url, log_dir, interval_epochs = 10):
        target = datetime.datetime.now(tz=JST()).strftime('%Y%m%d_%H%M%S')
        self.s3_url = '%s/%s' % (s3_base_url, target)
        self.log_dir = log_dir
        self.interval_epochs = interval_epochs
        print('s3 sync: %s, interval %d' % (self.s3_url, self.interval_epochs))

    def on_epoch_end(self, epoch, logs=None):
        if epoch > 0 and epoch % self.interval_epochs == 0:
            print('s3 sync..')
            self.sync()

    def sync(self):
        cmd = "aws s3 sync %s %s" % (self.log_dir, self.s3_url)
        print cmd
        res = (os.system(cmd) == 0)
        print res
        return res

