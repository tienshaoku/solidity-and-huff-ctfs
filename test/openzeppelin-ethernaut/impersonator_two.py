import ecdsa
import ecdsa.numbertheory as nt
import hashlib
from eth_keys import keys
from eth_utils import to_checksum_address

# source: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
# s1 = k^(-1)(z1 + r * da) mod n
# s2 = k^(-1)(z2 + r * da) mod n
# s1 - s2 = k^(-1)(z1 + r * da - (z2 + r * da)) mod n = k^(-1)(z1 - z2) mod n
# k = (z1 - z2) * (s1 - s2)^(-1) mod n
def recover_private_key(r, s1, s2, z1, z2, n):
    z_diff = (z1 - z2) % n
    s_diff = (s1 - s2) % n
    s_inv = nt.inverse_mod(s_diff, n)
    k = (z_diff * s_inv) % n

    # private_key = da = (s1 * k - z1) * r^(-1) mod n
    temp = (s1 * k - z1) % n
    r_inv = nt.inverse_mod(r, n)
    private_key = (temp * r_inv) % n

    return private_key

def private_key_to_address(private_key):
    private_key_bytes = private_key.to_bytes(32, 'big')

    # create private key object using eth-keys
    private_key_obj = keys.PrivateKey(private_key_bytes)
    
    address = private_key_obj.public_key.to_address()

    return to_checksum_address(address)

r = int("e5648161e95dbf2bfc687b72b745269fa906031e2108118050aba59524a23c40", 16)
s1 = int("70026fc30e4e02a15468de57155b080f405bd5b88af05412a9c3217e028537e3", 16)
s2 = int("4c3ac03b268ae1d2aca1201e8a936adf578a8b95a49986d54de87cd0ccb68a79", 16)
z1 = int("937fa99fb61f6cd81c00ddda80cc218c11c9a731d54ce8859cb2309c77b79bf3", 16)
z2 = int("6a0d6cd0c2ca5d901d94d52e8d9484e4452a3668ae20d63088909611a7dccc51", 16)
n = int("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", 16)

private_key = recover_private_key(r, s1, s2, z1, z2, n)
print(f"=== Recovered Private Key ===")
print(f"private_key = {hex(private_key)}")

print(f"\n=== Address verification ===")
expected_owner = "0x03E2cf81BBE61D1fD1421aFF98e8605a5A9e953a"
print(f"Expected owner: {expected_owner}")

recovered_address = private_key_to_address(private_key)
print(f"Recovered owner: {recovered_address}")

if recovered_address.lower() == expected_owner.lower():
    print("✅ Private key recovery successful!")
else:
    print("❌ Address verification failed! The recovered private key doesn't match the expected address.")