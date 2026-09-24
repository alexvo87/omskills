---
name: rust
description: "Rust coding rules for API services and core processing code, one rule per file with a bad and a good example, current for Rust 1.96 and the 2024 edition. Load this skill BEFORE writing, reviewing, or refactoring any Rust code, including a single function: choosing &T, clone, Cow, Arc or Box; designing error enums with thiserror or anyhow and propagating with ?; async code on Tokio such as handlers, workers, channels, JoinSet, select!, cancellation, spawn_blocking, and locks near await; serde structs for request and response bodies; newtypes, typestate, builders, and public API shape; numeric overflow and casts; tracing and structured logs; memory and allocation in hot paths; unsafe blocks and FFI; tests with proptest, mockall, criterion, snapshot and loom; workspace layout, features, MSRV; Clippy and lint configuration; and naming. Also load it when reviewing Rust for anti-patterns such as unwrap in production, clone to satisfy the borrow checker, String where &str suffices, or Box<dyn Trait> where impl Trait would do."
license: MIT
metadata:
  version: "2.0.0"
  sources:
    - name: leonardomso/rust-skills (rust-skills 1.5.1)
      files: "references/*.md (265 rules, 26 categories)"
  provenance: README.md
---

# Rust Rules for APIs and Core Processing

265 rules across 26 categories, one Markdown file per rule. Every file states why the rule
matters, shows a bad and a good example, and links related rules. Rules are current for
Rust 1.96 and the 2024 edition, and their good examples are compile-checked upstream.

Read this index first, then open only the handful of rule files whose prefix matches the
code in front of you. Do not load the whole `references/` directory.

## When to apply

- Writing a new function, struct, trait, module, or crate, or reviewing and refactoring Rust.
- Designing error types and mapping them at an API boundary.
- Writing handlers, background workers, pipelines, or anything on the Tokio runtime.
- Defining request and response types with serde.
- Sharing state between tasks; choosing `Mutex`, `RwLock`, channels, atomics, `OnceLock`.
- Touching numeric code, casts, or arithmetic on untrusted input.
- Adding logs, spans, or metrics.
- Optimizing a measured hot path, reducing allocations, or tuning release profiles.
- Writing or reviewing `unsafe` or FFI.
- Adding tests or benchmarks, configuring lints, or laying out a workspace.

## Rule categories by priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Ownership & Borrowing | CRITICAL | `own-` | 12 |
| 2 | Error Handling | CRITICAL | `err-` | 12 |
| 3 | Memory Optimization | CRITICAL | `mem-` | 17 |
| 4 | Unsafe Code | CRITICAL | `unsafe-` | 7 |
| 5 | API Design | HIGH | `api-` | 17 |
| 6 | Async/Await | HIGH | `async-` | 18 |
| 7 | Concurrency | HIGH | `conc-` | 4 |
| 8 | Compiler Optimization | HIGH | `opt-` | 12 |
| 9 | Numeric & Arithmetic Safety | HIGH | `num-` | 5 |
| 10 | Type Safety | MEDIUM | `type-` | 13 |
| 11 | Trait & Generics Design | MEDIUM | `trait-` | 6 |
| 12 | Conversions | MEDIUM | `conv-` | 3 |
| 13 | Const & Compile-Time | MEDIUM | `const-` | 4 |
| 14 | Serde | MEDIUM | `serde-` | 8 |
| 15 | Pattern Matching | MEDIUM | `pat-` | 5 |
| 16 | Macros | MEDIUM | `macro-` | 8 |
| 17 | Closures | MEDIUM | `closure-` | 5 |
| 18 | Collections | MEDIUM | `coll-` | 4 |
| 19 | Naming Conventions | MEDIUM | `name-` | 16 |
| 20 | Testing | MEDIUM | `test-` | 15 |
| 21 | Documentation | MEDIUM | `doc-` | 12 |
| 22 | Observability | MEDIUM | `obs-` | 7 |
| 23 | Performance Patterns | MEDIUM | `perf-` | 13 |
| 24 | Project Structure | LOW | `proj-` | 14 |
| 25 | Clippy & Linting | LOW | `lint-` | 13 |
| 26 | Anti-patterns | REFERENCE | `anti-` | 15 |

Apply CRITICAL before HIGH before MEDIUM before LOW. `anti-` files describe a mistake and
point to the rule that fixes it; read them when reviewing.

## Rule application by task

| Task | Primary prefixes |
|------|------------------|
| New function | `own-`, `err-`, `name-`, `pat-` |
| New struct or public API | `api-`, `type-`, `conv-`, `doc-` |
| HTTP handler or service method | `err-`, `async-`, `serde-`, `type-`, `obs-` |
| Background worker or pipeline | `async-`, `conc-`, `own-`, `mem-` |
| Error handling | `err-`, `api-`, `pat-` |
| Request and response bodies | `serde-`, `type-`, `api-` |
| Shared state or concurrency | `async-`, `conc-`, `own-` |
| Numeric or arithmetic | `num-`, `type-` |
| Logging and tracing | `obs-`, `err-` |
| Unsafe or FFI | `unsafe-`, `type-`, `test-` |
| Memory or allocation | `mem-`, `own-`, `perf-` |
| Performance tuning | `opt-`, `mem-`, `perf-` |
| Type conversions | `conv-`, `api-` |
| Macros | `macro-`, `anti-` |
| Closures and callbacks | `closure-`, `type-` |
| Tests and benchmarks | `test-` |
| Workspace, modules, features | `proj-`, `lint-` |
| Code review | `anti-`, `lint-`, `err-`, `own-` |

## Reference index

### 1. Ownership & Borrowing (CRITICAL)

- [`own-borrow-over-clone`](references/own-borrow-over-clone.md) - Prefer `&T` borrowing over `.clone()`
- [`own-slice-over-vec`](references/own-slice-over-vec.md) - Accept `&[T]` not `&Vec<T>`, `&str` not `&String`
- [`own-cow-conditional`](references/own-cow-conditional.md) - Use `Cow<'a, T>` for conditional ownership
- [`own-arc-shared`](references/own-arc-shared.md) - Use `Arc<T>` for thread-safe shared ownership
- [`own-rc-single-thread`](references/own-rc-single-thread.md) - Use `Rc<T>` for shared ownership in single-threaded contexts
- [`own-refcell-interior`](references/own-refcell-interior.md) - Use `RefCell<T>` for interior mutability in single-threaded code
- [`own-mutex-interior`](references/own-mutex-interior.md) - Use `Mutex<T>` for interior mutability across threads
- [`own-rwlock-readers`](references/own-rwlock-readers.md) - Use `RwLock<T>` when reads significantly outnumber writes
- [`own-copy-small`](references/own-copy-small.md) - Implement `Copy` for small, simple types
- [`own-clone-explicit`](references/own-clone-explicit.md) - Use explicit `Clone` for types where copying has meaningful cost
- [`own-move-large`](references/own-move-large.md) - Move large types instead of copying; use `Box` if moves are expensive
- [`own-lifetime-elision`](references/own-lifetime-elision.md) - Rely on lifetime elision rules; add explicit lifetimes only when required

### 2. Error Handling (CRITICAL)

- [`err-thiserror-lib`](references/err-thiserror-lib.md) - Use `thiserror` for library error types
- [`err-anyhow-app`](references/err-anyhow-app.md) - Use `anyhow` for application error handling
- [`err-result-over-panic`](references/err-result-over-panic.md) - Return `Result<T, E>` instead of panicking for recoverable errors
- [`err-context-chain`](references/err-context-chain.md) - Add context with `.context()` or `.with_context()`
- [`err-no-unwrap-prod`](references/err-no-unwrap-prod.md) - Avoid `unwrap()` in production code; use `?`, `expect()`, or handle errors
- [`err-expect-bugs-only`](references/err-expect-bugs-only.md) - Use `expect()` only for invariants that indicate bugs, not user errors
- [`err-question-mark`](references/err-question-mark.md) - Use `?` operator for clean propagation
- [`err-from-impl`](references/err-from-impl.md) - Implement `From<E>` for error conversions to enable `?` operator
- [`err-source-chain`](references/err-source-chain.md) - Preserve error chains with `#[source]` or `source()` method
- [`err-lowercase-msg`](references/err-lowercase-msg.md) - Start error messages lowercase, no trailing punctuation
- [`err-doc-errors`](references/err-doc-errors.md) - Document error conditions with `# Errors` section in doc comments
- [`err-custom-type`](references/err-custom-type.md) - Define custom error types for domain-specific failures

### 3. Memory Optimization (CRITICAL)

- [`mem-with-capacity`](references/mem-with-capacity.md) - Use `with_capacity()` when size is known
- [`mem-smallvec`](references/mem-smallvec.md) - Use `SmallVec` for usually-small collections
- [`mem-arrayvec`](references/mem-arrayvec.md) - Use `ArrayVec<T, N>` for fixed-capacity collections that never heap-allocate
- [`mem-box-large-variant`](references/mem-box-large-variant.md) - Box large enum variants to reduce overall enum size
- [`mem-boxed-slice`](references/mem-boxed-slice.md) - Use `Box<[T]>` instead of `Vec<T>` for fixed-size heap data
- [`mem-thinvec`](references/mem-thinvec.md) - Use `ThinVec<T>` for nullable collections with minimal overhead
- [`mem-clone-from`](references/mem-clone-from.md) - Use `clone_from()` to reuse allocations when repeatedly cloning
- [`mem-reuse-collections`](references/mem-reuse-collections.md) - Clear and reuse collections instead of creating new ones in loops
- [`mem-avoid-format`](references/mem-avoid-format.md) - Avoid `format!()` when string literals work
- [`mem-write-over-format`](references/mem-write-over-format.md) - Use `write!()` into existing buffers instead of `format!()` allocations
- [`mem-arena-allocator`](references/mem-arena-allocator.md) - Use arena allocators for batch allocations
- [`mem-zero-copy`](references/mem-zero-copy.md) - Use zero-copy patterns with slices and `Bytes`
- [`mem-compact-string`](references/mem-compact-string.md) - Use compact string types for memory-constrained string storage
- [`mem-smaller-integers`](references/mem-smaller-integers.md) - Use appropriately-sized integers to reduce memory footprint
- [`mem-assert-type-size`](references/mem-assert-type-size.md) - Use static assertions to guard against accidental type size growth
- [`mem-take-replace`](references/mem-take-replace.md) - Use `mem::take` / `mem::replace` to move a value out of a `&mut` without cloning
- [`mem-drop-order`](references/mem-drop-order.md) - Know and control drop order: struct fields drop top-to-bottom, locals in reverse

### 4. Unsafe Code (CRITICAL)

- [`unsafe-safety-comment`](references/unsafe-safety-comment.md) - Write a `// SAFETY:` comment above every `unsafe` block and a `# Safety` section in every `unsafe fn`.
- [`unsafe-minimize-scope`](references/unsafe-minimize-scope.md) - Keep `unsafe` blocks as small as possible — mark only the operation that requires unsafety, not the surrounding safe code.
- [`unsafe-miri-ci`](references/unsafe-miri-ci.md) - Run `cargo miri test` in CI for every crate that contains `unsafe` code.
- [`unsafe-maybeuninit`](references/unsafe-maybeuninit.md) - Use `MaybeUninit<T>` for uninitialized memory; never use `mem::uninitialized()` or `mem::zeroed()` for types with validity invariants.
- [`unsafe-extern-block`](references/unsafe-extern-block.md) - In Rust 2024, wrap `extern` blocks in `unsafe extern { }` and annotate each item as `safe` or `unsafe`.
- [`unsafe-send-sync-manual`](references/unsafe-send-sync-manual.md) - Document the invariants when manually implementing `Send` or `Sync`; prefer letting the compiler derive them automatically.
- [`unsafe-no-mangle-unsafe`](references/unsafe-no-mangle-unsafe.md) - In Rust 2024, write `#[unsafe(no_mangle)]`, `#[unsafe(export_name = "...")]`, and `#[unsafe(link_section = "...")]` — not the bare attribute forms.

### 5. API Design (HIGH)

- [`api-builder-pattern`](references/api-builder-pattern.md) - Use Builder pattern for complex construction
- [`api-builder-must-use`](references/api-builder-must-use.md) - Mark builder methods with `#[must_use]` to prevent silent drops
- [`api-newtype-safety`](references/api-newtype-safety.md) - Use newtypes to prevent mixing semantically different values
- [`api-typestate`](references/api-typestate.md) - Use typestate pattern to encode state machine invariants in the type system
- [`api-sealed-trait`](references/api-sealed-trait.md) - Use sealed traits to prevent external implementations while allowing use
- [`api-extension-trait`](references/api-extension-trait.md) - Use extension traits to add methods to external types
- [`api-parse-dont-validate`](references/api-parse-dont-validate.md) - Parse into validated types at boundaries
- [`api-impl-into`](references/api-impl-into.md) - Accept `impl Into<T>` for flexible APIs, implement `From<T>` for conversions
- [`api-impl-asref`](references/api-impl-asref.md) - Use `AsRef<T>` when you only need to borrow the inner data
- [`api-must-use`](references/api-must-use.md) - Mark types and functions with `#[must_use]` when ignoring results is likely a bug
- [`api-non-exhaustive`](references/api-non-exhaustive.md) - Use `#[non_exhaustive]` on public enums and structs for forward compatibility
- [`api-from-not-into`](references/api-from-not-into.md) - Implement `From<T>`, not `Into<U>` - From gives you Into for free
- [`api-default-impl`](references/api-default-impl.md) - Implement `Default` for types with sensible default values
- [`api-common-traits`](references/api-common-traits.md) - Implement standard traits (Debug, Clone, PartialEq, etc.) for public types
- [`api-serde-optional`](references/api-serde-optional.md) - Make serde a feature flag, not a hard dependency for library crates
- [`api-impl-fromiterator`](references/api-impl-fromiterator.md) - Implement `FromIterator` and `Extend` for collection types, and `IntoIterator` for all three reference forms
- [`api-operator-overload`](references/api-operator-overload.md) - Overload operators only when the semantics are natural and unsurprising

### 6. Async/Await (HIGH)

- [`async-tokio-runtime`](references/async-tokio-runtime.md) - Configure Tokio runtime appropriately for your workload
- [`async-no-lock-await`](references/async-no-lock-await.md) - Never hold `Mutex`/`RwLock` across `.await`
- [`async-spawn-blocking`](references/async-spawn-blocking.md) - Use `spawn_blocking` for CPU-intensive work
- [`async-tokio-fs`](references/async-tokio-fs.md) - Use `tokio::fs` instead of `std::fs` in async code
- [`async-cancellation-token`](references/async-cancellation-token.md) - Use `CancellationToken` for graceful shutdown and task cancellation
- [`async-join-parallel`](references/async-join-parallel.md) - Use `join!` or `try_join!` for concurrent independent futures
- [`async-try-join`](references/async-try-join.md) - Use `try_join!` for concurrent fallible operations with early return on error
- [`async-select-racing`](references/async-select-racing.md) - Use `select!` to race futures and handle the first to complete
- [`async-bounded-channel`](references/async-bounded-channel.md) - Use bounded channels to apply backpressure and prevent unbounded memory growth
- [`async-mpsc-queue`](references/async-mpsc-queue.md) - Use `mpsc` channels for async message queues between tasks
- [`async-broadcast-pubsub`](references/async-broadcast-pubsub.md) - Use `broadcast` channel for pub/sub where all subscribers receive all messages
- [`async-watch-latest`](references/async-watch-latest.md) - Use `watch` channel for sharing the latest value with multiple observers
- [`async-oneshot-response`](references/async-oneshot-response.md) - Use `oneshot` channel for request-response patterns
- [`async-joinset-structured`](references/async-joinset-structured.md) - Use `JoinSet` for managing dynamic collections of spawned tasks
- [`async-clone-before-await`](references/async-clone-before-await.md) - Clone Arc/Rc data before await points to avoid holding references across suspension
- [`async-fn-in-trait`](references/async-fn-in-trait.md) - Use native `async fn` in traits (stable 1.75) instead of the `async_trait` macro
- [`async-async-fn-bounds`](references/async-async-fn-bounds.md) - Use `AsyncFn`/`AsyncFnMut`/`AsyncFnOnce` bounds instead of `F: Fn() -> Fut, Fut: Future`
- [`async-cancel-safety`](references/async-cancel-safety.md) - Ensure futures used in `tokio::select!` branches are cancellation-safe

### 7. Concurrency (HIGH)

- [`conc-rayon-par-iter`](references/conc-rayon-par-iter.md) - Use rayon's `par_iter()` for CPU-bound data parallelism
- [`conc-scoped-threads`](references/conc-scoped-threads.md) - Use `std::thread::scope` to borrow stack data across threads
- [`conc-atomic-ordering`](references/conc-atomic-ordering.md) - Use the weakest correct memory `Ordering` for every atomic operation
- [`conc-thread-local`](references/conc-thread-local.md) - Prefer `thread_local!` with `Cell`/`RefCell` over `static mut`

### 8. Compiler Optimization (HIGH)

- [`opt-inline-small`](references/opt-inline-small.md) - Use `#[inline]` for small hot functions
- [`opt-inline-always-rare`](references/opt-inline-always-rare.md) - Use `#[inline(always)]` sparingly—only for critical hot paths proven by profiling
- [`opt-inline-never-cold`](references/opt-inline-never-cold.md) - Use `#[inline(never)]` and `#[cold]` for error paths and rarely-executed code
- [`opt-cold-unlikely`](references/opt-cold-unlikely.md) - Mark unlikely code paths with `#[cold]` to help compiler optimization
- [`opt-likely-hint`](references/opt-likely-hint.md) - Use code structure to hint at likely branches; use intrinsics on nightly
- [`opt-lto-release`](references/opt-lto-release.md) - Enable LTO in release builds
- [`opt-codegen-units`](references/opt-codegen-units.md) - Set `codegen-units = 1` for maximum optimization in release builds
- [`opt-pgo-profile`](references/opt-pgo-profile.md) - Use Profile-Guided Optimization (PGO) for maximum performance
- [`opt-target-cpu`](references/opt-target-cpu.md) - Use `target-cpu=native` for maximum performance on known deployment targets
- [`opt-bounds-check`](references/opt-bounds-check.md) - Use iterators and patterns that eliminate bounds checks in hot paths
- [`opt-simd-portable`](references/opt-simd-portable.md) - Use portable SIMD for vectorized operations across architectures
- [`opt-cache-friendly`](references/opt-cache-friendly.md) - Organize data for cache-efficient access patterns

### 9. Numeric & Arithmetic Safety (HIGH)

- [`num-overflow-explicit`](references/num-overflow-explicit.md) - Handle integer overflow explicitly: `checked_`/`saturating_`/`wrapping_`/`overflowing_`
- [`num-cast-try-from`](references/num-cast-try-from.md) - Avoid `as` for narrowing casts; use `From` for widening and `TryFrom` for narrowing
- [`num-float-compare`](references/num-float-compare.md) - Don't compare floats with `==`; use a tolerance, and `total_cmp` for ordering
- [`num-saturating-clamp`](references/num-saturating-clamp.md) - Bound values with `clamp` and saturating arithmetic
- [`num-nonzero`](references/num-nonzero.md) - Use `NonZero*` types to forbid zero and unlock the niche optimization

### 10. Type Safety (MEDIUM)

- [`type-newtype-ids`](references/type-newtype-ids.md) - Wrap IDs in newtypes: `UserId(u64)`
- [`type-newtype-validated`](references/type-newtype-validated.md) - Use newtypes to enforce validation at construction time
- [`type-enum-states`](references/type-enum-states.md) - Use enums for mutually exclusive states
- [`type-option-nullable`](references/type-option-nullable.md) - Use `Option<T>` for values that might not exist
- [`type-result-fallible`](references/type-result-fallible.md) - Use `Result<T, E>` for operations that can fail
- [`type-phantom-marker`](references/type-phantom-marker.md) - Use `PhantomData` to express type relationships without runtime cost
- [`type-never-diverge`](references/type-never-diverge.md) - Use `!` (never type) for functions that never return
- [`type-generic-bounds`](references/type-generic-bounds.md) - Add trait bounds only where needed, prefer where clauses for readability
- [`type-no-stringly`](references/type-no-stringly.md) - Avoid stringly-typed APIs; use enums, newtypes, or validated types
- [`type-repr-transparent`](references/type-repr-transparent.md) - Use `#[repr(transparent)]` for newtypes in FFI contexts
- [`type-deref-coercion`](references/type-deref-coercion.md) - Implement `Deref`/`DerefMut` only for smart-pointer and transparent wrapper types
- [`type-display-vs-debug`](references/type-display-vs-debug.md) - Use `Display` for user-facing output and `Debug` for diagnostics; never swap them
- [`type-numeric-fmt`](references/type-numeric-fmt.md) - Implement `LowerHex`, `UpperHex`, `Octal`, and `Binary` for numeric newtypes

### 11. Trait & Generics Design (MEDIUM)

- [`trait-associated-type-vs-generic`](references/trait-associated-type-vs-generic.md) - Use an associated type when each impl has exactly one output type; use a generic parameter when a type can implement the trait for many input types
- [`trait-blanket-impl`](references/trait-blanket-impl.md) - Use a blanket impl `impl<T: Bound> Trait for T` to give behaviour to every type that satisfies a bound
- [`trait-coherence-newtype`](references/trait-coherence-newtype.md) - Respect the orphan rule; wrap a foreign type in a newtype to implement a foreign trait on it
- [`trait-default-methods`](references/trait-default-methods.md) - Define a trait in terms of a few required methods plus defaulted ones built on top of them
- [`trait-dyn-vs-generic`](references/trait-dyn-vs-generic.md) - Choose static dispatch (generics / `impl Trait`) vs dynamic dispatch (`dyn Trait`) deliberately
- [`trait-object-safety`](references/trait-object-safety.md) - Keep a trait dyn-compatible (object-safe) when you need `dyn Trait`

### 12. Conversions (MEDIUM)

- [`conv-tryfrom-fallible`](references/conv-tryfrom-fallible.md) - Implement `TryFrom` for fallible conversions instead of ad-hoc conversion functions
- [`conv-fromstr-parsing`](references/conv-fromstr-parsing.md) - Implement `FromStr` to enable `str::parse` for string-to-type conversions
- [`conv-asmut-mutable`](references/conv-asmut-mutable.md) - Accept `impl AsMut<T>` for flexible mutable borrowed inputs instead of concrete mutable references

### 13. Const & Compile-Time (MEDIUM)

- [`const-block`](references/const-block.md) - Use inline `const { }` blocks for compile-time evaluation and assertions
- [`const-fn`](references/const-fn.md) - Make functions `const fn` when they can run at compile time
- [`const-generics`](references/const-generics.md) - Parameterize over values with const generics `<const N: usize>`
- [`const-vs-static`](references/const-vs-static.md) - Use `const` for an inlined value and `static` for a single addressed instance

### 14. Serde (MEDIUM)

- [`serde-rename-all`](references/serde-rename-all.md) - Match the external naming convention with `#[serde(rename_all = ...)]`
- [`serde-default-compat`](references/serde-default-compat.md) - Use `#[serde(default)]` for optional and backward-compatible fields
- [`serde-skip-empty`](references/serde-skip-empty.md) - Omit empty fields with `skip_serializing_if`
- [`serde-flatten`](references/serde-flatten.md) - Inline nested structs or capture extra keys with `#[serde(flatten)]`
- [`serde-enum-representation`](references/serde-enum-representation.md) - Choose enum tagging deliberately: externally, internally, adjacently tagged, or untagged
- [`serde-deny-unknown-fields`](references/serde-deny-unknown-fields.md) - Reject unexpected keys with `#[serde(deny_unknown_fields)]`
- [`serde-custom-with`](references/serde-custom-with.md) - Customize a field's (de)serialization with `with` / `serialize_with` / `deserialize_with`
- [`serde-try-from-validate`](references/serde-try-from-validate.md) - Validate while deserializing with `#[serde(try_from = "Raw")]`

### 15. Pattern Matching (MEDIUM)

- [`pat-let-else`](references/pat-let-else.md) - Use `let ... else` for early-return pattern extraction
- [`pat-matches-macro`](references/pat-matches-macro.md) - Use `matches!()` for boolean pattern tests
- [`pat-if-let-chains`](references/pat-if-let-chains.md) - Use `if let` chains to combine pattern bindings and conditions
- [`pat-exhaustive-enum`](references/pat-exhaustive-enum.md) - Match owned enums exhaustively; avoid catch-all `_` that hides new variants
- [`pat-at-bindings`](references/pat-at-bindings.md) - Use `@` bindings to capture a value while matching it against a pattern

### 16. Macros (MEDIUM)

- [`macro-prefer-functions`](references/macro-prefer-functions.md) - Reach for a macro only when a function or generic cannot express it
- [`macro-rules-hygiene`](references/macro-rules-hygiene.md) - Rely on `macro_rules!` hygiene and use `$crate` for paths to your crate's items
- [`macro-fragment-specifiers`](references/macro-fragment-specifiers.md) - Capture with precise fragment specifiers, not raw `:tt`, where you can
- [`macro-export-crate-path`](references/macro-export-crate-path.md) - Export declarative macros with `#[macro_export]` and a clean import path
- [`macro-private-helpers`](references/macro-private-helpers.md) - Hide macro-generated helper items behind a `#[doc(hidden)] pub mod __private`
- [`macro-proc-two-crate`](references/macro-proc-two-crate.md) - Put procedural macros in a dedicated `proc-macro = true` crate and re-export from the facade
- [`macro-proc-syn-quote`](references/macro-proc-syn-quote.md) - Build procedural macros with `syn`, `quote`, and `proc-macro2`
- [`macro-proc-error-spans`](references/macro-proc-error-spans.md) - Report proc-macro errors as spanned compile errors, never by panicking

### 17. Closures (MEDIUM)

- [`closure-fn-trait-bounds`](references/closure-fn-trait-bounds.md) - Require the least restrictive `Fn` trait a callback needs (`FnOnce` ⊇ `FnMut` ⊇ `Fn`)
- [`closure-impl-fn-return`](references/closure-impl-fn-return.md) - Return closures as `impl Fn`/`FnMut`/`FnOnce`, not `Box<dyn Fn>`
- [`closure-move-capture`](references/closure-move-capture.md) - Use `move` for closures that outlive the current scope; clone before `move` to keep the original
- [`closure-static-vs-dyn`](references/closure-static-vs-dyn.md) - Accept `impl Fn` (generic) for hot callbacks; use `&dyn Fn`/`Box<dyn Fn>` to cut code size or to store them
- [`closure-disjoint-capture`](references/closure-disjoint-capture.md) - Capture only what you use; lean on edition-2021 disjoint closure captures

### 18. Collections (MEDIUM)

- [`coll-binaryheap`](references/coll-binaryheap.md) - Use `BinaryHeap` for a priority queue or repeated max-extraction
- [`coll-map-choice`](references/coll-map-choice.md) - Pick the map by access pattern: `HashMap` (fast, unordered), `BTreeMap` (sorted / range queries), `IndexMap` (insertion order)
- [`coll-seq-choice`](references/coll-seq-choice.md) - Default to `Vec`; use `VecDeque` for queue/deque behaviour; avoid `LinkedList`
- [`coll-set-membership`](references/coll-set-membership.md) - Use `HashSet`/`BTreeSet` for membership tests and dedup, not linear `Vec::contains`

### 19. Naming Conventions (MEDIUM)

- [`name-types-camel`](references/name-types-camel.md) - Use `UpperCamelCase` for types, traits, and enum names
- [`name-variants-camel`](references/name-variants-camel.md) - Use `UpperCamelCase` for enum variants
- [`name-funcs-snake`](references/name-funcs-snake.md) - Use `snake_case` for functions, methods, variables, and modules
- [`name-consts-screaming`](references/name-consts-screaming.md) - Use `SCREAMING_SNAKE_CASE` for constants and statics
- [`name-lifetime-short`](references/name-lifetime-short.md) - Use short, conventional lifetime names: `'a`, `'b`, `'de`, `'src`
- [`name-type-param-single`](references/name-type-param-single.md) - Use single uppercase letters for type parameters: `T`, `E`, `K`, `V`
- [`name-as-free`](references/name-as-free.md) - `as_` prefix: free reference conversion
- [`name-to-expensive`](references/name-to-expensive.md) - Use `to_` prefix for expensive conversions that allocate or compute
- [`name-into-ownership`](references/name-into-ownership.md) - Use `into_` prefix for ownership-consuming conversions
- [`name-no-get-prefix`](references/name-no-get-prefix.md) - Omit get_ prefix for simple getters
- [`name-is-has-bool`](references/name-is-has-bool.md) - Use `is_`, `has_`, `can_`, `should_` prefixes for boolean-returning methods
- [`name-iter-convention`](references/name-iter-convention.md) - Use iter/iter_mut/into_iter for iterator methods
- [`name-iter-method`](references/name-iter-method.md) - Name iterator methods `iter()`, `iter_mut()`, and `into_iter()` consistently
- [`name-iter-type-match`](references/name-iter-type-match.md) - Name iterator types after their source method
- [`name-acronym-word`](references/name-acronym-word.md) - Treat acronyms as words in identifiers: `HttpServer`, not `HTTPServer`
- [`name-crate-no-rs`](references/name-crate-no-rs.md) - Don't suffix crate names with `-rs` or `-rust`

### 20. Testing (MEDIUM)

- [`test-cfg-test-module`](references/test-cfg-test-module.md) - Put unit tests in `#[cfg(test)] mod tests { }` within each module
- [`test-use-super`](references/test-use-super.md) - Use `use super::*;` in test modules to access parent module items
- [`test-integration-dir`](references/test-integration-dir.md) - Put integration tests in the `tests/` directory
- [`test-descriptive-names`](references/test-descriptive-names.md) - Use descriptive test names that explain what is being tested
- [`test-arrange-act-assert`](references/test-arrange-act-assert.md) - Structure tests with clear Arrange, Act, Assert sections
- [`test-proptest-properties`](references/test-proptest-properties.md) - Use proptest for property-based testing
- [`test-mockall-mocking`](references/test-mockall-mocking.md) - Use mockall for trait mocking
- [`test-mock-traits`](references/test-mock-traits.md) - Use traits for dependencies to enable mocking in tests
- [`test-fixture-raii`](references/test-fixture-raii.md) - Use RAII pattern (Drop trait) for automatic test cleanup
- [`test-tokio-async`](references/test-tokio-async.md) - Use `#[tokio::test]` for async tests
- [`test-should-panic`](references/test-should-panic.md) - Use `#[should_panic]` to test that code panics as expected
- [`test-criterion-bench`](references/test-criterion-bench.md) - Use `criterion` for benchmarking
- [`test-doctest-examples`](references/test-doctest-examples.md) - Keep documentation examples as executable doctests
- [`test-loom-concurrency`](references/test-loom-concurrency.md) - Use `loom` to exhaustively test lock-free and concurrent code
- [`test-snapshot-testing`](references/test-snapshot-testing.md) - Use snapshot testing (insta) for complex or serialized output

### 21. Documentation (MEDIUM)

- [`doc-all-public`](references/doc-all-public.md) - Document all public items with `///` doc comments
- [`doc-module-inner`](references/doc-module-inner.md) - Use `//!` for module-level documentation
- [`doc-examples-section`](references/doc-examples-section.md) - Include `# Examples` with runnable code
- [`doc-errors-section`](references/doc-errors-section.md) - Include `# Errors` section for fallible functions
- [`doc-panics-section`](references/doc-panics-section.md) - Include `# Panics` section for functions that can panic
- [`doc-safety-section`](references/doc-safety-section.md) - Include `# Safety` section for unsafe functions
- [`doc-question-mark`](references/doc-question-mark.md) - Use `?` in examples, not `.unwrap()`
- [`doc-hidden-setup`](references/doc-hidden-setup.md) - Use `# ` prefix to hide example setup code
- [`doc-intra-links`](references/doc-intra-links.md) - Use intra-doc links to reference types and items
- [`doc-link-types`](references/doc-link-types.md) - Use intra-doc links to connect related types and functions
- [`doc-cargo-metadata`](references/doc-cargo-metadata.md) - Fill `Cargo.toml` metadata for published crates
- [`doc-crate-readme`](references/doc-crate-readme.md) - Unify the README and crate root docs with `#![doc = include_str!("../README.md")]`

### 22. Observability (MEDIUM)

- [`obs-tracing-over-log`](references/obs-tracing-over-log.md) - Use `tracing` for structured, span-aware diagnostics instead of `println!` or bare `log`
- [`obs-library-facade`](references/obs-library-facade.md) - Libraries emit through the tracing/log facade and never install a subscriber
- [`obs-structured-fields`](references/obs-structured-fields.md) - Record structured key-value fields, not values interpolated into the message string
- [`obs-instrument-spans`](references/obs-instrument-spans.md) - Use `#[tracing::instrument]` and spans to attach context to async tasks and requests
- [`obs-levels-filter`](references/obs-levels-filter.md) - Use log levels meaningfully and filter with `EnvFilter` / `RUST_LOG`
- [`obs-error-chain`](references/obs-error-chain.md) - Log errors with their full source chain, and log each error exactly once
- [`obs-no-sensitive-data`](references/obs-no-sensitive-data.md) - Never log secrets or PII; redact or skip them

### 23. Performance Patterns (MEDIUM)

- [`perf-iter-over-index`](references/perf-iter-over-index.md) - Prefer iterators over manual indexing
- [`perf-iter-lazy`](references/perf-iter-lazy.md) - Keep iterators lazy, collect only when needed
- [`perf-collect-once`](references/perf-collect-once.md) - Don't collect intermediate iterators
- [`perf-entry-api`](references/perf-entry-api.md) - Use entry API for map insert-or-update
- [`perf-drain-reuse`](references/perf-drain-reuse.md) - Use drain to reuse allocations
- [`perf-extend-batch`](references/perf-extend-batch.md) - Use extend for batch insertions
- [`perf-chain-avoid`](references/perf-chain-avoid.md) - Avoid chain in hot loops
- [`perf-collect-into`](references/perf-collect-into.md) - Use collect_into for reusing containers
- [`perf-black-box-bench`](references/perf-black-box-bench.md) - Use black_box in benchmarks
- [`perf-release-profile`](references/perf-release-profile.md) - Optimize release profile settings
- [`perf-profile-first`](references/perf-profile-first.md) - Profile before optimizing
- [`perf-ahash`](references/perf-ahash.md) - Use a faster hasher (`ahash` / `FxHashMap`) when DoS resistance is not needed
- [`perf-io-buffering`](references/perf-io-buffering.md) - Wrap `Read`/`Write` in `BufReader`/`BufWriter` for many small operations

### 24. Project Structure (LOW)

- [`proj-lib-main-split`](references/proj-lib-main-split.md) - Keep `main.rs` minimal, logic in `lib.rs`
- [`proj-mod-by-feature`](references/proj-mod-by-feature.md) - Organize modules by feature, not type
- [`proj-flat-small`](references/proj-flat-small.md) - Keep small projects flat
- [`proj-mod-rs-dir`](references/proj-mod-rs-dir.md) - Use mod.rs for multi-file modules
- [`proj-pub-crate-internal`](references/proj-pub-crate-internal.md) - Use pub(crate) for internal APIs
- [`proj-pub-super-parent`](references/proj-pub-super-parent.md) - Use pub(super) for parent-only visibility
- [`proj-pub-use-reexport`](references/proj-pub-use-reexport.md) - Use pub use for clean public API
- [`proj-prelude-module`](references/proj-prelude-module.md) - Create prelude module for common imports
- [`proj-bin-dir`](references/proj-bin-dir.md) - Put multiple binaries in src/bin/
- [`proj-workspace-large`](references/proj-workspace-large.md) - Use workspaces for large projects
- [`proj-workspace-deps`](references/proj-workspace-deps.md) - Use workspace dependency inheritance for consistent versions across crates
- [`proj-feature-additive`](references/proj-feature-additive.md) - Design Cargo features to be strictly additive
- [`proj-msrv-declare`](references/proj-msrv-declare.md) - Declare `rust-version` (MSRV) in Cargo.toml and test it in CI
- [`proj-build-rs-minimal`](references/proj-build-rs-minimal.md) - Keep `build.rs` minimal, deterministic, and idempotent

### 25. Clippy & Linting (LOW)

- [`lint-deny-correctness`](references/lint-deny-correctness.md) - `#![deny(clippy::correctness)]`
- [`lint-warn-suspicious`](references/lint-warn-suspicious.md) - Enable clippy::suspicious for likely bugs
- [`lint-warn-style`](references/lint-warn-style.md) - Enable clippy::style for idiomatic code
- [`lint-warn-complexity`](references/lint-warn-complexity.md) - Enable clippy::complexity for simpler code
- [`lint-warn-perf`](references/lint-warn-perf.md) - Enable clippy::perf for performance improvements
- [`lint-pedantic-selective`](references/lint-pedantic-selective.md) - Enable clippy::pedantic selectively
- [`lint-missing-docs`](references/lint-missing-docs.md) - Warn on missing documentation for public items
- [`lint-unsafe-doc`](references/lint-unsafe-doc.md) - Require documentation for unsafe blocks
- [`lint-cargo-metadata`](references/lint-cargo-metadata.md) - Enable clippy::cargo for published crates
- [`lint-rustfmt-check`](references/lint-rustfmt-check.md) - Run cargo fmt --check in CI
- [`lint-workspace-lints`](references/lint-workspace-lints.md) - Configure lints at workspace level for consistent enforcement
- [`lint-cfg-check`](references/lint-cfg-check.md) - Enable `unexpected_cfgs` and declare known cfgs to catch feature-gate typos
- [`lint-clippy-nursery-selected`](references/lint-clippy-nursery-selected.md) - Enable high-value `clippy::nursery` lints selectively, not the whole group

### 26. Anti-patterns (REFERENCE)

- [`anti-unwrap-abuse`](references/anti-unwrap-abuse.md) - Don't use `.unwrap()` in production code
- [`anti-expect-lazy`](references/anti-expect-lazy.md) - Don't use expect for recoverable errors
- [`anti-clone-excessive`](references/anti-clone-excessive.md) - Don't clone when borrowing works
- [`anti-lock-across-await`](references/anti-lock-across-await.md) - Don't hold locks across await points
- [`anti-string-for-str`](references/anti-string-for-str.md) - Don't accept &String when &str works
- [`anti-vec-for-slice`](references/anti-vec-for-slice.md) - Don't accept &Vec<T> when &[T] works
- [`anti-index-over-iter`](references/anti-index-over-iter.md) - Don't use indexing when iterators work
- [`anti-panic-expected`](references/anti-panic-expected.md) - Don't panic on expected or recoverable errors
- [`anti-empty-catch`](references/anti-empty-catch.md) - Don't silently ignore errors
- [`anti-over-abstraction`](references/anti-over-abstraction.md) - Don't over-abstract with excessive generics
- [`anti-premature-optimize`](references/anti-premature-optimize.md) - Don't optimize before profiling
- [`anti-type-erasure`](references/anti-type-erasure.md) - Don't use Box<dyn Trait> when impl Trait works
- [`anti-format-hot-path`](references/anti-format-hot-path.md) - Don't use format! in hot paths
- [`anti-collect-intermediate`](references/anti-collect-intermediate.md) - Don't collect intermediate iterators
- [`anti-stringly-typed`](references/anti-stringly-typed.md) - Don't use strings where enums or newtypes would provide type safety

## Recommended Cargo.toml profiles

```toml
[profile.release]
opt-level = 3
lto = "fat"
codegen-units = 1
panic = "abort"
strip = true

[profile.bench]
inherits = "release"
debug = true
strip = false

[profile.dev]
opt-level = 0
debug = true

[profile.dev.package."*"]
opt-level = 3
```

`panic = "abort"` is a choice, not a default: keep unwinding if the service relies on
catching panics in tasks or on `std::panic::catch_unwind`. See `opt-lto-release` and
`perf-release-profile` before changing an existing profile.

## Safety

- Do not add `unsafe` without a `// SAFETY:` comment stating the invariant (`unsafe-safety-comment`).
- Do not remove an error variant, change a public type, rename a serde field, or change a
  status code mapping without checking every caller and client contract.
- Do not weaken a failing test or silence a Clippy lint to make a check pass; use
  `#[expect(...)]` with a reason when a lint is genuinely wrong (`lint-*`).
- Benchmark and profile before applying `opt-` or `mem-` rules to code that is not a
  measured hot path (`perf-profile-first`, `anti-premature-optimize`).
