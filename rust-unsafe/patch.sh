#!/usr/bin/env bash
# Move the vendored unsafe-checker rules from Rust 2021 to Rust 2024 syntax.
#
# Usage: patch.sh <references-dir>
#   <references-dir> holds the 47 rule files copied byte for byte from
#   actionbook/rust-skills skills/unsafe-checker/rules/ (names ffi-*, general-*,
#   io-*, mem-*, ptr-*, safety-*, union-*).
#
# Run it exactly once on a fresh copy. Each patch states how many times its anchor
# must occur across the tree (or in one named file). Before anything is written,
# every count must match and no inserted text may already be present; otherwise
# the script exits 1 naming the patch, and no file is changed. A second run on a
# patched tree therefore fails on the first patch, which the first run consumed.
#
# What changes and why (Rust 2024 edition):
#   1. `extern "C" {`         -> `unsafe extern "C" {`      extern blocks must be unsafe
#   2. `#[no_mangle]`         -> `#[unsafe(no_mangle)]`     unsafe attributes
#   3. `.gen()` on rand::Rng  -> `rand::rng().random()`     `gen` is a reserved keyword
#   4. unsafe operations inside `unsafe fn` bodies get an explicit `unsafe { }`
#      block with a SAFETY comment                          unsafe_op_in_unsafe_fn
set -euo pipefail

if [ "$#" -ne 1 ] || [ ! -d "$1" ]; then
  echo "usage: $0 <references-dir>" >&2
  exit 2
fi

python3 - "$1" <<'PY'
import os, re, sys

root = sys.argv[1]
files = sorted(f for f in os.listdir(root) if f.endswith(".md"))
texts = {f: open(os.path.join(root, f), encoding="utf-8").read() for f in files}
errors = []

# ---- 1. global, regex: extern blocks must be unsafe -------------------------
EXTERN_RE = re.compile(r'(?<!unsafe )extern "C" \{')
n = sum(len(EXTERN_RE.findall(t)) for t in texts.values())
if n != 34:
    errors.append(f'patch 1: expected 34 bare `extern "C" {{`, found {n}')

# ---- 2. global, literal: unsafe attribute ----------------------------------
n = sum(t.count("#[no_mangle]") for t in texts.values())
if n != 20:
    errors.append(f"patch 2: expected 20 `#[no_mangle]`, found {n}")
if any("#[unsafe(no_mangle)]" in t for t in texts.values()):
    errors.append("patch 2: `#[unsafe(no_mangle)]` already present")

# ---- 3 and 4. per-file, literal, exactly once each --------------------------
# (file, old, new)
LOCAL = [
    ("mem-04-reentrant.md",
     "    rand::thread_rng().gen()  // Thread-safe!",
     "    rand::rng().random()  // Thread-safe!"),

    ("ffi-14-stable-layout.md",
     "    unsafe fn into_vec(self) -> Vec<u8> {\n"
     "        Vec::from_raw_parts(self.ptr, self.len, self.cap)\n",
     "    unsafe fn into_vec(self) -> Vec<u8> {\n"
     "        // SAFETY: from_vec() leaked these parts from a live Vec<u8>, so they are valid.\n"
     "        unsafe { Vec::from_raw_parts(self.ptr, self.len, self.cap) }\n"),

    ("ffi-09-ref-not-ptr.md",
     "    // Why force caller to use unsafe?\n"
     "    c_process(data, len);\n",
     "    // Why force caller to use unsafe?\n"
     "    unsafe { c_process(data, len); }\n"),
    ("ffi-09-ref-not-ptr.md",
     "unsafe fn ptr_to_ref<'a>(p: *const Data) -> &'a Data {\n"
     "    &*p\n",
     "unsafe fn ptr_to_ref<'a>(p: *const Data) -> &'a Data {\n"
     "    // SAFETY: Caller guarantees p is valid, aligned, and lives for 'a.\n"
     "    unsafe { &*p }\n"),
    ("ffi-09-ref-not-ptr.md",
     "unsafe fn ptr_to_mut<'a>(p: *mut Data) -> &'a mut Data {\n"
     "    &mut *p\n",
     "unsafe fn ptr_to_mut<'a>(p: *mut Data) -> &'a mut Data {\n"
     "    // SAFETY: Caller guarantees p is valid, aligned, unaliased, and lives for 'a.\n"
     "    unsafe { &mut *p }\n"),

    ("general-03-no-alias.md",
     "pub unsafe fn get_value_unchecked(ptr: *const i32) -> i32 {\n"
     "    *ptr\n",
     "pub unsafe fn get_value_unchecked(ptr: *const i32) -> i32 {\n"
     "    // SAFETY: Caller guarantees ptr is valid and aligned.\n"
     "    unsafe { *ptr }\n"),

    ("safety-02-verify-invariants.md",
     "        // No verification that ptr is valid or len is correct!\n"
     "        let item = &*ptr.add(i);\n",
     "        // No verification that ptr is valid or len is correct!\n"
     "        let item = unsafe { &*ptr.add(i) };\n"),
    ("safety-02-verify-invariants.md",
     "        // SAFETY: Caller guarantees ptr points to len valid items\n"
     "        let item = &*ptr.add(i);\n",
     "        // SAFETY: Caller guarantees ptr points to len valid items\n"
     "        let item = unsafe { &*ptr.add(i) };\n"),

    ("safety-06-no-raw-ptr-api.md",
     "            data: Vec::from_raw_parts(ptr, len, cap)\n",
     "            // SAFETY: Caller upholds the contract in the # Safety section above.\n"
     "            data: unsafe { Vec::from_raw_parts(ptr, len, cap) },\n"),

    ("safety-07-unsafe-pair.md",
     "    pub unsafe fn get(&self, index: usize) -> &T {\n"
     "        &*self.ptr.add(index)\n",
     "    pub unsafe fn get(&self, index: usize) -> &T {\n"
     "        unsafe { &*self.ptr.add(index) }\n"),
    ("safety-07-unsafe-pair.md",
     "        debug_assert!(index < self.len, \"index out of bounds\");\n"
     "        &*self.ptr.add(index)\n",
     "        debug_assert!(index < self.len, \"index out of bounds\");\n"
     "        // SAFETY: Caller guarantees index < len.\n"
     "        unsafe { &*self.ptr.add(index) }\n"),

    ("safety-11-assert-not-debug.md",
     "    debug_assert!(index < slice.len());  // Gone in release!\n"
     "    &*slice.as_ptr().add(index)\n",
     "    debug_assert!(index < slice.len());  // Gone in release!\n"
     "    unsafe { &*slice.as_ptr().add(index) }\n"),
    ("safety-11-assert-not-debug.md",
     "    debug_assert!(!ptr.is_null());  // Won't catch bugs in release\n"
     "    ffi::process_data(ptr);\n",
     "    debug_assert!(!ptr.is_null());  // Won't catch bugs in release\n"
     "    unsafe { ffi::process_data(ptr); }\n"),
    ("safety-11-assert-not-debug.md",
     "    assert!(index < slice.len(), \"index {} out of bounds for len {}\", index, slice.len());\n"
     "    &*slice.as_ptr().add(index)\n",
     "    assert!(index < slice.len(), \"index {} out of bounds for len {}\", index, slice.len());\n"
     "    // SAFETY: The assert above proves index < len.\n"
     "    unsafe { &*slice.as_ptr().add(index) }\n"),
    ("safety-11-assert-not-debug.md",
     "    debug_assert!(index < slice.len());\n"
     "    &*slice.as_ptr().add(index)\n",
     "    debug_assert!(index < slice.len());\n"
     "    // SAFETY: Caller guarantees index < len.\n"
     "    unsafe { &*slice.as_ptr().add(index) }\n"),
    ("safety-11-assert-not-debug.md",
     "    let ptr = slice.as_ptr().add(index);\n",
     "    let ptr = unsafe { slice.as_ptr().add(index) };\n"),
]

for i, (f, old, new) in enumerate(LOCAL, 3):
    t = texts.get(f)
    if t is None:
        errors.append(f"patch {i}: missing file {f}")
        continue
    c = t.count(old)
    if c != 1:
        errors.append(f"patch {i} ({f}): anchor occurs {c} times, expected 1")
    if new in t:
        errors.append(f"patch {i} ({f}): replacement text already present")

if errors:
    print("\n".join(errors), file=sys.stderr)
    print("no file was changed", file=sys.stderr)
    sys.exit(1)

for f, old, new in LOCAL:
    texts[f] = texts[f].replace(old, new, 1)
for f in files:
    t = EXTERN_RE.sub('unsafe extern "C" {', texts[f])
    t = t.replace("#[no_mangle]", "#[unsafe(no_mangle)]")
    texts[f] = t

for f in files:
    open(os.path.join(root, f), "w", encoding="utf-8").write(texts[f])
print(f"patched {len(files)} files")
PY
