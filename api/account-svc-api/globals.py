import os

# import aiohttp
# from gql.transport.aiohttp import AioHttpTransport

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

class Globals:
    # def __init__(self):
        # conn = aiohttp.TCPConnector(limit=100)
        # session = aiohttp.ClientSession(connector=conn)
        # self.shared_transport = AioHttpTransport(session=session, session_owner=False)

    @property
    def transport(self):
        return self.shared_transport
    
    @transport.setter
    def transport(self, value):
        self.shared_transport = value

    # api prefix
    @property
    def api_prefix_v1(self):
        return "/api/v1"
    
    @property
    def app_version(self):
        return os.getenv("APP_VERSION", "2.0.0")
    
globals = Globals()