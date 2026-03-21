import datetime
import unittest
from unittest.mock import MagicMock, patch


class ScratchTest(unittest.TestCase):

    def test_scratch(self):
        datetime_mock = MagicMock(wraps=datetime.datetime)
        datetime_mock.now.return_value = datetime.datetime(1999, 1, 1)
        with patch('datetime.datetime', new=datetime_mock):
            self.assertEqual(datetime.datetime.now(), datetime.datetime(1999, 1, 1))
            print(datetime_mock.call_count == 1)



