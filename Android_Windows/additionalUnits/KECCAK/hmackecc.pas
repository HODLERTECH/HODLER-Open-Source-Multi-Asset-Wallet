unit hmackecc;

{HMAC-Keccak unit}


interface

(*************************************************************************

 DESCRIPTION     :  HMAC (hash message authentication) unit for Keccak

 REQUIREMENTS    :  TP5-7, D1-D7/D9-D12, FPC, VP, WDOSX

 EXTERNAL DATA   :  ---

 MEMORY USAGE    :  ---

 DISPLAY MODE    :  ---

 REFERENCES      :  - HMAC: Keyed-Hashing for Message Authentication
                      (http://tools.ietf.org/html/rfc2104)
                    - The Keyed-Hash Message Authentication Code (HMAC)
                      http://csrc.nist.gov/publications/fips/fips198/fips-198a.pdf
                    - US Secure Hash Algorithms (SHA and HMAC-SHA)
                      (http://tools.ietf.org/html/rfc4634)
                    - Keccak sponge function family main document, sections 4.2.3 and 4.2.1
                      http://keccak.noekeon.org/Keccak-main-2.1.pdf
                    - David Ireland's "Test vectors for HMAC-SHA-3" from
                      http://www.di-mgt.com.au/hmac_sha3_testvectors.html

 REMARKS         :  Provisional HMAC-Keccak routines (as for SHA3 there is no
                    official specification). Using D. Ireland's parameters, the
                    input block length used in the HMAC algorithm is state.rate.

 Version  Date      Author      Modification
 -------  --------  -------     ------------------------------------------
 0.01     09.11.12  W.Ehrhardt  Initial version
 0.02     10.11.12  we          Use context.Err
 0.03     11.11.12  we          BIT API
 0.04     13.11.12  we          removed context.DigLen
**************************************************************************)


(*-------------------------------------------------------------------------
 (C) Copyright 2012 Wolfgang Ehrhardt

 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising from
 the use of this software.

 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software in
    a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

 2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

 3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------*)

uses
  BTypes,keccak_n;

type
  THMACKec_Context = record
                       hashctx: THashState;
                       hmacbuf: array[0..143] of byte;
                       BlkLen : integer;
                       Err    : integer;
                     end;


procedure hmac_keccak_init(var ctx: THMACKec_Context; hashbitlen: integer; key: pointer; klen: word);
  {-Initialize HMAC context for Keccak with hashbitlen (224, 256, 384, or 512) }
  { and klen key bytes from and key^}

procedure hmac_keccak_inits(var ctx: THMACKec_Context; hashbitlen: integer; skey: Str255);
  {-Initialize HMAC context for Keccak with hashbitlen (224, 256, 384, or 512) and key from skey}

procedure hmac_keccak_update(var ctx: THMACKec_Context; data: pointer; dlen: word);
  {-HMAC data input, may be called more than once}

procedure hmac_keccak_updateXL(var ctx: THMACKec_Context; data: pointer; dlen: longint);
  {-HMAC data input, may be called more than once}

procedure hmac_keccak_final(var ctx: THMACKec_Context; var mac: TKeccakMaxDigest);
  {-End data input and calculate HMAC digest}

procedure hmac_keccak_finalbits(var ctx: THMACKec_Context; var mac: TKeccakMaxDigest; BData: byte; bitlen: integer);
  {-End data input with bitlen bits from BData and calculate HMAC digest}


implementation


{---------------------------------------------------------------------------}
procedure hmac_keccak_init(var ctx: THMACKec_Context; hashbitlen: integer; key: pointer; klen: word);
  {-Initialize HMAC context for Keccak with hashbitlen (224, 256, 384, or 512) }
  { and klen key bytes from and key^}
var
  k: integer;
begin
  fillchar(ctx, sizeof(ctx),0);
  with ctx do begin
    Err := Init(ctx.hashctx, hashbitlen);
    if Err<>0 then exit;
    BlkLen := hashctx.rate div 8;
    if klen > BlkLen then begin
      {Hash if key length > block length}
      Err := Update(ctx.hashctx, key, klen*8);
      if Err=0 then Err := Final(ctx.hashctx, @ctx.hmacbuf);
    end
    else move(key^, hmacbuf, klen);
    if Err=0 then begin
      {XOR with ipad}
      for k:=0 to BlkLen-1 do hmacbuf[k] := hmacbuf[k] xor $36;
      {start inner hash}
      Err := Init(hashctx, hashbitlen);
      if Err=0 then Err := Update(hashctx, @hmacbuf, BlkLen*8);
    end;
  end;
end;


{---------------------------------------------------------------------------}
procedure hmac_keccak_inits(var ctx: THMACKec_Context; hashbitlen: integer; skey: Str255);
  {-Initialize HMAC context for Keccak with hashbitlen (224, 256, 384, or 512) and key from skey}
begin
  hmac_keccak_init(ctx, hashbitlen, @skey[1], length(skey));
end;


{---------------------------------------------------------------------------}
procedure hmac_keccak_update(var ctx: THMACKec_Context; data: pointer; dlen: word);
  {-HMAC data input, may be called more than once}
begin
  with ctx do begin
    if Err=0 then Err := Update(hashctx, data, longint(dlen)*8);
  end;
end;


{---------------------------------------------------------------------------}
procedure hmac_keccak_updateXL(var ctx: THMACKec_Context; data: pointer; dlen: longint);
  {-HMAC data input, may be called more than once}
begin
  with ctx do begin
    if Err=0 then Err := Update(hashctx, data, longint(dlen)*8);
  end;
end;


{---------------------------------------------------------------------------}
procedure hmac_keccak_finalbits(var ctx: THMACKec_Context; var mac: TKeccakMaxDigest; BData: byte; bitlen: integer);
  {-End data input with bitlen bits from BData and calculate HMAC digest}
var
  i: integer;
begin
  with ctx do if Err=0 then begin
    {append the final bits from BData}
    if (bitlen>0) and (bitlen<=7) then Err := Update(hashctx, @BData, bitlen);
    {complete inner hash}
    if Err=0 then Err := Final(hashctx, @mac);
    {remove ipad from buf, XOR opad}
    if Err=0 then begin
      for i:=0 to ctx.BlkLen-1 do ctx.hmacbuf[i] := ctx.hmacbuf[i] xor ($36 xor $5c);
      {outer hash}
      i := hashctx.fixedOutputLength;
      Err := Init(hashctx, i);
      if Err=0 then Err := Update(hashctx, @hmacbuf, BlkLen*8);
      if Err=0 then Err := Update(hashctx, @mac, i);
      if Err=0 then Err := Final(hashctx, @mac);
    end;
  end;
end;


{---------------------------------------------------------------------------}
procedure hmac_keccak_final(var ctx: THMACKec_Context; var mac: TKeccakMaxDigest);
  {-End data input and calculate HMAC digest}
begin
  hmac_keccak_finalbits(ctx, mac, 0, 0);
end;

end.
