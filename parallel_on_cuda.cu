#include <iostream>
#include <vector>
#include <cuda_runtime.h>
#include <openssl/aes.h>

#define BLOCK_SIZE 16

__global__ void AES_encrypt_cuda( unsigned char *d_plaintext, unsigned char *d_ciphertext, AES_KEY *d_enc_key, int num_blocks ){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if( idx < num_blocks ){
        AES_encrypt( &d_plaintext[idx * BLOCK_SIZE], &d_ciphertext[idx * BLOCK_SIZE], d_enc_key );
    }
}

void AES_encrypt_parallel( const std::vector<unsigned char> &plaintext, std::vector<unsigned char> &ciphertext, const AES_KEY &enc_key ){
    int num_blocks = plaintext.size() / BLOCK_SIZE;
    ciphertext.resize( plaintext.size() );
    
    unsigned char *d_plaintext, *d_ciphertext;
    AES_KEY *d_enc_key;
    
    cudaMalloc( &d_plaintext, plaintext.size() );
    cudaMalloc( &d_ciphertext, ciphertext.size() );
    cudaMalloc( &d_enc_key, sizeof( AES_KEY ) );
    
    cudaMemcpy( d_plaintext, plaintext.data(), plaintext.size(), cudaMemcpyHostToDevice );
    cudaMemcpy( d_enc_key, &enc_key, sizeof( AES_KEY ), cudaMemcpyHostToDevice );
    
    int threadsPerBlock = 256;
    int blocksPerGrid = ( num_blocks + threadsPerBlock - 1 ) / threadsPerBlock;
    AES_encrypt_cuda<<<blocksPerGrid, threadsPerBlock>>>(d_plaintext, d_ciphertext, d_enc_key, num_blocks);
    
    cudaMemcpy( ciphertext.data(), d_ciphertext, ciphertext.size(), cudaMemcpyDeviceToHost );
    
    cudaFree( d_plaintext );
    cudaFree( d_ciphertext );
    cudaFree( d_enc_key );
}

int main(){
    const unsigned char key[BLOCK_SIZE] = "0123456789abcdef";
    const unsigned char plaintext[] = "This is a secret message that needs encryption.";
    
    int padded_size = ( ( sizeof( plaintext ) + BLOCK_SIZE - 1 ) / BLOCK_SIZE ) * BLOCK_SIZE;
    std::vector<unsigned char> padded_plaintext( padded_size, 0 );
    memcpy( padded_plaintext.data(), plaintext, sizeof( plaintext ) );
    
    AES_KEY enc_key;
    AES_set_encrypt_key( key, 128, &enc_key );
    
    std::vector<unsigned char> ciphertext;
    AES_encrypt_parallel( padded_plaintext, ciphertext, enc_key );
    
    std::cout << "Encryption complete." << std::endl;
    return 0;
}
