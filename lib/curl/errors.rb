module Curl
  module Err
    class CurlError < RuntimeError
    end

    class FTPError < CurlError
    end

    class HTTPError < CurlError
    end

    class FileError < CurlError
    end

    class LDAPError < CurlError
    end

    class TelnetError < CurlError
    end

    class TFTPError < CurlError
    end

    class CurlOK < CurlError
    end

    class UnsupportedProtocolError < CurlError
    end

    class FailedInitError < CurlError
    end

    class MalformedURLError < CurlError
    end

    class NotBuiltInError < CurlError
    end

    class MalformedURLUserError < CurlError
    end

    class ProxyResolutionError < CurlError
    end

    class HostResolutionError < CurlError
    end

    class ConnectionFailedError < CurlError
    end

    class WeirdReplyError < FTPError
    end

    class AccessDeniedError < FTPError
    end

    class BadPasswordError < FTPError
    end

    class WeirdPassReplyError < FTPError
    end

    class WeirdUserReplyError < FTPError
    end

    class WeirdPasvReplyError < FTPError
    end

    class Weird227FormatError < FTPError
    end

    class CantGetHostError < FTPError
    end

    class CantReconnectError < FTPError
    end

    class CouldntSetBinaryError < FTPError
    end

    class PartialFileError < CurlError
    end

    class CouldntRetrFileError < FTPError
    end

    class FTPWriteError < FTPError
    end

    class FTPQuoteError < FTPError
    end

    class HTTPFailedError < HTTPError
    end

    class WriteError < CurlError
    end

    class MalformedUserError < CurlError
    end

    class CouldntStorFileError < FTPError
    end

    class ReadError < CurlError
    end

    class OutOfMemoryError < CurlError
    end

    class TimeoutError < CurlError
    end

    class CouldntSetASCIIError < FTPError
    end

    class PortFailedError < FTPError
    end

    class CouldntUseRestError < FTPError
    end

    class CouldntGetSizeError < FTPError
    end

    class HTTPRangeError < HTTPError
    end

    class HTTPPostError < HTTPError
    end

    class SSLConnectError < CurlError
    end

    class BadResumeError < CurlError
    end

    class CouldntReadError < FileError
    end

    class CouldntBindError < LDAPError
    end

    class SearchFailedError < LDAPError
    end

    class LibraryNotFoundError < CurlError
    end

    class FunctionNotFoundError < CurlError
    end

    class AbortedByCallbackError < CurlError
    end

    class BadFunctionArgumentError < CurlError
    end

    class BadCallingOrderError < CurlError
    end

    class InterfaceFailedError < CurlError
    end

    class BadPasswordEnteredError < CurlError
    end

    class TooManyRedirectsError < CurlError
    end

    class UnknownOptionError < TelnetError
    end

    class BadOptionSyntaxError < TelnetError
    end

    class ObsoleteError < CurlError
    end

    class SSLPeerCertificateError < CurlError
    end

    class GotNothingError < CurlError
    end

    class SSLEngineNotFoundError < CurlError
    end

    class SSLEngineSetFailedError < CurlError
    end

    class SendError < CurlError
    end

    class RecvError < CurlError
    end

    class ShareInUseError < CurlError
    end

    class ConvFailed < CurlError
    end

    class ConvReqd < CurlError
    end

    class RemoteFileNotFound < CurlError
    end

    class Again < CurlError
    end

    class SSLCertificateError < CurlError
    end

    class SSLCipherError < CurlError
    end

    class SSLCACertificateError < CurlError
    end

    class BadContentEncodingError < CurlError
    end

    class SSLCacertBadFile < CurlError
    end

    class SSLCRLBadFile < CurlError
    end

    class SSLIssuerError < CurlError
    end

    class SSLShutdownFailed < CurlError
    end

    class SSHError < CurlError
    end

    class MultiInitError < CurlError
    end

    class MultiPerform < CurlError
    end

    class MultiBadHandle < CurlError
    end

    class MultiBadEasyHandle < CurlError
    end

    class MultiOutOfMemory < CurlError
    end

    class MultiInternalError < CurlError
    end

    class MultiBadSocket < CurlError
    end

    class MultiAddedAlready < CurlError
    end

    class MultiUnknownOption < CurlError
    end

    class InvalidLDAPURLError < LDAPError
    end

    class FileSizeExceededError < CurlError
    end

    class FTPSSLFailed < FTPError
    end

    class SendFailedRewind < CurlError
    end

    class SSLEngineInitFailedError < CurlError
    end

    class LoginDeniedError < CurlError
    end

    class NotFoundError < TFTPError
    end

    class PermissionError < TFTPError
    end

    class DiskFullError < TFTPError
    end

    class IllegalOperationError < TFTPError
    end

    class UnknownIDError < TFTPError
    end

    class FileExistsError < TFTPError
    end

    class NoSuchUserError < TFTPError
    end

    class InvalidPostFieldError < CurlError
    end

    class UnknownError < CurlError
    end    

    # misspellings/non-comforming retained for compatibility
    #
    # rescue will still work the same with these.
    SSLCaertBadFile = SSLCacertBadFile
    SSLCRLBadfile = SSLCRLBadFile
    SSLCypherError = SSLCipherError
    SSH = SSHError

    EASY_ERROR_MAP = [
      CurlOK,                           #0
      UnsupportedProtocolError,         #1
      FailedInitError,                  #2
      MalformedURLError,                #3
      NotBuiltInError,                  #4
      ProxyResolutionError,             #5
      HostResolutionError,              #6
      ConnectionFailedError,            #7
      WeirdReplyError,                  #8
      AccessDeniedError,                #9
      BadPasswordError,                 #10
      WeirdPassReplyError,              #11
      WeirdUserReplyError,              #12
      WeirdPasvReplyError,              #13
      Weird227FormatError,              #14
      CantGetHostError,                 #15
      CantReconnectError,               #16
      CouldntSetBinaryError,            #17
      PartialFileError,                 #18
      CouldntRetrFileError,             #19
      FTPWriteError,                    #20
      FTPQuoteError,                    #21
      HTTPFailedError,                  #22
      WriteError,                       #23
      MalformedUserError,               #24
      CouldntStorFileError,             #25
      ReadError,                        #26
      OutOfMemoryError,                 #27
      TimeoutError,                     #28
      CouldntSetASCIIError,             #29
      PortFailedError,                  #30
      CouldntUseRestError,              #31
      CouldntGetSizeError,              #32
      HTTPRangeError,                   #33
      HTTPPostError,                    #34
      SSLConnectError,                  #35
      BadResumeError,                   #36
      CouldntReadError,                 #37
      CouldntBindError,                 #38
      SearchFailedError,                #39
      LibraryNotFoundError,             #40
      FunctionNotFoundError,            #41
      AbortedByCallbackError,           #42
      BadFunctionArgumentError,         #43
      BadCallingOrderError,             #44
      InterfaceFailedError,             #45
      BadPasswordEnteredError,          #46
      TooManyRedirectsError,            #47
      UnknownOptionError,               #48
      BadOptionSyntaxError,             #49
      ObsoleteError,                    #50
      SSLPeerCertificateError,          #51
      GotNothingError,                  #52
      SSLEngineNotFoundError,           #53
      SSLEngineSetFailedError,          #54
      SendError,                        #55
      RecvError,                        #56
      ShareInUseError,                  #57
      SSLCertificateError,              #58
      SSLCipherError,                   #59
      SSLCACertificateError,            #60
      BadContentEncodingError,          #61
      InvalidLDAPURLError,              #62
      FileSizeExceededError,            #63
      FTPSSLFailed,                     #64
      SendFailedRewind,                 #65
      SSLEngineInitFailedError,         #66
      LoginDeniedError,                 #67
      NotFoundError,                    #68
      PermissionError,                  #69
      DiskFullError,                    #70
      IllegalOperationError,            #71
      UnknownIDError,                   #72
      FileExistsError,                  #73
      NotFoundError,                    #74
      ConvFailed,                       #75
      ConvReqd,                         #76
      SSLCacertBadFile,                 #77
      RemoteFileNotFound,               #78
      SSHError,                         #79
      SSLShutdownFailed,                #80
      Again,                            #81
      SSLCRLBadfile,                    #82
      SSLIssuerError,                   #83
    ]

    # TODO don't think we'll ever need -1 as an error,
    # so this could probably be an array...
    MULTI_ERROR_MAP = {
      -1 => MultiPerform,
      1  => MultiBadHandle,
      2  => MultiBadEasyHandle,
      3  => OutOfMemoryError,
      4  => MultiInternalError,
      5  => MultiBadSocket,
      6  => UnknownOptionError,
      7  => MultiAddedAlready,
    }
  end
end

