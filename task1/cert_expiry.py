import ssl
import socket
from datetime import datetime

def get_ssl_expiry(url):
    try:
        host = url.replace('https://', '').replace('http://', '').split('/')[0]

        # Connect to the host and request its SSL certificate
        context = ssl.create_default_context()
        with socket.create_connection((host, 443), timeout=10) as sock:  
            with context.wrap_socket(sock, server_hostname=host) as ssock:
                cert = ssock.getpeercert()

        # Extract the 'notAfter' and 'notBefore' fields from the certificate
        not_before = datetime.strptime(cert['notBefore'], '%b %d %H:%M:%S %Y GMT')
        not_after = datetime.strptime(cert['notAfter'], '%b %d %H:%M:%S %Y GMT')

        return not_before, not_after

    except socket.timeout:
        raise Exception("Connection timed out while attempting to connect to the host")
    except socket.gaierror:
        raise Exception("Failed to get address info for the host")
    except ssl.CertificateError:
        raise Exception("Certificate validation error")
    except ssl.SSLError as e:
        raise Exception(f"SSL error occurred: {e}")
    except Exception as e:
        raise Exception(f"An unexpected error occurred: {e}")
    

if __name__ == '__main__':
    not_before, not_after = get_ssl_expiry('https://example.com')
    print("Valid from:", not_before)
    print("Valid until:", not_after)

