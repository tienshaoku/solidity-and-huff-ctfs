#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! k256 = "0.13.4"
//! crypto-bigint = "0.5.5"
//! sha3 = "0.10.8"
//! hex = "0.4.3"
//! rand = "0.8"
//! num-bigint = "0.4.6"
//! ```

use crypto_bigint::Encoding;
use hex;
use k256::{
    elliptic_curve::{
        sec1::{FromEncodedPoint, ToEncodedPoint},
        Curve, PrimeField,
    },
    AffinePoint, ProjectivePoint, Scalar,
};
use num_bigint::BigUint;
use sha3::{Digest, Keccak256};

// usually hashed message should look like keccak256(amount, receiver, salt),
// which we have no idea of the result of keccak256(amount, receiver, salt) for a certain amount
// but when the hashed message is just bytes32(amount), we can derive the signature for arbitrary amount

// Verification
// R = u1 × G + u2 × Q_A, with R: the point with x-coordinate r
// G: base point (fixed)
// Q_A: curve point (recovered)
// u1 = z * s^(-1) mod n, with z: message hash
// u2 = r * s^(-1) mod n
// n: curve order

// Forgery
// 1. choose random u1, u2, then set R = u1 × G + u2 × Q_A
//    (unlike verification where R is computed from signature, here we define R first)
// 2. derive r = x_coordinate(P) mod n
// 3. derive s = r * u2^(-1) mod n
// 4. derive z = r × u1 × u2^(-1) mod n

fn main() {
    let alice_address = "0xA11CE84AcB91Ac59B0A4E2945C9157eF3Ab17D4e";
    let r_hex = "ab1dcd2a2a1c697715a62eb6522b7999d04aa952ffa2619988737ee675d9494f";
    let s_hex = "2b50ecce40040bcb29b5a8ca1da875968085f22b7c0a50f29a4851396251de12";
    let v = 28;
    let voucher_hash_hex = "87f1c8cd4c0e19511304b612a9b4996f8c2bd795796636bd25812cd5b0b6a973";

    let r_scalar = scalar_from_hex(r_hex);
    let s_scalar = scalar_from_hex(s_hex);
    let voucher_hash = scalar_from_hex(voucher_hash_hex);

    // there're 2 possible r points on evm, 27 & 28
    let recovery_id = v - 27;
    // format: 1 byte prefix + 32 bytes x-coordinate
    let mut compressed = [0u8; 33];
    // 0x02 is the base prefix; prefix is either 0x02 or 0x03, for even and odd y-coordinate
    compressed[0] = 0x02 + recovery_id as u8;
    compressed[1..].copy_from_slice(&r_scalar.to_bytes());

    let encoded_r = k256::EncodedPoint::from_bytes(&compressed).unwrap();
    // r affine point on elliptic curve
    let r_affine = AffinePoint::from_encoded_point(&encoded_r).unwrap();
    // projection for faster elliptic curve operations
    let R = ProjectivePoint::from(r_affine);

    let z = voucher_hash;
    // base point
    let G = ProjectivePoint::GENERATOR;

    // u1 = -z * r^(-1) mod n
    let r_inv = r_scalar.invert().unwrap();
    let u1 = -z * r_inv;
    // u2 = s * r^(-1) mod n
    let u2 = s_scalar * r_inv;

    // curve point Q_A = u1 * G + u2 * R
    let Q_A = G * u1 + R * u2;

    let alice_pubkey = AffinePoint::from(Q_A);

    let derived_address = pubkey_to_address(&alice_pubkey);
    if !derived_address.eq_ignore_ascii_case(alice_address) {
        panic!(
            "Deriv address from pubkey {} doesn't match Alice's address {}",
            derived_address, alice_address
        );
    }

    let mut rng = rand::thread_rng();
    let n = BigUint::from_bytes_be(&k256::Secp256k1::ORDER.to_be_bytes());

    let u1 = Scalar::generate_biased(&mut rng);
    let u2 = Scalar::generate_biased(&mut rng);

    // R = u1 × G + u2 × Q_A (forged signature point)
    let R_forged = G * u1 + ProjectivePoint::from(alice_pubkey) * u2;
    let R_forged_affine = AffinePoint::from(R_forged);

    let R_forged_bytes = R_forged_affine.to_encoded_point(false);
    let R_forged_uncompressed = R_forged_bytes.as_bytes();
    // even or odd, which can derive v = 27 or 28
    let y_parity = R_forged_uncompressed[64] & 1;

    // r = x_coordinate(R_forged) mod n
    let r_forged = point_x_to_scalar(&R_forged_bytes, &n);

    let u2_inv = u2.invert().unwrap();

    // s = r × u2^(-1) mod n
    let s_forged = mod_mul(&r_forged, &u2_inv, &n);
    // z = r × u1 × u2^(-1) mod n
    let z_forged = mod_mul_three(&r_forged, &u1, &u2_inv, &n);

    let n_half = &n / 2u32;
    let s_biguint = scalar_to_biguint(&s_forged);

    let (s_final, v_final) = if s_biguint > n_half {
        let s_fixed_biguint = &n - &s_biguint;
        let s_fixed = biguint_to_scalar(&s_fixed_biguint);
        // using another s point means we have to flip y too
        (s_fixed, 1 - y_parity)
    } else {
        (s_forged, y_parity)
    };
    let v = v_final + 27;

    println!("Forged signature:");
    println!("  r: 0x{}", hex::encode(r_forged.to_bytes()));
    println!("  s: 0x{}", hex::encode(s_final.to_bytes()));
    println!("  v: {}", v);
    println!(
        "  amount (message hash): 0x{}",
        hex::encode(z_forged.to_bytes())
    );
}

fn scalar_from_hex(hex_str: &str) -> Scalar {
    let bytes_vec: Vec<u8> = hex::decode(hex_str).unwrap();
    let bytes: [u8; 32] = bytes_vec.try_into().unwrap();
    Scalar::from_repr_vartime(bytes.into()).unwrap()
}

fn pubkey_to_address(pubkey: &AffinePoint) -> String {
    // false for uncompressed pubkey format: 1 byte prefix 0x04 + 32 bytes x-coordinate + 32 bytes y-coordinate
    // ethereum address requires both x & y coordinates to compute Keccak256 hash
    let pubkey_uncompressed = pubkey.to_encoded_point(false);
    let pubkey_bytes = pubkey_uncompressed.as_bytes();

    let mut hasher = Keccak256::new();
    hasher.update(&pubkey_bytes[1..]);
    // 32 bytes Keccak256 hash output
    let hash = hasher.finalize();

    // evm address takes the last 20 bytes
    let address_bytes = &hash[12..32];
    format!("0x{}", hex::encode(address_bytes))
}

fn scalar_to_biguint(scalar: &Scalar) -> BigUint {
    BigUint::from_bytes_be(&scalar.to_bytes())
}

fn biguint_to_scalar(biguint: &BigUint) -> Scalar {
    let bytes = biguint_to_bytes32(biguint);
    Scalar::from_repr_vartime(bytes.into()).unwrap()
}

fn biguint_to_bytes32(biguint: &BigUint) -> [u8; 32] {
    let bytes = biguint.to_bytes_be();
    let mut result = [0u8; 32];
    let start = 32usize.saturating_sub(bytes.len());
    result[start..].copy_from_slice(&bytes);
    result
}

/// Extract x-coordinate from an encoded point and return as Scalar (mod n)
fn point_x_to_scalar(encoded_point: &k256::EncodedPoint, n: &BigUint) -> Scalar {
    let uncompressed = encoded_point.as_bytes();
    let x_bytes: [u8; 32] = uncompressed[1..33].try_into().unwrap();
    let x_biguint = BigUint::from_bytes_be(&x_bytes);
    let r_biguint = &x_biguint % n;
    biguint_to_scalar(&r_biguint)
}

/// Perform modular multiplication: (a * b) % n, returning Scalar
fn mod_mul(a: &Scalar, b: &Scalar, n: &BigUint) -> Scalar {
    let a_biguint = scalar_to_biguint(a);
    let b_biguint = scalar_to_biguint(b);
    let result_biguint = (&a_biguint * &b_biguint) % n;
    biguint_to_scalar(&result_biguint)
}

/// Perform modular multiplication: (a * b * c) % n, returning Scalar
fn mod_mul_three(a: &Scalar, b: &Scalar, c: &Scalar, n: &BigUint) -> Scalar {
    let a_biguint = scalar_to_biguint(a);
    let b_biguint = scalar_to_biguint(b);
    let c_biguint = scalar_to_biguint(c);
    let result_biguint = ((&a_biguint * &b_biguint) * &c_biguint) % n;
    biguint_to_scalar(&result_biguint)
}
