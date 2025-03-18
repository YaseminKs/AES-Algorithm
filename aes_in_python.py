# pip install pycryptodome

from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
import base64

# Function to pad plaintext to be a multiple of AES block size (16 bytes)
def pad( text ):
    padding_length = AES.block_size - len( text ) % AES.block_size
    return text + chr( padding_length ) * padding_length

# Function to remove padding after decryption
def unpad( text ):
    return text[:-ord( text[-1] )]

# AES Encrypt Function
def encrypt( plain_text, key ):
    key = key[:32]  # Ensure 256-bit key (32 bytes)
    iv = get_random_bytes( AES.block_size )  # 16-byte IV
    cipher = AES.new( key, AES.MODE_CBC, iv )
    encrypted_bytes = cipher.encrypt( pad( plain_text ).encode() )
    return base64.b64encode( iv + encrypted_bytes ).decode()  # Encode IV + ciphertext

# AES Decrypt Function
def decrypt( encrypted_text, key ):
    key = key[:32]  # Ensure 256-bit key (32 bytes)
    encrypted_bytes = base64.b64decode( encrypted_text )
    iv = encrypted_bytes[:AES.block_size]  # Extract IV
    cipher = AES.new( key, AES.MODE_CBC, iv )
    decrypted_text = cipher.decrypt( encrypted_bytes[AES.block_size:] ).decode()
    return unpad( decrypted_text )

# Example Usage
if __name__ == "__main__":
    secret_key = get_random_bytes( 32 )  # 256-bit key
    original_text = "Hello, AES Encryption!"

    encrypted_text = encrypt( original_text, secret_key )
    print( "Encrypted:", encrypted_text )

    decrypted_text = decrypt( encrypted_text, secret_key )
    print( "Decrypted:", decrypted_text )


# Encrypted: Rqzpm3bLr5s9IB1bveAlVnE0+d5AXl4gAF+zTKa0ZgM=
# Decrypted: Hello, AES Encryption!
