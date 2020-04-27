# PySFML - Python bindings for SFML
# Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
#
# This file is part of PySFML project and is available under the zlib
# license.

#cdef extern from "pysfml/NumericObject.hpp":
#    pass

from cython.operator cimport dereference as deref
from cython.operator cimport preincrement as inc

from libc.stdlib cimport *
from libcpp.string cimport string
from libcpp.vector cimport vector

cimport sfml as sf
from sfml cimport Int8, Int16, Int32, Int64
from sfml cimport Uint8, Uint16, Uint32, Uint64
from pysfml.system cimport Time

cdef class IpAddress:
    cdef sf.IpAddress *p_this

    NONE = wrap_ipaddress(<sf.IpAddress*>&sf.ipaddress.None)
    LOCAL_HOST = wrap_ipaddress(<sf.IpAddress*>&sf.ipaddress.LocalHost)
    BROADCAST = wrap_ipaddress(<sf.IpAddress*>&sf.ipaddress.Broadcast)

    def __init__(self):
        self.p_this = new sf.IpAddress()

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "IpAddress(integer={0})".format(self.integer)

    def __str__(self):
        return self.string.decode('utf-8')

    def __richcmp__(IpAddress x, IpAddress y, int op):
        if op == 0:
            return x.p_this[0] <  y.p_this[0]
        elif op == 2:
            return x.p_this[0] == y.p_this[0]
        elif op == 4:
            return x.p_this[0] >  y.p_this[0]
        elif op == 1:
            return x.p_this[0] <= y.p_this[0]
        elif op == 3:
            return x.p_this[0] != y.p_this[0]
        elif op == 5:
            return x.p_this[0] >= y.p_this[0]

    @classmethod
    def from_string(self, _string):
        cdef string encoded_string
        encoded_string_temporary = _string.encode('UTF-8')
        encoded_string = string(<char*>encoded_string_temporary)

        cdef sf.IpAddress *p = new sf.IpAddress(encoded_string)
        return wrap_ipaddress(p)

    @classmethod
    def from_integer(self, Uint32 address):
        cdef sf.IpAddress *p = new sf.IpAddress(address)
        return wrap_ipaddress(p)

    @classmethod
    def from_bytes(self, Uint8 b1, Uint8 b2, Uint8 b3, Uint8 b4):
        cdef sf.IpAddress *p = new sf.IpAddress(b1, b2, b3, b4)
        return wrap_ipaddress(p)

    property string:
        def __get__(self):
            return self.p_this.toString().c_str()

    property integer:
        def __get__(self):
            return self.p_this.toInteger()

    @classmethod
    def get_local_address(self):
        cdef sf.IpAddress* p = new sf.IpAddress()
        p[0] = sf.ipaddress.getLocalAddress()
        return wrap_ipaddress(p)

    @classmethod
    def get_public_address(self, Time timeout=None):
        cdef sf.IpAddress* p = new sf.IpAddress()

        if not timeout:
            p[0] = sf.ipaddress.getPublicAddress()
        else:
            p[0] = sf.ipaddress.getPublicAddress(timeout.p_this[0])

        return wrap_ipaddress(p)

cdef wrap_ipaddress(sf.IpAddress* p):
    cdef IpAddress r = IpAddress.__new__(IpAddress)
    r.p_this = p
    return r

cdef class Socket:
    DONE = sf.socket.Done
    NOT_READY = sf.socket.NotReady
    DISCONNECTED = sf.socket.Disconnected
    ERROR = sf.socket.Error

    ANY_PORT = sf.socket.AnyPort

    cdef sf.Socket *p_socket

    def __init__(self):
        if self.__class__ == Socket:
            raise NotImplementedError('Socket is abstract')

    property blocking:
        def __get__(self):
            return self.p_socket.isBlocking()

        def __set__(self, bint blocking):
            self.p_socket.setBlocking(blocking)


class SocketException(Exception): pass
class SocketNotReady(SocketException): pass
class SocketDisconnected(SocketException): pass
class SocketError(SocketException): pass


cdef class TcpListener(Socket):
    cdef sf.TcpListener *p_this

    def __init__(self):
        self.p_this = new sf.TcpListener()
        self.p_socket = <sf.Socket*>self.p_this

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "TcpListener(blocking={0}, local_port={1})".format(self.blocking, self.local_port)

    property local_port:
        def __get__(self):
            return self.p_this.getLocalPort()

    def listen(self, unsigned short port):
        cdef sf.socket.Status status = self.p_this.listen(port)

        if status is not sf.socket.Done:
            if status is sf.socket.NotReady:
                raise SocketNotReady()
            elif status is sf.socket.Disconnected:
                raise SocketDisconnected()
            elif status is sf.socket.Error:
                raise SocketError()

    def close(self):
        self.p_this.close()

    def accept(self):
        cdef TcpSocket socket = TcpSocket()
        cdef sf.socket.Status status

        with nogil:
            status = self.p_this.accept(socket.p_this[0])

        if status is not sf.socket.Done:
            if status is sf.socket.NotReady:
                raise SocketNotReady()
            elif status is sf.socket.Disconnected:
                raise SocketDisconnected()
            elif status is sf.socket.Error:
                raise SocketError()

        return socket


cdef class TcpSocket(Socket):
    cdef sf.TcpSocket *p_this

    def __init__(self):
        self.p_this = new sf.TcpSocket()
        self.p_socket = <sf.Socket*>self.p_this

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "TcpSocket(blocking={0}, local_port={1}, remote_address={2}, remote_port={3})".format(self.blocking, self.local_port, self.remote_address, self.remote_port)

    property local_port:
        def __get__(self):
            return self.p_this.getLocalPort()

    property remote_address:
        def __get__(self):
            cdef sf.IpAddress *p = new sf.IpAddress()
            p[0] = self.p_this.getRemoteAddress()
            return wrap_ipaddress(p)

    property remote_port:
        def __get__(self):
            return self.p_this.getRemotePort()

    def connect(self, IpAddress remote_address, unsigned short remote_port, Time timeout=None):
        cdef sf.socket.Status status

        if not timeout:
            with nogil:
                status = self.p_this.connect(remote_address.p_this[0], remote_port)
        else:
            with nogil:
                status = self.p_this.connect(remote_address.p_this[0], remote_port, timeout.p_this[0])

        if status is not sf.socket.Done:
            if status is sf.socket.NotReady:
                raise SocketNotReady()
            elif status is sf.socket.Disconnected:
                raise SocketDisconnected()
            elif status is sf.socket.Error:
                raise SocketError()

    def disconnect(self):
        self.p_this.disconnect()

    def send(self, bytes data):
        cdef sf.socket.Status status
        cdef char* cdata = <char*>data
        cdef size_t cdata_len = len(data)

        with nogil:
            status = self.p_this.send(cdata, cdata_len)

        if status is not sf.socket.Done:
            if status is sf.socket.NotReady:
                raise SocketNotReady()
            elif status is sf.socket.Disconnected:
                raise SocketDisconnected()
            elif status is sf.socket.Error:
                raise SocketError()

    def receive(self, size_t size):
        cdef char* data = <char*>malloc(size * sizeof(char))
        cdef size_t received = 0
        cdef sf.socket.Status status

        with nogil:
            status = self.p_this.receive(data, size, received)

        if status is not sf.socket.Done:
            if status is sf.socket.NotReady:
                raise SocketNotReady()
            elif status is sf.socket.Disconnected:
                raise SocketDisconnected()
            elif status is sf.socket.Error:
                raise SocketError()

        return <bytes>(data)[:received]


cdef class UdpSocket(Socket):
    cdef sf.UdpSocket *p_this

    MAX_DATAGRAM_SIZE = sf.udpsocket.MaxDatagramSize

    def __init__(self):
        self.p_this = new sf.UdpSocket()
        self.p_socket = <sf.Socket*>self.p_this

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "UdpSocket(blocking={0}, local_port={1})".format(self.blocking, self.local_port)

    property local_port:
        def __get__(self):
            return self.p_this.getLocalPort()

    def bind(self, unsigned short port):
        cdef sf.socket.Status status = self.p_this.bind(port)

        if status is not sf.socket.Done:
            if status is sf.socket.NotReady:
                raise SocketNotReady()
            elif status is sf.socket.Disconnected:
                raise SocketDisconnected()
            elif status is sf.socket.Error:
                raise SocketError()

    def unbind(self):
        self.p_this.unbind()

    def send(self, bytes data, IpAddress remote_address, unsigned short remote_port):
        cdef sf.socket.Status status = self.p_this.send(<char*>data, len(data), remote_address.p_this[0], remote_port)

        if status is not sf.socket.Done:
            if status is sf.socket.NotReady:
                raise SocketNotReady()
            elif status is sf.socket.Disconnected:
                raise SocketDisconnected()
            elif status is sf.socket.Error:
                raise SocketError()

    def receive(self, size_t size):
        cdef char* data = <char*>malloc(size * sizeof(char))
        cdef size_t received = 0
        cdef IpAddress remote_address = IpAddress()
        cdef unsigned short port = 0
        cdef sf.socket.Status status = self.p_this.receive(data, size, received, remote_address.p_this[0], port)

        if status is not sf.socket.Done:
            if status is sf.socket.NotReady:
                raise SocketNotReady()
            elif status is sf.socket.Disconnected:
                raise SocketDisconnected()
            elif status is sf.socket.Error:
                raise SocketError()

        return (<bytes>(data)[:received], remote_address, port)


cdef class SocketSelector:
    cdef sf.SocketSelector *p_this

    def __init__(self):
        self.p_this = new sf.SocketSelector()

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "SocketSelector()"

    def add(self, Socket socket):
        self.p_this.add(socket.p_socket[0])

    def remove(self, Socket socket):
        self.p_this.remove(socket.p_socket[0])

    def clear(self):
        self.p_this.clear()

    def wait(self, Time timeout=None):
        cdef bint ret

        if not timeout:
            with nogil:
                ret = self.p_this.wait()
        else:
            with nogil:
                ret = self.p_this.wait(timeout.p_this[0])

        return ret

    def is_ready(self, Socket socket):
        return self.p_this.isReady(socket.p_socket[0])


cdef class FtpResponse:
    RESTART_MARKER_REPLY = sf.ftp.response.RestartMarkerReply
    SERVICE_READY_SOON = sf.ftp.response.ServiceReadySoon
    DATA_CONNECTION_ALREADY_OPENED = sf.ftp.response.DataConnectionAlreadyOpened
    OPENING_DATA_CONNECTION = sf.ftp.response.OpeningDataConnection
    OK = sf.ftp.response.Ok
    POINTLESS_COMMAND = sf.ftp.response.PointlessCommand
    SYSTEM_STATUS = sf.ftp.response.SystemStatus
    DIRECTORY_STATUS = sf.ftp.response.DirectoryStatus
    FILE_STATUS = sf.ftp.response.FileStatus
    HELP_MESSAGE = sf.ftp.response.HelpMessage
    SYSTEM_TYPE = sf.ftp.response.SystemType
    SERVICE_READY = sf.ftp.response.ServiceReady
    CLOSING_CONNECTION = sf.ftp.response.ClosingConnection
    DATA_CONNECTION_OPENED = sf.ftp.response.DataConnectionOpened
    CLOSING_DATA_CONNECTION = sf.ftp.response.ClosingDataConnection
    ENTERING_PASSIVE_MODE = sf.ftp.response.EnteringPassiveMode
    LOGGED_IN = sf.ftp.response.LoggedIn
    FILE_ACTION_OK = sf.ftp.response.FileActionOk
    DIRECTORY_OK = sf.ftp.response.DirectoryOk
    NEED_PASSWORD = sf.ftp.response.NeedPassword
    NEED_ACCOUNT_TO_LOG_IN = sf.ftp.response.NeedAccountToLogIn
    NEED_INFORMATION = sf.ftp.response.NeedInformation
    SERVICE_UNAVAILABLE = sf.ftp.response.ServiceUnavailable
    DATA_CONNECTION_UNAVAILABLE = sf.ftp.response.DataConnectionUnavailable
    TRANSFER_ABORTED = sf.ftp.response.TransferAborted
    FILE_ACTION_ABORTED = sf.ftp.response.FileActionAborted
    LOCAL_ERROR = sf.ftp.response.LocalError
    INSUFFICIENT_STORAGE_SPACE = sf.ftp.response.InsufficientStorageSpace
    COMMAND_UNKNOWN = sf.ftp.response.CommandUnknown
    PARAMETERS_UNKNOWN = sf.ftp.response.ParametersUnknown
    COMMAND_NOT_IMPLEMENTED = sf.ftp.response.CommandNotImplemented
    BAD_COMMAND_SEQUENCE = sf.ftp.response.BadCommandSequence
    PARAMETER_NOT_IMPLEMENTED = sf.ftp.response.ParameterNotImplemented
    NOT_LOGGED_IN = sf.ftp.response.NotLoggedIn
    NEED_ACCOUNT_TO_STORE = sf.ftp.response.NeedAccountToStore
    FILE_UNAVAILABLE = sf.ftp.response.FileUnavailable
    PAGE_TYPE_UNKNOWN = sf.ftp.response.PageTypeUnknown
    NOT_ENOUGH_MEMORY = sf.ftp.response.NotEnoughMemory
    FILENAME_NOT_ALLOWED = sf.ftp.response.FilenameNotAllowed
    INVALID_RESPONSE = sf.ftp.response.InvalidResponse
    CONNECTION_FAILED = sf.ftp.response.ConnectionFailed
    CONNECTION_CLOSED = sf.ftp.response.ConnectionClosed
    INVALID_FILE = sf.ftp.response.InvalidFile

    cdef sf.ftp.Response *p_response

    def __repr__(self):
        return "FtpResponse(ok={0}, status={1}, message={2})".format(self.ok, self.status, self.message)

    property ok:
        def __get__(self):
            return self.p_response.isOk()

    property status:
        def __get__(self):
            return self.p_response.getStatus()

    property message:
        def __get__(self):
            return self.p_response.getMessage().c_str()

cdef class FtpDirectoryResponse(FtpResponse):
    cdef sf.ftp.DirectoryResponse *p_this

    def __init__(self):
        raise NotImplementedError("Not meant to be instantiated")

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "FtpDirectoryResponse(ok={0}, status={1}, message={2})".format(self.ok, self.status, self.message)

    def get_directory(self):
        return self.p_this.getDirectory().c_str()


cdef class FtpListingResponse(FtpResponse):
    cdef sf.ftp.ListingResponse *p_this

    def __init__(self):
        raise NotImplementedError("Not meant to be instantiated")

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "FtpListingResponse(ok={0}, status={1}, message={2})".format(self.ok, self.status, self.message)

    property filenames:
        def __get__(self):
            cdef list r = []
            cdef vector[string]* filenames = <vector[string]*>&self.p_this.getListing()
            cdef vector[string].iterator filename = filenames.begin()
            cdef string temp
            while filename != filenames.end():
                temp = deref(filename)
                r.append(temp.c_str())
                inc(filename)

            return tuple(r)

cdef wrap_ftpresponse(sf.ftp.Response* p):
    cdef FtpResponse r = FtpResponse.__new__(FtpResponse)
    r.p_response = p
    return r


cdef wrap_ftpdirectoryresponse(sf.ftp.DirectoryResponse* p):
    cdef FtpDirectoryResponse r = FtpDirectoryResponse.__new__(FtpDirectoryResponse)
    r.p_this = p
    r.p_response = <sf.ftp.Response*>p
    return r


cdef wrap_ftplistingresponse(sf.ftp.ListingResponse* p):
    cdef FtpListingResponse r = FtpListingResponse.__new__(FtpListingResponse)
    r.p_this = p
    r.p_response = <sf.ftp.Response*>p
    return r

cdef class Ftp:
    BINARY = sf.ftp.Binary
    ASCII = sf.ftp.Ascii
    EBCDIC = sf.ftp.Ebcdic

    cdef sf.Ftp *p_this

    def __init__(self):
        self.p_this = new sf.Ftp()

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "Ftp()"

    def connect(self, IpAddress server, unsigned short port=21, Time timeout=None):
        cdef sf.ftp.Response* response = new sf.ftp.Response()

        if not timeout:
            with nogil: response[0] = self.p_this.connect(server.p_this[0], port)
        else:
            with nogil: response[0] = self.p_this.connect(server.p_this[0], port, timeout.p_this[0])

        return wrap_ftpresponse(response)

    def disconnect(self):
        cdef sf.ftp.Response* response = new sf.ftp.Response()
        response[0] = self.p_this.disconnect()
        return wrap_ftpresponse(response)

    def login(self, str name=None, str message=""):
        cdef sf.ftp.Response* response = new sf.ftp.Response()

        encoded_name_temporary = name.encode('UTF-8')
        encoded_message_temporary = message.encode('UTF-8')
        cdef char* encoded_name = encoded_name_temporary
        cdef char* encoded_message = encoded_message_temporary

        if not name:
            with nogil: response[0] = self.p_this.login()
        else:
            with nogil: response[0] = self.p_this.login(encoded_name, encoded_message)

        return wrap_ftpresponse(response)

    def keep_alive(self):
        cdef sf.ftp.Response* response = new sf.ftp.Response()

        with nogil:
            response[0] = self.p_this.keepAlive()

        return wrap_ftpresponse(response)

    def get_working_directory(self):
        # here Ftp::DirectoryResponse's constructors prevent us from
        # creating an empty object. We must cheat by passing an empty
        # Ftp::Reponse that we must destruct when the DirectoryResponse
        # is destroyed.
        cdef sf.ftp.Response* response = new sf.ftp.Response()
        cdef sf.ftp.DirectoryResponse* directory_response = new sf.ftp.DirectoryResponse(response[0])
        del response

        with nogil:
            directory_response[0] = self.p_this.getWorkingDirectory()

        return wrap_ftpdirectoryresponse(directory_response)

    def get_directory_listing(self, str directory=""):
        # here Ftp::ListingResponse's constructors prevent us from
        # creating an empty object. We must cheat by passing an empty
        # Ftp::Reponse and a false vector of char*. We must destruct
        # what we had allocated to cheat on when the ListingResponse
        # is destroyed.
        cdef sf.ftp.Response* response = new sf.ftp.Response()
        cdef sf.ftp.ListingResponse* listing_response = new sf.ftp.ListingResponse(response[0], "")
        del response

        encoded_directory_temporary = directory.encode('UTF-8')
        cdef char* encoded_directory = encoded_directory_temporary

        with nogil:
            listing_response[0] = self.p_this.getDirectoryListing(encoded_directory)

        return wrap_ftplistingresponse(listing_response)

    def change_directory(self, str directory):
        cdef sf.ftp.Response* response = new sf.ftp.Response()

        encoded_directory_temporary = directory.encode('UTF-8')
        cdef char* encoded_directory = encoded_directory_temporary

        with nogil:
            response[0] = self.p_this.changeDirectory(encoded_directory)

        return wrap_ftpresponse(response)

    def parent_directory(self):
        cdef sf.ftp.Response* response = new sf.ftp.Response()

        with nogil:
            response[0] = self.p_this.parentDirectory()

        return wrap_ftpresponse(response)

    def create_directory(self, str name):
        cdef sf.ftp.Response* response = new sf.ftp.Response()

        encoded_name_temporary = name.encode('UTF-8')
        cdef char* encoded_name = encoded_name_temporary

        with nogil:
            response[0] = self.p_this.createDirectory(encoded_name)

        return wrap_ftpresponse(response)

    def delete_directory(self, str name):
        cdef sf.ftp.Response* response = new sf.ftp.Response()

        encoded_name_temporary = name.encode('UTF-8')
        cdef char* encoded_name = encoded_name_temporary

        with nogil:
            response[0] = self.p_this.deleteDirectory(encoded_name)

        return wrap_ftpresponse(response)

    def rename_file(self, str filename, str newname):
        cdef sf.ftp.Response* response = new sf.ftp.Response()

        encoded_filename_temporary = filename.encode('UTF-8')
        encoded_newname_temporary = newname.encode('UTF-8')
        cdef char* encoded_filename = encoded_filename_temporary
        cdef char* encoded_newname = encoded_newname_temporary

        with nogil:
            response[0] = self.p_this.renameFile(encoded_filename, encoded_newname)

        return wrap_ftpresponse(response)

    def delete_file(self, str name):
        cdef sf.ftp.Response* response = new sf.ftp.Response()

        encoded_name_temporary = name.encode('UTF-8')
        cdef char* encoded_name = encoded_name_temporary

        with nogil:
            response[0] = self.p_this.deleteFile(encoded_name)

        return wrap_ftpresponse(response)

    def download(self, str remotefile, str localpath, sf.ftp.TransferMode mode=sf.ftp.Binary):
        cdef sf.ftp.Response* response = new sf.ftp.Response()

        encoded_remotefile_temporary = remotefile.encode('UTF-8')
        encoded_localpath_temporary = localpath.encode('UTF-8')
        cdef char* encoded_remotefile = encoded_remotefile_temporary
        cdef char* encoded_localpath = encoded_localpath_temporary

        with nogil:
            response[0] = self.p_this.download(encoded_remotefile, encoded_localpath, mode)

        return wrap_ftpresponse(response)

    def upload(self, str localfile, str remotepath, sf.ftp.TransferMode mode=sf.ftp.Binary):
        cdef sf.ftp.Response* response = new sf.ftp.Response()

        encoded_localfile_temporary = localfile.encode('UTF-8')
        encoded_remotepath_temporary = remotepath.encode('UTF-8')
        cdef char* encoded_localfile = encoded_localfile_temporary
        cdef char* encoded_remotepath = encoded_remotepath_temporary

        with nogil:
            response[0] = self.p_this.upload(encoded_localfile, encoded_remotepath, mode)

        return wrap_ftpresponse(response)


cdef class HttpRequest:
    GET = sf.http.request.Get
    POST = sf.http.request.Post
    HEAD = sf.http.request.Head

    cdef sf.http.Request *p_this

    def __init__(self, bytes uri=b"/", sf.http.request.Method method=sf.http.request.Get, bytes body=b""):
        self.p_this = new sf.http.Request(string(uri), method, string(body))

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "HttpRequest()"

    property field:
        def __set__(self, tuple v):
            cdef bytes field = v[0]
            cdef bytes value = v[1]
            self.p_this.setField(string(field), string(value))

    property method:
        def __set__(self, sf.http.request.Method method):
            self.p_this.setMethod(method)

    property uri:
        def __set__(self, bytes uri):
            self.p_this.setUri(string(uri))

    property http_version:
        def __set__(self, tuple value):
            cdef unsigned int major = value[0]
            cdef unsigned int minor = value[1]
            self.p_this.setHttpVersion(major, minor)

    property body:
        def __set__(self, bytes body):
            self.p_this.setBody(string(body))


cdef class HttpResponse:
    OK = sf.http.response.Ok
    CREATED = sf.http.response.Created
    ACCEPTED = sf.http.response.Accepted
    NO_CONTENT = sf.http.response.NoContent
    RESET_CONTENT = sf.http.response.ResetContent
    PARTIAL_CONTENT = sf.http.response.PartialContent
    MULTIPLE_CHOICES = sf.http.response.MultipleChoices
    MOVED_PERMANENTLY = sf.http.response.MovedPermanently
    MOVED_TEMPORARILY = sf.http.response.MovedTemporarily
    #NOT_MODIFIED = sf.http.response.NotModified
    #BAD_REQUEST = sf.http.response.BadRequest
    UNAUTHORIZED = sf.http.response.Unauthorized
    FORBIDDEN = sf.http.response.Forbidden
    NOT_FOUND = sf.http.response.NotFound
    RANGE_NOT_SATISFIABLE = sf.http.response.RangeNotSatisfiable
    INTERNAL_SERVER_ERROR = sf.http.response.InternalServerError
    NOT_IMPLEMENTED = sf.http.response.NotImplemented
    BAD_GATEWAY = sf.http.response.BadGateway
    SERVICE_NOT_AVAILABLE = sf.http.response.ServiceNotAvailable
    GATEWAY_TIMEOUT = sf.http.response.GatewayTimeout
    VERSION_NOT_SUPPORTED = sf.http.response.VersionNotSupported
    INVALID_RESPONSE = sf.http.response.InvalidResponse
    CONNECTION_FAILED = sf.http.response.ConnectionFailed

    cdef sf.http.Response *p_this

    def __init__(self):
        raise NotImplementedError("Not meant to be instantiated!")

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "HttpResponse()"

    def get_field(self, bytes field):
        return self.p_this.getField(string(field)).c_str()

    property status:
        def __get__(self):
            return self.p_this.getStatus()

    property major_http_version:
        def __get__(self):
            return self.p_this.getMajorHttpVersion()

    property minor_http_version:
        def __get__(self):
            return self.p_this.getMinorHttpVersion()

    property body:
        def __get__(self):
            return self.p_this.getBody().c_str()

cdef wrap_httpresponse(sf.http.Response *p):
    cdef HttpResponse r = HttpResponse.__new__(HttpResponse)
    r.p_this = p
    return r

cdef class Http:
    cdef sf.Http *p_this

    def __init__(self, bytes host, unsigned short port=0):
        self.p_this = new sf.Http(string(host), port)

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "Http()"

    def send_request(self, HttpRequest request, Time timeout=None):
        cdef sf.http.Response* p = new sf.http.Response()

        if not timeout:
            with nogil: p[0] = self.p_this.sendRequest(request.p_this[0])
        else:
            with nogil: p[0] = self.p_this.sendRequest(request.p_this[0], timeout.p_this[0])

        return wrap_httpresponse(p)
