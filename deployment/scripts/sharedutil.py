import grp
import logging
import os
import pwd


class sharedutil:
    @staticmethod
    def change_file_owner(owner, group, path):
        uid = pwd.getpwnam(owner).pw_uid
        gid = grp.getgrnam(group).gr_gid
        os.chown(path, uid, gid)

    @staticmethod
    def init_logger(log_file, loggerName):
        path = os.path.dirname(os.path.realpath(__file__))
        os.chdir(path)
        lHandler = logging.FileHandler(log_file, mode='a', encoding=None, delay=False)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        lHandler.setFormatter(formatter)
        logger = logging.getLogger(loggerName)
        logger.setLevel(logging.DEBUG)
        logger.addHandler(lHandler)
        return logger

    @staticmethod
    def change_owner_and_move_file(owner, group, sourcePath, targetPath):
        sharedutil.change_file_owner(owner, group, sourcePath)
        os.rename(sourcePath, targetPath)
