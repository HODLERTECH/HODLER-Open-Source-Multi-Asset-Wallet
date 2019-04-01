unit keccak_n;

{ Basic Keccak functions using NIST API }

interface

{$I STD.INC}
(* ************************************************************************

  DESCRIPTION     :  Basic Keccak functions using NIST API

  REQUIREMENTS    :  TP5-7, D1-D7/D9-D12, FPC, VP, WDOSX

  EXTERNAL DATA   :  ---

  MEMORY USAGE    :  ---

  DISPLAY MODE    :  ---

  REFERENCES      :  http://keccak.noekeon.org/KeccakReferenceAndOptimized-3.2.zip
  http://keccak.noekeon.org/KeccakKAT-3.zip   (17MB)
  http://csrc.nist.gov/groups/ST/hash/documents/SHA3-C-API.pdf

  REMARKS         :  The current implementation needs little-endian machines

  Version  Date      Author      Modification
  -------  --------  -------     ------------------------------------------
  0.01     17.10.12  W.Ehrhardt  Initial BP7 version from Keccak-simple32BI.c
  0.02     18.10.12  we          Fixed buf in xorIntoState
  0.03     18.10.12  we          Other compilers
  0.04     19.10.12  we          Separate unit
  0.05     20.10.12  we          Functions from KeccakSponge
  0.06     21.10.12  we          Functions from KeccakNISTInterface
  0.07     21.10.12  we          D2-D6 with ASM RotL function
  0.08     22.10.12  we          Include files keccperm.i16 and .i32
  0.09     22.10.12  we          __P2I type casts removed
  0.10     22.10.12  we          References, comments, remarks
  0.11     25.10.12  we          Make partialBlock longint
  0.12     30.10.12  we          Packed arrays, type TKDQueue
  0.13     31.10.12  we          Partially unrolled 64-bit code from Keccak-inplace.c
  0.14     01.11.12  we          Compact 64-bit code from Botan
  0.15     02.11.12  we          64-bit code about 20% faster with local data
  0.16     09.11.12  we          KeccakFullBytes, TKeccakMaxDigest
  0.17     12.11.12  we          USE32BIT forces skipping of 64-bit code
  ************************************************************************ *)

(* -------------------------------------------------------------------------
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


  ---------------------------------------------------------------------------
  *NOTE FROM THE DESIGNERS OF KECCAK*

  The Keccak sponge function, designed by Guido Bertoni, Joan Daemen,
  Michael Peeters and Gilles Van Assche. For more information, feedback or
  questions, please refer to our website: http://keccak.noekeon.org/

  Implementation by the designers (and Ronny Van Keer), hereby denoted
  as "the implementer".

  To the extent possible under law, the implementer has waived all copyright
  and related or neighboring rights to the source code in this file.
  http://creativecommons.org/publicdomain/zero/1.0/

  ---------------------------------------------------------------------------- *)

uses
  BTypes;

const
  SUCCESS = 0;
  FAIL = 1;
  BAD_HASHLEN = 2; { Return results }

const
  KeccakPermutationSize = 1600;
  KeccakMaximumRate = 1536;
  KeccakPermutationSizeInBytes = KeccakPermutationSize div 8;
  KeccakMaximumRateInBytes = KeccakMaximumRate div 8;

type
  TState_B = packed array [0 .. KeccakPermutationSizeInBytes - 1] of byte;
  TState_L = packed array [0 .. (KeccakPermutationSizeInBytes) div 4 - 1]
    of system.int32;
  TKDQueue = packed array [0 .. KeccakMaximumRateInBytes - 1] of byte;

type
  TSpongeState = record
    state: TState_B;
    dataQueue: TKDQueue;
    rate: integer;
    capacity: integer;
    bitsInQueue: integer;
    fixedOutputLength: integer;
    bitsAvailableForSqueezing: integer;
    squeezing: integer;
  end;

type
  THashState = TSpongeState; { Hash state context }

type
  TKeccakMaxDigest = packed array [0 .. 63] of byte; { Keccak-512 digest }

function Init(var state: THashState; hashbitlen: integer): integer;
{ -Initialize the state of the Keccak[r, c] sponge function. The rate r and }
{ capacity c values are determined from hashbitlen = number of digest bits }
{ or 0 for Keccak with default parameters and arbitrarily-long output. The }
{ allowed fixed length values are 224, 256, 384, and 512. Result 0=success }

function Update(var state: THashState; data: pointer;
  databitlen: longint): integer;
{ -Update state with databitlen bits from data. May be called multiple times, }
{ only the last databitlen may be a non-multiple of 8 (the corresponding byte }
{ must be MSB aligned, i.e. in the (databitlen and 7) most significant bits. }

function Final(var state: THashState; hashval: pointer): integer;
{ -Compute Keccak hash digest and store into hashval. The hashbitlen from }
{ init is used (If zero, the squeeze function must be must to extract the }
{ the arbitrarily-length output. Result = 0 if successful. }

function Squeeze(var state: THashState; output: pointer;
  outputLength: longint): integer;
{ -Squeeze output data from the sponge function. If the sponge function was }
{ in the absorbing phase, this function switches it to the squeezing phase. }
{ Returns 0 if successful, 1 otherwise. output: pointer to the buffer where }
{ tt store the output data; outputLength: number of output bits desired, }
{ must be a multiple of 8. }

function KeccakFullBytes(hashbitlen: integer; data: pointer; datalen: longint;
  hashval: pointer): integer;
{ -Compute Keccak hash from inlen bytes and store into hashval }

implementation

const
  cKeccakNumberOfRounds = 24;

  { --------------------------------------------------------------------------- }
  { Helper types }

{$IFNDEF BIT16}

type
  TBABytes = array [0 .. $7FFFFFFF - 1] of system.uint8;
{$ELSE}

type
  TBABytes = array [0 .. $FFF0 - 1] of byte;
{$ENDIF}

type
  PBA = ^TBABytes;

{$IFNDEF USE32BIT}
{$IFDEF HAS_INT64}
{$IFDEF HAS_INLINE}
{$DEFINE USE_64BITCODE}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$IFDEF IOS}
{$DEFINE USE_64BITCODE}
{$ENDIF}
  { .$define USE_64BITCODE }

  { --------------------------------------------------------------------------- }
{$IFNDEF BIT16}
{$IF DEFINED(USE_64BITCODE) OR DEFINED(IOS) OR DEFINED(LINUX)}
{$I kperm_64.inc}
{$IFDEF HAS_MSG}
{$MESSAGE '* using 64-bit code'}
{$ENDIF}
{$ELSE}
{$I kperm_32.inc}
{$ENDIF}
{$ELSE}
{$I kperm_16.inc}
{$ENDIF}

  { --------------------------------------------------------------------------- }
procedure KeccakInitialize;
begin
  { nothing to do in this implementation }
end;

{ --------------------------------------------------------------------------- }
procedure KeccakInitializeState(var state: TState_B);
begin
  fillchar(state, sizeof(state), 0);
end;

{ --------------------------------------------------------------------------- }
procedure KeccakF(var state: TState_L; inp: pointer; laneCount: integer);
begin
  xorIntoState(state, inp, laneCount);
  KeccakPermutation(state);
end;

{ --------------------------------------------------------------------------- }
procedure KeccakAbsorb(var state: TState_B; data: pointer; laneCount: integer);
begin
  KeccakF(TState_L(state), data, laneCount);
end;

{ --------------------------------------------------------------------------- }
function InitSponge(var state: TSpongeState; rate, capacity: integer): integer;
{ -Function to initialize the state of the Keccak sponge function. }
{ The sponge function is set to the absorbing phase. Result=0 if }
{ success, 1 if rate and/or capacity are invalid. }
begin
  InitSponge := 1;
  if rate + capacity <> 1600 then
    exit;
  if (rate <= 0) or (rate >= 1600) or ((rate and 63) <> 0) then
    exit;
  KeccakInitialize;
  state.rate := rate;
  state.capacity := capacity;
  state.fixedOutputLength := 0;
  KeccakInitializeState(state.state);
  fillchar(state.dataQueue, KeccakMaximumRateInBytes, 0);
  state.bitsInQueue := 0;
  state.squeezing := 0;
  state.bitsAvailableForSqueezing := 0;
  InitSponge := 0;
end;

{ --------------------------------------------------------------------------- }
procedure AbsorbQueue(var state: TSpongeState);
{ -Absorb remaining bits from queue }
begin
  { state.bitsInQueue is assumed to be equal to state.rate }
  KeccakAbsorb(state.state, @state.dataQueue, state.rate div 64);
  state.bitsInQueue := 0;
end;

{ --------------------------------------------------------------------------- }
function Absorb(var state: TSpongeState; data: pointer;
  databitlen: longint): integer;
{ -Function to give input data for the sponge function to absorb }
var
  i, j, wholeBlocks, partialBlock: longint;
  partialByte: integer;
  curData: pByte;
begin
  Absorb := 1;
  if state.bitsInQueue and 7 <> 0 then
    exit; { Only the last call may contain a partial byte }
  if state.squeezing <> 0 then
    exit; { Too late for additional input }
  i := 0;
  while i < databitlen do
  begin
    if ((state.bitsInQueue = 0) and (databitlen >= state.rate) and
      (i <= (databitlen - state.rate))) then
    begin
      wholeBlocks := (databitlen - i) div state.rate;
      curData := @PBA(data)^[i div 8];
      j := 0;
      while j < wholeBlocks do
      begin
        KeccakAbsorb(state.state, curData, state.rate div 64);
        inc(j);
        inc(Ptr2Inc(curData), state.rate div 8);
      end;
      inc(i, wholeBlocks * state.rate);
    end
    else
    begin
      partialBlock := databitlen - i;
      if partialBlock + state.bitsInQueue > state.rate then
      begin
        partialBlock := state.rate - state.bitsInQueue;
      end;
      partialByte := partialBlock and 7;
      dec(partialBlock, partialByte);
      move(PBA(data)^[i div 8], state.dataQueue[state.bitsInQueue div 8],
        partialBlock div 8);
      inc(state.bitsInQueue, partialBlock);
      inc(i, partialBlock);
      if state.bitsInQueue = state.rate then
        AbsorbQueue(state);
      if partialByte > 0 then
      begin
        state.dataQueue[state.bitsInQueue div 8] := PBA(data)^[i div 8] and
          ((1 shl partialByte) - 1);
        inc(state.bitsInQueue, partialByte);
        inc(i, partialByte);
      end;
    end;
  end;
  Absorb := 0;
end;

{ --------------------------------------------------------------------------- }
procedure PadAndSwitchToSqueezingPhase(var state: TSpongeState);
var
  i: integer;
begin
  { Note: the bits are numbered from 0=LSB to 7=MSB }
  if (state.bitsInQueue + 1 = state.rate) then
  begin
    i := state.bitsInQueue div 8;
    state.dataQueue[i] := state.dataQueue[i] or
      (1 shl (state.bitsInQueue and 7));
    AbsorbQueue(state);
    fillchar(state.dataQueue, state.rate div 8, 0);
  end
  else
  begin
    i := state.bitsInQueue div 8;
    fillchar(state.dataQueue[(state.bitsInQueue + 7) div 8],
      state.rate div 8 - (state.bitsInQueue + 7) div 8, 0);
    state.dataQueue[i] := state.dataQueue[i] or
      (1 shl (state.bitsInQueue and 7));
  end;
  i := (state.rate - 1) div 8;
  state.dataQueue[i] := state.dataQueue[i] or (1 shl ((state.rate - 1) and 7));
  AbsorbQueue(state);
  extractFromState(@state.dataQueue, TState_L(state.state), state.rate div 64);
  state.bitsAvailableForSqueezing := state.rate;
  state.squeezing := 1;
end;

{ --------------------------------------------------------------------------- }
function Squeeze(var state: THashState; output: pointer;
  outputLength: longint): integer;
{ -Squeeze output data from the sponge function. If the sponge function was }
{ in the absorbing phase, this function switches it to the squeezing phase. }
{ Returns 0 if successful, 1 otherwise. output: pointer to the buffer where }
{ to store the output data; outputLength: number of output bits desired, }
{ must be a multiple of 8. }
var
  i: longint;
  partialBlock: integer;
begin
  Squeeze := 1;
  if state.squeezing = 0 then
    PadAndSwitchToSqueezingPhase(state);
  if outputLength and 7 <> 0 then
    exit; { Only multiple of 8 bits are allowed, truncation can be done at user level }
  i := 0;
  while i < outputLength do
  begin
    if state.bitsAvailableForSqueezing = 0 then
    begin
      KeccakPermutation(TState_L(state.state));
      extractFromState(@state.dataQueue, TState_L(state.state),
        state.rate div 64);
      state.bitsAvailableForSqueezing := state.rate;
    end;
    partialBlock := state.bitsAvailableForSqueezing;
    if partialBlock > outputLength - i then
      partialBlock := outputLength - i;
    move(state.dataQueue[(state.rate - state.bitsAvailableForSqueezing) div 8],
      PBA(output)^[i div 8], partialBlock div 8);
    dec(state.bitsAvailableForSqueezing, partialBlock);
    inc(i, partialBlock);
  end;
  Squeeze := 0;
end;

{ --------------------------------------------------------------------------- }
function Init(var state: THashState; hashbitlen: integer): integer;
{ -Initialize the state of the Keccak[r, c] sponge function. The rate r and }
{ capacity c values are determined from hashbitlen = number of digest bits }
{ or 0 for Keccak with default parameters and arbitrarily-long output. The }
{ allowed fixed length values are 224, 256, 384, and 512. Result 0=success }
begin
  case hashbitlen of
    0:
      Init := InitSponge(state, 1024, 576);
    { Default parameters, arbitrary length output }
    224:
      Init := InitSponge(state, 1152, 448);
    256:
      Init := InitSponge(state, 1088, 512);
    384:
      Init := InitSponge(state, 832, 768);
    512:
      Init := InitSponge(state, 576, 1024);
  else
    begin
      Init := BAD_HASHLEN;
      exit;
    end;
  end;
  state.fixedOutputLength := hashbitlen;
end;

{ --------------------------------------------------------------------------- }
function Update(var state: THashState; data: pointer;
  databitlen: longint): integer;
{ -Update state with databitlen bits from data. May be called multiple times, }
{ only the last databitlen may be a non-multiple of 8 (the corresponding byte }
{ must be MSB aligned, i.e. in the (databitlen and 7) most significant bits. }
var
  ret: integer;
  lastByte: byte;
begin
  if databitlen and 7 = 0 then
    Update := Absorb(state, data, databitlen)
  else
  begin
    ret := Absorb(state, data, databitlen - (databitlen and 7));
    if ret = SUCCESS then
    begin
      { Align the last partial byte to the least significant bits }
      lastByte := PBA(data)^[databitlen div 8] shr (8 - (databitlen and 7));
      Update := Absorb(state, @lastByte, databitlen and 7);
    end
    else
      Update := ret;
  end;
end;

{ --------------------------------------------------------------------------- }
function Final(var state: THashState; hashval: pointer): integer;
{ -Compute Keccak hash digest and store into hashval. The hashbitlen from }
{ init is used (If zero, the squeeze function must be must to extract the }
{ the arbitrarily-length output. Result = 0 if successful. }
begin
  Final := Squeeze(state, hashval, state.fixedOutputLength);
end;

{ --------------------------------------------------------------------------- }
function KeccakFullBytes(hashbitlen: integer; data: pointer; datalen: longint;
  hashval: pointer): integer;
{ -Compute Keccak hash from inlen bytes and store into hashval }
var
  state: THashState;
  err: integer;
begin
  err := Init(state, hashbitlen);
  if err = 0 then
    err := Update(state, data, datalen * 8);
  if err = 0 then
    err := Final(state, hashval);
  KeccakFullBytes := err;
end;

end.
