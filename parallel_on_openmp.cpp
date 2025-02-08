#include <iostream>
#include <vector>
#include <omp.h>
#include <openssl/aes.h>
#include <cstring>

using namespace std;

void AES_encrypt_parallel( const vector<unsigned char> &plaintext, vector<unsigned char> &ciphertext, const AES_KEY &enc_key, int num_threads ){
    int num_blocks = plaintext.size() / AES_BLOCK_SIZE;
    ciphertext.resize( plaintext.size() );
    
    #pragma omp parallel for num_threads( num_threads )
    for( int i = 0 ; i < num_blocks ; i++ ){
        AES_encrypt( &plaintext[i * AES_BLOCK_SIZE], &ciphertext[i * AES_BLOCK_SIZE], &enc_key );
    }
}

void AES_decrypt_parallel( const vector<unsigned char> &ciphertext, vector<unsigned char> &decryptedtext, const AES_KEY &dec_key, int num_threads ){
    int num_blocks = ciphertext.size() / AES_BLOCK_SIZE;
    decryptedtext.resize( ciphertext.size() );
    
    #pragma omp parallel for num_threads( num_threads )
    for( int i = 0 ; i < num_blocks ; i++ ){
        AES_decrypt( &ciphertext[i * AES_BLOCK_SIZE], &decryptedtext[i * AES_BLOCK_SIZE], &dec_key );
    }
}

int main() {
    const unsigned char key[AES_BLOCK_SIZE] = "0123456789abcdef";
    const unsigned char plaintext[] = "This is a secret message that needs encryption.";
    int num_threads = 4;
    
    int padded_size = ( ( sizeof( plaintext ) + AES_BLOCK_SIZE - 1 ) / AES_BLOCK_SIZE ) * AES_BLOCK_SIZE;
    vector<unsigned char> padded_plaintext( padded_size, 0 );
    memcpy( padded_plaintext.data(), plaintext, sizeof( plaintext ) );
    
    AES_KEY enc_key, dec_key;
    AES_set_encrypt_key( key, 128, &enc_key );
    AES_set_decrypt_key( key, 128, &dec_key );
    
    vector<unsigned char> ciphertext, decryptedtext;
    AES_encrypt_parallel( padded_plaintext, ciphertext, enc_key, num_threads );
    AES_decrypt_parallel( ciphertext, decryptedtext, dec_key, num_threads );
    
    cout << "Decrypted text: " << string( decryptedtext.begin(), decryptedtext.end() ) << endl;
    return 0;
}
