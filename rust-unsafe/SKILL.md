---
name: rust-unsafe
description: "Rules for writing and reviewing unsafe Rust: raw pointers, NonNull, PhantomData, MaybeUninit, repr(C) and memory layout, unions, panic safety, double free, SAFETY comments and # Safety docs, manual Send/Sync, and the whole FFI boundary (extern blocks, #[unsafe(no_mangle)] exports, CString/CStr, catch_unwind, opaque handles, callbacks, raw fds). 47 rules, one per file, each with a bad and a good example in Rust 2024 syntax. Load this skill whenever the code in front of you contains unsafe, *const, *mut, extern, transmute, union, MaybeUninit, NonNull, libc, std::ffi, or #[repr(C)], or when reviewing whether a safe wrapper over unsafe code is sound. For everyday Rust without unsafe, use the rust skill instead."
license: MIT
metadata:
  version: "1.0.0"
  sources:
    - name: actionbook/rust-skills (unsafe-checker 1.0.0), translated from Rust-Coding-Guidelines/rust-coding-guidelines-zh
      files: "references/*.md (47 rules, 7 groups), examples moved to Rust 2024 by patch.sh"
  provenance: README.md
---

# Unsafe Rust and FFI Rules

47 rules in 7 groups, one Markdown file per rule. Every file states the rule, why it
matters, a bad and a good example, a checklist, and related rule ids. Examples use Rust
2024 syntax (`unsafe extern`, `#[unsafe(no_mangle)]`, explicit `unsafe { }` inside
`unsafe fn`); they are illustrative fragments, not compile-checked programs.

Read this index first, then open only the rule files whose prefix matches the code in
front of you. Do not load the whole `references/` directory.

This skill goes deeper than the seven `unsafe-` rules of the `rust` skill. Use both: the
`rust` skill for everything around the unsafe block, this one for what happens inside it
and at the C boundary.

## When to apply

- Writing or reviewing any `unsafe` block, `unsafe fn`, or `unsafe impl`.
- Building a safe abstraction over raw pointers, uninitialized memory, or a C library.
- Declaring `extern` blocks, exporting functions to C, passing strings, structs, closures,
  or handles across FFI.
- Choosing `#[repr(...)]`, using `union`, or relying on a type's memory layout.
- Deciding whether `unsafe` is justified at all.

## Rule groups by priority

| Priority | Group | Impact | Prefix | Rules |
|----------|-------|--------|--------|-------|
| 1 | General principles | CRITICAL | `general-` | 3 |
| 2 | Safety abstraction | CRITICAL | `safety-` | 11 |
| 3 | FFI | CRITICAL | `ffi-` | 18 |
| 4 | Raw pointers | HIGH | `ptr-` | 6 |
| 5 | Memory layout | HIGH | `mem-` | 6 |
| 6 | Union | HIGH | `union-` | 2 |
| 7 | I/O safety | MEDIUM | `io-` | 1 |

Each file's frontmatter carries `level` (`P` principle or `G` guideline), `impact`, the
upstream id (`original_id`), and the Clippy lint that detects the violation when one
exists.

## Rule application by task

| Task | Primary prefixes |
|------|------------------|
| Any new `unsafe` block | `general-`, `safety-09`, `safety-02` |
| Safe wrapper over unsafe code | `safety-`, `ptr-02`, `ptr-03` |
| Calling a C library | `ffi-01` to `ffi-09`, `ffi-17`, `mem-03`, `mem-04` |
| Exporting Rust to C | `ffi-04`, `ffi-08`, `ffi-10`, `ffi-12`, `ffi-16`, `ffi-18` |
| Structs shared with C | `ffi-11`, `ffi-13`, `ffi-14`, `mem-01`, `union-` |
| Uninitialized or raw memory | `mem-06`, `safety-03`, `ptr-04`, `ptr-05` |
| Raw file descriptors or handles | `io-01`, `ffi-03` |
| Manual `Send` or `Sync` | `safety-05`, `ptr-01` |

## Reference index

### 1. General principles (CRITICAL)

- [general-01-no-abuse](references/general-01-no-abuse.md) - Unsafe is not an escape hatch from the borrow checker or other compiler checks.
- [general-02-not-for-perf](references/general-02-not-for-perf.md) - Do not assume unsafe is faster; measure first and verify the invariants.
- [general-03-no-alias](references/general-03-no-alias.md) - Do not hide "unsafe" behind type aliases, re-exports, or wrapper names.

### 2. Safety abstraction (CRITICAL)

- [safety-01-panic-safety](references/safety-01-panic-safety.md) - A panic inside unsafe code must not leave data structures inconsistent; order bookkeeping after writes and use panic guards.
- [safety-02-verify-invariants](references/safety-02-verify-invariants.md) - The author of unsafe code is responsible for every invariant the compiler no longer checks.
- [safety-03-no-uninit-api](references/safety-03-no-uninit-api.md) - Public APIs must never return or expose uninitialized memory.
- [safety-04-double-free](references/safety-04-double-free.md) - Make sure a resource cannot be freed twice when a panic interrupts an operation.
- [safety-05-send-sync](references/safety-05-send-sync.md) - Manual `Send` or `Sync` impls must uphold the thread-safety invariants they claim.
- [safety-06-no-raw-ptr-api](references/safety-06-no-raw-ptr-api.md) - Public APIs take references, slices, and smart pointers, not raw pointers.
- [safety-07-unsafe-pair](references/safety-07-unsafe-pair.md) - Offer a checked safe method next to every unchecked unsafe one.
- [safety-08-no-mut-from-immut](references/safety-08-no-mut-from-immut.md) - Never return `&mut T` from `&self` or `&T` without interior mutability.
- [safety-09-safety-comment](references/safety-09-safety-comment.md) - Every `unsafe` block and `unsafe impl` gets a `// SAFETY:` comment.
- [safety-10-safety-doc](references/safety-10-safety-doc.md) - Every public `unsafe fn` documents the caller's obligations in a `# Safety` section.
- [safety-11-assert-not-debug](references/safety-11-assert-not-debug.md) - Check safety invariants with `assert!`, not `debug_assert!`, unless the caller owns the obligation.

### 3. FFI (CRITICAL)

- [ffi-01-no-string-direct](references/ffi-01-no-string-direct.md) - Use `CString` and `CStr` at the boundary; never pass `String` or `&str` to C.
- [ffi-02-read-ffi-docs](references/ffi-02-read-ffi-docs.md) - The `std::ffi` types differ subtly; read their docs before use.
- [ffi-03-drop-for-c-ptr](references/ffi-03-drop-for-c-ptr.md) - A wrapper that owns a C pointer implements `Drop` to call the C deallocator.
- [ffi-04-panic-boundary](references/ffi-04-panic-boundary.md) - Panics must not unwind into C; use `catch_unwind` or `extern "C-unwind"`.
- [ffi-05-portable-types](references/ffi-05-portable-types.md) - Use the C type aliases from `std` or `libc`; never assume C type sizes.
- [ffi-06-string-abi](references/ffi-06-string-abi.md) - Both sides must agree on encoding, null termination, and ownership of strings.
- [ffi-07-no-drop-external](references/ffi-07-no-drop-external.md) - Types whose lifetime is managed by external code must not implement `Drop`.
- [ffi-08-error-handling](references/ffi-08-error-handling.md) - Errors cross FFI as return codes, errno, or out parameters, never as `Result` or `Option`.
- [ffi-09-ref-not-ptr](references/ffi-09-ref-not-ptr.md) - Safe wrappers take references so non-null is enforced at compile time.
- [ffi-10-thread-safety](references/ffi-10-thread-safety.md) - Functions exported to C may be called from any thread; use atomics, `Mutex`, `OnceLock`.
- [ffi-11-packed-ub](references/ffi-11-packed-ub.md) - Never take a reference to a field of a `#[repr(packed)]` struct; use `read_unaligned`.
- [ffi-12-invariant-doc](references/ffi-12-invariant-doc.md) - Document and, where possible, verify the invariants assumed about C-provided parameters.
- [ffi-13-data-layout](references/ffi-13-data-layout.md) - Types shared with C carry `#[repr(C)]`.
- [ffi-14-stable-layout](references/ffi-14-stable-layout.md) - FFI types keep a stable layout; no generic `std` types in the ABI.
- [ffi-15-validate-external](references/ffi-15-validate-external.md) - Validate data from FFI, files, or the network before turning it into Rust types with invariants.
- [ffi-16-closure-to-c](references/ffi-16-closure-to-c.md) - Pass closures to C as a trampoline function pointer plus a data pointer.
- [ffi-17-opaque-types](references/ffi-17-opaque-types.md) - Use a dedicated opaque marker type per C handle instead of `*mut c_void`.
- [ffi-18-no-trait-objects](references/ffi-18-no-trait-objects.md) - Fat pointers such as `dyn Trait` have no C layout; never pass them across FFI.

### 4. Raw pointers (HIGH)

- [ptr-01-no-thread-share](references/ptr-01-no-thread-share.md) - Raw pointers are neither `Send` nor `Sync`; do not share them across threads without synchronization.
- [ptr-02-prefer-nonnull](references/ptr-02-prefer-nonnull.md) - Use `NonNull<T>` when the pointer is never null; it enables niche optimization and states intent.
- [ptr-03-phantomdata](references/ptr-03-phantomdata.md) - Add `PhantomData<T>` to structs holding raw pointers so ownership and variance are correct.
- [ptr-04-alignment](references/ptr-04-alignment.md) - Never dereference a pointer cast to a type with stricter alignment.
- [ptr-05-no-const-to-mut](references/ptr-05-no-const-to-mut.md) - Casting `*const T` to `*mut T` and writing through it is undefined behavior.
- [ptr-06-prefer-cast](references/ptr-06-prefer-cast.md) - Use `pointer::cast()` instead of `as` for pointer conversions.

### 5. Memory layout (HIGH)

- [mem-01-repr-layout](references/mem-01-repr-layout.md) - Choose `#[repr(...)]` deliberately for C interop, memory mapping, or layout guarantees.
- [mem-02-no-other-process](references/mem-02-no-other-process.md) - Do not poke the memory of other processes or dynamic libraries; use IPC or the library's API.
- [mem-03-no-auto-drop-foreign](references/mem-03-no-auto-drop-foreign.md) - Never build `String`, `Vec`, or `Box` from memory that Rust's allocator did not allocate.
- [mem-04-reentrant](references/mem-04-reentrant.md) - Prefer the reentrant `_r` variants of C functions and syscalls, or the Rust standard library.
- [mem-05-bitfield-crates](references/mem-05-bitfield-crates.md) - Use `bitflags`, `bitvec`, or `modular-bitfield` instead of hand-written bit manipulation.
- [mem-06-maybeuninit](references/mem-06-maybeuninit.md) - Use `MaybeUninit<T>`; `mem::uninitialized()` and `mem::zeroed()` are undefined behavior for most types.

### 6. Union (HIGH)

- [union-01-avoid-except-ffi](references/union-01-avoid-except-ffi.md) - Use `union` only for C interop; Rust code uses tagged enums.
- [union-02-no-cross-lifetime](references/union-02-no-cross-lifetime.md) - Do not write one union field and read another that carries a different lifetime.

### 7. I/O safety (MEDIUM)

- [io-01-raw-handle](references/io-01-raw-handle.md) - Track ownership of raw file descriptors and handles with `OwnedFd` and `BorrowedFd`.

## Clippy lints that catch violations

| Lint | Rule |
|------|------|
| `undocumented_unsafe_blocks` | safety-09 |
| `missing_safety_doc` | safety-10 |
| `panic_in_result_fn` | safety-01, ffi-04 |
| `non_send_fields_in_send_ty` | safety-05 |
| `uninit_assumed_init` | safety-03 |
| `uninit_vec` | mem-06 |
| `mut_from_ref` | safety-08 |
| `cast_ptr_alignment` | ptr-04 |
| `cast_ref_to_mut` | ptr-05 |
| `ptr_as_ptr` | ptr-06 |
| `unaligned_references` | ffi-11 |
| `debug_assert_with_mut_call` | safety-11 |

## Before every unsafe block

- `// SAFETY:` comment present and specific (safety-09).
- Invariants listed and either verified or documented as the caller's duty (safety-02, safety-10).
- Pointer validity, alignment, and aliasing checked (ptr-04, ptr-05, safety-08).
- Panic at any line leaves the structure consistent (safety-01, safety-04).
- Tested under Miri; the `rust` skill's `unsafe-miri-ci` rule covers the CI setup.
